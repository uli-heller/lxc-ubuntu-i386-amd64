How to create missing debs for jammy 32 bit?
============================================

This description was done using version v0.5
of "lxc-ubuntu-32bit".

create-32bit-image.sh jammy
---------------------------

Just try to create the image:

```
$ create-32bit-image.sh jammy
...
Creating jammy-v05-9c6bd9e4e0
Instance published with fingerprint: a4553c13d2ed21222b78b978895dac28edabf68dc7a0a47de5f4cbbae4bc0d27
Image exported successfully!           
Datei umbenannt 'tmp-jammy-export/a4553c13d2ed21222b78b978895dac28edabf68dc7a0a47de5f4cbbae4bc0d27.tar.gz' -> 'jammy-v0.5-lxcimage.tar.gz'
```

Try it out:

```
$ lxc image import jammy-v0.5-lxcimage.tar.gz --alias jammy-import
$ lxc launch jammy32 jammy-import
$ lxc ls jammy32
+---------+---------+------+------+-----------+-----------+
|  NAME   |  STATE  | IPV4 | IPV6 |   TYPE    | SNAPSHOTS |
+---------+---------+------+------+-----------+-----------+
| jammy32 | RUNNING |      |      | CONTAINER | 0         |
+---------+---------+------+------+-----------+-----------+
```

So: No IP address unfortunately!

Cleanup:

```
$ lxc delete --force jammy32
$ lxc image delete jammy-import
```

Use the debs from "focal"
-------------------------

Modify "create-32bit-image.sh" and VERSION:

create-32bit-image.sh:

```diff
--- create-32bit-image.sh.orig	2022-08-07 07:44:57.332552947 +0200
+++ create-32bit-image.sh	2022-08-07 07:46:20.504391786 +0200
@@ -46,9 +46,9 @@
 # netplan.io
 # libnetplan0
 # python3-netifaces
-test -d "debs/${OS}" && {
+test -d "debs/focal" && {
   >"./install-packages-${OS}"
-  for d in "debs/${OS}/"*; do
+  for d in "debs/focal/"*; do
     b="$(basename "${d}")"
     sudo cp "${d}" "./${OSDIR}/var/cache/apt/archives/${b}"
     echo "/var/cache/apt/archives/${b}" >>"./install-packages-${OS}"
```

VERSION:

```diff
--- VERSION.orig	2022-08-07 07:48:15.836168353 +0200
+++ VERSION	2022-08-07 07:36:35.697525724 +0200
@@ -1 +1 @@
-v0.5
+v0.5-p1
```

Try to create the image:

```
$ create-32bit-image.sh jammy
...
Building dependency tree... Done
Reading state information... Done
Note, selecting 'libnetplan0' instead of '/var/cache/apt/archives/libnetplan0_0.104-0ubuntu2~20.04.2_i386.deb'
Note, selecting 'netplan.io' instead of '/var/cache/apt/archives/netplan.io_0.104-0ubuntu2~20.04.2_i386.deb'
Note, selecting 'python3-netifaces' instead of '/var/cache/apt/archives/python3-netifaces_0.10.4-1ubuntu4_i386.deb'
Some packages could not be installed. This may mean that you have
requested an impossible situation or if you are using the unstable
distribution that some required packages have not yet been created
or been moved out of Incoming.
The following information may help to resolve the situation:

The following packages have unmet dependencies:
 python3-netifaces : Depends: python3 (< 3.9) but 3.10.4-0ubuntu2 is to be installed
E: Unable to correct problems, you have held broken packages.
...
```

Try To Install From Regular Package Sources
-------------------------------------------

Modify "create-32bit-image.sh" and VERSION:

create-32bit-image.sh:

```diff
--- create-32bit-image.sh.orig	2022-08-07 07:44:57.332552947 +0200
+++ create-32bit-image.sh	2022-08-07 07:54:25.615833997 +0200
@@ -46,6 +46,8 @@
 # netplan.io
 # libnetplan0
 # python3-netifaces
+sudo chroot "./${OSDIR}" apt-get install netplan.io
+
 test -d "debs/${OS}" && {
   >"./install-packages-${OS}"
   for d in "debs/${OS}/"*; do
```

VERSION:

```diff
--- VERSION.orig	2022-08-07 07:48:15.836168353 +0200
+++ VERSION	2022-08-07 07:53:06.751777555 +0200
@@ -1 +1 @@
-v0.5
+v0.5-p2
```

Try to create the image:

```
$ create-32bit-image.sh jammy
...
Building dependency tree... Done
Reading state information... Done
Package netplan.io is not available, but is referred to by another package.
This may mean that the package is missing, has been obsoleted, or
is only available from another source

E: Package 'netplan.io' has no installation candidate
Hit:1 http://archive.ubuntu.com/ubuntu jammy InRelease
Hit:2 http://archive.ubuntu.com/ubuntu jammy-updates InRelease
Hit:3 http://archive.ubuntu.com/ubuntu jammy-backports InRelease
...
```
