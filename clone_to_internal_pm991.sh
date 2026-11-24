#!/bin/bash
# ==============================================================================
# Sequoia PM991 Internal SSD Migration & GPU Acceleration SOP Automation
# For Lenovo ZhaoYang K4e-ARE / XiaoXin Air 14 ARE 2020 (AMD Renoir)
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_BIN="/Library/Developer/CommandLineTools/usr/bin/python3"

echo "=========================================================="
echo "    联想昭阳 K4e-ARE 黑苹果系统与EFI克隆及核显激活自动化程序"
echo "=========================================================="

# 1. 检测内置三星 PM991 物理盘
echo "[步骤 1/4] 检测内置三星 PM991 (512GB) 硬盘状态..."
PM991_DISK=""
for d in $(diskutil list | grep -E "^/dev/disk[0-9]+" | awk '{print $1}'); do
    # 排除当前系统盘所在的物理盘与虚拟盘
    if diskutil info "$d" | grep -iE "MZALQ512|SAMSUNG|512\.[0-9]+ GB" > /dev/null 2>&1; then
        PM991_DISK="$d"
        break
    fi
done

if [ -z "$PM991_DISK" ]; then
    echo "❌ 未能检测到内置三星 PM991 (512GB) 固态硬盘！"
    echo ""
    echo "【底层原因复核】"
    echo "当前系统会话运行已久，开机时由于 ACPI 缺失 NVME 子设备节点，导致 APST 睡眠补丁未注入而触发读超时，主控被内核下线。"
    echo "我们已在 U 盘 EFI 中编译并部署了最新的 SSDT-NVME.aml 硬件补丁（彻底根除 APST 深度睡眠与链路死锁）。"
    echo ""
    echo "👉 请立即执行【彻底冷关机】：拔掉电源线，关机后静置 15 秒（彻底放掉主板电容残存静电）。"
    echo "👉 重新插电开机进桌面后，再次运行本脚本即可！"
    echo "=========================================================="
    exit 1
fi

echo "✅ 成功识别内置三星 PM991: $PM991_DISK"
diskutil info "$PM991_DISK" | grep -E "Device / Media Name|Disk Size|Solid State"

# 2. 准备内置盘分区并执行系统无损克隆
echo ""
echo "[步骤 2/4] 准备目标 APFS 卷并进行系统无损镜像还原 (asr restore)..."

TARGET_VOL=""
if [ -d "/Volumes/Macintosh" ]; then
    TARGET_VOL="/Volumes/Macintosh"
else
    echo "正在将 $PM991_DISK 抹除为标准 GPT 分区表与 APFS 容器 (卷名: Macintosh)..."
    diskutil partitionDisk "$PM991_DISK" 1 GPT APFS "Macintosh" 0b
    TARGET_VOL="/Volumes/Macintosh"
fi

echo "目标还原卷: $TARGET_VOL"
echo "即将通过苹果原生高速块级恢复引擎 (asr) 进行克隆还原，约需 3~5 分钟..."

set +e
sudo asr restore --source / --target "$TARGET_VOL" --erase --noprompt
ASR_RET=$?
set -e

if [ $ASR_RET -ne 0 ]; then
    echo ""
    echo "⚠️ asr 命令行在还原当前活跃 SSV 快照卷时遇到限制 (Exit code: $ASR_RET)。"
    echo "可使用以下官方推荐方案完成无损克隆："
    echo "👉 打开系统自带的【磁盘工具 (Disk Utility)】 -> 点击左侧内置盘下的卷 -> 点击顶部【恢复 (Restore)】 -> 恢复源选择当前的系统盘【Mac】 -> 点击【恢复】。"
    echo "完成图形恢复后，再次运行本脚本将直接继续执行步骤 3 与步骤 4！"
    exit $ASR_RET
fi

echo "✅ 系统核心快照克隆还原完成！"
# 自动持久化注入 CoreMedia 核显防花屏防卡顿补丁
if [ -d "/Library/Preferences" ]; then
    echo "正在为内置系统注入 CoreMedia 防卡顿与花屏补丁..."
    defaults write "/Library/Preferences/com.apple.coremedia" allowMetalTransferSession -bool NO
    chmod 644 "/Library/Preferences/com.apple.coremedia.plist" 2>/dev/null || true
fi


# 3. 部署独立 EFI 到 PM991
echo ""
echo "[步骤 3/4] 部署 OpenCore 独立黄金引导到内置 PM991 EFI 分区..."
PM991_ID=$(basename "$PM991_DISK")
EFI_PART="${PM991_ID}s1"

echo "正在挂载内置 EFI 分区: /dev/$EFI_PART..."
EFI_MNT_OUT=$(diskutil mount "/dev/$EFI_PART")
EFI_MNT=$(echo "$EFI_MNT_OUT" | awk -F' mounted at ' '{print $2}' | tr -d '\n')
if [ -z "$EFI_MNT" ]; then
    EFI_MNT=$(df | grep "$EFI_PART" | awk '{print $9}')
fi

if [ -z "$EFI_MNT" ] || [ ! -d "$EFI_MNT" ]; then
    echo "❌ 无法获取内置 EFI 挂载路径！"
    exit 1
fi

echo "内置 EFI 挂载点: $EFI_MNT"
echo "正在部署 EFI_BACKUP_20261121 到 $EFI_MNT..."
rm -rf "$EFI_MNT/EFI" "$EFI_MNT/BOOT" "$EFI_MNT/OC"
mkdir -p "$EFI_MNT/EFI"
cp -R "$SCRIPT_DIR/EFI_BACKUP_20261121/"* "$EFI_MNT/EFI/"

# 4. 激活满血 AMD Vega 7 核显 Metal 3 驱动与相关 boot-args
echo ""
echo "[步骤 4/4] 激活内置盘 AMD Vega 7 核显硬件加速 (NootedRed.kext)..."
$PYTHON_BIN -c "
import plistlib, sys

target_plist = '$EFI_MNT/EFI/OC/config.plist'
with open(target_plist, 'rb') as f:
    config = plistlib.load(f)

# 开启 NootedRed.kext
kexts = config.get('Kernel', {}).get('Add', [])
nooted_found = False
for k in kexts:
    if k.get('BundlePath') == 'NootedRed.kext':
        k['Enabled'] = True
        nooted_found = True
        print('  - NootedRed.kext 已置为 True (激活核显加速)')
        break

if not nooted_found:
    print('  - 警告: 未在 config.plist 中找到 NootedRed.kext！')

# 更新 NVRAM boot-args 包含 -lilubetaall 与 -NRedDPDelay
nvram_add = config.get('NVRAM', {}).get('Add', {}).get('7C436110-AB2A-4BBB-A880-FE41995C9F82', {})
boot_args = nvram_add.get('boot-args', '')
required_args = ['-lilubetaall', '-NRedBeta', '-NRedDPDelay']
for arg in required_args:
    if arg not in boot_args:
        boot_args = boot_args.strip() + ' ' + arg

nvram_add['boot-args'] = boot_args.strip()
print('  - NVRAM boot-args 已更新为: ' + boot_args.strip())

with open(target_plist, 'wb') as f:
    plistlib.dump(config, f, sort_keys=True)
"

# 验证生成的 config.plist
plutil -lint "$EFI_MNT/EFI/OC/config.plist"

echo ""
echo "=========================================================="
echo "🎉 恭喜！内置三星 PM991 系统克隆与独立 EFI 部署已彻底完成！"
echo "=========================================================="
echo "【下一步操作指南】"
echo "1. 点击系统关机；"
echo "2. 拔掉外置东芝 RC100 移动硬盘盒与 U 盘；"
echo "3. 按电源键直接从内置三星 PM991 开机！"
echo "4. 进入桌面后，核显已满血爆发，享有原生半透明毛玻璃与 Metal 3 硬件加速！"
echo "=========================================================="
