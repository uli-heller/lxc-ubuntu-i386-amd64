#!/bin/sh
TARGET="$1"

#set -x
for m in dev/pts dev proc sys; do
    umount "${TARGET}/${m}"           2>/dev/null
    chroot "${TARGET}" umount "/${m}" 2>/dev/null
done
