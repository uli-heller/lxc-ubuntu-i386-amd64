Format: 3.0 (quilt)
Source: gocryptfs
Binary: gocryptfs
Architecture: any
Version: 2.4.0.51-1ubuntu0.24.04.2~uh~jammy1
Maintainer: Ubuntu Developers <ubuntu-devel-discuss@lists.ubuntu.com>
Uploaders: Felix Lechner <felix.lechner@lease-up.com>, Dmitry Smirnov <onlyjob@debian.org>
Homepage: https://github.com/rfjakob/gocryptfs
Standards-Version: 4.6.2
Vcs-Browser: https://salsa.debian.org/go-team/packages/gocryptfs
Vcs-Git: https://salsa.debian.org/go-team/packages/gocryptfs.git
Testsuite: autopkgtest
Testsuite-Triggers: @builddeps@
Build-Depends: debhelper-compat (= 13), dh-golang, golang-github-hanwen-go-fuse-dev (>= 2.1.0+git20220112~), golang-github-jacobsa-crypto-dev (>= 0.0~git20190317.0.9f44e2d+dfsg1), golang-github-moby-sys-dev, golang-github-pkg-xattr-dev (>= 0.4.1), golang-github-rfjakob-eme-dev (>= 1.1.1), golang-github-sabhiram-go-gitignore-dev (>= 1.0.2+git20210923~), golang-github-spf13-pflag-dev, golang-golang-x-crypto-dev, golang-golang-x-sys-dev (>= 0.0~git20200501.0.bc7a7d4), golang-golang-x-term-dev, pandoc, pkg-config, libssl-dev
Package-List:
 gocryptfs deb devel optional arch=any
Checksums-Sha1:
 1d70a44263195ec3e9a5fd606b17312a8efa3909 1379405 gocryptfs_2.4.0.51.orig.tar.gz
 346a625465ebdb3359d5cd799d4947c33f987afa 10748 gocryptfs_2.4.0.51-1ubuntu0.24.04.2~uh~jammy1.debian.tar.xz
Checksums-Sha256:
 86f21b91579cf7f8d7e0ecf922a34c3346b29382e8bac2a3f7100698cf545372 1379405 gocryptfs_2.4.0.51.orig.tar.gz
 90a12149a8d4c2317b59af7299925835bbdddc40bcc7afaa964eb5e9b062aa64 10748 gocryptfs_2.4.0.51-1ubuntu0.24.04.2~uh~jammy1.debian.tar.xz
Files:
 967aa5187672ca63aaf97cede7d31faf 1379405 gocryptfs_2.4.0.51.orig.tar.gz
 e536703b0cccb713663c470cb58ceb51 10748 gocryptfs_2.4.0.51-1ubuntu0.24.04.2~uh~jammy1.debian.tar.xz
Go-Import-Path: github.com/rfjakob/gocryptfs
Original-Maintainer: Debian Go Packaging Team <pkg-go-maintainers@lists.alioth.debian.org>
