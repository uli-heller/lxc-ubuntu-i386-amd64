#!/bin/sh

proot -0 -w / -b /dev -b /dev/pts -b /proc -b /sys -r "$@"
