#!/bin/bash
# need to configure raspi-firmware to use a specific ROOTPART

CUSTOM_ROOTPART="/dev/mmcblk1p2"

sed -i -E 's|^(#\s*)?ROOTPART=.*$|ROOTPART='"$CUSTOM_ROOTPART"'|' /etc/default/raspi-firmware

