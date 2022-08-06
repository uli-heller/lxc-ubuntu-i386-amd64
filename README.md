Howto create a 32bit ubuntu-20.04 container
===========================================

TLDR
----

```
./create-32bit-image.sh focal
# Asks for sudo password
# Creates
# - focal-metadata.tar.gz
# - focal-lxc.tar.gz
lxc image import focal-metadata.tar.gz focal-lxc.tar.gz --alias focal-32
lxc launch focal-32 my-running-image
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
As of this writing, v0.3 is the latest release, so I'm using this:

```
$ cd /data
$ wget https://github.com/uli-heller/lxc-ubuntu-32bit/releases/download/v0.3/lxc-ubuntu-32bit-v0.3.tar.xz
  # Creates "lxc-ubuntu-32bit-v0.3.tar.xz"
$ xz -cd lxc-ubuntu-32bit-v0.3.tar.xz | tar xf -
  # Extracts to the folder "lxc-ubuntu-32bit-v0.3"
$ cd lxc-ubuntu-32bit-v0.3
```

Create The Image Files
----------------------

```
$ ./create-32bit-image.sh focal
  # Typically asks for sudo password
  # Takes a couple of minutes
  # Creates "focal-v0.3-lxcimage.tar.gz"
```

Import And Start The LXC Image
-------------------------------

```
$ lxc image import focal-v0.3-lxcimage.tar.gz --alias focal-v0.3-import
$ lxc launch focal-v0.3-import focal-v0.3
$ lxc ls
+------------------+---------+----------------------+------+-----------+-----------+
|       NAME       |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+------------------+---------+----------------------+------+-----------+-----------+
| focal-v0.3       | RUNNING | 10.253.205.63 (eth0) |      | CONTAINER | 0         |
+------------------+---------+----------------------+------+-----------+-----------+
```

Cleaning Up - Delete LXC Container And LXC Image
------------------------------------------------

```
$ lxc stop focal-v0.3
$ lxc delete focal-v0.3
$ lxc image delete focal-v0.3-import
```

Not Yet Documented
------------------

- How to build the missing debs?
