# SPDX-License-Identifier: MIT
#
# Copyright (C) 2023 He Yong <hyyoxhk@163.com>
#

SUMMARY = "components core"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

PACKAGES = "${PN}-core ${PN}-extra"
# apt-conf
SUMMARY:${PN}-core = "Core basic tools and libraries"
RDEPENDS:${PN}-core = " \
    at \
    dash \
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
    \
    firmwared \
    db \
    sqlite3 \
    tzdata \
    ntpdate \
    networkmanager \
    \
    libgpiod \
    libiio \
    \
    parted \
    gptfdisk \
    e2fsprogs \
    e2fsprogs-resize2fs \
    resize-helper \
    \
    swupdate \
    u-boot-default-env \
    \
    ${@bb.utils.contains('COMBINED_FEATURES', 'alsa', 'alsa-state', '', d)} \
    ${@bb.utils.contains('COMBINED_FEATURES', 'alsa', 'alsa-utils-amixer', '', d)} \
    ${@bb.utils.contains('COMBINED_FEATURES', 'alsa', 'alsa-utils-aplay', '', d)} \
    ${@bb.utils.contains('COMBINED_FEATURES', 'wifi', 'hostapd', '', d)} \
    \
    ${@bb.utils.contains('DISTRO_FEATURES', 'nfs', 'nfs-utils-mount ', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'systemd-mount-partitions', '', d)} \
    \
    ${@bb.utils.contains('DISTRO_FEATURES', 'pulseaudio', 'pulseaudio', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'pulseaudio', 'pulseaudio-server', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'pulseaudio', 'pulseaudio-misc', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'pulseaudio', 'pulseaudio-module-combine-sink', '', d)} \
"

SUMMARY:${PN}-extra = "extra tools"
RDEPENDS:${PN}-extra = " \
    util-linux-lscpu \
    util-linux-blkid \
    memtester \
    i2c-tools \
    mmc-utils \
    usbutils \
    libgpiod-tools \
    libiio-iiod \
    libiio-tests \
    openssh-sftp     \
    openssh-sftp-server \
    iperf2 \
    ${@bb.utils.contains('COMBINED_FEATURES', 'alsa', 'alsa-state', '', d)} \
    ${@bb.utils.contains('COMBINED_FEATURES', 'alsa', 'alsa-utils-amixer', '', d)} \
    ${@bb.utils.contains('COMBINED_FEATURES', 'alsa', 'alsa-utils-aplay', '', d)} \
"
