#!/bin/bash
###
### build.sh
###
### Usage:
###   build.sh [-h] -a i386|amd64 [-b build-options] [-S] [-V middle-part] -o focal|jammy|noble [-s focal|jammy|noble] [-r|package...]
###
### Options:
###   -a architecture ... i386 or amd64
###   -o os ............. target: focal (20.04) or jammy (22.04) or noble (24.04)
###   -s os ............. source: focal (20.04) or jammy (22.04) or noble (24.04)
###   -S ................ create source package, too
###   -V middle-part .... middle part of version number, i.e. 2.4-0~(middle-part)~focal1
###   -i image.tar.xz ... lxc image file
###   -r ................ rebuild all required packages for the architecture/os
###   -b build-options .. prepend 'dpkg-buildpackage' with build-options
###   package ........... packages to build
###
### Examples:
###   ./build.sh -a i386 -o jammy at
###   ./build.sh -a i386 -o noble -r
###

BN="$(basename "$0")"
D="$(dirname "$0")"
D="$(cd "${D}" && pwd)"

help () {
   sed -rn 's/^### ?//;T;p' "$0"|sed -e "s/BN/${BN}/g"
}

usage () {
    help|sed -n "/^Usage:/,/^\s*$/p"
}

OS=noble
SOURCE_OS=
ARCHITECTURE=i386
IMAGE=
HELP=
USAGE=
REBUILD=
BUILD_OPTIONS=
SOURCE_PACKAGE=
VERSION_MIDDLE_DEFAULT="uh"
VERSION_MIDDLE=

DEBEMAIL=uli@heller.cool
DEBFULLNAME="Uli Heller"

while getopts 'hra:b:o:i:s:SV:' opt; do
    case $opt in
        a)
            ARCHITECTURE="${OPTARG}"
            ;;
        o)
            OS="${OPTARG}"
            ;;
        s)
            SOURCE_OS="${OPTARG}"
            ;;
	S)
	    SOURCE_PACKAGE="y"
	    ;;
        V)
            VERSION_MIDDLE="${OPTARG}"
            ;;
        i)
            IMAGE="${OPTARG}"
            ;;
	b)
	    BUILD_OPTIONS="${OPTARG}"
	    ;;
        h)
            HELP=y
            ;;
        r)
            REBUILD=y
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

test -z "${SOURCE_OS}" && SOURCE_OS="${OS}"

SOURCE_FROM_DIFFERENT_OS=
test "${SOURCE_OS}" != "${OS}" && SOURCE_FROM_DIFFERENT_OS=y
case "${OS}" in
    focal)
	COMPAT=12
	;;
    jammy)
	COMPAT=13
	;;
    noble)
	COMPAT=13
	;;
    default)
	COMPAT=12
	;;
esac

test -z "${VERSION_MIDDLE}" && VERSION_MIDDLE="${VERSION_MIDDLE_DEFAULT}"

#
# Extend parameter list for 'rebuild'
#
test -n "${REBUILD}" && {
    test -s "${D}/debs/${OS}/${ARCHITECTURE}/rebuild.conf" && {
        for p in $(cat "${D}/debs/${OS}/${ARCHITECTURE}/rebuild.conf"|grep -v '^#'); do
            set -- "${p}" "$@"
        done
    }
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
touch "${TMPDIR}/empty"

"${D}/init-gpg.sh"
"${D}/rebuild-ppa.sh" "${ARCHITECTURE}" "${OS}"

#
# replaceVariables <from >to
#
replaceVariables () {
  sed -e 's/\${\OS\}/'"${OS}/g" -e 's/\${\VERSION\}/'"${NEW_VERSION}/g" -e  's/\${\TIMESTAMP\}/'"${TIMESTAMP}/g"
}

RC=0
sudo "${D}/mount.sh" "${ROOTFS}" || {
    echo >&2 "${BN}: Probleme beim Einbinden von '${ROOTFS}'"
    exit 1
}

sudo chroot "${ROOTFS}" cat /etc/apt/sources.list >"${TMPDIR}/sources.list"
sed -e "s/^deb /deb-src /" -e "s/${OS}/${SOURCE_OS}/" <"${TMPDIR}/sources.list" >"${TMPDIR}/debsrc"
sudo chroot "${ROOTFS}" tee /etc/apt/sources.list.d/deb-src.list <"${TMPDIR}/debsrc" >/dev/null

sudo mkdir -p "${ROOTFS}/var/cache/lxc-ppa"
sudo cp "${D}/debs/${OS}/${ARCHITECTURE}"/*  "${ROOTFS}/var/cache/lxc-ppa"
sudo cp "${D}/debs/${OS}/${ARCHITECTURE}"/lxc.public.gpg "${ROOTFS}/etc/apt/trusted.gpg.d/."
echo "deb file:/var/cache/lxc-ppa/ ./"|sudo tee "${ROOTFS}/etc/apt/sources.list.d/lxc-ppa.list"

sudo chroot "${ROOTFS}" apt update
sudo chroot "${ROOTFS}" apt upgrade -y
sudo chroot "${ROOTFS}" apt install -y dpkg-dev devscripts equivs
sudo chroot "${ROOTFS}" bash -c "mkdir -p /src"
while [ $# -gt 0 -a "${RC}" -eq 0 ]; do
    PACKAGE="$1"
    sudo chroot "${ROOTFS}" bash -c "cd /src && rm -rf '${PACKAGE}'"
    sudo chroot "${ROOTFS}" bash -c "cd /src && mkdir -p '${PACKAGE}' && cd '${PACKAGE}' && ls *dsc" >"${TMPDIR}/before"
    sudo chroot "${ROOTFS}" bash -c "cd /src && cd '${PACKAGE}' && ls"      >"${TMPDIR}/before.ls"
    sudo chroot "${ROOTFS}" bash -c "cd /src && cd '${PACKAGE}' && apt-get source --download-only '${PACKAGE}'"
    sudo chroot "${ROOTFS}" bash -c "cd /src && cd '${PACKAGE}' && ls *dsc" >"${TMPDIR}/after"
    sudo chroot "${ROOTFS}" bash -c "cd /src && cd '${PACKAGE}' && ls" >"${TMPDIR}/after.ls"
    cmp "${TMPDIR}/before" "${TMPDIR}/after" >/dev/null 2>&1 || {
        (
            RC=0
            #set -x
            sudo find "${ROOTFS}/src/${PACKAGE}" -mindepth 1 -maxdepth 1 -type d|sudo xargs rm -rf
            sudo find "${ROOTFS}/src/${PACKAGE}" -name "*.deb"|sudo xargs rm -rf
            sudo chroot "${ROOTFS}" bash -c "cd /src && cd '${PACKAGE}' && apt-get source '${PACKAGE}'" || exit 1
            PACKAGE_FOLDER="$(sudo chroot "${ROOTFS}" bash -c "cd /src && cd '${PACKAGE}'/*/. && pwd")"
            test -n "${SOURCE_FROM_DIFFERENT_OS}" && {
                sudo sed -i -e "s/debhelper-compat\s*([^)]*)/debhelper-compat (=${COMPAT})/" "${ROOTFS}/${PACKAGE_FOLDER}/debian/control"
            }
            if [ -d "${D}/patches/${OS}/${PACKAGE}" ]; then
                PATCH_FOLDER="${D}/patches/${OS}/${PACKAGE}"
                # We do have a patch for the package. Now the situation
                # might be quite difficult related to version number
                # and dependencies
                #
                # Save the changelog - it might have been modified since we created the patch
                sudo chroot "${ROOTFS}" bash -c "cd '${PACKAGE_FOLDER}' && cat debian/changelog" >"${TMPDIR}/changelog" || exit 1
                DIFF=
                test -e "${PATCH_FOLDER}/"*.diff && DIFF="$(echo "${PATCH_FOLDER}/"*.diff)"
                CHANGELOG_PARAMETERS="${TMPDIR}/empty"
                test -e "${PATCH_FOLDER}/changelog.parameters" && CHANGELOG_PARAMETERS="${PATCH_FOLDER}/changelog.parameters"
                PREPARE_BUILD="$(grep "^PREPARE_BUILD=" "${CHANGELOG_PARAMETERS}"|cut -d= -f2-)"
                VERSION_SEARCH="$(grep "^VERSION_SEARCH=" "${CHANGELOG_PARAMETERS}"|cut -d= -f2-)"
                VERSION_REPLACE="$(grep "^VERSION_REPLACE=" "${CHANGELOG_PARAMETERS}"|cut -d= -f2-)"
                OLD_VERSION="$(head -1 "${ROOTFS}/${PACKAGE_FOLDER}/debian/changelog"|grep -o '(.*)'|tr -d '()')"
                NEW_VERSION="$(echo "${OLD_VERSION}"|sed "s/${VERSION_SEARCH}/${VERSION_REPLACE}/")"
                TIMESTAMP="$(date -R)"
                test -n "${DIFF}" && {
                    # Modify the patch - skip changelog
                    sed -e '/^diff.*changelog$/,/^diff/ d' "${DIFF}" >"${TMPDIR}/diff-without-changelog"
                    # Apply the modified patch
                    sudo chroot "${ROOTFS}" bash -c "cd '${PACKAGE_FOLDER}' && patch -p1" <"${TMPDIR}/diff-without-changelog" || exit 1
                    # Adjust the changelog
                    replaceVariables <"${D}/patches/${OS}/${PACKAGE}/changelog.tpl" >"${TMPDIR}/changelog.start"
                    echo >>"${TMPDIR}/changelog.start"
                    cat "${TMPDIR}/changelog.start" "${TMPDIR}/changelog"| sudo chroot "${ROOTFS}" bash -c "cd '${PACKAGE_FOLDER}' && tee debian/changelog" >/dev/null || exit 1
                }
                # Install dependencies
                echo "yes"|sudo chroot "${ROOTFS}" bash -c "cd '${PACKAGE_FOLDER}' && LC_ALL=C mk-build-deps -i" || exit 1
                test -n "${PREPARE_BUILD}" && {
                    PREPARE_BUILD_EXPANDED="$(echo "${PREPARE_BUILD}"|replaceVariables)"
                    sudo chroot "${ROOTFS}" bash -c "cd '${PACKAGE_FOLDER}' && eval ${PREPARE_BUILD_EXPANDED}" || exit 1
                }
            else
                #sudo chroot "${ROOTFS}" bash -c "cd '${PACKAGE_FOLDER}' && apt-get build-dep -y '${PACKAGE}'" || RC=1
		echo "yes"|sudo chroot "${ROOTFS}" bash -c "cd '${PACKAGE_FOLDER}' && LC_ALL=C mk-build-deps -i" || exit 1
            fi
            sudo chroot "${ROOTFS}" bash -c "cd '${PACKAGE_FOLDER}' && LC_ALL=C DEBFULLNAME='${DEBFULLNAME}' DEBEMAIL='${DEBEMAIL}' debchange --distribution '${OS}' --local '~${VERSION_MIDDLE}~${OS}' 'Repackaged for ${OS}'" || RC=1
            PACKAGE_FOLDER="$(sudo chroot "${ROOTFS}" bash -c "cd /src && cd '${PACKAGE}'/*/. && pwd")"
	    #PACKAGE_FOLDER="${PACKAGE_FOLDER}~${VERSION_MIDDLE}~${OS}"
	    DPKG_BUILDPACKAGE_OPTS="--build=binary"
	    test -n "${SOURCE_PACKAGE}" && DPKG_BUILDPACKAGE_OPTS=
            sudo chroot "${ROOTFS}" bash -c "cd '${PACKAGE_FOLDER}' && LC_ALL=C ${BUILD_OPTIONS} dpkg-buildpackage ${DPKG_BUILDPACKAGE_OPTS}" || RC=1
            test "${RC}" -eq "0" || { echo >&2 "Probleme beim Auspacken oder bauen - EXIT"; exit 1; }
            test -d "${D}/debs/${OS}/${ARCHITECTURE}" || mkdir -p "${D}/debs/${OS}/${ARCHITECTURE}"
            sudo cp "${ROOTFS}/src/${PACKAGE}"/*.deb "${D}/debs/${OS}/${ARCHITECTURE}/."
            sudo chown "$(id -un):$(id -gn)" "${D}/debs/${OS}/${ARCHITECTURE}"/*.deb
	    test -n "${SOURCE_PACKAGE}" && {
		test -d "${D}/debs/${OS}/src" || mkdir -p "${D}/debs/${OS}/src"
		sudo cp $(ls "${ROOTFS}/src/${PACKAGE}/"*|grep -v '.deb$') "${D}/debs/${OS}/src/."
		sudo chown "$(id -un):$(id -gn)" "${D}/debs/${OS}/src"/*
	    }
            "${D}/rebuild-ppa.sh"
            sudo cp "${D}/debs/${OS}/${ARCHITECTURE}"/*  "${ROOTFS}/var/cache/lxc-ppa"
            sudo chroot "${ROOTFS}" apt update
        ) || {
            #sudo find "${ROOTFS}/src/${PACKAGE}" -mindepth 1 -maxdepth 1 -newer "${TMPDIR}/before"|sudo xargs -t rm -rf
            (
                cd "${ROOTFS}/src/${PACKAGE}" || { echo >&2 "${BN}: Fehler mit '${ROOTFS}/src/${PACKAGE}'"; exit 1; }
                diff "${TMPDIR}/before.ls" "${TMPDIR}/after.ls"|grep "^>"|cut -c2-|sudo xargs -t rm -f
            )
            RC=1
        }
    }
    test "${RC}" -ne 0 && {
        echo >&2 "${BN}: error building package '${PACKAGE}' -> ABORTING"
        cleanUp
        exit 1
    }
    rm -rf "${TMPDIR}/before" "${TMPDIR}/after" "${TMPDIR}/before.ls" "${TMPDIR}/after.ls"
    shift
done
sudo chroot "${ROOTFS}" tee /etc/apt/sources.list <"${TMPDIR}/sources.list" >/dev/null
sudo "${D}/umount.sh" "${ROOTFS}"

#
# Create the GPG key for the ppa
#
test "${RC}" -eq 0 && {
  "${D}/init-gpg.sh"
  (
    cd "${D}/debs/${OS}/${ARCHITECTURE}"
    dpkg-scanpackages . >Packages
    {
        AFR="APT::FTPArchive::Release::"
        echo "${AFR}Origin \"lxc-ubuntu\";"
        echo "${AFR}Label \"lxc-ubuntu\";"
        echo "${AFR}Suite \"${OS}\";"
        echo "${AFR}Codename \"${OS}\";"
        echo "${AFR}Architectures \"${ARCHITECTURE}\";"
        #echo "${AFR}Components \".\";"
        echo "${AFR}Description \"Precompiled packages for our LXC containers\";"
    } >"Release.tmp"
    apt-ftparchive -c "Release.tmp" release "." >"./Release"
    rm -f "Release.tmp"
    rm -f "Release.gpg"
    gpg --homedir "${D}/gpg" -abs --digest-algo SHA256 -u "$(cat "${D}/gpg/keyid")" -o "Release.gpg" "Release"
    rm -f "InRelease"
    gpg --homedir "${D}/gpg" -abs --digest-algo SHA256 -u "$(cat "${D}/gpg/keyid")" --clearsign -o "InRelease" "Release"
    cp "${D}/gpg/lxc.public.asc" .
    cp "${D}/gpg/lxc.public.gpg" .
  )
}
cleanUp
