#!/bin/bash
# Builds a U-Boot only RaspberryPI image (with partitions)

set -eo pipefail
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"
source "$SRC_DIR/lib/common.sh"

# image builder options
DIST_DIR="$SRC_DIR/dist"
TMP_DOWNLOAD_DIR="$BUILD_DEST/tmp"
UBOOT_IMAGE_DEST=${UBOOT_IMAGE_DEST:-"$BUILD_DEST/u-boot-image.bin"}
MOUNT_TMP="${MOUNT_TMP:-/tmp/rpi.mount}"
IMAGE_SIZE_MB=150

_lo_umount() {
    if [[ "$0" != "--force" && "$DEBUG" -gt 2 ]]; then return 0; fi
    log_info "Unmounting loopback device..."
    mountpoint -q "$MOUNT_TMP$RPI_FIRMWARE_DIR" && $SUDO umount "$MOUNT_TMP$RPI_FIRMWARE_DIR" || true
    mountpoint -q "$MOUNT_TMP" && $SUDO umount "$MOUNT_TMP" || true
    if [[ -n "$LO_DEV" ]]; then
        $SUDO losetup -d "$LO_DEV"
    else $SUDO losetup -D; fi
}
if [[ "$1" =~ ^(-u|--un?mount)$ ]]; then _lo_umount --force; exit 0; fi

# reseve the image file
dd if=/dev/zero of="$UBOOT_IMAGE_DEST" bs=1M count="$IMAGE_SIZE_MB"

_PARTED_BOOT_START=1
_PARTED_BOOT_END=$(( "$IMAGE_BOOT_PART_MB" + "$_PARTED_BOOT_START" ))

log_info "Creating partitions..."
log_debug \
    '1:' "${_PARTED_BOOT_START}MiB" "${_PARTED_BOOT_END}MiB" $'\n' \
    '2:' "${_PARTED_BOOT_END}MiB" "100%"

parted --script "$UBOOT_IMAGE_DEST" \
    mklabel msdos \
    mkpart primary "${_PARTED_BOOT_START}MiB" "${_PARTED_BOOT_END}MiB" \
    type 1 0x0B set 1 boot on

LO_DEV=$($SUDO losetup -f)
$SUDO losetup -P "$LO_DEV" "$UBOOT_IMAGE_DEST"
log_info "Loopback device $LO_DEV mapped to '$UBOOT_IMAGE_DEST'"
trap _lo_umount EXIT

if [[ ! -b "${LO_DEV}p1" ]]; then
    log_fatal "Image partition scanning failed!"
fi

log_info "Formatting boot partition..."
$SUDO mkfs.vfat -n "$IMAGE_BOOT_PART_NAME" "${LO_DEV}p1"

# use the /boot/firmware convention to split partitions
$SUDO mkdir -p "$MOUNT_TMP"
log_debug "mount ${LO_DEV}p1 $MOUNT_TMP"
$SUDO mount "${LO_DEV}p1" "$MOUNT_TMP"

mkdir -p "$TMP_DOWNLOAD_DIR"
for file in "${RPI_FIRMWARE_FILES[@]}"; do
    # download the latest rpi firmware files (debian repo is outdated)
    mkdir -p "$TMP_DOWNLOAD_DIR/$(dirname "$file")"
    wget "https://github.com/raspberrypi/firmware/raw/master/boot/$file" \
        -O "$TMP_DOWNLOAD_DIR/$file"
    $SUDO mkdir -p "$MOUNT_TMP/$(dirname "$file")"
    $SUDO cp -f "$TMP_DOWNLOAD_DIR/$file" "$MOUNT_TMP/$file"
done

$SUDO cp -f "$DIST_DIR/labsi-rpi4/u-boot.bin" "$MOUNT_TMP/u-boot.bin"
#$SUDO cp -f "$DIST_DIR/labsi-rpi4/"*".dtb" "$MOUNT_TMP/"
$SUDO cp -f "$CUSTOM_CONFIG_DIR/files/boot/config.txt" "$MOUNT_TMP/config.txt"
$SUDO cp -f "$CUSTOM_CONFIG_DIR/files/boot/cmdline.txt" "$MOUNT_TMP/cmdline.txt"

log_debug $'Firmware files list: \n' "$(ls -lh "$MOUNT_TMP")"
$SUDO du -hs "$MOUNT_TMP"

echo "Successfully generated U-Boot image!"
ls -l "$UBOOT_IMAGE_DEST"

