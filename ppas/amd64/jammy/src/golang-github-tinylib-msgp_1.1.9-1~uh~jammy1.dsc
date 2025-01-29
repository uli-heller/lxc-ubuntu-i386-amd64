Format: 3.0 (quilt)
Source: golang-github-tinylib-msgp
Binary: msgp, golang-github-tinylib-msgp-dev
Architecture: any all
Version: 1.1.9-1~uh~jammy1
Maintainer: Debian Go Packaging Team <team+pkg-go@tracker.debian.org>
Uploaders: Tim Potter <tpot@hpe.com>
Homepage: https://github.com/tinylib/msgp
Standards-Version: 4.6.2
Vcs-Browser: https://salsa.debian.org/go-team/packages/golang-github-tinylib-msgp
Vcs-Git: https://salsa.debian.org/go-team/packages/golang-github-tinylib-msgp.git
Testsuite: autopkgtest-pkg-go
Build-Depends: debhelper-compat (= 13), dh-golang, golang-any, golang-github-philhofer-fwd-dev, golang-golang-x-tools-dev
Package-List:
 golang-github-tinylib-msgp-dev deb golang optional arch=all
 msgp deb golang optional arch=any
Checksums-Sha1:
 6294b382a69dbd1ce152f7df214dbbe399de6c97 93398 golang-github-tinylib-msgp_1.1.9.orig.tar.gz
 e62ac25a41d9f1decbd0eef6c150e5c52d209d18 3844 golang-github-tinylib-msgp_1.1.9-1~uh~jammy1.debian.tar.xz
Checksums-Sha256:
 91afd0cd228d3c632ff8b2ed8adf77fb4afd52305a7043319ba5c917b2083e8b 93398 golang-github-tinylib-msgp_1.1.9.orig.tar.gz
 8a62fda7f39b24156729d5921b93b2c7df8cd61b1e210e39de5bb5abda3fefd5 3844 golang-github-tinylib-msgp_1.1.9-1~uh~jammy1.debian.tar.xz
Files:
 33e6d75b1a29809281414b497c53d5c9 93398 golang-github-tinylib-msgp_1.1.9.orig.tar.gz
 bd2a9313b4cbe647149dd71bbf50ccad 3844 golang-github-tinylib-msgp_1.1.9-1~uh~jammy1.debian.tar.xz
Go-Import-Path: github.com/tinylib/msgp
