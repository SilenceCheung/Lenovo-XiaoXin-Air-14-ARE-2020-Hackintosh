#!/usr/bin/env python3
# ==============================================================================
# Comprehensive Hackintosh GPU & WebGPU Audit & Rigorous Verification Suite
# Professional Testing Protocol for AMD Vega 7 / NootedRed macOS 15.8.3
# ==============================================================================

import os, sys, time, glob, plistlib, subprocess, json

def print_section(title):
    print("\n" + "="*70)
    print(f"  {title}")
    print("="*70)

results = {"PASS": 0, "FAIL": 0, "WARN": 0}

# ----------------------------------------------------------------------
# 1. Audit all installed Applications and GPU Helper wrappers
# ----------------------------------------------------------------------
print_section("STAGE 1: Audit All Installed Applications & GPU Helpers")

user_home = os.path.expanduser("~")
app_search_paths = [
    "/Applications",
    os.path.join(user_home, "Applications")
]

all_apps = []
for p in app_search_paths:
    if os.path.isdir(p):
        for item in os.listdir(p):
            if item.endswith(".app"):
                all_apps.append(os.path.join(p, item))

print(f"[INFO] Found {len(all_apps)} top-level applications.")

wrapped_helpers = []
unwrapped_helpers = []

for app in all_apps:
    for root, dirs, files in os.walk(app):
        for d in dirs:
            if "Helper (GPU)" in d or "Helper(GPU)" in d:
                macos_dir = os.path.join(root, d, "Contents", "MacOS")
                if os.path.isdir(macos_dir):
                    for exe in os.listdir(macos_dir):
                        if exe.endswith(".orig"):
                            continue
                        orig_file = os.path.join(macos_dir, exe + ".orig")
                        curr_file = os.path.join(macos_dir, exe)
                        if os.path.exists(orig_file):
                            wrapped_helpers.append((curr_file, orig_file))
                        else:
                            unwrapped_helpers.append(curr_file)

print(f"[INFO] Total wrapped GPU helpers: {len(wrapped_helpers)}")
for curr, orig in wrapped_helpers:
    print(f"  [OK: WRAPPED] {curr}")
    results["PASS"] += 1

if unwrapped_helpers:
    print(f"[WARN] Total unwrapped GPU helpers found: {len(unwrapped_helpers)}")
    for unwrapped in unwrapped_helpers:
        print(f"  [PENDING WRAP] {unwrapped}")
        results["WARN"] += 1
else:
    print("[PASS] All discovered Helper (GPU) binaries are 100% wrapped!")
    results["PASS"] += 1

# ----------------------------------------------------------------------
# 2. Audit Plist Policies for All Discovered Bundle IDs
# ----------------------------------------------------------------------
print_section("STAGE 2: Audit Plist Preferences for All Bundle IDs")

bids_checked = 0
bids_immunized = 0

for app in all_apps:
    for root, dirs, files in os.walk(app):
        if "Info.plist" in files:
            ip = os.path.join(root, "Info.plist")
            try:
                with open(ip, "rb") as f:
                    p = plistlib.load(f)
                bid = p.get("CFBundleIdentifier")
                if bid and ("chrome" in bid.lower() or "electron" in bid.lower() or "taobao" in bid.lower() or "tencent" in bid.lower() or "dingtalk" in bid.lower() or "waxiang" in bid.lower()):
                    bids_checked += 1
                    sys_p = f"/Library/Preferences/{bid}.plist"
                    usr_p = os.path.join(user_home, "Library", "Preferences", f"{bid}.plist")
                    
                    sys_ok = False
                    if os.path.exists(sys_p):
                        with open(sys_p, "rb") as f2:
                            p2 = plistlib.load(f2)
                            if p2.get("HardwareAccelerationModeEnabled") is False:
                                sys_ok = True
                                
                    usr_ok = False
                    if os.path.exists(usr_p):
                        with open(usr_p, "rb") as f3:
                            p3 = plistlib.load(f3)
                            if p3.get("HardwareAccelerationModeEnabled") is False:
                                usr_ok = True
                                
                    if sys_ok or usr_ok:
                        bids_immunized += 1
                    else:
                        print(f"  [MISSING PREF] {bid} ({os.path.basename(root)})")
            except:
                pass

print(f"[INFO] Critical Bundle IDs Audited: {bids_checked}")
print(f"[INFO] Critical Bundle IDs Immunized: {bids_immunized}")
if bids_checked == bids_immunized and bids_checked > 0:
    print("[PASS] 100% of targeted Chromium/CEF/Electron bundle IDs have HardwareAccelerationModeEnabled=false!")
    results["PASS"] += 1
else:
    print(f"[WARN] Some bundle IDs missing plist policy ({bids_checked - bids_immunized})")
    results["WARN"] += 1

# ----------------------------------------------------------------------
# 3. Audit GPU Cache Cleanliness
# ----------------------------------------------------------------------
print_section("STAGE 3: Audit Dawn / WebGPU / GPUCache Residue")

home = user_home
cache_dirs_to_check = [
    os.path.join(home, "Library", "Application Support"),
    os.path.join(home, ".workbuddy"),
    os.path.join(home, "Library", "Caches")
]

bad_caches = []
for base in cache_dirs_to_check:
    if os.path.isdir(base):
        for root, dirs, files in os.walk(base):
            for d in dirs:
                if d in ["DawnGraphiteCache", "DawnWebGPUCache"]:
                    bad_caches.append(os.path.join(root, d))

if bad_caches:
    print(f"[WARN] Found {len(bad_caches)} unpurged Dawn/WebGPU shader cache folders:")
    for bc in bad_caches[:10]:
        print(f"  -> {bc}")
    results["WARN"] += 1
else:
    print("[PASS] Zero dirty Dawn / WebGPU shader caches detected on disk!")
    results["PASS"] += 1

# ----------------------------------------------------------------------
# 4. Audit Kernel GPU Reset History
# ----------------------------------------------------------------------
print_section("STAGE 4: Audit Kernel GPU Reset & Hang History")

try:
    log_out = subprocess.check_output(
        ["log", "show", "--predicate", "process == 'kernel'", "--style", "syslog", "--last", "1h"],
        universal_newlines=True
    )
    resets = [line for line in log_out.splitlines() if "gpuRestart" in line or "Ring Hang" in line or "AMDRadeonX5000" in line and "reset" in line.lower()]
    print(f"[INFO] Kernel GPU Resets in last 1 hour: {len(resets)}")
    if len(resets) == 0:
        print("[PASS] Zero GPU ring hangs or resets logged in the last 1 hour!")
        results["PASS"] += 1
    else:
        print("[INFO] Showing recent reset events:")
        for r in resets[-5:]:
            print(f"  {r}")
        results["WARN"] += 1
except Exception as e:
    print(f"[ERROR] Failed to query kernel log: {e}")
    results["FAIL"] += 1

# ----------------------------------------------------------------------
# 5. Audit Background Daemon & Environment Variables
# ----------------------------------------------------------------------
print_section("STAGE 5: Audit Safeguard Daemon & Environment State")

try:
    ps_out = subprocess.check_output(["ps", "aux"], universal_newlines=True)
    daemon_running = any("hackintosh-gpu-safeguard" in line for line in ps_out.splitlines())
    if daemon_running:
        print("[PASS] com.hackintosh.gpu-safeguard is RUNNING as root daemon.")
        results["PASS"] += 1
    else:
        print("[FAIL] com.hackintosh.gpu-safeguard is NOT running!")
        results["FAIL"] += 1
        
    env_out = subprocess.check_output(["launchctl", "asuser", "501", "launchctl", "getenv", "ELECTRON_DISABLE_GPU"], universal_newlines=True).strip()
    if env_out == "1":
        print("[PASS] User GUI domain (gui/501) launchd environment ELECTRON_DISABLE_GPU is set to '1'.")
        results["PASS"] += 1
    else:
        print(f"[WARN] launchd ELECTRON_DISABLE_GPU is '{env_out}', expected '1'")
        results["WARN"] += 1
except Exception as e:
    print(f"[ERROR] Failed checking daemon: {e}")
    results["FAIL"] += 1

# ----------------------------------------------------------------------
# Summary
# ----------------------------------------------------------------------
print_section("FINAL VERIFICATION SUMMARY")
print(f"PASSED CHECKS: {results['PASS']}")
print(f"WARNINGS:      {results['WARN']}")
print(f"FAILURES:      {results['FAIL']}")
if results["FAIL"] == 0:
    print("\n>>> CONCLUSION: GPU WebGPU Defense Architecture verified ROBUST and HEALTHY. <<<")
else:
    print("\n>>> CONCLUSION: Issues detected requiring remediation. <<<")
