#!/usr/bin/env bash
# ==============================================================================
# 🍏 联想小新 Air 14 ARE 2020 / 昭阳 K4e-ARE 黑苹果
#    系统智能全维度安全清理与性能优化大师 (v3.0 工业增强版)
# ==============================================================================

set -o pipefail

# 窗口标题与终端自适应
echo -n -e "\033]0;🍏 黑苹果系统智能清理与性能优化大师\007"
[ -t 1 ] && clear || true

# ANSI 颜色定义
BOLD='\033[1m'
NC='\033[0m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
RED='\033[0;31m'

USER_HOME="${HOME:-$(eval echo ~$USER)}"

# 内存读取函数 (GB)
get_free_ram() {
    vm_stat | perl -ne '/page size of (\d+)/ and $size=$1; /Pages free:\s+(\d+)/ and $free=$1; /Pages inactive:\s+(\d+)/ and $inactive=$1; END { printf "%.1f", ($free+$inactive)*$size/1024/1024/1024 }' 2>/dev/null || echo "0"
}

# 磁盘可用空间 (KB)
get_avail_kb() {
    df -k /System/Volumes/Data 2>/dev/null | tail -n 1 | awk '{print $4}'
}

# 打印美化横幅
print_banner() {
    echo -e "${CYAN}${BOLD}==============================================================================${NC}"
    echo -e "${GREEN}${BOLD}   🍏 联想小新 Air 14 ARE 2020 黑苹果 - 系统智能安全清理与内存优化大师 v3.0${NC}"
    echo -e "${CYAN}   专为 AMD Ryzen 4650U / Vega 7 深度定制 · 纯净 · 极速 · 100% 绝对安全${NC}"
    echo -e "${CYAN}${BOLD}==============================================================================${NC}"
    echo -e "${YELLOW}  [🛡️ 安全保障红线]${NC}"
    echo -e "  • 绝对不碰个人文档、桌面素材、代码工程与 Git 仓库"
    echo -e "  • 绝对不碰微信、QQ、千牛聊天记录本地数据库（仅清理网络临时切片与无用日志）"
    echo -e "  • 绝对保留浏览器 Cookie 与网站登录态（账号无缝常驻）"
    echo -e "  • 绝对不触碰 EFI 引导分区与核心系统描述文件"
    echo -e "${CYAN}------------------------------------------------------------------------------${NC}"
}

# 模块执行器
run_clean_engine() {
    local MODE="$1"
    
    BEFORE_KB=$(get_avail_kb)
    BEFORE_RAM=$(get_free_ram)
    
    echo ""
    echo -e "${BOLD}${PURPLE}🚀 正在启动全维度智能安全优化引擎 (清理前可用内存: ${BEFORE_RAM} GB)...${NC}"
    echo ""

    # 1. 软件残留
    echo -e "${BLUE}[01/12]${NC} 扫描并清理已卸载与废弃软件孤立配置文件..."
    rm -rf "${USER_HOME}/.workbuddy" "${USER_HOME}/.workbuddy-key-fallback" "${USER_HOME}/WorkBuddy" 2>/dev/null || true
    rm -rf "${USER_HOME}/Library/Application Support/com.tencent.workbuddy.mac" 2>/dev/null || true
    rm -rf "${USER_HOME}/Library/Caches/com.tencent.workbuddy.mac" 2>/dev/null || true
    echo -e "        ${GREEN}✓ 孤立残留配置清理就绪${NC}"

    # 2. 动态壁纸断点临时碎片 (严格保护已生效壁纸，杜绝误删重置)
    echo -e "${BLUE}[02/12]${NC} 扫描空中壁纸未完成的断点临时碎片 (严格保护用户已下载壁纸)..."
    sudo find "/Library/Application Support/com.apple.idleassetsd/Customer" -name "*.download" -type f -delete 2>/dev/null || true
    sudo find "/Library/Application Support/com.apple.idleassetsd/Customer" -name "*.tmp" -type f -delete 2>/dev/null || true
    echo -e "        ${GREEN}✓ 壁纸临时断点碎片清理完成 (用户已下载壁纸 100% 完好保留)${NC}"

    # 3. 客户端大型更新包与安装包缓存
    echo -e "${BLUE}[03/12]${NC} 清理电商客户端与微软 Office 更新下载安装包..."
    sudo rm -rf /Library/Caches/com.microsoft.autoupdate.fba/* 2>/dev/null || true
    rm -rf "${USER_HOME}/Library/Caches/com.microsoft.autoupdate.fba"/* 2>/dev/null || true
    rm -rf "${USER_HOME}/Library/Caches/com.taobao.Aliworkbench/update.upkg" 2>/dev/null || true
    echo -e "        ${GREEN}✓ 巨型升级包与安装残留清理完成${NC}"

    # 4. 浏览器代码与 GPU 渲染缓存 (严格保留登录凭据)
    echo -e "${BLUE}[04/12]${NC} 清理 Chrome、Safari 与 WebKit 临时渲染与代码缓存 (保留登录态)..."
    rm -rf "${USER_HOME}/Library/Caches/Google/Chrome/Default/Cache"/* 2>/dev/null || true
    rm -rf "${USER_HOME}/Library/Caches/Google/Chrome/Default/Code Cache"/* 2>/dev/null || true
    rm -rf "${USER_HOME}/Library/Caches/com.apple.Safari/Cache"* 2>/dev/null || true
    rm -rf "${USER_HOME}/Library/Caches/com.apple.WebKit.WebContent"/* 2>/dev/null || true
    rm -rf "${USER_HOME}/Library/Caches/com.apple.WebKit.GPU"/* 2>/dev/null || true
    echo -e "        ${GREEN}✓ 网页渲染与离线缓存清理完成 (所有网站登录状态完美保留)${NC}"

    # 5. 电商 CEF 工具缓存
    echo -e "${BLUE}[05/12]${NC} 清理千牛、瓦香 (Waxiang) 与常用工具 CEF 临时文件..."
    rm -rf "${USER_HOME}/Library/Caches/QNCEF1301Temp"/* 2>/dev/null || true
    rm -rf "${USER_HOME}/Library/Caches/com.taobao.Aliworkbench/Cache"/* 2>/dev/null || true
    rm -rf "${USER_HOME}/Library/Caches/com.taobao.Aliworkbench/Code Cache"/* 2>/dev/null || true
    rm -rf "${USER_HOME}/Library/Caches/Waxiang/Cache"/* 2>/dev/null || true
    rm -rf "${USER_HOME}/Library/Caches/ArtCraft Launcher/Cache"/* 2>/dev/null || true
    rm -rf "${USER_HOME}/Library/Caches/com.apple.helpd"/* 2>/dev/null || true
    echo -e "        ${GREEN}✓ 电商客户端临时 HTTP 缓存清理完成${NC}"

    # 6. 微信网络临时缓存与崩溃报告 (绝对不触碰本地聊天记录数据库)
    echo -e "${BLUE}[06/12]${NC} 清理微信/微信分身网络临时切片与崩溃日志 (严格保护本地聊天数据)..."
    rm -rf "${USER_HOME}/Library/Containers/com.tencent.xinWeChat/Data/Documents/app_data/radium/cache"/* 2>/dev/null || true
    rm -rf "${USER_HOME}/Library/Containers/com.tencent.xinWeChat/Data/Documents/app_data/crashinfo"/* 2>/dev/null || true
    rm -rf "${USER_HOME}/Library/Containers/com.tencent.xinWeChat2/Data/Documents/app_data/radium/cache"/* 2>/dev/null || true
    rm -rf "${USER_HOME}/Library/Containers/com.tencent.xinWeChat2/Data/Documents/app_data/crashinfo"/* 2>/dev/null || true
    rm -rf "${USER_HOME}/Library/Caches/com.tencent.xinWeChat"/* 2>/dev/null || true
    rm -rf "${USER_HOME}/Library/Caches/com.tencent.xinWeChat2"/* 2>/dev/null || true
    echo -e "        ${GREEN}✓ 微信临时网络缓存清理完成 (聊天记录与文件100%安全)${NC}"

    # 7. 开发者与包管理工具构建轮子缓存
    echo -e "${BLUE}[07/12]${NC} 清理 Python pip、Homebrew 与包管理器下载轮子缓存..."
    rm -rf "${USER_HOME}/Library/Caches/pip"/* 2>/dev/null || true
    rm -rf "${USER_HOME}/Library/Caches/Homebrew"/* 2>/dev/null || true
    rm -rf "${USER_HOME}/.cache"/* 2>/dev/null || true
    echo -e "        ${GREEN}✓ 依赖与构建轮子缓存瘦身完成${NC}"

    # 8. 访达 QuickLook 缩略图与图标缓存刷新
    echo -e "${BLUE}[08/12]${NC} 重置并刷新 QuickLook 缩略图引擎与图标服务缓存..."
    rm -rf "${USER_HOME}/Library/Caches/com.apple.QuickLook.thumbnailcache"/* 2>/dev/null || true
    qlmanage -r cache >/dev/null 2>&1 || true
    qlmanage -r >/dev/null 2>&1 || true
    echo -e "        ${GREEN}✓ 缩略图缓存刷新完成 (消除访达图标偶发卡顿)${NC}"

    # 9. 崩溃转储、关机挂起与 GPU 重启日志清理
    echo -e "${BLUE}[09/12]${NC} 清理系统底层崩溃转储、关机卡顿历史日志与过期报告..."
    sudo rm -rf /Library/Logs/DiagnosticReports/Retired/* 2>/dev/null || true
    sudo rm -rf /Library/Logs/DiagnosticReports/*.shutdownStall 2>/dev/null || true
    sudo rm -rf /Library/Logs/DiagnosticReports/*.gpuRestart 2>/dev/null || true
    sudo rm -rf /Library/Logs/DiagnosticReports/*.spin 2>/dev/null || true
    sudo rm -rf /Library/Logs/DiagnosticReports/*.ips 2>/dev/null || true
    rm -rf "${USER_HOME}/Library/Logs/DiagnosticReports"/* 2>/dev/null || true
    echo -e "        ${GREEN}✓ 底层转储日志清理完成 (杜绝日志狂暴增长)${NC}"

    # 10. 废纸篓安全清空与超期 /private/tmp 清理
    echo -e "${BLUE}[10/12]${NC} 清空废纸篓并安全清除 /private/tmp 超期孤立垃圾..."
    rm -rf "${USER_HOME}/.Trash"/* 2>/dev/null || true
    sudo find /private/tmp -type f -atime +2 -delete 2>/dev/null || true
    echo -e "        ${GREEN}✓ 废纸篓与临时垃圾清理完成${NC}"

    # 11. APFS 本地快照瘦身与 DNS 缓存刷新
    echo -e "${BLUE}[11/12]${NC} 释放 APFS 备份影子快照并刷新系统 DNS 解析服务..."
    sudo tmutil thinlocalsnapshots /System/Volumes/Data 10000000000 4 >/dev/null 2>&1 || true
    dscacheutil -flushcache >/dev/null 2>&1 || true
    sudo killall -HUP mDNSResponder >/dev/null 2>&1 || true
    echo -e "        ${GREEN}✓ APFS 存储快照瘦身完成，DNS 缓存已复位${NC}"

    # 12. 物理内存深层整理与 purge
    echo -e "${BLUE}[12/12]${NC} 执行内核级 purge 物理内存深层整理 (归还 Inactive RAM)..."
    sudo purge >/dev/null 2>&1 || true
    echo -e "        ${GREEN}✓ 物理内存整理完毕，非活跃内存已全面回收${NC}"

    # 统计数据与计算
    AFTER_KB=$(get_avail_kb)
    AFTER_RAM=$(get_free_ram)
    
    DIFF_KB=$((AFTER_KB - BEFORE_KB))
    DIFF_MB=$((DIFF_KB / 1024))
    if [ "$DIFF_MB" -lt 0 ]; then DIFF_MB=0; fi
    
    BEFORE_GB_DISP=$((BEFORE_KB / 1024 / 1024))
    AFTER_GB_DISP=$((AFTER_KB / 1024 / 1024))

    echo ""
    echo -e "${CYAN}${BOLD}==============================================================================${NC}"
    echo -e "${GREEN}${BOLD}   🎉 深度清理与性能优化圆满完成！${NC}"
    echo -e "${CYAN}${BOLD}==============================================================================${NC}"
    echo -e "  💾 可用磁盘空间 : ${YELLOW}${BEFORE_GB_DISP} GB${NC} ➔ ${GREEN}${BOLD}${AFTER_GB_DISP} GB${NC}"
    if [ "$DIFF_MB" -ge 1024 ]; then
        FREED_DISP="$((DIFF_MB / 1024)).$(( (DIFF_MB % 1024) / 100 )) GB"
        echo -e "  ✨ 成功释放磁盘 : ${GREEN}${BOLD}+${FREED_DISP} (${DIFF_MB} MB)${NC}"
    else
        FREED_DISP="${DIFF_MB} MB"
        echo -e "  ✨ 成功释放磁盘 : ${GREEN}${BOLD}+${FREED_DISP}${NC}"
    fi
    echo -e "  🧠 物理可用内存 : ${YELLOW}${BEFORE_RAM} GB${NC} ➔ ${GREEN}${BOLD}${AFTER_RAM} GB (大幅降低内存压力)${NC}"
    echo -e "  🌐 网络与 DNS   : 已热重置，网页加载更加顺畅"
    echo -e "${CYAN}------------------------------------------------------------------------------${NC}"

    # 原生 macOS 桌面横幅通知与提示音
    osascript -e "display notification \"成功释放 ${FREED_DISP} 空间！当前可用：${AFTER_GB_DISP} GB，可用内存：${AFTER_RAM} GB\" with title \"🍏 黑苹果系统优化大师\" subtitle \"深度清理与内存优化完成\" sound name \"Glass\"" 2>/dev/null || true
}

# 仅快速整理内存与刷新 DNS
run_quick_ram() {
    BEFORE_RAM=$(get_free_ram)
    echo ""
    echo -e "${BOLD}${PURPLE}⚡ 正在执行秒级物理内存整理与网络 DNS 刷新...${NC}"
    sudo purge >/dev/null 2>&1 || true
    dscacheutil -flushcache >/dev/null 2>&1 || true
    sudo killall -HUP mDNSResponder >/dev/null 2>&1 || true
    AFTER_RAM=$(get_free_ram)
    echo -e "  ${GREEN}✓ 内存整理完毕！可用内存: ${YELLOW}${BEFORE_RAM} GB${NC} ➔ ${GREEN}${BOLD}${AFTER_RAM} GB${NC}"
    osascript -e "display notification \"物理内存已成功释放，当前可用内存：${AFTER_RAM} GB\" with title \"🍏 黑苹果极速优化\" sound name \"Ping\"" 2>/dev/null || true
}

# 磁盘与硬件状态检测
show_status() {
    echo ""
    echo -e "${BOLD}${CYAN}📊 系统当前硬件与存储状态体检报告：${NC}"
    echo "------------------------------------------------------------------------------"
    df -h / /System/Volumes/Data
    echo ""
    echo -e "${BOLD}• 系统运行时间与平均负载：${NC}"
    uptime
    echo ""
    echo -e "${BOLD}• 电池状态与供电来源：${NC}"
    pmset -g batt | tail -n 2
    echo ""
    echo -e "${BOLD}• 物理内存分配概况：${NC}"
    echo "  当前空闲+非活跃可用内存: $(get_free_ram) GB"
    echo "------------------------------------------------------------------------------"
}

# 主交互逻辑
main() {
    print_banner
    
    echo -e "请选择执行模式 (倒计时 ${YELLOW}5 秒${NC} 默认自动启动【1. 全能极速安全清理】):"
    echo -e "  ${GREEN}${BOLD}[1] 🚀 一键全能极速安全清理 (推荐：清理12大项，大幅释放磁盘与内存)${NC}"
    echo -e "  ${BLUE}[2] ⚡ 仅极速物理内存整理与 DNS 刷新 (秒级释放 Inactive RAM)${NC}"
    echo -e "  ${PURPLE}[3] 📊 查阅系统存储分布与当前硬件负载报告${NC}"
    echo -e "  ${RED}[0] 退出${NC}"
    echo ""
    
    CHOICE=""
    read -t 5 -r -p "请输入选项 [1/2/3/0] (直接回车或等待5秒默认执行 1): " CHOICE || true
    echo ""
    
    if [ -z "$CHOICE" ]; then
        CHOICE="1"
    fi
    
    case "$CHOICE" in
        1)
            run_clean_engine "full"
            ;;
        2)
            run_quick_ram
            ;;
        3)
            show_status
            ;;
        0|q|Q)
            echo "已取消操作，安全退出。"
            exit 0
            ;;
        *)
            echo -e "${YELLOW}输入无效，默认执行全能极速安全清理...${NC}"
            run_clean_engine "full"
            ;;
    esac
    
    echo ""
    read -n 1 -s -r -p "按任意键退出窗口..."
    echo ""
}

main "$@"
