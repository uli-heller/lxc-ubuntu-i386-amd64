RELEASE
=======

How to do a release?
I'm using v1.12.1 as an example for this!

Introduction
------------

There is a release v1.11. It happened in February 2023.
Now, roughly 18 months later, release v1.12.1 is about
to be released. For this, I'd like to get new containers
based on the new implementation. Ideally, the new
containers will have recent versions of our extra debs!

Update the old lxc image file for jammy
-----------------------------

OBSOLETE!

- Download from github
  - [jammy-v1.11-i386-lxcimage.tar.xz](https://github.com/uli-heller/lxc-ubuntu-i386-amd64/releases/download/v1.11/jammy-v1.11-i386-lxcimage.tar.xz)
  - [jammy-v1.11-i386-lxcimage.tar.xz.ssh-sig](https://github.com/uli-heller/lxc-ubuntu-i386-amd64/releases/download/v1.11/jammy-v1.11-i386-lxcimage.tar.xz.ssh-sig)
- Verify the signature
- Import the image: `lxc image import ~/Downloads/tmp/jammy-v1.11-i386-lxcimage.tar.xz --alias jammy-v1.11-i386-image`
- Launch the image: `lxc launch jammy-v1.11-i386-image jammy-v111-i386`
- Verify: `lxc ls jammy-v111-i386`
  ```
  +-----------------+---------+-----------------------+------+-----------+-----------+
  |      NAME       |  STATE  |         IPV4          | IPV6 |   TYPE    | SNAPSHOTS |
  +-----------------+---------+-----------------------+------+-----------+-----------+
  | jammy-v111-i386 | RUNNING | 10.253.205.172 (eth0) |      | CONTAINER | 0         |
  +-----------------+---------+-----------------------+------+-----------+-----------+
  ```
- Update:
  - `lxc exec jammy-v111-i386 bash`
  - `apt update`
  - `apt upgrade`
  - `exit`
- Shutdown: `lxc stop jammy-v111-i386`
- Export:
  - `lxc publish jammy-v111-i386 --alias jammy-v111-i386 --compression xz`
  - `lxc image export jammy-v111-i386 jammy-v111-i386`
  - `ls jammy-v111-i386*` -> jammy-v111-i386.tar.xz
- Cleanup
  - `lxc delete jammy-v111-i386`
  - `lxc image delete jammy-v111-i386`
  - `lxc image delete jammy-v1.11-i386-image`

Rebuild the debs for jammy
----------------

- `rm -rf build-jammy-i386`
- `./build.sh -a i386 -o jammy -i $HOME/Downloads/jammy-v1.11-i386-lxcimage.tar.xz -r`
- `git status debs/jammy`
  ```
  debs/jammy/i386/libnetplan-dev_0.106.1-7dp010.22.04.4~jammy_i386.deb
  debs/jammy/i386/libnetplan0_0.106.1-7dp010.22.04.4~jammy_i386.deb
  debs/jammy/i386/netplan.io_0.106.1-7dp010.22.04.4~jammy_i386.deb
  debs/jammy/i386/openvswitch-common_2.17.9-0ubuntu0.22.04.1_i386.deb
  ...
  ```

Some of the packages have been updated.

Remove obsolete debs for jammy
--------------------

```
$ find debs/jammy/i386/ -name "*.deb"|cut -d _ -f 1|sort -u
...
debs/jammy/i386/rdmacm-utils
debs/jammy/i386/rdma-core
debs/jammy/i386/srptools

$ for d in $(find debs/jammy/i386/ -name "*.deb"|cut -d _ -f 1|sort -u); do \
    n="$(echo "${d}_"*|tr " " "\n"|sort -V|tail -1)";                      \
    echo "${d}_"*|tr " " "\n"|grep -v "${n}"|xargs -r git rm;              \
  done
...
rm 'debs/jammy/i386/openvswitch-switch_2.17.3-0ubuntu0.22.04.1_i386.deb'
rm 'debs/jammy/i386/openvswitch-switch-dpdk_2.17.3-0ubuntu0.22.04.1_i386.deb'
rm 'debs/jammy/i386/openvswitch-test_2.17.3-0ubuntu0.22.04.1_all.deb'
rm 'debs/jammy/i386/openvswitch-testcontroller_2.17.3-0ubuntu0.22.04.1_i386.deb'
rm 'debs/jammy/i386/openvswitch-vtep_2.17.3-0ubuntu0.22.04.1_i386.deb'
rm 'debs/jammy/i386/python3-openvswitch_2.17.3-0ubuntu0.22.04.1_all.deb'
```

Complete procedure for focal
------------------

- Download from github
  - [focal-v1.11-i386-lxcimage.tar.xz](https://github.com/uli-heller/lxc-ubuntu-i386-amd64/releases/download/v1.11/focal-v1.11-i386-lxcimage.tar.xz)
  - [focal-v1.11-i386-lxcimage.tar.xz.ssh-sig](https://github.com/uli-heller/lxc-ubuntu-i386-amd64/releases/download/v1.11/focal-v1.11-i386-lxcimage.tar.xz.ssh-sig)
- `./build.sh -a i386 -o focal -i ~/Downloads/tmp/focal-v1.11-i386-lxcimage.tar.xz -r` -> Problem bei "netplan.io" - korrigiert
- Remove old debs:
  ```
  for d in $(find debs/focal/i386/ -name "*.deb"|cut -d _ -f 1|sort -u); do \
    n="$(echo "${d}_"*|tr " " "\n"|sort -V|tail -1)";                       \
    echo "${d}_"*|tr " " "\n"|grep -v "${n}"|xargs -r git rm;               \
  done
  ```

Create a new tag
----------------

```
git tag v1.12.1
git push
git push --tags
```

Create lxc images
-----------------

```
./create-release.sh
```
