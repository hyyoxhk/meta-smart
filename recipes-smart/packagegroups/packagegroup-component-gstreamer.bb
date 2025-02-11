# SPDX-License-Identifier: MIT
#
# Copyright (C) 2024 He Yong <hyyoxhk@163.com>
#

SUMMARY = "Gstreamer1-0 components"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

PACKAGES = "${PN}"

SUMMARY:${PN} = "gstreamer1-0 about"
RDEPENDS:${PN} = " \
    gstreamer1.0-plugins-base-meta \
    gstreamer1.0-plugins-good-meta \
    gstreamer1.0-plugins-bad-meta \
    gstreamer1.0-plugins-ugly-meta \
    \
    gstreamer1.0-libav \
    gstreamer1.0-omx \
    gstreamer1.0-rtsp-server \
"
