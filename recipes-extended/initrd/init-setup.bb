# SPDX-License-Identifier: MIT
#
# Copyright (C) 2023 He Yong <hyyoxhk@163.com>
#

SUMMARY = "setup script"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${SMARTBASE}/COPYING.MIT;md5=175118499ff863b5f1bd66a0a5e5ed48"

SRC_URI = "file://init-setup.sh"

RDEPENDS:${PN} = "initramfs-framework-base udev-extraconf"

inherit allarch

S = "${WORKDIR}"

do_install() {
    install -d ${D}/init.d
    install -m 0755 ${WORKDIR}/init-setup.sh ${D}/init.d/30-setup
}

FILES:${PN} += "/init.d/30-setup"
