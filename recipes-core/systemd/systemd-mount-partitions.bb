# SPDX-License-Identifier: MIT
#
# Copyright (C) 2018, STMicroelectronics - All Rights Reserved
# Released under the MIT license (see COPYING.MIT for the terms)
#
# Copyright (C) 2023 He Yong <hyyoxhk@163.com>
#

SUMMARY = "Mount partitions"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${SMARTBASE}/COPYING.MIT;md5=175118499ff863b5f1bd66a0a5e5ed48"

SRC_URI = " \
    file://mount-partitions.service    \
    file://mount-partitions.sh         \
    "

inherit systemd

SYSTEMD_PACKAGES = "${@bb.utils.contains('DISTRO_FEATURES','systemd','${PN}','',d)}"
SYSTEMD_SERVICE:${PN} = "mount-partitions.service"
SYSTEMD_AUTO_ENABLE:${PN} = "enable"

do_install () {
    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${systemd_unitdir}/system ${D}/${base_sbindir}
        install -m 644 ${WORKDIR}/mount-partitions.service ${D}/${systemd_unitdir}/system
        install -m 755 ${WORKDIR}/mount-partitions.sh ${D}/${base_sbindir}/
    fi
}

FILES:${PN} += " ${systemd_unitdir} ${base_sbindir}"
