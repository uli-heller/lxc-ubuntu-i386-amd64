Format: 3.0 (quilt)
Source: virtualbox
Binary: virtualbox-qt, virtualbox, virtualbox-dkms, virtualbox-source, virtualbox-guest-x11, virtualbox-guest-utils
Architecture: amd64 i386
Version: 7.0.16-dfsg-2ubuntu1.1~uh~jammy1
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
 df6cfdd02e421af587e64b6855d8049056e20af3 78681676 virtualbox_7.0.16-dfsg.orig.tar.xz
 e66c54fbcea0bdb2ecce8a970b27e2644810366a 78720 virtualbox_7.0.16-dfsg-2ubuntu1.1~uh~jammy1.debian.tar.xz
Checksums-Sha256:
 9af16b80e8f18c7f3f7f935817e6ce094904c1c392a86e37c16773d7b1d25997 78681676 virtualbox_7.0.16-dfsg.orig.tar.xz
 9cdf62b9334debf3b0bfce0f850caf0b0b36bd7443fa86668858075bc3593c42 78720 virtualbox_7.0.16-dfsg-2ubuntu1.1~uh~jammy1.debian.tar.xz
Files:
 eea3497f179943f5a3b02204a2f863a0 78681676 virtualbox_7.0.16-dfsg.orig.tar.xz
 00aefd11571e295e51f087bf8fec1af3 78720 virtualbox_7.0.16-dfsg-2ubuntu1.1~uh~jammy1.debian.tar.xz
Original-Maintainer: Debian Virtualbox Team <team+debian-virtualbox@tracker.debian.org>
