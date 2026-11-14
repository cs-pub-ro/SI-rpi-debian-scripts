# Embedded Systems Debian rootfs configuration for labs

KERNEL_VERSION=${KERNEL_VERSION:-6.18}
KERNEL_BRANCH="rpi-$KERNEL_VERSION.y"
KERNEL_DEFCONFIG=${KERNEL_DEFCONFIG:-"bcm2712_defconfig"}

UBOOT_BRANCH="v2026.10"
UBOOT_DEFCONFIG=${UBOOT_DEFCONFIG:-"rpi_arm64_defconfig"}

RPI_FIRMWARE_FILES=(start4.elf fixup4.dat bcm2712-rpi-5-b.dtb bcm2712d0-rpi-5-b.dtb
	overlays/overlay_map.dtb overlays/hat_map.dtb overlays/disable-bt.dtbo
	overlays/pciex1-compat-pi5.dtbo overlays/pcie-32bit-dma-pi5.dtbo 
	overlays/pcie-32bit-dma.dtbo overlays/dwc2.dtbo)


RPI_SKIP_BOOT_RAMDISK=1
LABSI_USE_COMPILED_KERNEL=1
if [[ -n "$LABSI_USE_COMPILED_KERNEL" ]]; then
	EXTRA_PACKAGES=()
else
	EXTRA_PACKAGES=(raspi-firmware linux-image-generic linux-headers-generic linux-libc-dev)
	SKIP_BOOT_FILES=y
fi

function rootfs_install_hook() {
	# copy custom install scripts to exec. dir
	cp -ar "$CUSTOM_CONFIG_DIR/install-scripts/"* "$INSTALL_SRC/scripts/"
	cp -ar "$CUSTOM_CONFIG_DIR/files/"* "$INSTALL_SRC/files/"
}

function image_build_hook() {
	export BUILD_FULL_IMAGE=1
	chmod +x "$CUSTOM_CONFIG_DIR/copy-image-files.sh"
	"$CUSTOM_CONFIG_DIR/copy-image-files.sh" "$1/$RPI_FIRMWARE_DIR"
}
