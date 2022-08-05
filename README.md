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
