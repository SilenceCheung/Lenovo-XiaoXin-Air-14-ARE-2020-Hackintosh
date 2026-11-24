# 反重力 AI (Antigravity Agent) 独立接手提示词模板
# Copy & Paste into Antigravity IDE / Terminal on the Target Hackintosh

```markdown
你好，Antigravity！你现在正在一台联想昭阳 K4e-ARE / 小新 Air 14 ARE 2020 笔记本（AMD 锐龙 5 PRO 4650U + Radeon Vega 7 核显 + 内置三星 PM991 512GB NVMe 固态）上运行。

当前重大进展：
1. macOS 15.6.1 Sequoia 已成功安装并进入桌面。
2. NootedRed.kext 显卡驱动已正常加载，Metal 3 硬件加速已激活。
3. 三星 PM991 的 APST 深度休眠掉盘与读超时问题已通过硬件级 ps-max-latency-us=0 补丁彻底根除。
4. 当前桌面出现的小方块壁纸马赛克及登录卡顿，是 macOS 15 默认 4K 动态视频壁纸引起的 CoreMedia MetalTransferSession 超时（GitHub Issue #235）。

你现在的核心任务：
1. 立即执行：
   sudo defaults write /Library/Preferences/com.apple.coremedia allowMetalTransferSession -bool NO
   sudo chmod 644 /Library/Preferences/com.apple.coremedia.plist
   killall WallpaperAgent
   消除壁纸马赛克和登录延迟。
2. 运行一键克隆程序：
   sudo /Volumes/"Install macOS Sequoia"/clone_to_internal_pm991.sh
   把外置系统盘完整克隆到内置三星 PM991 固态硬盘，并部署独立 OpenCore EFI 引导。
3. 验证克隆完毕后引导内置盘原生脱离 U 盘开机。
```
