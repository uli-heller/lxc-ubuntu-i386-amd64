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

As of 2022-12-29, these are the container images:

- jammy-v1.8-amd64-lxcimage.tar.xz ....... 64bit Ubuntu 22.04
- jammy-v1.8-i386-lxcimage.tar.xz ........ 32bit Ubuntu 22.04
- focal-v1.8-amd64-lxcimage.tar.xz ....... 64bit Ubuntu 20.04
- focal-v1.8-i386-lxcimage.tar.xz ........ 32bit Ubuntu 20.04

Special images, **not for general use**:
- uli-jammy-v1.8-amd64-lxcimage.tar.xz ... 64bit Ubuntu 22.04 with Uli's preferences
- uli-jammy-v1.8-i386-lxcimage.tar.xz .... 32bit Ubuntu 22.04 with Uli's preferences
- uli-focal-v1.8-amd64-lxcimage.tar.xz ... 64bit Ubuntu 20.04 with Uli's preferences
- uli-focal-v1.8-i386-lxcimage.tar.xz .... 32bit Ubuntu 20.04 with Uli's preferences
- dp-jammy-v1.8-amd64-lxcimage.tar.xz ... 64bit Ubuntu 22.04 with Uli's other set of preferences
- dp-jammy-v1.8-i386-lxcimage.tar.xz .... 32bit Ubuntu 22.04 with Uli's other set of preferences
- dp-focal-v1.8-amd64-lxcimage.tar.xz ... 64bit Ubuntu 20.04 with Uli's other set of preferences
- dp-focal-v1.8-i386-lxcimage.tar.xz .... 32bit Ubuntu 20.04 with Uli's other set of preferences

Execute all of them by executing:

```
for r in noble jammy focal; do for a in amd64 i386; do ./create-image.sh -k -a ${a} ${r}; done; done

# Below, images not for general usage are created
for r in noble jammy focal; do for a in amd64 i386; do ./create-image.sh -U -k -a ${a} ${r}; done; done
for r in noble jammy focal; do for a in amd64 i386; do ./create-image.sh -m dp-modifications -p dp -k -a ${a} ${r}; done; done
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

```
uli@ulicsl:/data/qemu/lxc-ubuntu-i386-amd64-v1.8-pre$ lxc image import --alias u dp-jammy-v1.7-11-gdb2b454-amd64-lxcimage.tar.xz
Image imported with fingerprint: 1967a2940c5d3578221ad4a4030303c7f9e7f7c8e094f3f6e017b99137d7604d
uli@ulicsl:/data/qemu/lxc-ubuntu-i386-amd64-v1.8-pre$ lxc launch u t
Creating t
Starting t
uli@ulicsl:/data/qemu/lxc-ubuntu-i386-amd64-v1.8-pre$ lxc launch u s
Creating s
Starting s
uli@ulicsl:/data/qemu/lxc-ubuntu-i386-amd64-v1.8-pre$ lxc copy s r
uli@ulicsl:/data/qemu/lxc-ubuntu-i386-amd64-v1.8-pre$ lxc start r
uli@ulicsl:/data/qemu/lxc-ubuntu-i386-amd64-v1.8-pre$ lxc ls
+-----------------+---------+-----------------------+------+-----------+-----------+
|      NAME       |  STATE  |         IPV4          | IPV6 |   TYPE    | SNAPSHOTS |
+-----------------+---------+-----------------------+------+-----------+-----------+
| r               | RUNNING | 10.253.205.59 (eth0)  |      | CONTAINER | 0         |
+-----------------+---------+-----------------------+------+-----------+-----------+
| s               | RUNNING | 10.253.205.233 (eth0) |      | CONTAINER | 0         |
+-----------------+---------+-----------------------+------+-----------+-----------+
| t               | RUNNING | 10.253.205.92 (eth0)  |      | CONTAINER | 0         |
+-----------------+---------+-----------------------+------+-----------+-----------+
uli@ulicsl:/data/qemu/lxc-ubuntu-i386-amd64-v1.8-pre$ ssh root@10.253.205.92 cat /etc/machine-id
The authenticity of host '10.253.205.92 (10.253.205.92)' can't be established.
ECDSA key fingerprint is SHA256:DdUh0eHFjNEEaMdMCT4Dk6k2k2LuF1gJPyCmwKeR6yQ.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '10.253.205.92' (ECDSA) to the list of known hosts.
d886e141aee0484aa760150b4a1f720f
uli@ulicsl:/data/qemu/lxc-ubuntu-i386-amd64-v1.8-pre$ ssh root@10.253.205.233 cat /etc/machine-id
The authenticity of host '10.253.205.233 (10.253.205.233)' can't be established.
ECDSA key fingerprint is SHA256:juaZQQH4a7YXsYxPPiwaB0fiKoMwRLEzRe/ejuh5mgI.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '10.253.205.233' (ECDSA) to the list of known hosts.
f99dbfd572a74ca99da7217854b2d444
uli@ulicsl:/data/qemu/lxc-ubuntu-i386-amd64-v1.8-pre$ ssh root@10.253.205.59 cat /etc/machine-id
The authenticity of host '10.253.205.59 (10.253.205.59)' can't be established.
ECDSA key fingerprint is SHA256:ls0Cb4gITYtnbN4MuaylXB2mD1sA5kLXG9TrZPvN6/8.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '10.253.205.59' (ECDSA) to the list of known hosts.
86fd3d3aabd341aba2e905628372d426
uli@ulicsl:/data/qemu/lxc-ubuntu-i386-amd64-v1.8-pre$ lxc stop r s t
uli@ulicsl:/data/qemu/lxc-ubuntu-i386-amd64-v1.8-pre$ lxc delete r s t
uli@ulicsl:/data/qemu/lxc-ubuntu-i386-amd64-v1.8-pre$ lxc image delete u
```

### Why is the 32 bit image larger than my 64 bit images?

`apt-get clean` reduces the size!

### How to build the missing debs?

See [jammy-debs.md](jammy-debs.md) on how I build the DEBs for jammy (22.04)
and [focal-debs.md](focal-debs.md) for focal (20.04)!

These descriptions help to bootstrap the 32 bit images. Once you have
'almost' complete images, you'll be able to build additional debs by

```
./build.sh -a i386 -o jammy at
./build.sh -a i386 -o jammy joe-jupp
...
./build.sh -a i386 -o focal at
./build.sh -a i386 -o focal joe-jupp
...
```
