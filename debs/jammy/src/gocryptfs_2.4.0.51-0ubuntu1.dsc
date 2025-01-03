Format: 3.0 (quilt)
Source: gocryptfs
Binary: gocryptfs
Architecture: any
Version: 2.4.0.51-0ubuntu1
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
 1d70a44263195ec3e9a5fd606b17312a8efa3909 1379405 gocryptfs_2.4.0.51.orig.tar.gz
 baebb348cb20f45684f5202a49df54a481990821 10748 gocryptfs_2.4.0.51-0ubuntu1.debian.tar.xz
Checksums-Sha256:
 86f21b91579cf7f8d7e0ecf922a34c3346b29382e8bac2a3f7100698cf545372 1379405 gocryptfs_2.4.0.51.orig.tar.gz
 5eb38d73e2a4b72472890075c7cb9f115050cde3e4b84581516a76c3dce2f548 10748 gocryptfs_2.4.0.51-0ubuntu1.debian.tar.xz
Files:
 967aa5187672ca63aaf97cede7d31faf 1379405 gocryptfs_2.4.0.51.orig.tar.gz
 65cd5d9557ef2f987f61ad7492018362 10748 gocryptfs_2.4.0.51-0ubuntu1.debian.tar.xz
Go-Import-Path: github.com/rfjakob/gocryptfs
Original-Maintainer: Debian Go Packaging Team <pkg-go-maintainers@lists.alioth.debian.org>
