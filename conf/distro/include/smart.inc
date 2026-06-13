# SPDX-License-Identifier: MIT
#
# Copyright (C) 2023 He Yong <hyyoxhk@163.com>
#

require conf/distro/include/no-static-libs.inc
require conf/distro/include/yocto-uninative.inc
INHERIT += "uninative"

DISTRO = "smart"
DISTRO_NAME = "smart (Yocto Project Based Distro)"

DISTRO_VERSION = "4.0.9"
DISTRO_VERSION[vardepsexclude] = "DATE"

DISTRO_CODENAME = "kirkstone"

MAINTAINER = "He Yong <hyyoxhk@163.com>"

TARGET_VENDOR = "-smart"

LOCALCONF_VERSION = "1"

SDK_VENDOR = "-smartsdk"
SDK_VERSION := "${@'${DISTRO_VERSION}'.replace('snapshot-${DATE}','snapshot')}"
SDK_VERSION[vardepsexclude] = "DATE"

SDK_NAME = "${DISTRO}-${SDK_ARCH}"
SDKPATHINSTALL = "/opt/${DISTRO}"

TOOLCHAIN_HOST_TASK:append = " packagegroup-rust-cross-canadian-${MACHINE}"
TOOLCHAIN_HOST_TASK:append = " packagegroup-go-cross-canadian-${MACHINE}"

# DISTRO features
# =========================================================================
DISTRO_FEATURES  = "alsa"
DISTRO_FEATURES += "argp"
DISTRO_FEATURES += "ext2"
DISTRO_FEATURES += "ext4"
DISTRO_FEATURES += "largefile"
DISTRO_FEATURES += "ipv4"
DISTRO_FEATURES += "ipv6"
DISTRO_FEATURES += "multiarch"
DISTRO_FEATURES += "wifi"
DISTRO_FEATURES += "nfs"
DISTRO_FEATURES += "usbgadget"
DISTRO_FEATURES += "usbhost"
DISTRO_FEATURES += "xattr"
DISTRO_FEATURES += "zeroconf"
DISTRO_FEATURES += "bluetooth"
DISTRO_FEATURES += "bluez5"
DISTRO_FEATURES += "pam"
DISTRO_FEATURES += "acl"
DISTRO_FEATURES += "pci"

DISTRO_FEATURES_FILTER_NATIVESDK = "wayland"

# add support of gstreamer
#DISTRO_FEATURES += "gstreamer"

# Disabling pulseaudio
DISTRO_FEATURES += "pulseaudio"

# add support of KDE (since OE thud version)
DISTRO_FEATURES += " kde"

# add support of splashscreen
#DISTRO_FEATURES += "splashscreen"

# systemd support
DISTRO_FEATURES += "polkit"
INIT_MANAGER = "systemd"

# =========================================================================
# Preferred version
# =========================================================================

PREFERRED_VERSION_libdrm ?= "2.4.115"
PREFERRED_VERSION_mtdev ?= "1.1.6"
PREFERRED_VERSION_libinput ?= "1.22.1"
PREFERRED_VERSION_wayland-protocols ?= "1.31"
PREFERRED_VERSION_wayland ?= "1.21.0"

# X11 addons
DISTRO_EXTRA_RDEPENDS:append = " ${@bb.utils.contains('DISTRO_FEATURES', 'x11', 'xf86-video-modesetting', '', d)} "

ROOT_HOME = "/root"

INITRAMFS_IMAGE ?= "smart-image-initrd"
INITRAMFS_SHORTNAME ?= "initrd.img"

IMAGE_BOOT_FILES += " \
    ${DEPLOY_DIR_IMAGE}/${INITRAMFS_IMAGE}-${MACHINE}.${INITRAMFS_FSTYPES};${INITRAMFS_SHORTNAME} \
    "
