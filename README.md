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
