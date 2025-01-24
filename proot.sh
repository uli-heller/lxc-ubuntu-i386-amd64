#!/bin/sh

D="$(dirname "$0")"
ROOTFS="$(realpath $1)"
FOLDER="$(echo "${ROOTFS}"|sed -e 's,/rootfs.*$,,')"
OS_ARCH="$(echo "${FOLDER}"|grep -o -- '-[^-]*-[^-]*$')"
OS="$(echo "${OS_ARCH}"|cut -d "-" -f 2)"
ARCH="$(echo "${OS_ARCH}"|cut -d "-" -f 3)"

exec proot -0 -w / -b /dev -b /dev/pts -b /proc -b /sys -b "$(realpath "${D}/ppas/${ARCH}/${OS}"):/var/cache/${OS}" -r "$@"
