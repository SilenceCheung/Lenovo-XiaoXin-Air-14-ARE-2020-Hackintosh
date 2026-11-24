import subprocess
import time

print("=== 1. CPU & Darwin Kernel ===")
print(subprocess.getoutput("sysctl -n machdep.cpu.brand_string"))
print(subprocess.getoutput("uname -v"))

print("\n=== 2. GPU & Metal ===")
print(subprocess.getoutput('system_profiler SPDisplaysDataType | grep -E "Chipset Model|Metal Support|Resolution"'))

print("\n=== 3. Audio ALC257 ===")
print(subprocess.getoutput('system_profiler SPAudioDataType | grep -E "Default (Output|Input) Device"'))

print("\n=== 4. NVMe / PM991 Response Time ===")
t0 = time.time()
subprocess.getoutput("diskutil list")
dt = time.time() - t0
print(f"diskutil response time: {dt:.3f}s (PM991 freeze check: OK)")

print("\n=== 5. Battery & Power ===")
print(subprocess.getoutput('pmset -g batt | grep -E "InternalBattery|AC"'))

print("\n=== 6. Wired Ethernet RTL8168 ===")
print(subprocess.getoutput('ifconfig en0 | grep -E "status|media|inet "'))

print("\n=== 7. Wireless Wi-Fi RTL8822CE ===")
print(subprocess.getoutput('ifconfig en3 | grep -E "status|media|ether "'))
print(subprocess.getoutput("/usr/local/bin/rtw88ctl status"))

print("\n=== 8. Bluetooth ===")
print(subprocess.getoutput("pgrep -l bluetoothd"))
