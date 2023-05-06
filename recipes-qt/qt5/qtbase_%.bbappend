# SPDX-License-Identifier: MIT
#
# Copyright (C) 2023 He Yong <hyyoxhk@163.com>
#

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://qt-wayland.sh"

do_install:append () {
    install -d ${D}${sysconfdir}/profile.d/
    install -m 0755 ${WORKDIR}/qt-wayland.sh ${D}/${sysconfdir}/profile.d/
}
