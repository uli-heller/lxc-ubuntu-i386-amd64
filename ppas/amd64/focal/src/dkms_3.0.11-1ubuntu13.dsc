-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA512

Format: 3.0 (quilt)
Source: dkms
Binary: dkms, dh-dkms, dkms-test-dkms
Architecture: all amd64
Version: 3.0.11-1ubuntu13
Maintainer: Ubuntu Developers <ubuntu-devel-discuss@lists.ubuntu.com>
Uploaders: David Paleino <dapal@debian.org>, Petter Reinholdtsen <pere@debian.org>, Aron Xu <aron@debian.org>, Mario Limonciello <Mario_Limonciello@dell.com>, Andreas Beckmann <anbe@debian.org>,
Homepage: https://github.com/dell/dkms
Standards-Version: 4.6.2
Vcs-Browser: https://salsa.debian.org/debian/dkms
Vcs-Git: https://salsa.debian.org/debian/dkms.git
Testsuite: autopkgtest, autopkgtest-pkg-dkms
Testsuite-Triggers: linux-headers-generic, linux-headers-rpi, linux-image-generic, openssl
Build-Depends: debhelper-compat (= 13)
Package-List:
 dh-dkms deb kernel optional arch=all
 dkms deb kernel optional arch=all
 dkms-test-dkms deb kernel optional arch=amd64
Checksums-Sha1:
 e3abd2af84bfe53bcda15d6ba6b4a43e6c526999 93521 dkms_3.0.11.orig.tar.gz
 d33c40d21761c8dc8abc22551aabce56958a918f 26068 dkms_3.0.11-1ubuntu13.debian.tar.xz
Checksums-Sha256:
 c5582aa7ab1815d23c63adc09fdf96f04842381a76471d205f3b183e90b3d4d1 93521 dkms_3.0.11.orig.tar.gz
 a50b8cdb78d39ea4e4223f47eee80f6e814e5dcf4276c37fbc536ab7acbe35c9 26068 dkms_3.0.11-1ubuntu13.debian.tar.xz
Files:
 14586490dbe1421f34991d3f8d092b27 93521 dkms_3.0.11.orig.tar.gz
 5b3cdf4de1b2f4e5b03e0f2454d08482 26068 dkms_3.0.11-1ubuntu13.debian.tar.xz
Original-Maintainer: Dynamic Kernel Module System Team <dkms@packages.debian.org>

-----BEGIN PGP SIGNATURE-----

iQJHBAEBCgAxFiEET7WIqEwt3nmnTHeHb6RY3R2wP3EFAmYUE9UTHGp1bGlhbmtA
dWJ1bnR1LmNvbQAKCRBvpFjdHbA/cWqVD/99cGEYS9N1M0Izy5lfTpbL5hyalabd
Oigere05jom0D4O8pbZeQbMz8vX4Yfozi+tlSBbDvqKnNx7YsOB4BLQKD4vad+3H
IKzlcL/sBBCXBulCD9DPDM9bIMnEaT0/LHj32NHBkCfSYdqrLxqM7U46svQ7NoY3
8cvYCKP9wK+9EbgFb2I2pbrHQZ7bUIn4/f5KvksFBwWf6+OReQS/j/YuvjHHqg9/
9XveYXOQXVR1+yxAOWady1CDhjBURe/htz18KYFPIDy1plsNLvj3rRnbyuv1kEyn
RKcGtKMWv/tToSxxSxo6P7lOLolZntvfA8RmCfdBxVn6XsJCznFrrJM5VOuqYpE3
KfzGVzKF5+DWTceNhblvcJvqFcnt5KCzWG8xKZ+lXLVQRfUPS5djhzrhLKrrFwDr
phFCyRccAlTowhNSQa8NB82rDkzkrg5mWHW10Vu2122zuhEsvVZNtJuuP4lSQsF8
PeZkCQ37diAaG5mMRU2iEev9MJwAs1KCCTcGylPUJ+YQ5gcHXNtKA+QvOURrxpN/
4QyEoFn3h0SpvjfXDDINae4kbRxYhW4ZPgzHtrOwqVXDcD7m6l2NkaQZM/GaxYUw
UmOeMcHJb+Alh7A8s32Sh3Au8qHqTMYozWPQ0o+MyU4QZsOSysClnWUT13K0Vcgi
lzQGPznduS0BpA==
=UMuM
-----END PGP SIGNATURE-----
