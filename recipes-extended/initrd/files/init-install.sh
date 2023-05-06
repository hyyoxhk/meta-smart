#!/bin/sh -e
#
# Copyright (C) 2008-2011 Intel
#
# install.sh [device_name] [rootfs_name]
#

PATH=/sbin:/bin:/usr/sbin:/usr/bin

# Get a list of hard drives
hdnamelist=""
live_dev_name=`cat /proc/mounts | grep ${1%/} | awk '{print $1}'`
live_dev_name=${live_dev_name#\/dev/}

dev_attr=""
case $live_dev_name in
    mmcblk*)
        dev_attr="sdcard"
        ;;
    sd*)
        dev_attr="udisk"
        ;;
    *)
        dev_attr="none"
    ;;
esac

# Only strip the digit identifier if the device is not an mmc
case $live_dev_name in
    nvme*)
        ;;
    *)
        if [ "$dev_attr" = "sdcard" ]; then
            live_dev_name=${live_dev_name%p*}
        elif [ "$dev_attr" = "udisk" ]; then
            live_dev_name=${live_dev_name%%[0-9]*}
        else
            echo "[ERROR]: unknown device, not currently supported !!!"
        fi
        ;;
esac

echo "[INFO]: searching for hard drives ..."
echo ""

# Some eMMC devices have special sub devices such as mmcblk0boot0 etc
# we're currently only interested in the root device so pick them wisely
devices=`ls /sys/block/ | grep -v mmcblk` || true
mmc_devices=`ls /sys/block/ | grep "mmcblk[0-9]\{1,\}$"` || true
devices="$devices $mmc_devices"

for device in $devices; do
    case $device in
        loop*)
            # skip loop device
            ;;
        sr*)
            # skip CDROM device
            ;;
        ram*)
            # skip ram device
            ;;
        *)
            # skip the device LiveOS is on
            # Add valid hard drive name to the list
            case $device in
                $live_dev_name*)
                # skip the device we are running from
                ;;
                *)
                    hdnamelist="$hdnamelist $device"
                ;;
            esac
            ;;
    esac
done

TARGET_DEVICE_NAME=""
for hdname in $hdnamelist; do
    # Display found hard drives and their basic info
    echo "-------------------------------"
    echo /dev/$hdname
    if [ -r /sys/block/$hdname/device/vendor ]; then
        echo -n "VENDOR="
        cat /sys/block/$hdname/device/vendor
    fi
    if [ -r /sys/block/$hdname/device/model ]; then
        echo -n "MODEL="
        cat /sys/block/$hdname/device/model
    fi
    if [ -r /sys/block/$hdname/device/uevent ]; then
        echo -n "UEVENT="
        cat /sys/block/$hdname/device/uevent
    fi
    echo
done

# Get user choice
while true; do
    echo "Please select an install target or press n to exit ($hdnamelist ): "
    read answer
    if [ "$answer" = "n" ]; then
        echo "[WARNING]: installation manually aborted."
        exit 1
    fi
    for hdname in $hdnamelist; do
        if [ "$answer" = "$hdname" ]; then
            TARGET_DEVICE_NAME=$answer
            break
        fi
    done
    if [ -n "$TARGET_DEVICE_NAME" ]; then
        break
    fi
done

if [ -n "$TARGET_DEVICE_NAME" ]; then
    echo "[INFO]: installing image on /dev/$TARGET_DEVICE_NAME ..."
    echo ""
else
    echo "[ERROR]: No hard drive selected. Installation aborted."
    echo ""
    exit 1
fi

device=/dev/${TARGET_DEVICE_NAME}

#
# The udev automounter can cause pain here, kill it
#
rm -f /etc/udev/rules.d/automount.rules
rm -f /etc/udev/scripts/mount*

#
# Unmount anything the automounter had mounted
#
umount ${device}* 2> /dev/null || /bin/true

echo "[WARNING]: formatting the disk ..."
echo ""
mkfs.vfat ${device} -I &> /dev/null

echo "[WARNING]: writing data, do not power off ..."
echo ""
dd if=/run/media/$1/$2 of=${device} bs=8M conv=fdatasync status=progress
sync
echo "[SUCCESS]: writing data is complete..."
echo ""

echo "Remove your installation media, and press ENTER"
read enter
echo ""
echo "Rebooting..."
reboot -f
