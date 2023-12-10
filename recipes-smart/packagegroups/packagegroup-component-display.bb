# SPDX-License-Identifier: MIT
#
# Copyright (C) 2023 He Yong <hyyoxhk@163.com>
#

SUMMARY = "components display"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup features_check

# weston-init requires pam enabled if started via systemd
REQUIRED_DISTRO_FEATURES = "wayland ${@oe.utils.conditional('VIRTUAL-RUNTIME_init_manager', 'systemd', 'pam', '', d)}"

PACKAGES = "${PN}"
SUMMARY:${PN} = "about display"
RDEPENDS:${PN} = " \
    weston \
    weston-init \
    wayland-utils \
"
