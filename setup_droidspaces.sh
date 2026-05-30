#!/bin/bash
# Droidspaces modular setup script
# This script applies the confirmed kABI patch and enables the required configs.

OUT_DIR=${1:-"out"}

echo "=========================================="
echo "      Applying Droidspaces Support        "
echo "=========================================="

# 1. Apply confirmed kABI patch (3_4_5 works for this kernel)
PATCH_NAME="001.GKI-below-6.12-fix_sysvipc_kabi_3_4_5.patch"
PATCH_URL="https://raw.githubusercontent.com/ravindu644/Droidspaces-OSS/main/Documentation/resources/kernel-patches/GKI/below-kernel-6.12/$PATCH_NAME"

echo "[*] Downloading $PATCH_NAME..."
curl -sLO "$PATCH_URL"

echo "[*] Applying $PATCH_NAME..."
if patch -p1 < "$PATCH_NAME"; then
    echo "[+] Successfully applied $PATCH_NAME"
    rm -f "$PATCH_NAME"
else
    echo "[-] Error: Failed to apply Droidspaces kABI patch!"
    rm -f "$PATCH_NAME"
    exit 1
fi

# 2. Add configs to out/.config if it exists
if [ -f "$OUT_DIR/.config" ]; then
    echo "[*] Enabling Droidspaces kernel configs..."
    configs=(
        "CONFIG_SYSVIPC"
        "CONFIG_POSIX_MQUEUE"
        "CONFIG_IPC_NS"
        "CONFIG_PID_NS"
        "CONFIG_DEVTMPFS"
        "CONFIG_NETFILTER_XT_MATCH_ADDRTYPE"
        "CONFIG_NETFILTER_XT_TARGET_REJECT"
        "CONFIG_NETFILTER_XT_TARGET_LOG"
        "CONFIG_NETFILTER_XT_MATCH_RECENT"
        "CONFIG_IP_SET"
        "CONFIG_IP_SET_HASH_IP"
        "CONFIG_IP_SET_HASH_NET"
        "CONFIG_NETFILTER_XT_SET"
        "CONFIG_TMPFS_POSIX_ACL"
        "CONFIG_TMPFS_XATTR"
    )

    for cfg in "${configs[@]}"; do
        scripts/config --file "$OUT_DIR/.config" -e "$cfg"
    done
    echo "[+] Droidspaces configs added."
else
    echo "[-] $OUT_DIR/.config not found! Please apply configs manually."
fi
