# SPDX-License-Identifier: MIT
#
# Copyright (C) 2023 He Yong <hyyoxhk@163.com>
#

SUMMARY = "Smart image standard"
LICENSE = "MIT"

include recipes-smart/images/smart-image.inc
inherit core-image

IMAGE_FEATURES += " \
    splash \
    package-management \
    ssh-server-dropbear \
    hwcodecs \
    weston \
"

CORE_IMAGE_EXTRA_INSTALL += " \
    packagegroup-component-base-core \
    packagegroup-component-display \
"

do_image_wic[depends] += "${INITRD_IMAGE}:do_image_complete"
