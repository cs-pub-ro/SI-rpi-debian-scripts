#!/bin/bash
# Compiles the U-Boot script

set -eo pipefail
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"
source "$SRC_DIR/lib/common.sh"

DIST_DIR="$SRC_DIR/dist"
"$UBOOT_DEST/tools/mkimage" -A arm64 -T script -C none -n "Boot script" -d "$CUSTOM_CONFIG_DIR/files/uboot-script.txt" "$DIST_DIR/labsi-rpi4/boot.scr"

