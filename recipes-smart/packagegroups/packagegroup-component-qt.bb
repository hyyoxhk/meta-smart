# SPDX-License-Identifier: MIT
#
# Copyright (C) 2024 He Yong <hyyoxhk@163.com>
#

SUMMARY = "Framework sample qt components"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

PACKAGES = "${PN}-base ${PN}-fonts ${PN}-extra"

SUMMARY:${PN}-base = "Qt base"
RDEPENDS:${PN}-base = " \
    qtbase                          \
    qtbase-plugins                  \
    \
    qtdeclarative                   \
    qtdeclarative-qmlplugins        \
    \
    qtgraphicaleffects-qmlplugins   \
    \
    qtmultimedia                    \
    qtmultimedia-plugins            \
    qtmultimedia-qmlplugins         \
    \
    qtscript                        \
    qttranslations                  \
    qtwayland                       \
    qtwayland-plugins               \
    "

SUMMARY:${PN}-fonts = "Qt fonts"
RDEPENDS:${PN}-fonts = " \
    ttf-dejavu-common \
    ttf-dejavu-sans \
    ttf-dejavu-sans-mono \
    ttf-dejavu-serif \
    source-han-sans-cn-fonts \
    "

SUMMARY:${PN}-extra = "Qt extra"
RDEPENDS:${PN}-extra = " \
    qtsvg                           \
    qtsvg-plugins                   \
    \
    qtlocation                      \
    qtlocation-qmlplugins           \
    qtlocation-plugins              \
    \
    qtquickcontrols                 \
    qtquickcontrols-qmlplugins      \
    qtquickcontrols2                \
    qtquickcontrols2-qmlplugins     \
    \
    qtsensors                       \
    qtserialport                    \
    \
    qtcharts                        \
    qtcharts-qmlplugins             \
    \
    qtvirtualkeyboard               \
    "
