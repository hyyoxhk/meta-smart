# SPDX-License-Identifier: MIT
#
# Copyright (C) 2023 He Yong <hyyoxhk@163.com>
#

SUMMARY = "Smart image small"
LICENSE = "MIT"

include recipes-smart/images/smart-image.inc
inherit core-image

SYSTEMD_DEFAULT_TARGET = "multi-user.target"

IMAGE_FEATURES += " \
    package-management \
    ssh-server-dropbear \
    hwcodecs \
"

CORE_IMAGE_EXTRA_INSTALL += " \
    packagegroup-component-base \
"

inherit extrausers
EXTRA_USERS_PARAMS = " \
    useradd -d /home/smart smart; \
    useradd -p '' smart; \
    usermod -a -G audio smart; \
    usermod -a -G adm smart; \
    usermod -a -G sudo smart; \
    usermod -s /bin/sh smart; \
"

do_image_wic[depends] += "${INITRD_IMAGE}:do_image_complete"
