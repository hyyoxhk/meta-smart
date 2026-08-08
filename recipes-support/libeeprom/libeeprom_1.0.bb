SUMMARY = "EEPROM layout parsing and access library"
DESCRIPTION = "libeeprom reads, decodes and updates EEPROM fields using JSON"
DESCRIPTION += "layout descriptions."
HOMEPAGE = "https://github.com/hyyoxhk/libeeprom"
SECTION = "libs"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = " \
	file://LICENSES/GPL-2.0-only;md5=a23a74b3f4caf9616230789d94217acb \
"

SRC_URI = "git://github.com/hyyoxhk/libeeprom.git;protocol=https;branch=main"
SRCREV = "79e190d73e60c2d0f18e1737f12ad8a2b92d0171"

S = "${WORKDIR}/git"

inherit meson pkgconfig

DEPENDS = "json-c"

PACKAGECONFIG ??= ""
PACKAGECONFIG[write] = "-Denable-write=true,-Denable-write=false"

FILES:${PN} += "${sysconfdir}/eeprom"
