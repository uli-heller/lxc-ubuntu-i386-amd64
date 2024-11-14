How to create missing debs for noble 32 bit?
============================================

This description was done using version v1.11
of "lxc-ubuntu-32bit".

create-32bit-image.sh noble
---------------------------

Just try to create the image:

```
$ create-32bit-image.sh noble
...
```

Try it out:

```
$ lxc image import noble-*-lxcimage.tar.gz --alias noble-32-import
$ lxc launch noble-32 noble-32-import
$ lxc ls noble-32
+----------+---------+------+------+-----------+-----------+
|   NAME   |  STATE  | IPV4 | IPV6 |   TYPE    | SNAPSHOTS |
+----------+---------+------+------+-----------+-----------+
| noble-32 | RUNNING |      |      | CONTAINER | 0         |
+----------+---------+------+------+-----------+-----------+
```

So: No IP address unfortunately!

Cleanup:

```
$ lxc delete --force noble-32
$ lxc image delete noble-32-import
```

Create missing debs
-------------------

### at

```
$ ./build.sh -a i386 -o noble -i noble-v1.11-7-g55ca80f-i386-lxcimage.tar.xz at
...
```

### logrotate

```
$ ./build.sh -a i386 -o noble logrotate
...
```

### netplan.io

```
$ ./build.sh -a i386 -o noble netplan.io
...
The following packages have unmet dependencies:
 builddeps:netplan.io : Depends: python3-cffi but it is not going to be installed
                        Depends: python3-coverage but it is not installable
                        Depends: python3-pytest-cov but it is not going to be installed
                        Depends: python3-netifaces but it is not installable
                        Depends: pandoc but it is not installable
```

So we have to build lots of dependencies first:

```
./build.sh -a i386 -o noble python3-cffi
./build.sh -a i386 -o noble python3-coverage
./build.sh -a i386 -o noble python3-pytest-cov
./build.sh -a i386 -o noble python3-netifaces
./build.sh -a i386 -o noble pandoc # lots of dependencies - see below
```

### pandoc

```
$ ./build.sh -a i386 -o noble pandoc
...
dpkg-checkbuilddeps: error: Unmet build dependencies: alex cdbs dh-buildinfo ghc ghc-prof happy haskell-devscripts libghc-hslua-cli-dev (<< 1.5) libghc-hslua-cli-dev (>= 1.4.1) libghc-hslua-cli-prof libghc-pandoc-dev (>= 3.1.3) libghc-pandoc-lua-engine-dev (<< 0.3) libghc-pandoc-lua-engine-dev (>= 0.2) libghc-pandoc-lua-engine-prof libghc-pandoc-prof libghc-temporary-dev (<< 1.4) libghc-temporary-prof pandoc-data
...
```

Trying to build the missing dependencies leads to:

- ghc -> ghc:nativ -> creates nothing

So I decided to create a netplan package without a dependency to pandoc!

### netplan.io (again)

```
$ ./build.sh -a i386 -o noble netplan.io
  # Creates build-noble-i386/rootfs/src/netplan.io/netplan.io-1.0.1
  # Try to build it using "sudo chroot build-noble-i386/rootfs"
  # Which files do need modification?
  #   - debian/control
  #   - debian/netplan-generator.install
  #   - debian/netplan.io.install
```

Once you know how to build netplan.io without pandoc,
copy the "old" files into

- patches/noble/prepare-netplan-patch/netplan.io_no-pandoc/orig

and the new files into

- patches/noble/prepare-netplan-patch/netplan.io_no-pandoc/no-pandoc

Create a DIFF:

```
diff -ur \
  patches/noble/prepare-netplan-patch/netplan.io_no-pandoc/orig \
  patches/noble/prepare-netplan-patch/netplan.io_no-pandoc/no-pandoc \
  >patches/noble/netplan.io/no-pandoc.diff
```

Additionally, copy the files "changelog.paramrters"
and "changelog.tpl" from "patches/jammy/netplan.io"
to "patches/noble/netplan.io".

Now you'll be able to build:

```
$ ./build.sh -a i386 -o noble netplan.io
```

### joe-jupp

```
./build.sh -a i386 -o noble jupp
./build.sh -a i386 -o noble joe-jupp
```
