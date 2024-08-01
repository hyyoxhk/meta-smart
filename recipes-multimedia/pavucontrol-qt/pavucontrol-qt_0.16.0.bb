SUMMARY = "pavucontrol-qt is the Qt port of pulseaudio volume control pavucontrol"
HOMEPAGE = "https://github.com/lxqt/pavucontrol-qt/"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://LICENSE;md5=751419260aa954499f7abaabaa882bbe"

SRC_URI = " \
    git://github.com/lxqt/pavucontrol-qt.git;protocol=https;branch=master \
    file://0001-Cmake-remove-dependency-lxqt.patch \
"
SRCREV = "650876762e4e3f715b3804fa45d66a7377c8eea9"

S = "${WORKDIR}/git"

inherit cmake_qt5 pkgconfig

DEPENDS += "qtbase glib-2.0 pulseaudio qttools qttools-native"

RDEPENDS_${PN} += "pulseaudio-server"
