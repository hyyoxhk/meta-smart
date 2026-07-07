#!/bin/sh
# Licensed on MIT

PATH=/sbin:/bin:/usr/sbin:/usr/bin

RESIZE_MARKER=".ramdisk-resize-done"
RESIZE_MOUNT="/run/resize-datafs"

resize_enabled() {
    [ "${bootparam_root}" = "/dev/nfs" ] && return 1

    [ "$(whoami)" = "root" ] || fatal "resize: must run as root"

    for tool in sgdisk parted partprobe resize2fs e2fsck realpath lsblk blkid awk sed sort tail; do
        command -v "${tool}" >/dev/null 2>&1 || fatal "resize: missing ${tool}"
    done

    return 0
}

resize_mount_datafs() {
    mkdir -p "${RESIZE_MOUNT}"
    mount -t ext4 -o rw "${1}" "${RESIZE_MOUNT}"
}

resize_root_device() {
    case "${bootparam_root}" in
        UUID=*)
            realpath "/dev/disk/by-uuid/${bootparam_root#UUID=}"
            ;;
        PARTUUID=*)
            realpath "/dev/disk/by-partuuid/${bootparam_root#PARTUUID=}"
            ;;
        PARTLABEL=*)
            realpath "/dev/disk/by-partlabel/${bootparam_root#PARTLABEL=}"
            ;;
        LABEL=*)
            realpath "/dev/disk/by-label/${bootparam_root#LABEL=}"
            ;;
        *)
            realpath "${bootparam_root}"
            ;;
    esac
}

resize_disk_from_partition() {
    local part_name disk_name

    part_name="$(basename "${1}")"
    [ -r "/sys/class/block/${part_name}/partition" ] || return 1

    disk_name="$(basename "$(readlink -f "/sys/class/block/${part_name}/..")")"
    [ -b "/dev/${disk_name}" ] || return 1

    echo "/dev/${disk_name}"
}

resize_last_partition_number() {
    lsblk -lnpo NAME,TYPE "${1}" \
        | awk '$2=="part"{print $1}' \
        | sed "s/.*[^0-9]\([0-9]\+\)$/\1/" \
        | sort -n \
        | tail -1
}

resize_partition_device() {
    local disk part_num part_prefix

    disk="${1}"
    part_num="${2}"
    part_prefix=""

    if [ ! "${disk#/dev/mmcblk}" = "${disk}" ] || \
       [ ! "${disk#/dev/nvme}" = "${disk}" ]; then
        part_prefix="p"
    fi

    echo "${disk}${part_prefix}${part_num}"
}

resize_fix_partition_table() {
    local pttype

    pttype="$(blkid -p -s PTTYPE -o value "${1}" 2>/dev/null)"

    case "${pttype}" in
        gpt)
            # The image was dd'ed from a smaller wic file, so move the backup GPT first.
            sgdisk -e "${1}" || fatal "resize: failed to relocate backup GPT on ${1}"
            ;;
        dos|msdos)
            ;;
        *)
            fatal "resize: unsupported partition table type on ${1}: ${pttype}"
            ;;
    esac
}

resize_run() {
    local root_dev data_dev

    echo "RESIZE-HELPER START" >/dev/kmsg

    root_dev="$(resize_root_device)" || fatal "resize: cannot resolve root device from bootparam_root"
    [ -b "${root_dev}" ] || fatal "resize: root device ${root_dev} is not a block device"

    RESIZE_DISK="$(resize_disk_from_partition "${root_dev}")" || \
        fatal "resize: cannot resolve parent disk for ${root_dev}"

    RESIZE_PART_NUM="$(resize_last_partition_number "${RESIZE_DISK}")"
    [ -n "${RESIZE_PART_NUM}" ] || fatal "resize: cannot find last partition on ${RESIZE_DISK}"

    data_dev="$(resize_partition_device "${RESIZE_DISK}" "${RESIZE_PART_NUM}")"
    [ -b "${data_dev}" ] || fatal "resize: data partition ${data_dev} is not a block device"

    resize_mount_datafs "${data_dev}" || fatal "resize: cannot mount ${data_dev}"
    if [ -e "${RESIZE_MOUNT}/${RESIZE_MARKER}" ]; then
        umount "${RESIZE_MOUNT}"
        echo "RESIZE-HELPER SKIP" >/dev/kmsg
        return 0
    fi
    umount "${RESIZE_MOUNT}" || fatal "resize: cannot unmount ${data_dev}"

    resize_fix_partition_table "${RESIZE_DISK}"

    parted -s "${RESIZE_DISK}" resizepart "${RESIZE_PART_NUM}" 100% || \
        fatal "resize: failed to resize partition ${RESIZE_PART_NUM} on ${RESIZE_DISK}"

    partprobe "${RESIZE_DISK}" >/dev/null 2>&1 || true
    blockdev --rereadpt "${RESIZE_DISK}" >/dev/null 2>&1 || true
    command -v udevadm >/dev/null 2>&1 && udevadm settle

    e2fsck -f -y "${data_dev}" || fatal "resize: e2fsck failed on ${data_dev}"
    resize2fs "${data_dev}" || fatal "resize: resize2fs failed on ${data_dev}"

    resize_mount_datafs "${data_dev}" || fatal "resize: cannot remount ${data_dev}"
    touch "${RESIZE_MOUNT}/${RESIZE_MARKER}" || fatal "resize: cannot write resize marker"
    sync
    umount "${RESIZE_MOUNT}" || fatal "resize: cannot unmount ${data_dev} after marker write"

    echo "RESIZE-HELPER FINISH" >/dev/kmsg
}
