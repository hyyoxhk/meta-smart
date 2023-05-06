# SPDX-License-Identifier: MIT
#
# Copyright (C) 2023 He Yong <hyyoxhk@163.com>
#

FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

PACKAGECONFIG:append = " firstboot"

do_install:append() {
    # Remove this service useless for our needs
    rm -f ${D}/${rootlibexecdir}/systemd/system-generators/systemd-gpt-auto-generator

    # Disable the systemd-networkd service, but keep the package
    sed -i "s/enable systemd-networkd.service/disable systemd-networkd.service/" ${D}${systemd_unitdir}/system-preset/90-systemd.preset
    sed -i "s/enable systemd-network-generator.service/disable systemd-network-generator.service/" ${D}${systemd_unitdir}/system-preset/90-systemd.preset
}
