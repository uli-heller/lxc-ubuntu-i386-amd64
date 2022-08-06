Howto create a 32bit ubuntu-20.04 container
===========================================

Originally, I created this repo to describe how to setup the
container. I planned to add the missing debs to this repo, too.
Over time, I extended the goals. So now:

- There is a ready-to-use 32 bit image within the release
- There is a script creating the ready-to-use image

TLDR
----

```
./create-32bit-image.sh focal
# Asks for sudo password
# Creates "focal-(version)-lxcimage.tar.gz"
lxc image import focal-v0.5-lxcimage.tar.gz --alias focal-v0.5
lxc launch focal-v0.5 my-running-image
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

Select the release you want to play with [here at Github](https://github.com/uli-heller/lxc-ubuntu-32bit/releases).
As of this writing, v0.5 is the latest release, so I'm using this:

```
$ cd /data
$ wget https://github.com/uli-heller/lxc-ubuntu-32bit/releases/download/v0.5/lxc-ubuntu-32bit-v0.5.tar.xz
  # Creates "lxc-ubuntu-32bit-v0.5.tar.xz"
$ xz -cd lxc-ubuntu-32bit-v0.5.tar.xz | tar xf -
  # Extracts to the folder "lxc-ubuntu-32bit-v0.5"
$ cd lxc-ubuntu-32bit-v0.5
```

Create The Image Files
----------------------

```
$ ./create-32bit-image.sh focal
  # Typically asks for sudo password
  # Takes a couple of minutes
  # Creates "focal-v0.5-lxcimage.tar.gz"
```

Import And Start The LXC Image
-------------------------------

```
$ lxc image import focal-v0.5-lxcimage.tar.gz --alias focal-v0.5-import
$ lxc launch focal-v0.5-import focal-v0.5
$ lxc ls
+------------------+---------+----------------------+------+-----------+-----------+
|       NAME       |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+------------------+---------+----------------------+------+-----------+-----------+
| focal-v0.5       | RUNNING | 10.253.205.63 (eth0) |      | CONTAINER | 0         |
+------------------+---------+----------------------+------+-----------+-----------+
```

Cleaning Up - Delete LXC Container And LXC Image
------------------------------------------------

```
$ lxc stop focal-v0.5
$ lxc delete focal-v0.5
$ lxc image delete focal-v0.5-import
```

Open Topics
-----------

- How to build the missing debs?

Solved Topics
-------------

### Why is the 32 bit image larger than my 64 bit images?

`apt-get clean` reduces the size!
