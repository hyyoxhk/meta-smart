# SPDX-License-Identifier: MIT
#
# Copyright (C) 2023 He Yong <hyyoxhk@163.com>
#

FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

SRC_URI +=  "file://libc.conf"

do_install:append() {
    install -d 644 ${D}/${sysconfdir}/ld.so.conf.d
    install -m 644 ${WORKDIR}/libc.conf ${D}/${sysconfdir}/ld.so.conf.d/libc.conf
}

FILES:ldconfig += "${sysconfdir}/ld.so.conf.d/libc.conf"
