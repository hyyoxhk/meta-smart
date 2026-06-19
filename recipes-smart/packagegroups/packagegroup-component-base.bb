# SPDX-License-Identifier: MIT
#
# Copyright (C) 2023 He Yong <hyyoxhk@163.com>
#

SUMMARY = "components base"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

PACKAGES = "${PN}"
# apt-conf
SUMMARY:${PN} = "basic tools and libraries"
RDEPENDS:${PN} = " \
    at \
    bash \
    coreutils \
    cpio \
    cronie \
    glibc-utils \
    file \
    findutils \
    gawk \
    grep \
    gzip \
    localedef \
    lsb-release \
    procps \
    psmisc \
    sed \
    tar \
    time \
    util-linux \
    glibc \
    libgcc \
    zlib \
    nspr \
    nss \
    libinih \
    json-c \
    \
    sudo \
    firmwared \
    db \
    sqlite3 \
    tzdata \
    ntpdate \
    networkmanager \
    \
    libgpiod \
    libiio \
    c-periphery \
    \
    parted \
    gptfdisk \
    e2fsprogs \
    e2fsprogs-resize2fs \
    \
    swupdate \
    u-boot-default-env \
    \
    mediamtx \
    opencv \
    \
    ${@bb.utils.contains('COMBINED_FEATURES', 'alsa', 'alsa-state', '', d)} \
    ${@bb.utils.contains('COMBINED_FEATURES', 'alsa', 'alsa-utils-amixer', '', d)} \
    ${@bb.utils.contains('COMBINED_FEATURES', 'alsa', 'alsa-utils-aplay', '', d)} \
    ${@bb.utils.contains('COMBINED_FEATURES', 'wifi', 'hostapd', '', d)} \
    \
    ${@bb.utils.contains('DISTRO_FEATURES', 'nfs', 'nfs-utils-mount ', '', d)} \
    \
    ${@bb.utils.contains('DISTRO_FEATURES', 'pulseaudio', 'pulseaudio', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'pulseaudio', 'pulseaudio-server', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'pulseaudio', 'pulseaudio-misc', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'pulseaudio', 'pulseaudio-module-combine-sink', '', d)} \
"
