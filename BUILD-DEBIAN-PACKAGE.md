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

Ohne "root" - beinahe
---------------------

### Focal

```
./build-proot.sh -S -a amd64 -s noble -o focal golang-github-hanwen-go-fuse-dev
./build-proot.sh -S -a amd64 -b "DEB_BUILD_OPTIONS=nocheck" -s noble -o focal golang-github-moby-sys-dev
./build-proot.sh -S -a amd64 -s noble -o focal golang-github-sabhiram-go-gitignore-dev
./build-proot.sh -S -a amd64 -s noble -o focal golang-any
# ... ohne "root" klappen die Tests nicht
./build-proot.sh -S -a amd64 -b "DEB_BUILD_OPTIONS=nocheck" -s noble -o focal golang-golang-x-sys-dev
./build-proot.sh -S -a amd64 -s noble -o focal golang-golang-x-term-dev
./build-proot.sh -S -R -a amd64 -b "DEB_BUILD_OPTIONS=nostrip" -s noble -o focal gocryptfs
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
./build-proot.sh -S -R -a amd64 -b "DEB_BUILD_OPTIONS=nostrip" -s noble -o jammy gocryptfs
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
- `dpkg-buildpackage` ... klappt!
- 