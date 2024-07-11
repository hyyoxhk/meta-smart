# SPDX-License-Identifier: MIT
#
# Copyright (C) 2023 He Yong <hyyoxhk@163.com>
#

do_install:append () {
    sed -i 's/# \(%sudo	ALL=(ALL:ALL) ALL\)/\1/' ${D}${sysconfdir}/sudoers
}
