#!/bin/sh
# Licensed on MIT

setup_enabled() {
    return 0
}

setup_run() {
    ROOT_IMAGE="magic.img"
    ROOT_DISK=""
    shelltimeout=30

    if [ -z "$bootparam_root" -o "$bootparam_root" = "/dev/ram0" ]; then
        echo "[INFO]: waiting for removable media..."
        echo ""
        C=0
        while true
        do
            for i in `ls /run/media 2>/dev/null`; do
                if [ -f /run/media/$i/$ROOT_IMAGE ] ; then
                    found="yes"
                    ROOT_DISK="$i"
                    break
                fi
            done
            if [ "$found" = "yes" ]; then
                break;
            fi
            # don't wait for more than $shelltimeout seconds, if it's set
            if [ -n "$shelltimeout" ]; then
                echo -n " " $(( $shelltimeout - $C ))
                if [ $C -ge $shelltimeout ]; then
                    echo "[INFO]: mounted filesystems"
                    echo ""
                    mount | grep media
                    echo "[INFO]: available block devices"
                    echo ""
                    cat /proc/partitions
                    fatal "[ERROR]: cannot find $ROOT_IMAGE file in /run/media/* , dropping to a shell"
                fi
                C=$(( C + 1 ))
            fi
            sleep 1
        done
        # The existing rootfs module has no support for rootfs images. Assign the rootfs image.
        bootparam_root="/run/media/$ROOT_DISK/$ROOT_IMAGE"
    fi

    if [ "$bootparam_LABEL" != "boot" -a -f /init.d/$bootparam_LABEL.sh ]; then
        if [ -f /run/media/$ROOT_DISK/$ROOT_IMAGE ] ; then
            ./init.d/$bootparam_LABEL.sh $ROOT_DISK $ROOT_IMAGE
        else
            fatal "[ERROR]: could not find $bootparam_LABEL script"
        fi
    fi
}
