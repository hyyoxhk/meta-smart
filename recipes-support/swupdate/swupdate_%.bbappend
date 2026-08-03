# SPDX-License-Identifier: MIT
#
# Copyright (C) 2023 He Yong <hyyoxhk@163.com>
#

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
    file://0001-build-add-pkg-config-metadata-for-libswupdate.patch \
    file://09-swupdate-args \
    file://10-mongoose-args \
    file://swupdate.cfg \
    file://defconfig \
    "

do_install:append() {
    install -d ${D}${libdir}/swupdate/conf.d/
    install -m 755 ${WORKDIR}/09-swupdate-args ${D}${libdir}/swupdate/conf.d/

    install -d ${D}${sysconfdir}
    install -m 644 ${WORKDIR}/swupdate.cfg ${D}${sysconfdir}

    echo "${MACHINE} ${HW_VERSION}" > ${D}${sysconfdir}/hwrevision
}
