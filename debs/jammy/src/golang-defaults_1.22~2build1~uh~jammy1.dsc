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
 a341ebe9a374cd508e9d71163df893e8c2939561 31192 golang-defaults_1.22~2build1~uh~jammy1.tar.xz
Checksums-Sha256:
 9f41e9cbc97f161a7151f5faeaf816ffed47ce2066dfb5f465cb771ac3e53c8a 31192 golang-defaults_1.22~2build1~uh~jammy1.tar.xz
Files:
 04e34fcb7e903834c389295c8c4ed613 31192 golang-defaults_1.22~2build1~uh~jammy1.tar.xz
Original-Maintainer: Debian Go Compiler Team <team+go-compiler@tracker.debian.org>
