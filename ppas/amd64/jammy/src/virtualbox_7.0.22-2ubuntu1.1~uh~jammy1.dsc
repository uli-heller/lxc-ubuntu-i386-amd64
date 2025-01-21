Format: 3.0 (quilt)
Source: virtualbox
Binary: virtualbox-qt, virtualbox, virtualbox-dkms, virtualbox-source, virtualbox-guest-x11, virtualbox-guest-utils
Architecture: amd64 i386
Version: 7.0.22-2ubuntu1.1~uh~jammy1
Maintainer: Ubuntu Developers <ubuntu-devel-discuss@lists.ubuntu.com>
Uploaders: Ritesh Raj Sarraf <rrs@debian.org>, Gianfranco Costamagna <locutusofborg@debian.org>
Homepage: https://www.virtualbox.org
Standards-Version: 4.6.1
Vcs-Browser: https://salsa.debian.org/pkg-virtualbox-team/virtualbox
Vcs-Git: https://salsa.debian.org/pkg-virtualbox-team/virtualbox.git
Testsuite: autopkgtest-pkg-dkms
Build-Depends: bzip2, debhelper-compat (= 13), default-jdk, jaxws, dh-python, dh-sequence-dkms, docbook-xml, docbook-xsl, dpkg-dev (>= 1.15.6~), g++-multilib, genisoimage, glslang-tools, gsoap, acpica-tools, kbuild (>= 1:0.1.9998svn3589~), libasound2-dev, libcap-dev, libcurl4-gnutls-dev, libdevmapper-dev, libdrm-dev, libegl1-mesa-dev, libgl1-mesa-dev, libglu1-mesa-dev, libgsoap-dev, liblzf-dev, liblzma-dev, libidl-dev, libogg-dev, libpam0g-dev, libpixman-1-dev, libpng-dev, libpulse-dev, libqt5x11extras5-dev, libqt5opengl5-dev, qttools5-dev, libsdl1.2-dev, libsdl2-dev, libssl-dev, libtpms-dev, libvncserver-dev, libvorbis-dev, libvpx-dev, libx11-dev, libxcomposite-dev, libxcursor-dev, libxdamage-dev, libxext-dev, libxi-dev, libxinerama-dev, libxml2-dev, libxml2-utils, libxmu-dev, libxrandr-dev, libxrender-dev, libxslt1-dev, libxt-dev, lsb-release, lynx, makeself, module-assistant, nasm, python3-dev, texlive-fonts-extra, texlive-fonts-recommended, texlive-latex-extra, texlive-latex-recommended, uuid-dev, x11proto-gl-dev, x11proto-xf86dri-dev, xserver-xorg-dev, xsltproc, yasm, zlib1g-dev
Package-List:
 virtualbox deb contrib/misc optional arch=amd64
 virtualbox-dkms deb contrib/kernel optional arch=amd64
 virtualbox-guest-utils deb contrib/misc optional arch=amd64,i386
 virtualbox-guest-x11 deb contrib/x11 optional arch=amd64,i386
 virtualbox-qt deb contrib/misc optional arch=amd64
 virtualbox-source deb contrib/kernel optional arch=amd64
Checksums-Sha1:
 a5316c74f7cc941a9fc71879a307222d1fc0043a 174643573 virtualbox_7.0.22.orig.tar.bz2
 03cbdd1f62bfc245dbc9628c2f33bd81960cf79d 87580 virtualbox_7.0.22-2ubuntu1.1~uh~jammy1.debian.tar.xz
Checksums-Sha256:
 cf3ddf633ca410f1b087b0722413e83247cda4f14d33323dc122a4a42ff61981 174643573 virtualbox_7.0.22.orig.tar.bz2
 ad9911bce99ac0bb8dbeecd41af8d2e3a9766ab70c977fc0d2fed022c965d25d 87580 virtualbox_7.0.22-2ubuntu1.1~uh~jammy1.debian.tar.xz
Files:
 b6894cb48637f34e56c60d84165e688f 174643573 virtualbox_7.0.22.orig.tar.bz2
 95e36c0c7b4ac955d7cea5870ef53b1d 87580 virtualbox_7.0.22-2ubuntu1.1~uh~jammy1.debian.tar.xz
Original-Maintainer: Debian Virtualbox Team <team+debian-virtualbox@tracker.debian.org>
