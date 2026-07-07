#!/bin/sh
# Licensed on MIT

PATH=/sbin:/bin:/usr/sbin:/usr/bin

setup_enabled() {
    return 0
}

setup_mount_tmpfs() {
    local target opts

    target="$1"
    opts="$2"

    mkdir -p "$target"
    mountpoint -q "$target" && return 0

    mount -t tmpfs -o "$opts" tmpfs "$target" || \
        info "setup: failed to mount tmpfs on $target"
}

setup_mount_tmpfses() {
    if [ -d /run/udev ] && ! mountpoint -q /run; then
        info "setup: /run has udev state, skipping late tmpfs mount"
    else
        setup_mount_tmpfs /run "mode=0755,nodev,nosuid,strictatime"
    fi

    setup_mount_tmpfs /tmp "mode=1777,nodev,nosuid"
    setup_mount_tmpfs /var/volatile "defaults"
    setup_mount_tmpfs /dev/shm "mode=1777,nodev,nosuid,noexec"

    mkdir -p /run/lock /var/lock
}

setup_run() {
    setup_mount_tmpfses

    if [ "$bootparam_LABEL" != "boot" ]; then
        if [ "$bootparam_LABEL" = "install-efi" -a "$bootparam_root" = "/dev/ram0" ]; then
            [ -f "/init.d/$bootparam_LABEL.sh" ] && /init.d/$bootparam_LABEL.sh
        elif [ "$bootparam_LABEL" = "recovery" -a "$bootparam_root" = "/dev/ram0" ]; then
            exec setsid cttyhack /bin/sh
        fi
    fi
}
