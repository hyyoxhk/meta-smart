# SPDX-License-Identifier: MIT
#
# Copyright (C) 2023 He Yong <hyyoxhk@163.com>
#

SUMMARY = "factory image"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${SMARTBASE}/COPYING.MIT;md5=175118499ff863b5f1bd66a0a5e5ed48"

# We provide an InitRD specific to machine
PACKAGE_ARCH = "${MACHINE_ARCH}"

S = "${WORKDIR}"

FACTORY_IMAGE ?= ""
FACTORY_SHORTNAME ?= "magic.img"

do_fetch[noexec] = "1"
do_unpack[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    if [ -z "${FACTORY_IMAGE}" ]; then
        bbnote "No Factory Image set"
        return
    fi

    echo "Copying magic.img file into ./images/ ..."
    FACTORY_IMAGE_FILE=$(find ${DEPLOY_DIR_IMAGE} -name ${FACTORY_IMAGE}*-${MACHINE}.wic)
    if [ -e "${FACTORY_IMAGE_FILE}" ]; then
        install -d ${D}/images
        install -m 0644 ${FACTORY_IMAGE_FILE} ${D}/images/${FACTORY_SHORTNAME}
    else
        bbfatal "Could not find ${FACTORY_IMAGE}*-${MACHINE}.wic image file in ${DEPLOY_DIR_IMAGE} folder"
    fi
}
do_install[depends] += "${@' '.join([i + ':do_image_complete' for i in d.getVar('FACTORY_IMAGE').split()])}"

PACKAGEBUILDPKGD:remove = " package_prepare_pkgdata"

FILES:${PN} += "/images/magic.img"
