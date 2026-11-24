#!/usr/bin/env bash
# ==============================================================================
# 联想小新 Air 14 ARE 2020 黑苹果 - 系统无效文件与缓存一键安全清理
# ==============================================================================

echo -n -e "\033]0;macOS 系统无效文件与缓存清理\007"
[ -t 1 ] && clear || true

# 调用全维度清理引擎
/usr/local/bin/hackintosh-cleaner

AVAIL_GB=$(df -h /System/Volumes/Data | tail -n 1 | awk '{print $4}')

osascript -e "display notification \"系统多维缓存清理与内存优化完成！当前可用磁盘空间：${AVAIL_GB}\" with title \"黑苹果系统维护\" subtitle \"清理系统缓存完成\"" 2>/dev/null || true

echo ""
read -n 1 -s -r -p "按任意键退出窗口..."
echo ""
exit 0
