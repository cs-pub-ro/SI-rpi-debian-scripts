#!/bin/bash
# Builds a U-Boot only RaspberryPI image (with partitions)

set -eo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/../../lib/base.sh"

@import 'load_config'

DIST_DIR="$SRC_DIR/dist"
TMP_DOWNLOAD_DIR="$BUILD_DEST/tmp"
MOUNT_TMP="$1"

if [[ -z "$MOUNT_TMP" ]] ||  ! mountpoint -q "$MOUNT_TMP"; then
    sh_log_fatal "Invalid RPi boot mountpoint: '$MOUNT_TMP'!"
fi

mkdir -p "$TMP_DOWNLOAD_DIR"
for file in "${RPI_FIRMWARE_FILES[@]}"; do
    # download the latest rpi firmware files (debian repo is outdated)
    mkdir -p "$TMP_DOWNLOAD_DIR/$(dirname "$file")"
    wget "https://github.com/raspberrypi/firmware/raw/master/boot/$file" \
        -O "$TMP_DOWNLOAD_DIR/$file"
    $SUDO mkdir -p "$MOUNT_TMP/$(dirname "$file")"
    $SUDO cp -f "$TMP_DOWNLOAD_DIR/$file" "$MOUNT_TMP/$file"
done

$SUDO cp -f "$DIST_DIR/labsi-rpi5/u-boot.bin" "$MOUNT_TMP/u-boot.bin"
#$SUDO cp -f "$DIST_DIR/labsi-rpi5/"*".dtb" "$MOUNT_TMP/"
$SUDO cp -f "$CUSTOM_CONFIG_DIR/files/boot/config.txt" "$MOUNT_TMP/config.txt"
$SUDO cp -f "$CUSTOM_CONFIG_DIR/files/boot/cmdline.txt" "$MOUNT_TMP/cmdline.txt"

if [[ -n "$BUILD_FULL_IMAGE" ]]; then
    # also copy kernel files
    $SUDO cp -f "$ROOTFS_MOUNTPOINT/boot/vmlinuz-"* "$MOUNT_TMP/"
    $SUDO cp -f "$ROOTFS_MOUNTPOINT/boot/initrd.img-"* "$MOUNT_TMP/"
    $SUDO rm -f "$MOUNT_TMP/boot.img"
    # plus boot script ;)
    "$CUSTOM_CONFIG_DIR/build-uboot-script.sh"
    $SUDO cp -f "$DIST_DIR/labsi-rpi5/boot.scr" "$MOUNT_TMP/"
fi

$SUDO ls -lh "$MOUNT_TMP"

