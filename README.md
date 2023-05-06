# meta-smart

**English**,
[简体中文][ZH_CN]

[EN]:README.md
[ZH_CN]:README_zh.md

## Summary

meta-smart is a group of public packages extracted based on yocto, mainly used to simplify development. It contains some standard Linux Standards Base interfaces. in addition to ported swupdate, and scripts for autoresize disk size, and for Factory burning firmware configuration (this function requires the SOC to support SD card or U disk boot)

## Dependencies

[YOCTO]

URI: https://git.yoctoproject.org/poky

branch: same dedicated branch as meta-smart

[meta-openembedded]

URI: https://github.com/openembedded/meta-openembedded.git

[meta-qt5]

URI: https://github.com/meta-qt5/meta-qt5.git

branch: same dedicated branch as meta-smart

[meta-swupdate]

URI: https://github.com/sbabic/meta-swupdate.git

branch: same dedicated branch as meta-smart

## How to use

this layer provides a small version and a standard version. The small version is a minimal set of tools, The standard version adds the Qt5 basic library and display backend weston based on the small version. Weston may be replaced with other display backends in the future. (Perhaps it is weston-pro that I rewrote based on the wlroots library). At present, the small version has been debugged in the iTop-4412 development department

- build small

```shell
$> bitbake smart-image-small
```

- build standard

```shell
$> bitbake smart-image-standard
```

# Contributing

If you want to contribute changes, you can send Github pull requests at https://github.com/hyyoxhk/meta-smart/pulls
