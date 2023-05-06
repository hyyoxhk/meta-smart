# SPDX-License-Identifier: MIT
#
# Copyright (C) 2023 He Yong <hyyoxhk@163.com>
#

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

PACKAGECONFIG_CONFARGS = ""

SRC_URI += " \
    file://09-swupdate-args \
    file://11-suricatta-args \
    file://swupdate.cfg \
    file://defconfig \
    "

do_install:append() {
    install -d ${D}${libdir}/swupdate/conf.d/
    install -m 755 ${WORKDIR}/09-swupdate-args ${D}${libdir}/swupdate/conf.d/
    install -m 755 ${WORKDIR}/11-suricatta-args ${D}${libdir}/swupdate/conf.d/

    install -d ${D}${sysconfdir}
    install -m 644 ${WORKDIR}/swupdate.cfg ${D}${sysconfdir}
    sed -i -e "s/@machine@/${MACHINE}/; s/@image_version@/${IMAGE_VERSION}/" ${D}${sysconfdir}/swupdate.cfg
    sed -i -e "s/@distro@/${DISTRO}/; s/@distro_version@/${DISTRO_VERSION}/" ${D}${sysconfdir}/swupdate.cfg

    sed -i -e "s/@hw_version@/${HW_VERSION}/; s/@linux_version@/${LINUX_VERSION}/" ${D}${sysconfdir}/swupdate.cfg
    sed -i -e "s/@custom_app@/${CUSTOM_APP}/; s/@app_version@/${APP_VERSION}/" ${D}${sysconfdir}/swupdate.cfg

    echo "${MACHINE} ${HW_VERSION}" > ${D}${sysconfdir}/hwrevision
}
