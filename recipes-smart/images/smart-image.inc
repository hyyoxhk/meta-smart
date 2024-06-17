rootfs_reversion () {
    echo ${IMAGE_VERSION} > ${IMAGE_ROOTFS}/etc/reversion
    bbnote "rootfs_reversion: set /etc/reversion to ${IMAGE_VERSION}"
}
ROOTFS_POSTPROCESS_COMMAND:append = "rootfs_reversion;"

zap_empty_weston_password () {
    if [ -e ${IMAGE_ROOTFS}/etc/shadow ]; then
        sed -i 's%^weston:!:%weston::%' ${IMAGE_ROOTFS}/etc/shadow
    fi
}
ROOTFS_POSTPROCESS_COMMAND:append = "zap_empty_weston_password;"
