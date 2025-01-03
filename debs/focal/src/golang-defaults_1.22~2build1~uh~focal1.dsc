Format: 3.0 (native)
Source: golang-defaults
Binary: golang-go, golang-any, gccgo-go, golang-src, golang-doc, golang
Architecture: any all
Version: 2:1.22~2build1~uh~focal1
Maintainer: Ubuntu Developers <ubuntu-devel-discuss@lists.ubuntu.com>
Uploaders: Michael Stapelberg <stapelberg@debian.org>, Paul Tagliamonte <paultag@debian.org>, Tianon Gravi <tianon@debian.org>, Michael Hudson-Doyle <mwhudson@debian.org>, Martina Ferrari <tina@debian.org>, Dr. Tobias Quathamer <toddy@debian.org>, Anthony Fok <foka@debian.org>
Homepage: https://golang.org
Standards-Version: 4.6.2
Vcs-Browser: https://salsa.debian.org/go-team/compiler/golang-defaults
Vcs-Git: https://salsa.debian.org/go-team/compiler/golang-defaults.git
Build-Depends: debhelper-compat (= 12), dh-exec
Package-List:
 gccgo-go deb golang optional arch=any
 golang deb golang optional arch=amd64,arm64,armel,armhf,i386,mips,mips64el,mipsel,ppc64el,riscv64,s390x
 golang-any deb golang optional arch=any
 golang-doc deb doc optional arch=all
 golang-go deb golang optional arch=amd64,arm64,armel,armhf,i386,mips,mips64el,mipsel,ppc64,ppc64el,riscv64,s390x
 golang-src deb golang optional arch=all
Checksums-Sha1:
 ef54cd65fc3566c2ca23391be630083d06786bba 31192 golang-defaults_1.22~2build1~uh~focal1.tar.xz
Checksums-Sha256:
 5d70837a22310ac00d6781e6e931ec5cf186fb83ca07b0bd0b29ec33a04e4465 31192 golang-defaults_1.22~2build1~uh~focal1.tar.xz
Files:
 c1f0f32281c7239f905cefd89d620907 31192 golang-defaults_1.22~2build1~uh~focal1.tar.xz
Original-Maintainer: Debian Go Compiler Team <team+go-compiler@tracker.debian.org>
