# SPDX-License-Identifier: MIT
#
# Copyright (C) 2023 He Yong <hyyoxhk@163.com>
#

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " file://var-volatile-home.service.in"

VOLATILE_BINDS += " \
    /var/volatile/dropbear /etc/dropbear\n\
    /var/volatile/home /home/smart\n\
"

do_install:append() {
    install -m 0644 ${WORKDIR}/var-volatile-home.service.in ${D}${systemd_system_unitdir}/var-volatile-home.service
}
