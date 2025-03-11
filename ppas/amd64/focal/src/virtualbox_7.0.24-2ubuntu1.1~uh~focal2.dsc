Format: 3.0 (quilt)
Source: virtualbox
Binary: virtualbox-qt, virtualbox, virtualbox-dkms, virtualbox-source, virtualbox-guest-x11, virtualbox-guest-utils
Architecture: amd64 i386
Version: 7.0.24-2ubuntu1.1~uh~focal2
Maintainer: Ubuntu Developers <ubuntu-devel-discuss@lists.ubuntu.com>
Uploaders: Ritesh Raj Sarraf <rrs@debian.org>, Gianfranco Costamagna <locutusofborg@debian.org>
Homepage: https://www.virtualbox.org
Standards-Version: 4.6.1
Vcs-Browser: https://salsa.debian.org/pkg-virtualbox-team/virtualbox
Vcs-Git: https://salsa.debian.org/pkg-virtualbox-team/virtualbox.git
Testsuite: autopkgtest-pkg-dkms
Build-Depends: bzip2, debhelper-compat (= 12), default-jdk, jaxws, dh-python, dh-sequence-dkms, docbook-xml, docbook-xsl, dpkg-dev (>= 1.15.6~), g++-multilib, genisoimage, glslang-tools, gsoap, acpica-tools, kbuild (>= 1:0.1.9998svn3589~), libasound2-dev, libcap-dev, libcurl4-gnutls-dev, libdevmapper-dev, libdrm-dev, libegl1-mesa-dev, libgl1-mesa-dev, libglu1-mesa-dev, libgsoap-dev, liblzf-dev, liblzma-dev, libidl-dev, libogg-dev, libpam0g-dev, libpixman-1-dev, libpng-dev, libpulse-dev, libqt5x11extras5-dev, libqt5opengl5-dev, qttools5-dev, libsdl1.2-dev, libssl-dev, libtpms-dev, libvncserver-dev, libvorbis-dev, libvpx-dev, libx11-dev, libxcomposite-dev, libxcursor-dev, libxdamage-dev, libxext-dev, libxi-dev, libxinerama-dev, libxml2-dev, libxml2-utils, libxmu-dev, libxrandr-dev, libxrender-dev, libxslt1-dev, libxt-dev, lsb-release, lynx, makeself, module-assistant, nasm, python3-dev, texlive-fonts-extra, texlive-fonts-recommended, texlive-latex-extra, texlive-latex-recommended, uuid-dev, x11proto-gl-dev, x11proto-xf86dri-dev, xserver-xorg-dev, xsltproc, yasm, zlib1g-dev
Package-List:
 virtualbox deb contrib/misc optional arch=amd64
 virtualbox-dkms deb contrib/kernel optional arch=amd64
 virtualbox-guest-utils deb contrib/misc optional arch=amd64,i386
 virtualbox-guest-x11 deb contrib/x11 optional arch=amd64,i386
 virtualbox-qt deb contrib/misc optional arch=amd64
 virtualbox-source deb contrib/kernel optional arch=amd64
Checksums-Sha1:
 99ce98561363e74b0d31ed142fa1da805c64a88b 174663788 virtualbox_7.0.24.orig.tar.bz2
 db5e6735e55909677007d578584d13093da42407 88116 virtualbox_7.0.24-2ubuntu1.1~uh~focal2.debian.tar.xz
Checksums-Sha256:
 340d66f52251e23d9bc1eb4fdf70e44cb9d1db69bc5064e3f7bdfb8bc0e3a458 174663788 virtualbox_7.0.24.orig.tar.bz2
 7ae6f42105a0844e02601f82e23f9732dfffe726869febb38a3d0c74177b66db 88116 virtualbox_7.0.24-2ubuntu1.1~uh~focal2.debian.tar.xz
Files:
 b589c3d999f0ff1ddb1cd03c59f766aa 174663788 virtualbox_7.0.24.orig.tar.bz2
 5d1bd671bede29aefac640fcdbb532c6 88116 virtualbox_7.0.24-2ubuntu1.1~uh~focal2.debian.tar.xz
Original-Maintainer: Debian Virtualbox Team <team+debian-virtualbox@tracker.debian.org>
