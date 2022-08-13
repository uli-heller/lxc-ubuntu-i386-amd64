Howto create a 32/64 bit ubuntu container
=====================================

Originally, I created this repo to describe how to setup the
container. I planned to add the missing debs to this repo, too.
Over time, I extended the goals. So now:

- There is are ready-to-use 32 bit images within the release
- There is are ready-to-use 64 bit images within the release
- There is a script creating the ready-to-use images

The images are quite a bit smaller than the ubuntu standard images.

TLDR
----

```
./create-32bit-image.sh focal
  # Asks for sudo password
  # Creates "focal-(version)-(architecture)-lxcimage.tar.gz"
lxc image import focal-v1.5-i386-lxcimage.tar.gz --alias focal-32bit-import
lxc launch focal-32bit-import my-running-image
```

Select Your Playground
----------------------

Select a folder with roughly 2 GB free space. For me, this is "/data":

```
$ df -h /data
Filesystem                     Size  Used Avail Use% Mounted on
/dev/mapper/ubuntu--vg-datalv  300G  199G  100G  67% /data
```

Download And Extract A Release
------------------------------

Select the release you want to play with [here at Github](https://github.com/uli-heller/lxc-ubuntu-i386-amd64/releases).
As of this writing, v1.5 is the latest release, so I'm using this:

```
$ cd /data
$ wget https://github.com/uli-heller/lxc-ubuntu-i386-amd64/releases/download/v1.5/lxc-ubuntu-i386-amd64-v1.5.tar.xz
  # Creates "lxc-ubuntu-i386-amd64-v1.5.tar.xz"
$ xz -cd lxc-ubuntu-i386-amd64-v1.5.tar.xz | tar xf -
  # Extracts to the folder "lxc-ubuntu-i386-amd64-v1.5"
$ cd lxc-ubuntu-i386-amd64-v1.5
```

Create The Image Files
----------------------

```
$ ./create-32bit-image.sh focal
  # Typically asks for sudo password
  # Takes a couple of minutes
  # Creates "focal-v1.5-i386-lxcimage.tar.xz"
```

Import And Start The LXC Image
-------------------------------

```
$ lxc image import focal-v1.5-i386-lxcimage.tar.xz --alias focal-32bit-import
$ lxc launch focal-32bit-import focal-32bit
$ lxc ls
+------------------+---------+----------------------+------+-----------+-----------+
|       NAME       |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+------------------+---------+----------------------+------+-----------+-----------+
| focal-32bit      | RUNNING | 10.253.205.63 (eth0) |      | CONTAINER | 0         |
+------------------+---------+----------------------+------+-----------+-----------+
```

Cleaning Up - Delete LXC Container And LXC Image
------------------------------------------------

```
$ lxc stop focal-32bit
$ lxc delete focal-32bit
$ lxc image delete focal-32bit-import
```

Open Topics
-----------

No open topics

Solved Topics
-------------

### Why is the 32 bit image larger than my 64 bit images?

`apt-get clean` reduces the size!

### How to build the missing debs?

See [jammy-debs.md](jammy-debs.md) on how I build the DEBs for jammy (22.04)
and [focal-debs.md](focal-debs.md) for focal (20.04)!
