#!/bin/sh
TARGET="$1"

mount --bind /dev "${TARGET}/dev"
mount --bind /dev/pts "${TARGET}/dev/pts"
mount --bind /proc "${TARGET}/proc"
#mount --bind /run "${TARGET}/run"
mount --bind /sys "${TARGET}/sys"
