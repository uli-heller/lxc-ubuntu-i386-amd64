Format: 3.0 (quilt)
Source: dkms
Binary: dkms, dh-dkms, dkms-test-dkms
Architecture: all amd64
Version: 3.0.11-1ubuntu13~uh~focal1
Maintainer: Ubuntu Developers <ubuntu-devel-discuss@lists.ubuntu.com>
Uploaders: David Paleino <dapal@debian.org>, Petter Reinholdtsen <pere@debian.org>, Aron Xu <aron@debian.org>, Mario Limonciello <Mario_Limonciello@dell.com>, Andreas Beckmann <anbe@debian.org>,
Homepage: https://github.com/dell/dkms
Standards-Version: 4.6.2
Vcs-Browser: https://salsa.debian.org/debian/dkms
Vcs-Git: https://salsa.debian.org/debian/dkms.git
Testsuite: autopkgtest, autopkgtest-pkg-dkms
Testsuite-Triggers: linux-headers-generic, linux-headers-rpi, linux-image-generic, openssl
Build-Depends: debhelper-compat (= 12)
Package-List:
 dh-dkms deb kernel optional arch=all
 dkms deb kernel optional arch=all
 dkms-test-dkms deb kernel optional arch=amd64
Checksums-Sha1:
 e3abd2af84bfe53bcda15d6ba6b4a43e6c526999 93521 dkms_3.0.11.orig.tar.gz
 e4ad3cb05ae8b5fcf6dc01bd9591f85f22ee02a8 26112 dkms_3.0.11-1ubuntu13~uh~focal1.debian.tar.xz
Checksums-Sha256:
 c5582aa7ab1815d23c63adc09fdf96f04842381a76471d205f3b183e90b3d4d1 93521 dkms_3.0.11.orig.tar.gz
 b1042e99c0881c54d67abb435a3ef3e14f079a8d9ee9529795b26234ae034acd 26112 dkms_3.0.11-1ubuntu13~uh~focal1.debian.tar.xz
Files:
 14586490dbe1421f34991d3f8d092b27 93521 dkms_3.0.11.orig.tar.gz
 acb22dc63215f05c04bc44d5905af135 26112 dkms_3.0.11-1ubuntu13~uh~focal1.debian.tar.xz
Original-Maintainer: Dynamic Kernel Module System Team <dkms@packages.debian.org>
