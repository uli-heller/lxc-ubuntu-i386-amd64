-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA512

Format: 3.0 (native)
Source: golang-defaults
Binary: golang-go, golang-any, gccgo-go, golang-src, golang-doc, golang
Architecture: any all
Version: 2:1.22~2build1
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
 3c38f2c6ebd4031a01675a646c9995ad9d760472 31144 golang-defaults_1.22~2build1.tar.xz
Checksums-Sha256:
 7c1cf2f07e4f7efe56a7640a171171f01db549390d85575576b5d7c18c129fee 31144 golang-defaults_1.22~2build1.tar.xz
Files:
 e490f35a1aeff5368b722ba0d91f6e39 31144 golang-defaults_1.22~2build1.tar.xz
Original-Maintainer: Debian Go Compiler Team <team+go-compiler@tracker.debian.org>

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCgAdFiEEoIn7Nqr72tWswTJQafeQFxohCYQFAmYKSvUACgkQafeQFxoh
CYTLJg/9FH1nNtXjVv+YoAYRvQhzZYJmEBPxt7tsenciZ6HpGNO5fayUzBk32J/T
CbEeYKmzk1b5KRS4Uz2r6jOy1HDoS8+PW2q38+uTjijxQM4llqGI97QiRX1WX5ad
CqU8t4piZEUZGhsQYmfxjU5erussxcBPK/nNMokADJETOe1TuSZMc7Gd+YzDLqee
doMo6OeRTF/m3dT2T2apjlopMG6kTtq80llY2n5h+0SGAQdVSnB6oQ9VZIldBcQM
4+9NdK8pmhezxLsItgLt1arGyTA1fb7DrBTwEgOLUMWamHuc1yjkCXbyIDUiNgSw
bc0l63GGMtSq9KeXZoDYm6+ybWf7oF0Rux8nPNrYmLlpTglKdXQQDXegwjOK6QlE
7CHCLVvPLISu7AOQdDhCSxwk1hwnaaQI0NWoy/JySgA21ZrppvoleuefINhsx+Ba
3w/vF6gmIKIz9t3f6jdXjkRuF+MlpqYUVmiOdHdiIjSfKMkGFps5uX0z4bkgZZ5x
upOHn6+T+cVDXcp0Mnz+RlRTydCGeYr34O72qtBJmGm3vZLNvW7LPqcZkRGj9kvd
jRwaidzm6/6i+FP5j45WrcjCPIOgdwCdIXsBZDZxZ4XdG1/aqj0GjUxFowd4fl6+
2ZmmQZxsO6LVUBPQbn3UHXb6dRcYCSb15zcGoLQxM8whCtGMQDs=
=yvQP
-----END PGP SIGNATURE-----
