#!/bin/sh
#
# $1 ... osdir
# $2 ... package name
#
OSDIR="$1"
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

while [ $# -gt 0 ]; do
    PACKAGE="$1"
    sudo chroot "${ROOTFS}" bash -c "cd /src && mkdir '${PACKAGE}' && cd '${PACKAGE}' && apt-get source '${PACKAGE}' && apt-get build-dep -y '${PACKAGE}'"
    sudo chroot "${ROOTFS}" bash -c "cd '/src/${PACKAGE}/'*/. && dpkg-buildpackage"
    shift
done
sudo "${D}/umount.sh" "${ROOTFS}"
