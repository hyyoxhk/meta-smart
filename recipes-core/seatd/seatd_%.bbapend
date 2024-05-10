# SPDX-License-Identifier: MIT
#
# Copyright (C) 2023 He Yong <hyyoxhk@163.com>
#

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://seatd.service"

inherit systemd

do_install:append () {
    install -d ${D}${systemd_system_unitdir}
    install -m 644 ${WORKDIR}/seatd.service ${D}${systemd_system_unitdir}
}

FILES:${PN} += "${systemd_system_unitdir}/seatd.service"

SYSTEMD_SERVICE:${PN} = "seatd.service"
