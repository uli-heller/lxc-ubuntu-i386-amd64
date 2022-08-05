#!/bin/sh
TARGET="$1"

umount "${TARGET}/dev/pts"
umount "${TARGET}/dev"
umount "${TARGET}/proc"
#umount "${TARGET}/run"
umount "${TARGET}/sys"
