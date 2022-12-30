#!/bin/bash
###
### build.sh
###
### Usage:
###   build.sh -a i386|amd64 -o focal|jammy package...
###
### Options:
###   -a architecture ... i386 or amd64
###   -o os ............. focal (20.04) or jammy (22.04)
###   -i image.tar.xz ... lxc image file
###   package ........... packages to build
###
### Examples:
###   ./build.sh -a i386 -o jammy at
###

BN="$(basename "$0")"
D="$(dirname "$0")"

help () {
   sed -rn 's/^### ?//;T;p' "$0"|sed -e "s/BN/${BN}/g"
}

usage () {
    help|sed -n "/^Usage:/,/^\s*$/p"
}

OS=jammy
ARCHITECTURE=i386
IMAGE=
HELP=
USAGE=

while getopts 'ha:o:i:' opt; do
    case $opt in
        a)
            ARCHITECTURE="${OPTARG}"
            ;;
        o)
            OS="${OPTARG}"
            ;;
	i)
	    IMAGE="${OPTARG}"
	    ;;
        h)
            HELP=y
            ;;
        *)
            USAGE=y
            ;;
    esac
done
shift "$(expr "${OPTIND}" - 1)"

test -n "${HELP}" && {
    help
    exit 0
}

test -n "${USAGE}" && {
    usage >&2
    exit 1
}

sudo true || exit 1

OSDIR="build-${OS}-${ARCHITECTURE}"

test -d "${OSDIR}" || mkdir "${OSDIR}"

TMPDIR="/tmp/${BN}-$(openssl rand -hex 20)-$$~"

ROOTFS="${OSDIR}/rootfs"
test -d "${ROOTFS}" || {
  test -z "${IMAGE}" && IMAGE="$(echo "${D}/${OS}-"*"-${ARCHITECTURE}-lxcimage.tar.xz")"
  test -e "${IMAGE}" || {
    echo >&2 "${BN}: LXC image '${IMAGE}' does not exist!"
    exit 1
  }
  xz -cd "${IMAGE}"|( cd "${OSDIR}" ; sudo tar -xf -; )
}

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
sudo chroot "${ROOTFS}" cat /etc/apt/sources.list >"${TMPDIR}/sources.list"
sed -e "s/^deb/deb-src/" <"${TMPDIR}/sources.list" >"${TMPDIR}/debsrc"
sudo chroot "${ROOTFS}" tee -a /etc/apt/sources.list <"${TMPDIR}/debsrc" >/dev/null
sudo chroot "${ROOTFS}" apt update
sudo chroot "${ROOTFS}" apt upgrade -y
sudo chroot "${ROOTFS}" apt install -y dpkg-dev
sudo chroot "${ROOTFS}" bash -c "mkdir -p /src"
while [ $# -gt 0 ]; do
    PACKAGE="$1"
    sudo chroot "${ROOTFS}" bash -c "cd /src && mkdir -p '${PACKAGE}' && cd '${PACKAGE}' && ls *dsc" >"${TMPDIR}/before"
    sudo chroot "${ROOTFS}" bash -c "cd /src && cd '${PACKAGE}' && apt-get source --download-only '${PACKAGE}'"
    sudo chroot "${ROOTFS}" bash -c "cd /src && cd '${PACKAGE}' && ls *dsc" >"${TMPDIR}/after"
    cmp "${TMPDIR}/before" "${TMPDIR}/after" >/dev/null 2>&1 || {
	sudo find "${ROOTFS}/src/${PACKAGE}" -mindepth 1 -maxdepth 1 -type d|sudo xargs rm -rf
	sudo find "${ROOTFS}/src/${PACKAGE}" -name "*.deb"|sudo xargs rm -rf
	sudo chroot "${ROOTFS}" bash -c "cd /src && cd '${PACKAGE}' && apt-get source '${PACKAGE}' && apt-get build-dep -y '${PACKAGE}'"
	sudo chroot "${ROOTFS}" bash -c "cd '/src/${PACKAGE}/'*/. && dpkg-buildpackage"
    }
    rm -rf "${TMPDIR}/before" "${TMPDIR}/after"
    shift
done
sudo chroot "${ROOTFS}" tee /etc/apt/sources.list <"${TMPDIR}/sources.list" >/dev/null
sudo "${D}/umount.sh" "${ROOTFS}"
cleanUp
