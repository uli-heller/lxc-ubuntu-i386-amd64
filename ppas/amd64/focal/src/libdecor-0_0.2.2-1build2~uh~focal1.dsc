Format: 3.0 (quilt)
Source: libdecor-0
Binary: libdecor-0-0, libdecor-0-dev, libdecor-0-plugin-1-cairo, libdecor-0-plugin-1-gtk, libdecor-tests
Architecture: any
Version: 0.2.2-1build2~uh~focal1
Maintainer: Ubuntu Developers <ubuntu-devel-discuss@lists.ubuntu.com>
Uploaders:  Christian Rauch <Rauch.Christian@gmx.de>, Simon McVittie <smcv@debian.org>
Homepage: https://gitlab.freedesktop.org/libdecor/libdecor
Standards-Version: 4.6.2
Vcs-Browser: https://salsa.debian.org/sdl-team/libdecor-0
Vcs-Git: https://salsa.debian.org/sdl-team/libdecor-0.git
Testsuite: autopkgtest
Testsuite-Triggers: build-essential, libdbus-1-dev, libwayland-dev, libxkbcommon-dev, pkg-config, wayland-protocols, weston
Build-Depends: debhelper-compat (= 12), libcairo2-dev, libdbus-1-dev, libegl-dev <!noinsttest>, libgl-dev <!noinsttest>, libgtk-3-dev, libopengl-dev <!noinsttest>, libpango1.0-dev, libwayland-dev (>= 1.18), libxkbcommon-dev <!noinsttest>, meson, pkg-config, wayland-protocols
Package-List:
 libdecor-0-0 deb libs optional arch=any
 libdecor-0-dev deb libdevel optional arch=any
 libdecor-0-plugin-1-cairo deb libs optional arch=any
 libdecor-0-plugin-1-gtk deb libs optional arch=any
 libdecor-tests deb misc optional arch=any profile=!noinsttest
Checksums-Sha1:
 06d36c8b8fcf179a31f498df9ab57dfde977069d 63748 libdecor-0_0.2.2.orig.tar.gz
 6d68e9dedd5b88fa07cd21f5d4faa056207241ca 6408 libdecor-0_0.2.2-1build2~uh~focal1.debian.tar.xz
Checksums-Sha256:
 40a1d8be07d8b1f66e8fb98a1f4a84549ca6bf992407198a5055952be80a8525 63748 libdecor-0_0.2.2.orig.tar.gz
 0b3d90232db3571c1421d8143024e3c9e5851ca86d4d57759a8ba36750ff5e6a 6408 libdecor-0_0.2.2-1build2~uh~focal1.debian.tar.xz
Files:
 94223f6d80a9ae542655f70cc2c95eaf 63748 libdecor-0_0.2.2.orig.tar.gz
 9eab9b7dfdce8ab63b778c8df5473741 6408 libdecor-0_0.2.2-1build2~uh~focal1.debian.tar.xz
Original-Maintainer: Debian SDL packages maintainers <pkg-sdl-maintainers@lists.alioth.debian.org>
