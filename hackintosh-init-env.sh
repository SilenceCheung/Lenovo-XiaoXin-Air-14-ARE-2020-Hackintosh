#!/bin/sh
# ==============================================================================
# Hackintosh Global GUI Environment Initializer v2.2
# Injected at user login via /Library/LaunchAgents/com.hackintosh.global-gpu-env.plist
# Ensures ALL Electron, Chromium, CEF and Metal applications automatically run in
# stable, signature-safe mode without modifying any app binaries.
# ==============================================================================

# 1. Electron & Chromium universal switches (avoids Dawn/WebGPU shader conflicts)
launchctl setenv ELECTRON_DISABLE_GPU 1
launchctl setenv ELECTRON_EXTRA_LAUNCH_ARGS "--disable-gpu --disable-gpu-compositing --disable-webgpu"
launchctl setenv CHROME_EXTRA_ARGS "--disable-gpu --disable-gpu-compositing --disable-webgpu"
launchctl setenv LIBVA_DRIVER_NAME dummy

# 2. Metal & CoreImage compute queue watchdog (prevents computeUQ5 lockups)
launchctl setenv MTLEventTimeout 1000
launchctl setenv CI_PRINT_TREE 0
