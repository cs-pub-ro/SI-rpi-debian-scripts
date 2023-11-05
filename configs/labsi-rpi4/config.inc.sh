# Embedded Systems Debian rootfs configuration for labs

KERNEL_VERSION=${KERNEL_VERSION:-6.1}
KERNEL_BRANCH="rpi-$KERNEL_VERSION.y"
KERNEL_DEFCONFIG=${KERNEL_DEFCONFIG:-"bcm2711_defconfig"}

UBOOT_DEFCONFIG=${UBOOT_DEFCONFIG:-"rpi_4_defconfig"}

EXTRA_PACKAGES=(raspi-firmware linux-image-generic linux-headers-generic linux-libc-dev)

SKIP_BOOT_FILES=y
RPI_SKIP_IMAGE_GEN=1

function rootfs_install_hook() {
	# copy custom install scripts to exec. dir
	cp -ar "$CUSTOM_CONFIG_DIR/install-scripts/"* "$INSTALL_SRC/scripts/"
	cp -ar "$CUSTOM_CONFIG_DIR/files/"* "$INSTALL_SRC/files/"
}

