# SPDX-License-Identifier: MIT
#
# Copyright (C) 2023 He Yong <hyyoxhk@163.com>
#

# Simple initramfs image. Mostly used for live images.
SUMMARY = "initrd image"
LICENSE = "MIT"

python __anonymous () {
    d.setVar("IMAGE_FSTYPES", d.getVar("INITRAMFS_FSTYPES") or "")
}

inherit core-image

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

do_image[depends] += "${DM_VERITY_IMAGE}:do_image_${@d.getVar('DM_VERITY_IMAGE_TYPE').replace('-', '_')}"

deploy_verity_hash() {
    install -D -m 0644 \
        ${STAGING_VERITY_DIR}/${DM_VERITY_IMAGE}.${DM_VERITY_IMAGE_TYPE}.verity.env \
        ${IMAGE_ROOTFS}${datadir}/misc/dm-verity.env
}
IMAGE_PREPROCESS_COMMAND += "deploy_verity_hash;"
