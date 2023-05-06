# meta-smart

[English][EN],
**简体中文**

[EN]:README.md
[ZH_CN]:README_zh.md

## 摘要

meta-smart是基于yocto提取的一些公共包组, 主要用于简化开发等. 里面包含了一些Linux Standards Base接口, 此外还有移植好的swupdate, 和自动扩展磁盘size的脚, 和用于工厂烧写固件的配置(此功能需要SOC支持SD卡或U盘启动)

有关详细信息，请参阅以下相应部分.

## 依赖

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

## 如何使用

本layer提供了small版本和standard版本, small版是一个最小的工具集合，standard版本在small版本的基础上添加了Qt5基础库和显示后端weston, 后期可能会将weston替换成别的显示后端(或许是我自己基于wlroots库重写的weston-pro). 目前small版本已经在iTop-4412开发部调试好了

- 构建small版本

```shell
$> bitbake smart-image-small
```

- 构建standard版本

```shell
$> bitbake smart-image-standard
```

## 贡献

如果您有提交的修正, 请在本仓库上提 pull requests, 地址是 https://github.com/hyyoxhk/meta-smart/pulls
