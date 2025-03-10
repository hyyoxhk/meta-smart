# SPDX-License-Identifier: MIT
#
# Copyright (C) 2025 He Yong <hyyoxhk@163.com>
#

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

dirs755:append = " /usr/local"

do_install:append () {
    rm ${D}${sysconfdir}/skel/.profile
    rm ${D}${sysconfdir}/skel/.bashrc
}
