# SPDX-License-Identifier: MIT
#
# Copyright (C) 2023 He Yong <hyyoxhk@163.com>
#

SUMMARY = "initrd for emmc installation option"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${SMARTBASE}/COPYING.MIT;md5=175118499ff863b5f1bd66a0a5e5ed48"

RDEPENDS:${PN} = "initramfs-framework-base coreutils dosfstools"

SRC_URI = "file://init-install.sh"

inherit allarch

S = "${WORKDIR}"

do_install() {
    install -d ${D}/init.d
    install -m 0755 ${WORKDIR}/init-install.sh ${D}/init.d/install.sh
}

FILES:${PN} = "/init.d/install.sh"
