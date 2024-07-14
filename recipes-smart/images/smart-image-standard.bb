# SPDX-License-Identifier: MIT
#
# Copyright (C) 2023 He Yong <hyyoxhk@163.com>
#

SUMMARY = "Smart image standard"
LICENSE = "MIT"

include recipes-smart/images/smart-image.inc
inherit core-image populate_sdk_qt5

SYSTEMD_DEFAULT_TARGET = "graphical.target"

IMAGE_FEATURES += " \
    splash \
    package-management \
    ssh-server-dropbear \
    hwcodecs \
"

CORE_IMAGE_EXTRA_INSTALL += " \
    packagegroup-component-base \
    packagegroup-component-display \
    packagegroup-component-qt-base \
    packagegroup-component-qt-fonts \
    packagegroup-component-qt-extra \
"

do_image_wic[depends] += "${INITRD_IMAGE}:do_image_complete"
