Format: 3.0 (native)
Source: golang-defaults
Binary: golang-go, golang-any, gccgo-go, golang-src, golang-doc, golang
Architecture: any all
Version: 2:1.22~2build1~uh~jammy1
Maintainer: Ubuntu Developers <ubuntu-devel-discuss@lists.ubuntu.com>
Uploaders: Michael Stapelberg <stapelberg@debian.org>, Paul Tagliamonte <paultag@debian.org>, Tianon Gravi <tianon@debian.org>, Michael Hudson-Doyle <mwhudson@debian.org>, Martina Ferrari <tina@debian.org>, Dr. Tobias Quathamer <toddy@debian.org>, Anthony Fok <foka@debian.org>
Homepage: https://golang.org
Standards-Version: 4.6.2
Vcs-Browser: https://salsa.debian.org/go-team/compiler/golang-defaults
Vcs-Git: https://salsa.debian.org/go-team/compiler/golang-defaults.git
Build-Depends: debhelper-compat (= 13), dh-exec
Package-List:
 gccgo-go deb golang optional arch=any
 golang deb golang optional arch=amd64,arm64,armel,armhf,i386,mips,mips64el,mipsel,ppc64el,riscv64,s390x
 golang-any deb golang optional arch=any
 golang-doc deb doc optional arch=all
 golang-go deb golang optional arch=amd64,arm64,armel,armhf,i386,mips,mips64el,mipsel,ppc64,ppc64el,riscv64,s390x
 golang-src deb golang optional arch=all
Checksums-Sha1:
 a331118e50e5da353e0e0e2919f78782078d8294 31200 golang-defaults_1.22~2build1~uh~jammy1.tar.xz
Checksums-Sha256:
 8c586c4fd662d78c56eda2c2d1353cb0f0348f1505ba073a0ebdd522deef7d19 31200 golang-defaults_1.22~2build1~uh~jammy1.tar.xz
Files:
 03525809eeb460c2d7fa17db8d1b2b47 31200 golang-defaults_1.22~2build1~uh~jammy1.tar.xz
Original-Maintainer: Debian Go Compiler Team <team+go-compiler@tracker.debian.org>
