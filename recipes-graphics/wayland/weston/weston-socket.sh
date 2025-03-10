#!/bin/sh

if [ -z $XDG_RUNTIME_DIR ]; then
    XDG_RUNTIME_DIR=/run/user/`id -u`
    if [ -e $XDG_RUNTIME_DIR ]; then
        export XDG_RUNTIME_DIR
        if [ -e $XDG_RUNTIME_DIR/wayland-0 ]; then
            export WAYLAND_DISPLAY=wayland-0
        fi
        if [ -e $XDG_RUNTIME_DIR/wayland-1 ]; then
            export WAYLAND_DISPLAY=wayland-1
        fi
    fi
fi
