netplan.io
==========

The package "netplan.io" depends on "pandoc" and
"pandoc" is pretty difficult to build.

Currently, our approach is to patch "netplan.io"
removing the dependency.

Problem
-------

There is a patch which works OK for jammy and netplan-0.105.
It fails for netplan-0.106:

```
+ sudo chroot build-jammy-i386/rootfs bash -c 'cd '\''/src/netplan.io/netplan.io-0.106.1'\'' && patch -p1'
patching file .pc/applied-patches
Hunk #1 succeeded at 1 with fuzz 1.
patching file .pc/uli-no-pandoc/Makefile
patching file Makefile
Hunk #1 succeeded at 67 with fuzz 2 (offset 17 lines).
Hunk #2 succeeded at 161 (offset 27 lines).
Hunk #3 FAILED at 149.
1 out of 3 hunks FAILED -- saving rejects to file Makefile.rej
patching file debian/control
Hunk #1 FAILED at 27.
1 out of 1 hunk FAILED -- saving rejects to file debian/control.rej
patching file debian/patches/series
Hunk #1 succeeded at 1 with fuzz 1.
patching file debian/patches/uli-no-pandoc
+ exit 1
rm -f netplan.io_0.106.1-7ubuntu0.22.04.4.debian.tar.xz netplan.io_0.106.1-7ubuntu0.22.04.4.dsc netplan.io_0.106.1.orig.tar.gz 
build.sh: error building package 'netplan.io' -> ABORTING
```

Review the existing patch
-------------------------

- [patches/jammy/netplan.io/netplan.io-0.105_no-pandoc.diff](patches/jammy/netplan.io/netplan.io-0.105_no-pandoc.diff)
- Affected files: `grep '^diff' patches/jammy/netplan.io/netplan.io-0.105_no-pandoc.diff|cut -d " " -f 3-`
  - netplan.io-0.105.orig/.pc/applied-patches netplan.io-0.105/.pc/applied-patches
  - netplan.io-0.105.orig/.pc/uli-no-pandoc/Makefile netplan.io-0.105/.pc/uli-no-pandoc/Makefile
  - netplan.io-0.105.orig/Makefile netplan.io-0.105/Makefile
  - netplan.io-0.105.orig/debian/changelog netplan.io-0.105/debian/changelog
  - netplan.io-0.105.orig/debian/control netplan.io-0.105/debian/control
  - netplan.io-0.105.orig/debian/patches/series netplan.io-0.105/debian/patches/series
  - netplan.io-0.105.orig/debian/patches/uli-no-pandoc netplan.io-0.105/debian/patches/uli-no-pandoc
- This comes down to
  - Makefile
  - debian/control

Create a fresh patch
--------------------

- Create a folder for the original files
  - patches/jammy/prepare-netplan-patch/orig/debian
- Copy the original files into patches/jammy/prepare-netplan-patch/orig
  - `mv patches/jammy/netplan.io patches/jammy/netplan.io-deactivated`
  - `./build.sh -a i386 -o jammy netplan.io`
  - `cp build-jammy-i386/rootfs/src/netplan.io/netplan.io-0.106.1/Makefile patches/jammy/prepare-netplan-patch/orig/.`
  - `cp build-jammy-i386/rootfs/src/netplan.io/netplan.io-0.106.1/debian/control patches/jammy/prepare-netplan-patch/orig/debian/.`
  - `mv patches/jammy/netplan.io-deactivated patches/jammy/netplan.io`
- Create a folder for the modified files
  - `cp -a patches/jammy/prepare-netplan-patch/orig  patches/jammy/prepare-netplan-patch/no-pandoc`
- Apply the old patch
  - `cat patches/jammy/netplan.io/netplan.io-0.105_no-pandoc.diff | ( cd patches/jammy/prepare-netplan-patch/no-pandoc; patch -f -p1 )`
  - Lots of errors - most can be ignored
  - Look for files ending with ".rej"
- Makefile
  - Look at Makefile and Makefile.rej
  - easy fix!
- debian/control
  - Look at debian/control and debian/control.rej
  - easy fix!
- Delete working files
  - `rm patches/jammy/prepare-netplan-patch/no-pandoc/{Makefile~,Makefile.*,debian/control~,debian/control.*}`
- Create new patch: `( cd patches/jammy/prepare-netplan-patch; diff -ur orig no-pandoc ) >patches/jammy/netplan.io/netplan.io-0.106.1_no-pandoc.diff`
- Deactivate old patch: `git mv patches/jammy/netplan.io/netplan.io-0.105_no-pandoc.diff  patches/jammy/netplan.io/netplan.io-0.105_no-pandoc.diff.deactivated`

Build again
-----------

```
$ ./build.sh -a i386 -o jammy netplan.io
dpkg-scanpackages: Information: 211 Einträge wurden in Ausgabe-Paketdatei geschrieben.
gpg: WARNUNG: Unsichere Zugriffsrechte des Home-Verzeichnis `/home/uli/git/github/uli-heller/lxc-ubuntu-i386-amd64/gpg'
gpg: WARNUNG: Unsichere Zugriffsrechte des Home-Verzeichnis `/home/uli/git/github/uli-heller/lxc-ubuntu-i386-amd64/gpg'
deb file:/var/cache/lxc-ppa/ ./
Get:1 file:/var/cache/lxc-ppa ./ InRelease [1821 B]
Get:1 file:/var/cache/lxc-ppa ./ InRelease [1821 B]
...
Reading state information... Done
All packages are up to date.
dpkg-scanpackages: Information: 211 Einträge wurden in Ausgabe-Paketdatei geschrieben.
gpg: WARNUNG: Unsichere Zugriffsrechte des Home-Verzeichnis `/home/uli/git/github/uli-heller/lxc-ubuntu-i386-amd64/gpg'
gpg: WARNUNG: Unsichere Zugriffsrechte des Home-Verzeichnis `/home/uli/git/github/uli-heller/lxc-ubuntu-i386-amd64/gpg'
```
