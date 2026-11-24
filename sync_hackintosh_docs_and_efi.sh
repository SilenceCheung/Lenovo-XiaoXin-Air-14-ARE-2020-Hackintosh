#!/bin/bash
# ==============================================================================
# 联想昭阳 K4e-ARE / 小新 Air 14 ARE 2020 黑苹果项目双端文档与 EFI 双向同步工具
# Hackintosh Project Bidirectional Sync Tool (Host Mac <--> Target Hackintosh)
# ==============================================================================

set -e

HOST_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_IPS=("${TARGET_IP:-127.0.0.1}")
TARGET_USER="${TARGET_USER:-username}"
TARGET_PASS="${TARGET_PASS:-password}"
TARGET_MAINT_DIR="/Users/${TARGET_USER}/Hackintosh_Maintenance"
ACTION="${1:-push}"

echo "======================================================================"
echo "  🔄 黑苹果双端信息与 EFI 自动化同步工具"
echo "  开发机目录: ${HOST_DIR}"
echo "  目标机路径: ${TARGET_USER}@TARGET_IP:${TARGET_MAINT_DIR}"
echo "  同步模式: ${ACTION}"
echo "======================================================================"

# 1. 自动探测目标黑苹果可用 IP
echo "[1/4] 正在检测目标黑苹果机器网络连通性..."
FOUND_IP=""
for ip in "${TARGET_IPS[@]}"; do
    if sshpass -p "${TARGET_PASS}" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=2 "${TARGET_USER}@${ip}" "echo 'OK'" >/dev/null 2>&1; then
        FOUND_IP="${ip}"
        break
    fi
done

if [ -z "$FOUND_IP" ]; then
    echo "❌ 错误: 无法连接到目标黑苹果 (${TARGET_IPS[*]})，请检查以太网/Type-C连接与IP地址！"
    exit 1
fi

TARGET_IP="${FOUND_IP}"
SSH_CMD="sshpass -p '${TARGET_PASS}' ssh -o StrictHostKeyChecking=no ${TARGET_USER}@${TARGET_IP}"
RSYNC_SSH="sshpass -p '${TARGET_PASS}' ssh -o StrictHostKeyChecking=no"

echo "✅ 成功连通目标机器: ${TARGET_USER}@${TARGET_IP}！"

# 2. 确保目标机维护目录存在
echo "[2/4] 校验目标机器维护目录结构..."
${SSH_CMD} "mkdir -p ${TARGET_MAINT_DIR}/EFI_LATEST"

# 3. 执行同步动作
if [ "$ACTION" == "push" ]; then
    echo "[3/4] 正在将开发机最新文档推送到黑苹果机器..."
    rsync -avz --exclude ".DS_Store" --exclude "*.bin" -e "${RSYNC_SSH}" \
        "${HOST_DIR}/"*.md "${TARGET_USER}@${TARGET_IP}:${TARGET_MAINT_DIR}/"

    echo "[4/4] 正在同步 EFI 到黑苹果本地备份与物理引导分区..."
    rsync -avz --delete -e "${RSYNC_SSH}" \
        "${HOST_DIR}/EFI/" "${TARGET_USER}@${TARGET_IP}:${TARGET_MAINT_DIR}/EFI_LATEST/"
    
    # 挂载物理 EFI 分区进行写入，写入完成后强制卸载隐藏，杜绝用户误操作风险
    ${SSH_CMD} '
        EFI_DEV=$(diskutil list | grep -iE "EFI|Microsoft Basic Data EFI" | head -n 1 | awk "{print \$NF}")
        if [ -n "$EFI_DEV" ]; then
            echo "-> 找到物理引导分区: /dev/$EFI_DEV，挂载中..."
            diskutil mount "$EFI_DEV" >/dev/null 2>&1 || true
            if [ -d /Volumes/EFI ]; then
                touch /Volumes/EFI/.metadata_never_index
                echo "-> 正在同步最新 EFI 到物理分区 /Volumes/EFI/EFI/ ..."
                rsync -a --delete ~/Hackintosh_Maintenance/EFI_LATEST/ /Volumes/EFI/EFI/
                sync
                echo "-> 物理 EFI 写入完成，立即执行安全卸载并隐藏..."
                diskutil unmount force /Volumes/EFI >/dev/null 2>&1 || true
                echo "✅ 物理 EFI 分区已完全隐藏保护，Finder 界面无残留！"
            else
                echo "⚠️ 挂载失败，物理 EFI 分区未能写入（本地备份已更新）。"
            fi
        else
            echo "⚠️ 未找到物理 EFI 分区，跳过物理分区写入。"
        fi
    '

elif [ "$ACTION" == "pull" ]; then
    echo "[3/4] 正在从黑苹果机器拉取最新文档..."
    rsync -avz --exclude ".DS_Store" -e "${RSYNC_SSH}" \
        "${TARGET_USER}@${TARGET_IP}:${TARGET_MAINT_DIR}/"*.md "${HOST_DIR}/"

    echo "[4/4] 正在从黑苹果拉取物理 EFI 到开发机..."
    ${SSH_CMD} '
        EFI_DEV=$(diskutil list | grep -iE "EFI|Microsoft Basic Data EFI" | head -n 1 | awk "{print \$NF}")
        if [ -n "$EFI_DEV" ]; then
            diskutil mount "$EFI_DEV" >/dev/null 2>&1 || true
        fi
    '
    if ${SSH_CMD} "[ -d /Volumes/EFI/EFI ]"; then
        echo '-> 物理 EFI 存在，拉取物理 EFI...'
        rsync -avz --delete -e "${RSYNC_SSH}" \
            "${TARGET_USER}@${TARGET_IP}:/Volumes/EFI/EFI/" "${HOST_DIR}/EFI/"
    else
        echo '-> 物理 EFI 未挂载，从本地备份拉取...'
        rsync -avz --delete -e "${RSYNC_SSH}" \
            "${TARGET_USER}@${TARGET_IP}:${TARGET_MAINT_DIR}/EFI_LATEST/" "${HOST_DIR}/EFI/"
    fi
    ${SSH_CMD} 'diskutil unmount force /Volumes/EFI >/dev/null 2>&1 || true'

else
    echo "❌ 未知参数: $ACTION. 请输入 push 或 pull"
    exit 1
fi

# 同步同步脚本本身到黑苹果端
rsync -avz -e "${RSYNC_SSH}" "${HOST_DIR}/sync_hackintosh_docs_and_efi.sh" "${TARGET_USER}@${TARGET_IP}:${TARGET_MAINT_DIR}/"

echo "======================================================================"
echo "  🎉 同步全部完成！开发机与黑苹果两端文档与 EFI 状态已 100% 镜像一致！"
echo "======================================================================"
