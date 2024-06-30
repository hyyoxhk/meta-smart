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
    gstreamer1.0 \
    gstreamer1.0-libav \
    gstreamer1.0-meta-base \
    gstreamer1.0-omx \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-rtsp-server \
"
