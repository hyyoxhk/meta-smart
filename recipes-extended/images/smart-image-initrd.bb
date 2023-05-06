# SPDX-License-Identifier: MIT
#
# Copyright (C) 2023 He Yong <hyyoxhk@163.com>
#

# Simple initramfs image. Mostly used for live images.
SUMMARY = "initrd image"
LICENSE = "MIT"

IMAGE_FSTYPES = "${INITRAMFS_FSTYPES}"
inherit core-image

IMAGE_FSTYPES:remove = "wic ext4 ext4.gz"

IMAGE_ROOTFS_SIZE = "8192"
IMAGE_ROOTFS_EXTRA_SPACE = "0"

# Do not pollute the initrd image with rootfs features
IMAGE_FEATURES = ""

IMAGE_LINGUAS = ""

PACKAGE_INSTALL = " \
    busybox \
    initramfs-framework-base \
    initramfs-module-udev \
    init-setup \
    init-install \
    coreutils \
    dosfstools \
"
