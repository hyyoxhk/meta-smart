# SPDX-License-Identifier: MIT
#
# Copyright (C) 2023 He Yong <hyyoxhk@163.com>
#

SUMMARY = "resize executable"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://init-resize.sh"

RDEPENDS:${PN} = "initramfs-framework-base e2fsprogs-resize2fs util-linux-lsblk util-linux-blkid"

inherit allarch

S = "${WORKDIR}"

do_install() {
    install -d ${D}/init.d
    install -m 0755 ${WORKDIR}/init-resize.sh ${D}/init.d/70-resize
}

FILES:${PN} += "/init.d/70-resize"
