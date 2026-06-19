#!/bin/sh
# Licensed on MIT

setup_enabled() {
    return 0
}

setup_run() {
    if [ "$bootparam_LABEL" != "boot" ]; then
        if [ "$bootparam_LABEL" = "install" ]; then
            [ -f "/init.d/$bootparam_LABEL.sh" ] && /init.d/$bootparam_LABEL.sh
        elif [ "$bootparam_LABEL" = "recovery" ]; then
            exec setsid cttyhack /bin/sh
        fi
    fi
}
