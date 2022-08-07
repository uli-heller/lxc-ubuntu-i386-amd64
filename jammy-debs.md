How to create missing debs for jammy 32 bit?
============================================

This description was done using version v0.5
and later v0.6
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

So: There is no easy way, we have to build the debs
on our own!

Building The Debs
-----------------

According to my experiences from the past, we need this deb:

- netplan.io

Within this pagagraph, I describe how to build it.

### Create The Non-working Image Keeping Intermediate Folders

Note: I'm using v0.6 for this! I've done some experiments based on
"fakeroot" and "fakechroot", but there seem to exist some issues
related to using a 32 bit chroot within a 64 bit host environment.

Create the image and the build folder:

```
$ cd .../lxc-ubuntu-32bit-v0.6
$ ./create-32bit-image.sh -k jammy jammy-build
...
Creating jammy-v06-9147717f2f
Instance published with fingerprint: 5852f056cba24437126629d729fc5ab9a11f2f6dee91b681126bcd389d2d9d5a
Image exported successfully!           
Datei umbenannt 'tmp-jammy-export/5852f056cba24437126629d729fc5ab9a11f2f6dee91b681126bcd389d2d9d5a.tar.gz' -> 'jammy-v0.6-lxcimage.tar.gz'
  # There is a folder named "jammy-build" afterwards
```

### Mount And Configure Build Chroot

```
$ cat jammy-build/etc/apt/sources.list|sed -e "s/^deb /deb-src /"|sudo tee jammy-build/etc/apt/sources.list.d/deb-src.list >/dev/null
$ sudo mkdir jammy-build/src
$ sudo ./mount.sh jammy-build
$ sudo chroot jammy-build apt-get update
...
Get:16 http://archive.ubuntu.com/ubuntu jammy-security/restricted Sources [19.0 kB]
Get:17 http://archive.ubuntu.com/ubuntu jammy-security/universe Sources [12.0 kB]
Fetched 19.9 MB in 5s (4264 kB/s)                        
Reading package lists... Done
$ sudo chroot jammy-build apt-get install -y dpkg-dev
  # installs "dpkg-source" required by "apt-get source ..."
```

### Running A Test Build

```
$ PACKAGE=(package-name)
$ sudo chroot jammy-build bash -c "cd /src && mkdir '${PACKAGE}' && cd '${PACKAGE}' && apt-get source '${PACKAGE}' && apt-get build-dep '${PACKAGE}'"
$ sudo chroot jammy-build bash -c "cd '/src/${PACKAGE}/'*/. && dpkg-buildpackage"
```

Typically, these are the outcomes:

- The build succeeds without any issue
- The build preparation fails because of missing dependencies -> build the dependencies
- The build fails (not observed so far)

#### Running Test Build Of netplan.io

```
$ PACKAGE=netplan.io
$ sudo chroot jammy-build bash -c "cd /src && mkdir '${PACKAGE}' && cd '${PACKAGE}' && apt-get source '${PACKAGE}' && apt-get build-dep '${PACKAGE}'"
...
The following packages have unmet dependencies:
 builddeps:netplan.io : Depends: python3-coverage but it is not installable
                        Depends: python3-netifaces but it is not installable
                        Depends: pandoc but it is not installable
                        Depends: openvswitch-switch but it is not installable
E: Unable to correct problems, you have held broken packages.
```

So there are missing dependencies. We have to build these
and come back to "netplan.io" once all of them are ready!

#### Tree Of Missing Debs

Here is the consolidated list of missing debs:

- netplan.io
  - python3-coverage
  - python3-netifaces
  - pandoc
    - ghc
      - ghc
  - openvswitch-switch
    - libdpdk-dev
      - libfdt-dev
      - libibverbs-dev
        - pandoc

#### Special Case pandoc

Tryining to build pandoc leads to the dependency "ghc" (somehow related to Haskall)
which has a dependency to itself. Currently, I have no idea on how to continue here,
so I'm going to modify all packages depending on pandoc. I'll remove pandoc from these.

### Building libibverbs-dev

We know that libibverbs-dev depends on pandoc for building.
So we have to patch it...

```
$ PACKAGE=libibverbs-dev
$ sudo chroot jammy-build bash -c "cd /src && mkdir '${PACKAGE}' && cd '${PACKAGE}' && apt-get source '${PACKAGE}'"
$ sudo patch -d "jammy-build/src/${PACKAGE}" <patches/jammy/rdma-core/rdma-core-39.0_no-pandoc.diff
$ sudo chroot jammy-build bash -c "cd '/src/${PACKAGE}/'*/. && dpkg-buildpackage"
  # Shows lots of missing packages -> install them via apt-get
$ sudo chroot jammy-build apt-get install -y cmake cython3 libnl-3-dev libnl-route-3-dev libsystemd-dev libudev-dev ninja-build
$ sudo chroot jammy-build bash -c "cd '/src/${PACKAGE}/'*/. && dpkg-buildpackage"
```

### Installing libibverbs-dev

```
$ PACKAGE=libibverbs-dev
$ sudo chroot jammy-build bash -c "cd '/src/${PACKAGE}/'; apt-get install ./libibverbs-dev_39.0-1dp01~jammy1_i386.deb ./ibverbs-providers_39.0-1dp01~jammy1_i386.deb ./libibverbs1_39.0-1dp01~jammy1_i386.deb"
  # Later on, we will detect that we need "rdma-core", too. So we install it, too!
$ sudo chroot jammy-build bash -c "cd '/src/${PACKAGE}/'; apt-get install ./rdma-core_39.0-1dp01~jammy1_i386.deb"
```

### Building libfdt-dev

```
$ PACKAGE=libfdt-dev
$ sudo chroot jammy-build bash -c "cd /src && mkdir '${PACKAGE}' && cd '${PACKAGE}' && apt-get source '${PACKAGE}' && apt-get build-dep '${PACKAGE}'"
$ sudo chroot jammy-build bash -c "cd '/src/${PACKAGE}/'*/. && dpkg-buildpackage"
```

### Installing libfdt-dev

```
$ PACKAGE=libfdt-dev
$ sudo chroot jammy-build bash -c "cd '/src/${PACKAGE}/'; apt-get install ./libfdt-dev_1.6.1-1_i386.deb ./libfdt1_1.6.1-1_i386.deb"
```

### Building libdpdk-dev

```
$ PACKAGE=libdpdk-dev
$ sudo chroot jammy-build bash -c "cd /src && mkdir '${PACKAGE}' && cd '${PACKAGE}' && apt-get source '${PACKAGE}' && apt-get build-dep '${PACKAGE}'"
$ sudo chroot jammy-build bash -c "cd '/src/${PACKAGE}/'*/. && dpkg-buildpackage"
```

### Installing libdpdk-dev

```
$ PACKAGE=libdpdk-dev
$ sudo chroot jammy-build bash -c "cd '/src/${PACKAGE}/'; apt-get install  ./libdpdk-dev_21.11.1-0ubuntu0.3_i386.deb ./librte*.deb"
```

### Building openvswitch-switch

```
$ PACKAGE=openvswitch-switch
$ sudo chroot jammy-build bash -c "cd /src && mkdir '${PACKAGE}' && cd '${PACKAGE}' && apt-get source '${PACKAGE}' && apt-get build-dep '${PACKAGE}'"
$ sudo chroot jammy-build bash -c "cd '/src/${PACKAGE}/'*/. && dpkg-buildpackage"
```

### Installing openvswitch-switch

```
$ PACKAGE=openvswitch-switch
$ sudo chroot jammy-build bash -c "cd '/src/${PACKAGE}/'; apt-get install ./openvswitch-switch_2.17.0-0ubuntu1_i386.deb ./openvswitch-common_2.17.0-0ubuntu1_i386.deb"
```

### Building python3-coverage

```
$ PACKAGE=python3-coverage
$ sudo chroot jammy-build bash -c "cd /src && mkdir '${PACKAGE}' && cd '${PACKAGE}' && apt-get source '${PACKAGE}' && apt-get build-dep '${PACKAGE}'"
$ sudo chroot jammy-build bash -c "cd '/src/${PACKAGE}/'*/. && dpkg-buildpackage"
```

### Installing python3-coverage

```
$ PACKAGE=python3-coverage
$ sudo chroot jammy-build bash -c "cd '/src/${PACKAGE}/'; apt-get install ./python3-coverage_6.2+dfsg1-2build1_i386.deb"
```

### Building python3-netifaces

```
$ PACKAGE=python3-netifaces
$ sudo chroot jammy-build bash -c "cd /src && mkdir '${PACKAGE}' && cd '${PACKAGE}' && apt-get source '${PACKAGE}' && apt-get build-dep '${PACKAGE}'"
$ sudo chroot jammy-build bash -c "cd '/src/${PACKAGE}/'*/. && dpkg-buildpackage"
```

### Installing python3-netifaces

```
$ PACKAGE=python3-netifaces
$ sudo chroot jammy-build bash -c "cd '/src/${PACKAGE}/'; apt-get install ./python3-netifaces_0.11.0-1build2_i386.deb"
```

### Building netplan.io

We know that netplan.io depends on pandoc for building.
So we have to patch it...

```
$ PACKAGE=netplan.io
$ sudo chroot jammy-build bash -c "cd /src && mkdir '${PACKAGE}' && cd '${PACKAGE}' && apt-get source '${PACKAGE}'"
$ sudo patch -d "jammy-build/src/${PACKAGE}" <patches/jammy/netplan.io/netplan.io_no-pandoc.diff
$ sudo chroot jammy-build bash -c "cd '/src/${PACKAGE}/'*/. && dpkg-buildpackage"
  # Shows lots of missing packages -> install them via apt-get
$ sudo chroot jammy-build apt-get install -y cmake cython3 libnl-3-dev libnl-route-3-dev libsystemd-dev libudev-dev ninja-build
$ sudo chroot jammy-build bash -c "cd '/src/${PACKAGE}/'*/. && dpkg-buildpackage"
```


### Installing netplan.io

```
$ PACKAGE=netplan.io
$ sudo chroot jammy-build bash -c "cd '/src/${PACKAGE}/'; apt-get install ./netplan.io_0.104-0dp01~jammy2.1_i386.deb ./libnetplan0_0.104-0dp01~jammy2.1_i386.deb"
```

### Unmounting The Build Chroot

```
$ sudo ./umount.sh jammy-build
```
