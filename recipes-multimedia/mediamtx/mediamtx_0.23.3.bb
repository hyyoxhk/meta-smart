SUMMARY = "MediaMTX / rtsp-simple-server is a ready-to-use and zero-dependency server and proxy that allows users to publish, read and proxy live video and audio streams."
GO_IMPORT = "github.com/bluenviron/mediamtx"
HOMEPAGE = "https://${GO_IMPORT}"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://src/${GO_IMPORT}/LICENSE;md5=77fd2623bd5398430be5ce60489c2e81"

SRC_URI = "git://${GO_IMPORT};branch=main;protocol=https"
SRCREV = "99aa0d0ac9955d5a6abb86fa1e966b7ab74b9dbd"

GO_INSTALL = "${GO_IMPORT}"
do_compile[network] = "1"

do_compile:prepend () {
    export GOPROXY="https://goproxy.cn,direct"
}

# build executable instead of shared object
GO_LINKSHARED = ""
GOBUILDFLAGS:remove = "-buildmode=pie"

inherit go-mod
