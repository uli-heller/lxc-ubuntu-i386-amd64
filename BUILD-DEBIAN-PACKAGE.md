Anleitung zum Bauen eines Debian-Pakets
=======================================

Ziel
----

Ich möchte es schaffen, dass ich ein Quellpaket aus Ubuntu-22.04
für Ubuntu-20.04 baue. Also:

- Build-Umgebung für 20.04 (focal)
- Quellpakete konfigurieren für 22.04 (jammy)
- Quellpaket hetunterladen
- ... auspacken
- ... bauen

Idealerweise klappt das ohne "root".

build.sh
--------

Erweitert um die Option "-s source-os".

Aufrufe:

- Baut das Paket "gocryptfs" für 20.04 (focal): `./build.sh -a amd64 -o focal gocryptfs`
  - Paket liegt danach unter debs/focal/amd64/gocryptfs_1.7.1-1ubuntu0.1_amd64.deb
- Baut das Paket "gocryptfs" für 20.04 (focal): `./build.sh -a amd64 -o focal -s focal gocryptfs`
  - Paket liegt danach unter debs/focal/amd64/gocryptfs_1.7.1-1ubuntu0.1_amd64.deb
- Baut das Paket "gocryptfs" aus 22.04 (jammy) für 20.04 (focal): `./build.sh -a amd64 -s jammy -o focal gocryptfs`
  - Klappt, wenn man zuvor die ganzen Abhängigkeiten baut - siehe "Herausforderungen"
- Baut das Paket "gocryptfs" aus 24.04 (noble) für 20.04 (focal): `./build.sh -a amd64 -b "DEB_BUILD_OPTIONS=nostrip" -s noble -o focal gocryptfs`
  - Die Option `-b "DEB_BUILD_OPTIONS=nostrip"` behebt die Probleme mit "dwz"
  - `./build.sh -a amd64 -s noble -o focal golang-github-hanwen-go-fuse-dev` ... klappt nicht
    - Neuere Go-Version
      ```
      sudo chroot build-focal-amd64/rootfs bash
      apt install golang-1.22
      rm /usr/bin/go
      rm /usr/bin/gofmt
      echo >/usr/bin/go <<'EOF'
      #!/bin/sh
      GOROOT=/usr/lib/go-1.22
      export GOROOT
      exec "${GOROOT}/bin/go" "$@"
      EOF
      chmod +x /usr/bin/go
      echo >/usr/bin/gofmt <<'EOF'
      #!/bin/sh
      GOROOT=/usr/lib/go-1.22
      export GOROOT
      exec "${GOROOT}/bin/gofmt" "$@"
      EOF
      chmod +x /usr/bin/gofmt
      go version #1.22
    
      # update-alternatives --install /usr/bin/go go /usr/lib/go-1.22/bin/go 3
      # update-alternatives --install /usr/bin/gofmt gofmt /usr/lib/go-1.22/bin/gofmt 3
      # go version --> Fehlermeldung
      ```
    - Damit klappt's!
  - `./build.sh -a amd64 -s noble -o focal golang-github-moby-sys-dev`
    - Probleme bei "mount"
    - `./build.sh -a amd64 -b "DEB_BUILD_OPTIONS=nocheck" -s noble -o focal golang-github-moby-sys-dev`
  - `./build.sh -a amd64 -s noble -o focal golang-github-sabhiram-go-gitignore-dev`
  - `./build.sh -a amd64 -s noble -o focal golang-golang-x-term-dev`
    - Probleme mit golang-any
    - `./build.sh -a amd64 -s noble -o focal golang-any`
    - Probleme mit golang-golang-x-sys-dev
    - `./build.sh -a amd64 -s noble -o focal golang-golang-x-sys-dev`
- Baut das Paket "gocryptfs" aus 24.04 (noble) für 22.04 (jammy): `./build.sh -a amd64 -s noble -o jammy gocryptfs`
  - `./build.sh -a amd64 -s noble -o jammy golang-github-hanwen-go-fuse-dev`
  - `./build.sh -a amd64 -s noble -o jammy golang-github-sabhiram-go-gitignore-dev`

Herausforderungen
-----------------

### debhelper-compat (= 13)

Lösung: Die Versionsnummer ändern auf diejenige des Ziel-Betriebsystems, also:

- focal: 12
- jammy: 13

### Pakete mit Versionsnummern

Bei GOCRYPTFS mit `-s jammy -o focal`:

- golang-github-hanwen-go-fuse-dev (>= 2.0.3)
- golang-github-pkg-xattr-dev (>= 0.4.1)
- golang-github-rfjakob-eme-dev (>= 1.1.1)
- golang-golang-x-sys-dev (>= 0.0~git20200501.0.bc7a7d4)

Erster Ansatz: Bauen der Pakete, also: `./build.sh -a amd64 -s jammy -o focal golang-github-hanwen-go-fuse-dev`

```
... apt-get build-dep -y 'golang-github-hanwen-go-fuse-dev'...
Building dependency tree       
Reading state information... Done
Some packages could not be installed. This may mean that you have
requested an impossible situation or if you are using the unstable
distribution that some required packages have not yet been created
or been moved out of Incoming.
The following information may help to resolve the situation:

The following packages have unmet dependencies:
 builddeps:golang-github-hanwen-go-fuse : Depends: debhelper-compat (= 13)
E: Unable to correct problems, you have held broken packages.
...
```

Mit weiteren Korrekturen

- `./build.sh -a amd64 -s jammy -o focal golang-github-hanwen-go-fuse-dev` erzeugt "golang-github-hanwen-go-fuse-dev_2.0.3-1_all.deb"
- `./build.sh -a amd64 -s jammy -o focal golang-github-pkg-xattr-dev` erzeugt "golang-github-pkg-xattr-dev_0.4.2-1_all.deb"
- `./build.sh -a amd64 -s jammy -o focal golang-github-rfjakob-eme-dev` erzeugt "golang-github-rfjakob-eme-dev_1.1.1-1_all.deb"
- `./build.sh -a amd64 -s jammy -o focal golang-golang-x-sys-dev` klappt nicht wegen dh-sequence-golang welches bereitgestellt wird von dh-golang
- `./build.sh -a amd64 -s jammy -o focal dh-golang` klappt
- `./build.sh -a amd64 -s jammy -o focal golang-golang-x-sys-dev` klappt
- `./build.sh -a amd64 -s jammy -o focal gocryptfs` klappt nun auch und erzeugt "gocryptfs_1.8.0-1ubuntu0.1_amd64.deb"

Mit "root"
----------

### Focal

```
./build.sh -S -a amd64 -s noble -o focal golang-github-hanwen-go-fuse-dev
./build.sh -S -a amd64 -b "DEB_BUILD_OPTIONS=nocheck" -s noble -o focal golang-github-moby-sys-dev
./build.sh -S -a amd64 -s noble -o focal golang-github-sabhiram-go-gitignore-dev
./build.sh -S -a amd64 -s noble -o focal golang-any
./build.sh -S -a amd64 -s noble -o focal golang-golang-x-sys-dev
./build.sh -S -a amd64 -s noble -o focal golang-golang-x-term-dev
./build.sh -S -a amd64 -b "DEB_BUILD_OPTIONS=nostrip" -s noble -o focal gocryptfs
```

### Jammy

```
./build.sh -S -a amd64 -s noble -o jammy golang-github-hanwen-go-fuse-dev
./build.sh -S -a amd64 -b "DEB_BUILD_OPTIONS=nocheck" -s noble -o jammy golang-github-moby-sys-dev
./build.sh -S -a amd64 -s noble -o jammy golang-github-sabhiram-go-gitignore-dev
./build.sh -S -a amd64 -s noble -o jammy golang-any
./build.sh -S -a amd64 -s noble -o jammy golang-golang-x-sys-dev
./build.sh -S -a amd64 -s noble -o jammy golang-golang-x-term-dev
./build.sh -S -a amd64 -b "DEB_BUILD_OPTIONS=nostrip" -s noble -o jammy gocryptfs
```

Ohne "root"
-----------

Hierfür verwende ich PROOT.
Das hat(te) leider Probleme mit langen Dateinamen.
Hab eine Korrektur dafür erarbeitet und in PROOT-5.4.0.3
veröffentlicht! Nun geht es ohne "root". Davor mußte ich
bei "gocryptfs" die Option "-R" verwenden!

### Focal

```
./build-proot.sh -S -a amd64 -s noble -o focal golang-github-hanwen-go-fuse-dev
./build-proot.sh -S -a amd64 -b "DEB_BUILD_OPTIONS=nocheck" -s noble -o focal golang-github-moby-sys-dev
./build-proot.sh -S -a amd64 -s noble -o focal golang-github-sabhiram-go-gitignore-dev
./build-proot.sh -S -a amd64 -s noble -o focal golang-any
# ... ohne "root" klappen die Tests nicht
./build-proot.sh -S -a amd64 -b "DEB_BUILD_OPTIONS=nocheck" -s noble -o focal golang-golang-x-sys-dev
./build-proot.sh -S -a amd64 -s noble -o focal golang-golang-x-term-dev
# ... geht nur mit "root", wegen langen Dateinamen (2025-01-03)
#     Korrigiert mit proot-5.4.0.3
./build-proot.sh -S -a amd64 -b "DEB_BUILD_OPTIONS=nostrip" -s noble -o focal gocryptfs
```

### Jammy

```
./build-proot.sh -S -a amd64 -s noble -o jammy golang-github-hanwen-go-fuse-dev
./build-proot.sh -S -a amd64 -b "DEB_BUILD_OPTIONS=nocheck" -s noble -o jammy golang-github-moby-sys-dev
./build-proot.sh -S -a amd64 -s noble -o jammy golang-github-sabhiram-go-gitignore-dev
./build-proot.sh -S -a amd64 -s noble -o jammy golang-any
# ... ohne "root" klappen die Tests nicht
./build-proot.sh -S -a amd64 -b "DEB_BUILD_OPTIONS=nocheck" -s noble -o jammy golang-golang-x-sys-dev
./build-proot.sh -S -a amd64 -s noble -o jammy golang-golang-x-term-dev
# ... geht nur mit "root", wegen langen Dateinamen (2025-01-03)
#     Korrigiert mit proot-5.4.0.3
./build-proot.sh -S -a amd64 -b "DEB_BUILD_OPTIONS=nostrip" -s noble -o jammy gocryptfs
```

golang-github-aperturerobotics-jacobsa-crypto
---------------------------------------------

### Jammy

Ich bin grob so vorgegangen:

- Ausgangspunkt: golang-github-jacobsa-crypto
- `uupdate -u jacobsa-crypto-1.0.2.tar.gz`
- Viele Dateien angepasst:
  - jacobsa/crypto -> aperturerobotics/jacobsa-crypto
- `dpkg-buildpackage` -> klappt

### Focal

- Ausgangspunkt sind die Pakete für Jammy
  - `mkdir build-proot-focal-amd64/rootfs/src/golang-github-aperturerobotics-jacobsa-crypto`
  - `cp debs/jammy/src/*aper* build-proot-focal-amd64/rootfs/src/golang-github-aperturerobotics-jacobsa-crypto`
- `proot -r build-proot-focal-amd64/rootfs -b /proc -b /dev -b /dev/pts -b /sys -w / bash`
- `cd /src/golang-github-aperturerobotics-jacobsa-crypto/`
- `dpkg-source -x *.dsc`
- `cd golang-github-aperturerobotics-jacobsa-crypto-1.0.2/`
- debian/control anpassen: "=13" -> "=12", "jammy" -> "focal"
- `LC_ALL=C dpkg-buildpackage` ... klappt!
- `cp build-proot-focal-amd64/rootfs/src/golang-github-aperturerobotics-jacobsa-crypto/golang-github-aperturerobotics-jacobsa-crypto* debs/focal/src/.`
- `mv -v debs/focal/src/*deb debs/focal/amd64/.`
- `./rebuild-ppa.sh`

qrterminal und golang-github-mdp-qrterminal-dev
-----------------------------------------------

### Jammy

- `./build-proot.sh -S -a amd64 -b "DEB_BUILD_OPTIONS=nostrip" -s noble -o jammy qrterminal`
  Erzeugt die Version 3.0.0. Danach noch manuell aktualisiert auf 3.2.0!

### Focal

Nachdem es für Jammy bereits gebaut wurde, ist es für Focal einfacher:

- `./build-proot.sh -S -a amd64 -b "DEB_BUILD_OPTIONS=nostrip" -s jammy -o focal qrterminal`
  TBD

### Probleme

#### Jammy - Aktualisierung von 3.0.0 auf 3.2.0

```
$ cp .../qrterminal-3.2.0.tar.gz* build-proot-jammy-amd64/rootfs/src/qrterminal/.
$ proot -S build-proot-jammy-amd64/rootfs -w / bash
# cd /src/qrterminal/qrterminal-3.0.0
# LC_ALL=C DEBFULLNAME="Uli Heller"   DEBEMAIL=uli@heller.cool uupdate -u ../qrterminal-3.2.0.tar.gz
uupdate: New Release will be 3.2.0-0ubuntu1.
uupdate: Untarring the new sourcecode archive ../qrterminal-3.2.0.tar.gz
uupdate: Unpacking the debian/ directory from version 3.0.0-2ubuntu0.24.04.2~uh~jammy1 worked fine.
uupdate: Remember: Your current directory is the OLD sourcearchive!
uupdate: Do a "cd ../qrterminal-3.2.0" to see the new package
```

debian/changelog anpassen:

```diff
--- debian/changelog.orig	2025-01-04 10:13:02.881677948 +0000
+++ debian/changelog	2025-01-04 10:12:52.629340960 +0000
@@ -1,4 +1,4 @@
-qrterminal (3.2.0-0ubuntu1) UNRELEASED; urgency=medium
+qrterminal (3.2.0-2ubuntu0.24.04.2~uh~jammy1) jammy; urgency=medium
 
   * New upstream release.
```

Nochmal bauen:

```
$ ./proot.sh build-proot-jammy-amd64/rootfs bash
# cd /src/qrterminal/qrterminal-3.2.0
# LC_ALL=C DEB_BUILD_OPTIONS=nostrip dpkg-buildpackage
...
dpkg-gencontrol: warning: Depends field of package qrterminal: substitution variable ${shlibs:Depends} used, but is not defined
   dh_md5sums -O--builddirectory=_build -O--buildsystem=golang
   dh_builddeb -O--builddirectory=_build -O--buildsystem=golang
dpkg-deb: building package 'golang-github-mdp-qrterminal-dev' in '../golang-github-mdp-qrterminal-dev_3.2.0-2ubuntu0.24.04.2~uh~jammy1_all.deb'.
dpkg-deb: building package 'qrterminal' in '../qrterminal_3.2.0-2ubuntu0.24.04.2~uh~jammy1_amd64.deb'.
 dpkg-genbuildinfo -O../qrterminal_3.2.0-2ubuntu0.24.04.2~uh~jammy1_amd64.buildinfo
 dpkg-genchanges -O../qrterminal_3.2.0-2ubuntu0.24.04.2~uh~jammy1_amd64.changes
dpkg-genchanges: info: including full source code in upload
 dpkg-source --after-build .
dpkg-buildpackage: info: full upload (original source is included)
```

Pakete ablegen:

```
$ cp build-proot-jammy-amd64/rootfs/src/qrterminal/*3.2.0* debs/jammy/src/.
$ mv -v debs/jammy/src/*3.2.0*deb debs/jammy/amd64/.
Datei umbenannt 'debs/jammy/src/golang-github-mdp-qrterminal-dev_3.2.0-2ubuntu0.24.04.2~uh~jammy1_all.deb' -> 'debs/jammy/amd64/./golang-github-mdp-qrterminal-dev_3.2.0-2ubuntu0.24.04.2~uh~jammy1_all.deb'
Datei umbenannt 'debs/jammy/src/qrterminal_3.2.0-2ubuntu0.24.04.2~uh~jammy1_amd64.deb' -> 'debs/jammy/amd64/./qrterminal_3.2.0-2ubuntu0.24.04.2~uh~jammy1_amd64.deb'
```

#### Jammy - Probleme mit "dwz"

```
$ ./build-proot.sh -S -a amd64 -s noble -o jammy qrterminal
...
   dh_compress -O--builddirectory=_build -O--buildsystem=golang
   dh_fixperms -O--builddirectory=_build -O--buildsystem=golang
   dh_missing -O--builddirectory=_build -O--buildsystem=golang
   dh_dwz -a -O--builddirectory=_build -O--buildsystem=golang
dwz: debian/qrterminal/usr/bin/qrterminal: Found compressed .debug_abbrev section, not attempting dwz compression
dh_dwz: error: dwz -- debian/qrterminal/usr/bin/qrterminal returned exit code 1
dh_dwz: error: Aborting due to earlier error
make: *** [debian/rules:4: binary] Error 2
dpkg-buildpackage: error: debian/rules binary subprocess returned exit status 2
Probleme beim Auspacken oder bauen - EXIT
rm -f qrterminal_3.0.0-2ubuntu0.24.04.2.debian.tar.xz qrterminal_3.0.0-2ubuntu0.24.04.2.dsc qrterminal_3.0.0.orig.tar.gz
build-proot.sh: error building package 'qrterminal' -> ABORTING
```

Korrekturversuch analog zu GOCRYPTFS - Option '-b "DEB_BUILD_OPTIONS=nostrip"':

```
$ ./build-proot.sh -S -a amd64 -b "DEB_BUILD_OPTIONS=nostrip" -s noble -o jammy qrterminal
...
dpkg-gencontrol: warning: Depends field of package qrterminal: substitution variable ${shlibs:Depends} used, but is not defined
   dh_md5sums -O--builddirectory=_build -O--buildsystem=golang
   dh_builddeb -O--builddirectory=_build -O--buildsystem=golang
dpkg-deb: building package 'golang-github-mdp-qrterminal-dev' in '../golang-github-mdp-qrterminal-dev_3.0.0-2ubuntu0.24.04.2~uh~jammy1_all.deb'.
dpkg-deb: building package 'qrterminal' in '../qrterminal_3.0.0-2ubuntu0.24.04.2~uh~jammy1_amd64.deb'.
 dpkg-genbuildinfo -O../qrterminal_3.0.0-2ubuntu0.24.04.2~uh~jammy1_amd64.buildinfo
 dpkg-genchanges -O../qrterminal_3.0.0-2ubuntu0.24.04.2~uh~jammy1_amd64.changes
dpkg-genchanges: warning: the current version (3.0.0-2ubuntu0.24.04.2~uh~jammy1) is earlier than the previous one (3.0.0-2ubuntu0.24.04.2)
dpkg-genchanges: info: not including original source code in upload
 dpkg-source --after-build .
dpkg-buildpackage: info: binary and diff upload (original source NOT included)
...
```

Hat geklappt!

#### Jammy - libqtermwidget5-1-dev:amd64 < none @un H > (>= 1.4.0)

Schrott! Ich habe mich vertippt und "qterminal" statt "qrterminal" gebaut!

```
$ ./build-proot.sh -S -a amd64 -s noble -o jammy qterminal
...

Selecting previously unselected package qterminal-build-deps.
(Reading database ... 53176 files and directories currently installed.)
Preparing to unpack qterminal-build-deps_1.4.0-0ubuntu5_all.deb ...
Unpacking qterminal-build-deps (1.4.0-0ubuntu5) ...
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
Correcting dependencies...Starting pkgProblemResolver with broken count: 1
Starting 2 pkgProblemResolver with broken count: 1
Investigating (0) qterminal-build-deps:amd64 < 1.4.0-0ubuntu5 @iU K Nb Ib >
Broken qterminal-build-deps:amd64 Depends on libqtermwidget5-1-dev:amd64 < none @un H > (>= 1.4.0)
  Removing qterminal-build-deps:amd64 because I can't find libqtermwidget5-1-dev:amd64
Done
...
```

Versuch 1: Versionsnummer entfernt auch debian/control.

```diff
--- debian/control~	2025-01-04 09:37:00.000000000 +0000
+++ debian/control	2025-01-04 09:40:49.997594053 +0000
@@ -13,7 +13,7 @@
                libkf5windowsystem-dev,
                libqt5svg5-dev,
                libqt5x11extras5-dev,
-               libqtermwidget5-1-dev (>= 1.4.0),
+               libqtermwidget5-1-dev,
                libutf8proc-dev,
                libx11-dev,
                lxqt-build-tools (>= 0.13.0)
```

Klappt leider auch nicht:

```
# mk-build-deps -i
...
Reading state information... Done
Correcting dependencies...Starting pkgProblemResolver with broken count: 1
Starting 2 pkgProblemResolver with broken count: 1
Investigating (0) qterminal-build-deps:amd64 < 1.4.0-0ubuntu5 @iU K Nb Ib >
Broken qterminal-build-deps:amd64 Depends on libqtermwidget5-1-dev:amd64 < none @un H >
  Removing qterminal-build-deps:amd64 because I can't find libqtermwidget5-1-dev:amd64
Done
 Done
Starting pkgProblemResolver with broken count: 0
Starting 2 pkgProblemResolver with broken count: 0
...

# apt-cache search ".*qter.*"|grep qtermwid
libqtermwidget5-0 - Terminal emulator widget for Qt 5 (shared libraries)
libqtermwidget5-0-dev - Terminal emulator widget for Qt 5 (development files)
qml-module-qmltermwidget - QML port of qtermwidget
qtermwidget5-data - Terminal emulator widget for Qt 5 (data files)
```

Also: Auch noch "5-1" ersetzen durch "5-0":

```diff
+++ debian/control	2025-01-04 09:45:12.120978303 +0000
@@ -13,7 +13,7 @@
                libkf5windowsystem-dev,
                libqt5svg5-dev,
                libqt5x11extras5-dev,
-               libqtermwidget5-1-dev (>= 1.4.0),
+               libqtermwidget5-0-dev,
                libutf8proc-dev,
                libx11-dev,
                lxqt-build-tools (>= 0.13.0)
```

Nun bei `mk-build-deps -i` - Mecker wegen lxqt-build-tools:

```
# mk-build-deps -i
...
Reading state information... Done
Correcting dependencies...Starting pkgProblemResolver with broken count: 1
Starting 2 pkgProblemResolver with broken count: 1
Investigating (0) qterminal-build-deps:amd64 < 1.4.0-0ubuntu5 @iU K Nb Ib >
Broken qterminal-build-deps:amd64 Depends on lxqt-build-tools:amd64 < none | 0.10.0-1ubuntu1 @un uH > (>= 0.13.0)
  Removing qterminal-build-deps:amd64 because I can't find lxqt-build-tools:amd64
Done
 Done
Starting pkgProblemResolver with broken count: 0
Starting 2 pkgProblemResolver with broken count: 0
...
```

Finale Version von "debian/control":

```diff
--- debian/control.orig	2025-01-04 09:44:59.733796416 +0000
+++ debian/control	2025-01-04 09:47:27.090114759 +0000
@@ -13,10 +13,10 @@
                libkf5windowsystem-dev,
                libqt5svg5-dev,
                libqt5x11extras5-dev,
-               libqtermwidget5-1-dev (>= 1.4.0),
+               libqtermwidget5-0-dev,
                libutf8proc-dev,
                libx11-dev,
-               lxqt-build-tools (>= 0.13.0)
+               lxqt-build-tools
 Standards-Version: 4.6.2
 Vcs-Browser: https://git.lubuntu.me/Lubuntu/qterminal-packaging
 Vcs-Git: https://git.lubuntu.me/Lubuntu/qterminal-packaging.git
```

Changelog anpassen:

```
# DEBFULLNAME="Uli Heller" \
  DEBEMAIL=uli@heller.cool \
  debchange --changelog debian/changelog \
    --distribution focal --local "~uli2" \
    "Manually repackaged for jammy/22.04"
```
