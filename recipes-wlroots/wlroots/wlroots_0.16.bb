SUMMARY = "A modular Wayland compositor library"
DESCRIPTION = "Pluggable, composable, unopinionated modules for building a \
Wayland compositor; or about 50,000 lines of code you were \
going to write anyway."
HOMEPAGE = "https://gitlab.freedesktop.org/wlroots"
BUGTRACKER = "https://gitlab.freedesktop.org/wlroots/wlroots/-/issues"
SECTION = "graphics"
LICENSE = "MIT & CC0-1.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=7578fad101710ea2d289ff5411f1b818"
LIC_FILES_CHKSUM += "file://tinywl/LICENSE;md5=d957da0415f5b0b974bfc6063afab2b5"

REQUIRED_DISTRO_FEATURES = "wayland"

DEPENDS = "hwdata-native libdrm libxkbcommon pixman seatd wayland wayland-native wayland-protocols"

SRC_URI = "git://gitlab.freedesktop.org/wlroots/wlroots.git;branch=0.16;protocol=https \
           file://0001-Extensions-used-by-wlroots-copied-from-weston-s-shar.patch \
"
SRCREV = "0a32b5a74db06a27bee55a47205951bb277a9657"

S = "${WORKDIR}/git"
PV = "0.16.2"

inherit meson pkgconfig features_check

EXTRA_OEMESON += "-Dexamples=false"

PACKAGECONFIG ?= "${@bb.utils.filter('DISTRO_FEATURES', 'systemd sysvinit vulkan x11 xwayland opengl', d)} \
                  libinput"

PACKAGECONFIG[opengl] = ",,virtual/egl virtual/libgles2"
PACKAGECONFIG[gbm] = ",,virtual/libgbm"
PACKAGECONFIG[libinput] = ",,libinput"
PACKAGECONFIG[systemd] = ",,systemd"
PACKAGECONFIG[sysvinit] = ",,eudev elogind"
PACKAGECONFIG[vulkan] = ",,vulkan-loader vulkan-headers glslang-native"
PACKAGECONFIG[x11] = ",,xcb-util-renderutil"
PACKAGECONFIG[xwayland] = "-Dxwayland=enabled,-Dxwayland=disabled,xwayland xcb-util-wm,xwayland"
