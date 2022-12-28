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

### Create And Run A Single Container

For example:

- 32 bit
- Ubuntu-20.04 - focal

Execute:

```
./create-32bit-image.sh focal
  # Asks for sudo password
  # Creates "focal-(version)-(architecture)-lxcimage.tar.gz"
lxc image import focal-v1.6-i386-lxcimage.tar.gz --alias focal-v1.6-i386
lxc launch focal-v16-i386 my-running-image
```

### Create All Container Images

As of 2022-12-25, these are the container images:

- jammy-v1.7-amd64-lxcimage.tar.xz ....... 64bit Ubuntu 22.04
- uli-jammy-v1.7-amd64-lxcimage.tar.xz ... 64bit Ubuntu 22.04 with Uli's preferences
- jammy-v1.7-i386-lxcimage.tar.xz ........ 32bit Ubuntu 22.04
- uli-jammy-v1.7-i386-lxcimage.tar.xz .... 32bit Ubuntu 22.04 with Uli's preferences
- focal-v1.7-amd64-lxcimage.tar.xz ....... 64bit Ubuntu 20.04
- uli-focal-v1.7-amd64-lxcimage.tar.xz ... 64bit Ubuntu 20.04 with Uli's preferences
- focal-v1.7-i386-lxcimage.tar.xz ........ 32bit Ubuntu 20.04
- uli-focal-v1.7-i386-lxcimage.tar.xz .... 32bit Ubuntu 20.04 with Uli's preferences

Execute all of them by executing:

```
./create-image.sh -a x86_64 -k jammy
./create-image.sh -a x86_64 -k -U jammy
sudo rm -rf jammy jammy*lz4 jammy*txt
./create-image.sh -a i686 -k jammy
./create-image.sh -a i686 -k -U jammy
sudo rm -rf jammy jammy*lz4 jammy*txt

./create-image.sh -a x86_64 -k focal
./create-image.sh -a x86_64 -k -U focal
sudo rm -rf focal focal*lz4 focal*txt
./create-image.sh -a i686 -k focal
./create-image.sh -a i686 -k -U focal
sudo rm -rf focal focal*lz4 focal*txt
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
As of this writing, v1.6 is the latest release, so I'm using this:

```
$ cd /data
$ wget https://github.com/uli-heller/lxc-ubuntu-i386-amd64/releases/download/v1.6/lxc-ubuntu-i386-amd64-v1.6.tar.xz
  # Creates "lxc-ubuntu-i386-amd64-v1.6.tar.xz"
$ xz -cd lxc-ubuntu-i386-amd64-v1.6.tar.xz | tar xf -
  # Extracts to the folder "lxc-ubuntu-i386-amd64-v1.6"
$ cd lxc-ubuntu-i386-amd64-v1.6
```

Create The Image Files
----------------------

```
$ ./create-32bit-image.sh focal
  # Typically asks for sudo password
  # Takes a couple of minutes
  # Creates "focal-v1.6-i386-lxcimage.tar.xz"
```

Import And Start The LXC Image
-------------------------------

```
$ lxc image import focal-v1.6-i386-lxcimage.tar.xz --alias focal-v1.6-i386
$ lxc launch focal-v1.6-i386 focal-32bit
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
$ lxc image delete focal-v1.6-i386
```

Open Topics
-----------

No open topics

Solved Topics
-------------

### Handling of 'machine-id' and 'ssh_host*key'

According to [BUILDING_IMAGES](https://systemd.io/BUILDING_IMAGES/) and
[linuxcontainers - image handling](https://linuxcontainers.org/lxd/docs/master/image-handling/#)
the machine-id should be different for each and every container instance.
My observation is that they are basically constant for the standard containers.

I changed this for my containers:

- After `lxc launch`, the files are freshly initialized. Launching the same image twice
  creates different sets of machine-id and ssh_host*key files

- After `lxc copy`, the files are freshly initialized

- After `lxc rename`, the files are freshly initialized

### Why is the 32 bit image larger than my 64 bit images?

`apt-get clean` reduces the size!

### How to build the missing debs?

See [jammy-debs.md](jammy-debs.md) on how I build the DEBs for jammy (22.04)
and [focal-debs.md](focal-debs.md) for focal (20.04)!
