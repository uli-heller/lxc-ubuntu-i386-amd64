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

TMPDIR="/tmp/${BN}-$(openssl rand -hex 20)-$$~"

ROOTFS="${OSDIR}"
test -d "${OSDIR}/rootfs" && ROOTFS="${OSDIR}/rootfs"

cleanUp () {
    rm -rf "${TMPDIR}"
    test "$(df "${ROOTFS}/dev"|cut -d" " -f1)" != "$(df "${ROOTFS}/tmp"|cut -d" " -f1)" && {
	sudo "${D}/umount.sh" "${ROOTFS}"
    }
    test -n "${RC}" && exit "${RC}"
}

trap cleanUp 0 1 2 3 4 5 6 7 8 9 10 12 13 14 15
mkdir "${TMPDIR}"

sudo "${D}/mount.sh" "${ROOTFS}"
sudo chroot "${ROOTFS}" apt update
sudo chroot "${ROOTFS}" apt upgrade -y
while [ $# -gt 0 ]; do
    PACKAGE="$1"
    sudo chroot "${ROOTFS}" bash -c "cd /src && mkdir -p '${PACKAGE}' && cd '${PACKAGE}' && ls *dsc" >"${TMPDIR}/before"
    sudo chroot "${ROOTFS}" bash -c "cd /src && cd '${PACKAGE}' && apt-get source --download-only '${PACKAGE}'"
    sudo chroot "${ROOTFS}" bash -c "cd /src && cd '${PACKAGE}' && ls *dsc" >"${TMPDIR}/after"
    cmp "${TMPDIR}/before" "${TMPDIR}/after" >/dev/null 2>&1 || {
	sudo chroot "${ROOTFS}" bash -c "cd /src && cd '${PACKAGE}' && apt-get source '${PACKAGE}' && apt-get build-dep -y '${PACKAGE}'"
	sudo chroot "${ROOTFS}" bash -c "cd '/src/${PACKAGE}/'*/. && dpkg-buildpackage"
    }
    rm -rf "${TMPDIR}/before" "${TMPDIR}/after"
    shift
done
sudo "${D}/umount.sh" "${ROOTFS}"
cleanUp
