# Copyright (C) 2022 He Yong <hyyoxhk@163.com>

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

DEPENDS += "pcsc-lite readline"

SRC_URI += " \
    file://wpa_ctrl.h \
    file://0001-nl80211-add-extra-ies-only-if-allowed-by-driver.patch \
    file://02_dbus_group_policy.patch \
    file://07_dbus_service_syslog.patch \
    file://allow-legacy-renegotiation.patch \
    file://allow-tlsv1.patch \
    file://disable-eapol-werror.patch \
    file://lower_security_level_for_tls_1.patch \
    file://manpage-replace-wheel-with-netdev.patch \
    file://systemd-add-reload-support.patch \
    file://wpa_service_ignore-on-isolate.patch \
    file://0001-Use-pkg-config-for-libpcsclite-compiler-flags.patch \
    "

do_compile:append() {
    oe_runmake libwpa_client.so -C wpa_supplicant
}

do_install:append() {
    install -d ${D}${nonarch_libdir}
    install -m 644 ${S}/wpa_supplicant/libwpa_client.so ${D}${libdir}/libwpa_client.so.${PV}
    ln -sf libwpa_client.so.${PV} ${D}${libdir}/libwpa_client.so

    install -d ${D}${includedir}
    install -m 644 ${WORKDIR}/wpa_ctrl.h ${D}${includedir}
}
