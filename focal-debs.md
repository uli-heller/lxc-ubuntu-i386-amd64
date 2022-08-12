How to create missing debs for focal 32 bit?
============================================

This description was done using version v0.6
of "lxc-ubuntu-32bit".

According to my experiences from the past, we need this deb:

- netplan.io

Within this pagagraph, I describe how to build it.

```
$ cd .../lxc-ubuntu-32bit-v0.6
$ ./create-32bit-image.sh -k focal focal-build
...
Creating focal-v06-c6f8c45cac
Instance published with fingerprint: 2427cfabcaf64df8a0d3ea8532c424826b47edba270efd19ca247ae717079905
Image exported successfully!           
Datei umbenannt 'tmp-focal-export/2427cfabcaf64df8a0d3ea8532c424826b47edba270efd19ca247ae717079905.tar.gz' -> 'focal-v0.6-lxcimage.tar.gz'
  # There is a folder named "focal-build" afterwards
```

## Configure Build Chroot

```
$ cat focal-build/etc/apt/sources.list|sed -e "s/^deb /deb-src /"|sudo tee focal-build/etc/apt/sources.list.d/deb-src.list >/dev/null
$ sudo mkdir focal-build/src
$ sudo ./mount.sh focal-build
$ sudo chroot focal-build apt-get update
...
Get:16 http://archive.ubuntu.com/ubuntu focal-security/main Sources [242 kB]
Get:17 http://archive.ubuntu.com/ubuntu focal-security/universe Sources [94.8 kB]
Get:18 http://archive.ubuntu.com/ubuntu focal-security/restricted Sources [44.5 kB]
Fetched 12.0 MB in 3s (3587 kB/s)                       
Reading package lists... Done
$ sudo chroot focal-build apt-get install -y dpkg-dev
  # installs "dpkg-source" required by "apt-get source ..."
$ sudo chroot focal-build apt-get install -y quilt
$ sudo ./umount.sh focal-build
```

## Running A Test Build

```
$ PACKAGE=(package-name)
$ ./build.sh focal-build "${PACKAGE}"
```

Typically, these are the outcomes:

- The build succeeds without any issue
- The build preparation fails because of missing dependencies -> build the dependencies
- The build fails (not observed so far)

## Running Test Build Of netplan.io

```
$ PACKAGE=netplan.io
$ ./build.sh focal-build "${PACKAGE}"
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

## Tree Of Missing Debs

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
- isc-dhcp-client (optional)
  - libbind-export-dev (optional)
- logrotate (optional)

## Special Case pandoc

Tryining to build pandoc leads to the dependency "ghc" (somehow related to Haskall)
which has a dependency to itself. Currently, I have no idea on how to continue here,
so I'm going to modify all packages depending on pandoc. I'll remove pandoc from these.

## Building libfdt-dev

```
$ PACKAGE=libfdt-dev
$ ./build.sh focal-build "${PACKAGE}"
```

## Installing libfdt-dev

```
$ PACKAGE=libfdt-dev
$ ./install.sh focal-build "${PACKAGE}" ./libfdt-dev_1.5.1-1_i386.deb ./libfdt1_1.5.1-1_i386.deb
```

## Building libdpdk-dev

```
$ PACKAGE=libdpdk-dev
$ ./build.sh focal-build "${PACKAGE}"
```

## Installing libdpdk-dev

```
$ PACKAGE=libdpdk-dev
  # TODO: Does this work? ---------------------------------------------------------------vvvvvvvvvvvvv
$ ./install.sh focal-build "${PACKAGE}" ./libdpdk-dev_19.11.12-0ubuntu0.20.04.1_i386.deb ./librte*.deb
```

## Building python3-netifaces

```
$ PACKAGE=python3-netifaces
$ ./build.sh focal-build "${PACKAGE}"
```

## Installing python3-netifaces

```
$ PACKAGE=python3-netifaces
$ ./install.sh focal-build "${PACKAGE}" ./python3-netifaces_0.10.4-1ubuntu4_i386.deb
```

## Building openvswitch-switch

```
$ PACKAGE=openvswitch-switch
$ sudo ./mount.sh focal-build
$ sudo chroot focal-build bash -c "cd /src && mkdir '${PACKAGE}' && cd '${PACKAGE}' && apt-get source '${PACKAGE}' && apt-get build-dep '${PACKAGE}'"
$ sudo chroot focal-build bash -c "cd '/src/${PACKAGE}/'*/. && dpkg-buildpackage"
  # Aborts with an error
  #     File "setup.py", line 28
  #       file=sys.stderr)
  #           ^
  #   SyntaxError: invalid syntax
$ sudo chroot focal-build rm -rf "/srv/${PACKAGE}"
$ sudo chroot focal-build bash -c "cd /src && mkdir '${PACKAGE}' && cd '${PACKAGE}' && apt-get source '${PACKAGE}' && apt-get build-dep '${PACKAGE}'"
$ sudo patch -d "focal-build/src/${PACKAGE}" -p0 <patches/focal/openvswitch/openvswitch-2.13.5_python2.diff
$ sudo chroot focal-build bash -c "cd '/src/${PACKAGE}/'*/. && dpkg-buildpackage"
$ sudo ./umount.sh focal-build
```

## Installing openvswitch-switch

```
$ PACKAGE=openvswitch-switch
$ ./install.sh focal-build "${PACKAGE}" ./openvswitch-switch_2.13.5-0dp01~focal1_i386.deb ./openvswitch-common_2.13.5-0dp01~focal1_i386.deb
```

## Building python3-coverage

```
$ PACKAGE=python3-coverage
$ ./build.sh focal-build "${PACKAGE}"
```

## Installing python3-coverage

```
$ PACKAGE=python3-coverage
$ ./install.sh focal-build "${PACKAGE}" ./python3-coverage_4.5.2+dfsg.1-4ubuntu1_i386.deb
```

## Building netplan.io

We know that netplan.io depends on pandoc for building.
So we have to patch it...

```
$ PACKAGE=netplan.io
$ sudo ./mount.sh focal-build
$ sudo chroot focal-build bash -c "cd /src && mkdir '${PACKAGE}' && cd '${PACKAGE}' && apt-get source '${PACKAGE}'"
$ sudo patch -d "focal-build/src/${PACKAGE}" <patches/focal/netplan.io/netplan.io_no-pandoc.diff
$ sudo chroot focal-build bash -c "cd '/src/${PACKAGE}/'*/. && dpkg-buildpackage"
  # Shows lots of missing packages -> install them via apt-get
$ sudo chroot focal-build apt-get install -y cmake cython3 libnl-3-dev libnl-route-3-dev libsystemd-dev libudev-dev ninja-build
$ sudo chroot focal-build bash -c "cd '/src/${PACKAGE}/'*/. && dpkg-buildpackage"
$ sudo ./umount.sh focal-build
```

### Installing netplan.io

```
$ PACKAGE=netplan.io
$ ./install.sh focal-build "${PACKAGE}" ./netplan.io_0.104-0dp01~focal2.1_i386.deb ./libnetplan0_0.104-0dp01~focal2.1_i386.deb
```

### Optional Packages

#### Building libbind-export-dev

```
$ PACKAGE=libbind-export-dev
$ ./build.sh focal-build "${PACKAGE}"
```

#### Installing libbind-export-dev

```
$ PACKAGE=libbind-export-dev
$ ./install.sh focal-build "${PACKAGE}" ./libbind-export-dev_9.11.16+dfsg-3~ubuntu1_i386.deb ./libdns-export1109_9.11.16+dfsg-3~ubuntu1_i386.deb ./libirs-export161_9.11.16+dfsg-3~ubuntu1_i386.deb ./libisc-export1105_9.11.16+dfsg-3~ubuntu1_i386.deb ./libisccc-export161_9.11.16+dfsg-3~ubuntu1_i386.deb ./libisccfg-export163_9.11.16+dfsg-3~ubuntu1_i386.deb
```

#### Building isc-dhcp-client

```
$ PACKAGE=isc-dhcp-client
$ ./build.sh focal-build "${PACKAGE}"
```

#### Installing isc-dhcp-client

```
$ PACKAGE=isc-dhcp-client
$ ./install.sh focal-build "${PACKAGE}" ./isc-dhcp-client_4.4.1-2.1ubuntu5.20.04.3_i386.deb
```

#### Building logrotate

```
$ PACKAGE=logrotate
$ ./build.sh focal-build "${PACKAGE}"
```

#### Installing isc-dhcp-client

```
$ PACKAGE=logrotate
$ ./install.sh focal-build "${PACKAGE}" ./logrotate_3.14.0-4ubuntu3_i386.deb
```
