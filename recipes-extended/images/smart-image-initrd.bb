# SPDX-License-Identifier: MIT
#
# Copyright (C) 2023 He Yong <hyyoxhk@163.com>
#

# Simple initramfs image. Mostly used for live images.
SUMMARY = "initrd image"
LICENSE = "MIT"

inherit core-image

python __anonymous () {
    d.setVar("IMAGE_FSTYPES", d.getVar("INITRAMFS_FSTYPES") or "")
}

IMAGE_ROOTFS_SIZE = "8192"
IMAGE_ROOTFS_EXTRA_SPACE = "0"

# Do not pollute the initrd image with rootfs features
IMAGE_FEATURES = ""

IMAGE_LINGUAS = ""

PACKAGE_INSTALL = " \
    busybox \
    initramfs-framework-base \
    initramfs-module-overlayroot \
    initramfs-module-udev \
    init-setup \
    init-install \
    coreutils \
    dosfstools \
"
