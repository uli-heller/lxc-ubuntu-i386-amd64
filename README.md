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
  # Creates "focal-metadata.tar.gz" and "focal-lxc.tar.gz"
```

Import the LXC Image
--------------------

```
$ lxc image import focal-metadata.tar.gz focal-lxc.tar.gz --alias focal-32
Image imported with fingerprint: 59535d55802cb34506da20cbe0079beb020987fa5a131a802a8653da296ab683
```

Launch the LXC Container
------------------------

```
$ lxc launch focal-32 my-running-image
Creating my-running-image
Starting my-running-image
```

Query the LXC Container
-----------------------

```
$ lxc ls my-running-.image
+------------------+---------+----------------------+------+-----------+-----------+
|       NAME       |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+------------------+---------+----------------------+------+-----------+-----------+
| my-running-image | RUNNING | 10.253.205.63 (eth0) |      | CONTAINER | 0         |
+------------------+---------+----------------------+------+-----------+-----------+
```

Note: There is an IP address available for the container!

Cleaning Up - Delete LXC Container And LXC Image
------------------------------------------------

```
$ lxc stop my-running-image
$ lxc delete my-running-image
$ lxc image delete focal-32
```

Not Yet Documented
------------------

- How to build the missing debs?
