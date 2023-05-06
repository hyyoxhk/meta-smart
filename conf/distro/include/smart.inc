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

# Append distro name to each image name
IMAGE_BASENAME:append = "-${DISTRO}"

SDK_VENDOR = "-smartsdk"
SDK_VERSION := "${@'${DISTRO_VERSION}'.replace('snapshot-${DATE}','snapshot')}"
SDK_VERSION[vardepsexclude] = "DATE"

SDK_NAME = "${DISTRO}-${SDK_ARCH}"
SDKPATHINSTALL = "/opt/${DISTRO}"

IMAGE_LINGUAS = "en-us"

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

DISTRO_FEATURES_FILTER_NATIVESDK = "wayland"

# add support of gstreamer
#DISTRO_FEATURES += "gstreamer"

# Disabling pulseaudio
DISTRO_FEATURES += "pulseaudio"

# add support of splashscreen
#DISTRO_FEATURES += "splashscreen"

# systemd support
DISTRO_FEATURES += "polkit"
INIT_MANAGER = "systemd"

# X11 addons
DISTRO_EXTRA_RDEPENDS:append = " ${@bb.utils.contains('DISTRO_FEATURES', 'x11', 'xf86-video-modesetting', '', d)} "

ROOT_HOME = "/root"

INITRD_IMAGE ?= "smart-image-initrd"
INITRD_SHORTNAME ?= "initrd.img"

IMAGE_BOOT_FILES += " \
    ${DEPLOY_DIR_IMAGE}/${INITRD_IMAGE}-${DISTRO}-${MACHINE}.${INITRAMFS_FSTYPES};${INITRD_SHORTNAME} \
    "
