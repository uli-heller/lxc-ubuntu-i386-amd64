Format: 3.0 (quilt)
Source: gocryptfs
Binary: gocryptfs
Architecture: any
Version: 2.4.0.54-1ubuntu0.24.04.2~uh~focal2
Maintainer: Ubuntu Developers <ubuntu-devel-discuss@lists.ubuntu.com>
Uploaders: Felix Lechner <felix.lechner@lease-up.com>, Dmitry Smirnov <onlyjob@debian.org>
Homepage: https://github.com/rfjakob/gocryptfs
Standards-Version: 4.6.2
Vcs-Browser: https://salsa.debian.org/go-team/packages/gocryptfs
Vcs-Git: https://salsa.debian.org/go-team/packages/gocryptfs.git
Testsuite: autopkgtest
Testsuite-Triggers: @builddeps@
Build-Depends: debhelper-compat (= 12), dh-golang, golang-github-hanwen-go-fuse-dev (>= 2.1.0+git20220112~), golang-github-aperturerobotics-jacobsa-crypto-dev, golang-github-mdp-qrterminal-dev, golang-github-moby-sys-dev, golang-github-pkg-xattr-dev (>= 0.4.1), golang-github-rfjakob-eme-dev (>= 1.1.1), golang-github-sabhiram-go-gitignore-dev (>= 1.0.2+git20210923~), golang-github-spf13-pflag-dev, golang-golang-x-crypto-dev, golang-golang-x-sys-dev (>= 0.0~git20200501.0.bc7a7d4), golang-golang-x-term-dev, pandoc, pkg-config, libssl-dev
Package-List:
 gocryptfs deb devel optional arch=any
Checksums-Sha1:
 a23210d9d71fd7d3434b83710db85f38c2bd7fe0 1379775 gocryptfs_2.4.0.54.orig.tar.gz
 106d5bdf5967a5d07ea096e3897d22d513e1f924 10788 gocryptfs_2.4.0.54-1ubuntu0.24.04.2~uh~focal2.debian.tar.xz
Checksums-Sha256:
 b14e96441a5db025d3edef25363d006122503ded009291e60e6111915091fe99 1379775 gocryptfs_2.4.0.54.orig.tar.gz
 f2ba21d1c034fc8cf46982b6d8626b0db0fed28f1c627c84f62ce93c02f3d141 10788 gocryptfs_2.4.0.54-1ubuntu0.24.04.2~uh~focal2.debian.tar.xz
Files:
 7be65a5381ecd641ef10f92eb61a906e 1379775 gocryptfs_2.4.0.54.orig.tar.gz
 2e9d30deef5d91b57a3471749b843572 10788 gocryptfs_2.4.0.54-1ubuntu0.24.04.2~uh~focal2.debian.tar.xz
Go-Import-Path: github.com/rfjakob/gocryptfs
Original-Maintainer: Debian Go Packaging Team <pkg-go-maintainers@lists.alioth.debian.org>
