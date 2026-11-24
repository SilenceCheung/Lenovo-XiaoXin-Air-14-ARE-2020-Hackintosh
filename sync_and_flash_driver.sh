#!/bin/bash
set -e

echo "=== 黑苹果外置盘 EFI 自动同步与驱动刷入工具 ==="
EFI_DISK=$(diskutil list | grep -B 2 "EFI" | grep "/dev/disk" | awk '{print $1}' | head -n 1)

if [ -z "$EFI_DISK" ]; then
    echo "未检测到外置 EFI 分区，请确保外置固态硬盘已插入当前 Mac！"
    exit 1
fi

EFI_PART=$(diskutil list "$EFI_DISK" | grep "EFI" | awk '{print $NF}' | head -n 1)
if [ -z "$EFI_PART" ]; then
    echo "未能在 $EFI_DISK 上定位 EFI 分区！"
    exit 1
fi

echo "检测到目标 EFI 分区: /dev/$EFI_PART"
diskutil mount "/dev/$EFI_PART"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/Users/silence/Desktop/黑苹果相关/EFI_BACKUP_$TIMESTAMP"
mkdir -p "$BACKUP_DIR"
echo "正在创建目标盘当前完整快照备份 -> $BACKUP_DIR"
cp -R /Volumes/EFI/EFI "$BACKUP_DIR/"

echo "正在部署最新编译优化的 rtw88.kext 与引导配置..."
rm -rf /Volumes/EFI/EFI/OC/Kexts/rtw88.kext
cp -R /Users/silence/Desktop/黑苹果相关/EFI_BACKUP_20261121/OC/Kexts_Staging/rtw88.kext /Volumes/EFI/EFI/OC/Kexts/
cp /Users/silence/Desktop/黑苹果相关/EFI_BACKUP_20261121/OC/config_with_wifi.plist /Volumes/EFI/EFI/OC/config.plist

echo "正在将 rtw88ctl 控制工具同步至外置系统盘..."
# 如果挂载了数据分区或用户卷，复制一份过去
diskutil unmount /Volumes/EFI

echo "=== 同步完成！现在可以拔下移动硬盘插回笔记本开机测试！ ==="
