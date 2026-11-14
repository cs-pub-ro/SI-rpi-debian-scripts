#!/bin/bash
# Compiles the U-Boot script

set -eo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/../../lib/base.sh"

@import 'load_config'

DIST_DIR="$SRC_DIR/dist"
"$UBOOT_DEST/tools/mkimage" -A arm64 -T script -C none -n "Boot script" -d "$CUSTOM_CONFIG_DIR/files/uboot-script.txt" "$DIST_DIR/labsi-rpi4/boot.scr"

