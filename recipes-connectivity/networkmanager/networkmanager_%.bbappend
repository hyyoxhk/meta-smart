# Copyright (C) 2022 He Yong <hyyoxhk@163.com>

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
    file://NetworkManager.conf \
    file://NetworkManager.service \
"

PACKAGECONFIG:append = " modemmanager nmtui"

do_install:append() {
    install -m 644 ${WORKDIR}/NetworkManager.conf ${D}${sysconfdir}/NetworkManager
    install -m 644 ${WORKDIR}/NetworkManager.service ${D}${systemd_system_unitdir}
}
