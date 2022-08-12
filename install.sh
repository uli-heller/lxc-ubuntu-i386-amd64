#!/bin/sh
#
# $1 ... osdir
# $2 ... package name
# $3 ... deb name
#
OSDIR="$1"
shift
PACKAGE="$1
shift
BN="$(basename "$0")"
D="$(dirname "$0")"

test -d "${OSDIR}" || {
    echo >&2 "${BN}: No directory '${OSDIR}'"
    exit 1
}

ROOTFS="${OSDIR}"
test -d "${OSDIR}/rootfs" && ROOTFS="${OSDIR}/rootfs"

sudo "${D}/mount.sh" "${ROOTFS}"
sudo chroot focal-build bash -c "cd '/src/${PACKAGE}/'; apt-get install $*"
sudo "${D}/umount.sh" "${ROOTFS}"
