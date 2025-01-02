Format: 3.0 (quilt)
Source: gocryptfs
Binary: gocryptfs
Architecture: any
Version: 2.4.0-1ubuntu0.24.04.2~uh~jammy1
Maintainer: Ubuntu Developers <ubuntu-devel-discuss@lists.ubuntu.com>
Uploaders: Felix Lechner <felix.lechner@lease-up.com>, Dmitry Smirnov <onlyjob@debian.org>
Homepage: https://github.com/rfjakob/gocryptfs
Standards-Version: 4.6.2
Vcs-Browser: https://salsa.debian.org/go-team/packages/gocryptfs
Vcs-Git: https://salsa.debian.org/go-team/packages/gocryptfs.git
Testsuite: autopkgtest
Testsuite-Triggers: @builddeps@
Build-Depends: debhelper-compat (= 13), dh-golang, golang-any, golang-github-hanwen-go-fuse-dev (>= 2.1.0+git20220112~), golang-github-jacobsa-crypto-dev (>= 0.0~git20190317.0.9f44e2d+dfsg1), golang-github-moby-sys-dev, golang-github-pkg-xattr-dev (>= 0.4.1), golang-github-rfjakob-eme-dev (>= 1.1.1), golang-github-sabhiram-go-gitignore-dev (>= 1.0.2+git20210923~), golang-github-spf13-pflag-dev, golang-golang-x-crypto-dev, golang-golang-x-sys-dev (>= 0.0~git20200501.0.bc7a7d4), golang-golang-x-term-dev, pandoc, pkg-config, libssl-dev
Package-List:
 gocryptfs deb devel optional arch=any
Checksums-Sha1:
 f969a80b4cfcf5ca869d723f3f4487322ef45b01 1134296 gocryptfs_2.4.0.orig.tar.xz
 5acfac066c7fb39751f8fbc1fa4c6a153cc10d33 10716 gocryptfs_2.4.0-1ubuntu0.24.04.2~uh~jammy1.debian.tar.xz
Checksums-Sha256:
 7cd65c3fd5f02d822432458e82e4c13223a6e959cb6568ffe5313e88c0a81dbe 1134296 gocryptfs_2.4.0.orig.tar.xz
 930946c464918d679bf2c06313d9795926495378b9fd3ee09fa62ee637be0fc1 10716 gocryptfs_2.4.0-1ubuntu0.24.04.2~uh~jammy1.debian.tar.xz
Files:
 c58c300e84ac0667c0ec52b79e3a5ce0 1134296 gocryptfs_2.4.0.orig.tar.xz
 2afb70d223572d38a5e1160f88de3001 10716 gocryptfs_2.4.0-1ubuntu0.24.04.2~uh~jammy1.debian.tar.xz
Go-Import-Path: github.com/rfjakob/gocryptfs
Original-Maintainer: Debian Go Packaging Team <pkg-go-maintainers@lists.alioth.debian.org>
