#!/usr/bin/env bash
# ==============================================================================
# 微信双开 / 多开一键启动工具 (自适应微信版本升级，防失效架构)
# ==============================================================================

WECHAT1="/Applications/WeChat.app"
WECHAT2="/Applications/WeChat2.app"

if [ ! -d "$WECHAT1" ]; then
    osascript -e 'display alert "错误" message "未在 /Applications 找到主微信应用！" as critical'
    exit 1
fi

# 1. 智能检测主微信是否更新：若 WeChat2 缺失或版本号与主微信不一致，自动执行自适应同步
NEED_SYNC=0
if [ ! -d "$WECHAT2" ]; then
    NEED_SYNC=1
else
    V1=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$WECHAT1/Contents/Info.plist" 2>/dev/null || echo "1")
    V2=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$WECHAT2/Contents/Info.plist" 2>/dev/null || echo "0")
    if [ "$V1" != "$V2" ]; then
        NEED_SYNC=1
    fi
fi

if [ "$NEED_SYNC" -eq 1 ]; then
    echo "检测到主微信版本更新或分身缺失，正在执行自适应升级同步..."
    echo "1111" | sudo -S rm -rf "$WECHAT2"
    echo "1111" | sudo -S cp -R "$WECHAT1" "$WECHAT2"
    echo "1111" | sudo -S /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier com.tencent.xinWeChat2" "$WECHAT2/Contents/Info.plist"
    echo "1111" | sudo -S xattr -rc "$WECHAT2"
    echo "1111" | sudo -S codesign --force --deep --sign - "$WECHAT2"
    echo "1111" | sudo -S chown -R $(whoami):admin "$WECHAT2"
    echo "分身自适应更新完成！"
fi

# 2. 启动主微信（若尚未运行）
if ! pgrep -f "${WECHAT1}/Contents/MacOS/WeChat" >/dev/null 2>&1; then
    open -a "$WECHAT1"
    sleep 1.2
fi

# 3. 启动第二个微信分身（若尚未运行）
if ! pgrep -f "${WECHAT2}/Contents/MacOS/WeChat" >/dev/null 2>&1; then
    open -a "$WECHAT2"
    osascript -e 'display notification "已成功启动 2 个独立的微信窗口！" with title "微信双开" subtitle "启动成功"' 2>/dev/null || true
else
    # 两个实例均已在跑，唤醒到前台
    open -a "$WECHAT1"
    open -a "$WECHAT2"
    osascript -e 'display notification "两个微信均已在运行中，已为您切换到前台！" with title "微信双开" subtitle "运行中"' 2>/dev/null || true
fi

# 4. 自动平稳退出终端
osascript -e 'tell application "Terminal" to close (first window whose name contains "微信双开")' 2>/dev/null || true
exit 0
