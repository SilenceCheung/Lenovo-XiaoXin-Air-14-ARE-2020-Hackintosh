#!/bin/bash
# ==============================================================================
# Sequoia Phase 2 BaseSystem Copy Fixer & Diagnostic Utility
# For Lenovo XiaoXin Air 14 ARE 2020 / ZhaoYang K4e-ARE (PM991 SSD)
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_OUT="$SCRIPT_DIR/installer_error_diagnosis.txt"
exec > >(tee -a "$LOG_OUT") 2>&1

echo "=========================================================="
echo " Starting Diagnostic & Remediation at $(date)"
echo " Running from directory: $SCRIPT_DIR"
echo "=========================================================="

# 1. Check all disks and APFS containers
echo ""
echo "--- 1. APFS Container & Disk List ---"
diskutil list
echo ""
diskutil apfs list

# 2. Check for Macintosh HD and Install Data
TARGET_MNT=""
if [ -d "/Volumes/Macintosh HD/macOS Install Data" ]; then
    TARGET_MNT="/Volumes/Macintosh HD"
elif [ -d "/Volumes/Macintosh HD - Data/macOS Install Data" ]; then
    TARGET_MNT="/Volumes/Macintosh HD - Data"
elif [ -d "/Volumes/Macintosh/macOS Install Data" ]; then
    TARGET_MNT="/Volumes/Macintosh"
else
    # Search for macOS Install Data on any mounted volume
    for v in /Volumes/*; do
        if [ -d "$v/macOS Install Data" ]; then
            TARGET_MNT="$v"
            break
        fi
    done
fi

if [ -n "$TARGET_MNT" ]; then
    echo ""
    echo "--- 2. Found Target Installation at: $TARGET_MNT ---"
    echo "Contents of macOS Install Data:"
    ls -la "$TARGET_MNT/macOS Install Data"
    
    echo ""
    echo "--- 3. Error Analysis from Logs ---"
    if [ -f "$TARGET_MNT/macOS Install Data/ia.log" ]; then
        echo ">> Matching lines in ia.log:"
        grep -i -C 3 "BaseSystem" "$TARGET_MNT/macOS Install Data/ia.log" | tail -n 20
        echo ">> Last 20 lines of ia.log:"
        tail -n 20 "$TARGET_MNT/macOS Install Data/ia.log"
    fi
    
    if [ -f "$TARGET_MNT/macOS Install Data/install.log" ]; then
        echo ">> Matching lines in install.log:"
        grep -i -C 3 "BaseSystem" "$TARGET_MNT/macOS Install Data/install.log" | tail -n 20
        echo ">> Last 20 lines of install.log:"
        tail -n 20 "$TARGET_MNT/macOS Install Data/install.log"
    fi
else
    echo "WARNING: macOS Install Data directory not found on mounted volumes!"
fi

# 3. Discover Volume Group UUID
UUID="6BBDF7C7-4465-41BF-8122-05CCAC5CE0AE"
if [ -n "$TARGET_MNT" ]; then
    DETECTED_UUID=$(diskutil info "$TARGET_MNT" | awk -F': *' '/Volume UUID/ {print $2}')
    if [ -n "$DETECTED_UUID" ]; then
        UUID="$DETECTED_UUID"
    fi
fi
echo ""
echo "--- 4. Target Volume UUID: $UUID ---"

# 4. Check & Mount APFS Volumes (Preboot & Recovery)
echo ""
echo "--- 5. Mounting Preboot and Recovery Volumes ---"
diskutil list | grep -E "Preboot|Recovery" | while read -r line; do
    IDENT=$(echo "$line" | awk '{print $NF}')
    if [ -n "$IDENT" ]; then
        echo "Mounting $IDENT..."
        diskutil mount "$IDENT" || mount -u -w "/dev/$IDENT"
    fi
done

# Check mount status
echo ""
echo "Current Mounts:"
df -h | grep -E "Preboot|Recovery|Macintosh"

# 5. Pre-stage BaseSystem.dmg & BaseSystem.chunklist into Recovery & Preboot
USB_SRC="$SCRIPT_DIR/BaseSystem"
if [ ! -f "$USB_SRC/BaseSystem.dmg" ]; then
    # Fallback search
    USB_SRC=$(find /Volumes -name "BaseSystem.dmg" 2>/dev/null | grep -v "macOS Install Data" | head -n 1)
    USB_SRC=$(dirname "$USB_SRC")
fi

echo ""
echo "--- 6. Pre-staging Recovery Assets from $USB_SRC ---"
if [ -f "$USB_SRC/BaseSystem.dmg" ]; then
    SRC_SIZE=$(stat -f%z "$USB_SRC/BaseSystem.dmg")
    echo "Source BaseSystem.dmg size: $SRC_SIZE bytes"
    
    # Target 1: /Volumes/Recovery/$UUID
    if [ -d "/Volumes/Recovery" ]; then
        echo "Targeting /Volumes/Recovery/$UUID..."
        mkdir -p "/Volumes/Recovery/$UUID"
        cp -p -v "$USB_SRC/BaseSystem.dmg" "/Volumes/Recovery/$UUID/BaseSystem.dmg"
        cp -p -v "$USB_SRC/BaseSystem.chunklist" "/Volumes/Recovery/$UUID/BaseSystem.chunklist"
        chmod -R 755 "/Volumes/Recovery/$UUID"
    else
        echo "Notice: /Volumes/Recovery not mounted as directory, trying container recovery volumes..."
    fi
    
    # Target 2: /Volumes/Preboot/$UUID
    if [ -d "/Volumes/Preboot" ]; then
        echo "Targeting /Volumes/Preboot/$UUID..."
        mkdir -p "/Volumes/Preboot/$UUID"
        mkdir -p "/Volumes/Preboot/$UUID/com.apple.installer"
        cp -p -v "$USB_SRC/BaseSystem.dmg" "/Volumes/Preboot/$UUID/BaseSystem.dmg"
        cp -p -v "$USB_SRC/BaseSystem.chunklist" "/Volumes/Preboot/$UUID/BaseSystem.chunklist"
        cp -p -v "$USB_SRC/BaseSystem.dmg" "/Volumes/Preboot/$UUID/com.apple.installer/BaseSystem.dmg"
        cp -p -v "$USB_SRC/BaseSystem.chunklist" "/Volumes/Preboot/$UUID/com.apple.installer/BaseSystem.chunklist"
        chmod -R 755 "/Volumes/Preboot/$UUID"
    fi
    
    # Target 3: Validate /macOS Install Data/BaseSystem.dmg
    if [ -n "$TARGET_MNT" ] && [ -d "$TARGET_MNT/macOS Install Data" ]; then
        INST_DMG="$TARGET_MNT/macOS Install Data/BaseSystem.dmg"
        if [ -f "$INST_DMG" ]; then
            INST_SIZE=$(stat -f%z "$INST_DMG")
            echo "Target macOS Install Data BaseSystem.dmg size: $INST_SIZE bytes"
            if [ "$INST_SIZE" -ne "$SRC_SIZE" ]; then
                echo "Warning: Target size differs! Refreshing BaseSystem.dmg in macOS Install Data..."
                cp -p -v "$USB_SRC/BaseSystem.dmg" "$INST_DMG"
                cp -p -v "$USB_SRC/BaseSystem.chunklist" "$TARGET_MNT/macOS Install Data/BaseSystem.chunklist"
            fi
        fi
    fi
    echo ""
    echo ">>> Remediation copying complete!"
else
    echo "ERROR: Source BaseSystem.dmg not found!"
fi

echo ""
echo "=========================================================="
echo " Remediation Complete. Please restart the laptop and"
echo " select 'macOS Installer' in OpenCore to resume Phase 2!"
echo "=========================================================="
