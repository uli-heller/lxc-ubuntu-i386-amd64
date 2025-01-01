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

build.sh
--------

Erweitert um die Option "-s source-os".

Aufrufe:

- Baut das Paket "gocryptfs" für 20.04 (focal): `./build.sh -a amd64 -o focal gocryptfs`
  - Paket liegt danach unter debs/focal/amd64/gocryptfs_1.7.1-1ubuntu0.1_amd64.deb
- Baut das Paket "gocryptfs" für 20.04 (focal): `./build.sh -a amd64 -o focal -s focal gocryptfs`
  - Paket liegt danach unter debs/focal/amd64/gocryptfs_1.7.1-1ubuntu0.1_amd64.deb
- Baut das Paket "gocryptfs" aus 22.04 (jammy) für 20.04 (focal): `./build.sh -a amd64 -s jammy -o focal gocryptfs`
  - Fehlermeldungen!

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
