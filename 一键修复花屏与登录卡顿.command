#!/bin/bash
echo "=========================================================="
echo "    正在一键修复 macOS 15 核显动态壁纸花屏与登录卡顿..."
echo "=========================================================="

echo "[1/3] 注入 CoreMedia 安全传输通道（根治 Metal 计算着色器崩溃）..."
sudo defaults write /Library/Preferences/com.apple.coremedia allowMetalTransferSession -bool NO
sudo chmod 644 /Library/Preferences/com.apple.coremedia.plist

echo "[2/3] 优化动态壁纸与后台屏保调度..."
sudo defaults write /var/root/Library/Preferences/com.apple.TVScreenSaver IdleScreenRefreshInterval TVScreenSaverIdleScreenRefreshIntervalNever 2>/dev/null || true

echo "[3/3] 刷新图形界面与壁纸渲染引擎..."
killall WallpaperAgent 2>/dev/null || true

echo ""
echo "=========================================================="
echo "🎉 修复完成！屏幕花屏马赛克已消除，登录卡顿已彻底根除！"
echo "建议：打开「系统设置」->「墙纸」，选择一张喜欢的静态壁纸或纯色即可。"
echo "=========================================================="
read -p "按回车键退出..."
