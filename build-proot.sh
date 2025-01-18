#!/bin/bash
###
### build-proot.sh
###
### Usage:
###   build-proot.sh [-h] -a i386|amd64 [-b build-options] [-S] [-R] [-V middle-part] -o focal|jammy|noble [-s focal|jammy|noble] package...
###
### Options:
###   -a architecture ... i386 or amd64
###   -o os ............. target: focal (20.04) or jammy (22.04) or noble (24.04)
###   -s os ............. source: focal (20.04) or jammy (22.04) or noble (24.04)
###   -S ................ create source package, too
###   -V middle-part .... middle part of version number, i.e. 2.4-0~uh~focal1
###   -i image.tar.xz ... lxc image file
###   -R ................ use "root" for build (required by GOCRYPTFS for example)
###   -b build-options .. prepend 'dpkg-buildpackage' with build-options
###   -k ................ keep sources even on failures
###   package ........... package to build
###
### Examples:
###   ./build.sh -a i386 -o jammy at
###   ./build.sh -a amd64 -o jammy -s noble -S -R virtualbox
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
VERSION_MIDDLE="uh"
USE_ROOT=
KEEP=

DEBEMAIL=uli@heller.cool
DEBFULLNAME="Uli Heller"
LC_ALL=C
export LC_ALL

USER_GROUP="$(id -un):$(id -gn)"

while getopts 'hkra:b:o:i:s:RSV:' opt; do
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
        R)
            USE_ROOT="y"
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
        k)
            KEEP=y
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

PROOT="$(which proot)" || {
    echo >&2 "${BN}: Missing binary 'proot' - fix by executing 'sudo apt install proot' - ABORTED!"
    exit 1
}

myProot () {
    "${PROOT}" -0 -w / -b /dev -b /dev/pts -b /proc -b /sys -r "$@"
}

myExec () {
    if [ -n "${USE_ROOT}" ]; then
        "${D}/exec.sh" "$@"
    else
        myProot "$@"
    fi
}

test -z "${SOURCE_OS}" && SOURCE_OS="${OS}"

test -n "${USE_ROOT}" && sudo true

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

OSDIR="build-proot-${OS}-${ARCHITECTURE}"

test -d "${OSDIR}" || mkdir "${OSDIR}"

TMPDIR="/tmp/${BN}-$(openssl rand -hex 20)-$$~"

ROOTFS="${OSDIR}/rootfs"
test -d "${ROOTFS}" || {
  test -z "${IMAGE}" && IMAGE="$(echo "${D}/${OS}-"*"-${ARCHITECTURE}-lxcimage.tar.xz")"
  test -e "${IMAGE}" || {
    # Check github
    #set -x
    LATEST_VERSION="$(git tag -l|sort -r -V|head -1)"
    GITHUB_URL="$(git remote get-url origin)"
    expr "${GITHUB_URL}" : http >/dev/null || {
        GITHUB_URL="https://github.com/$(echo "${GITHUB_URL}"|cut -d ":" -f 2-)"
    }
    #https://github.com/uli-heller/lxc-ubuntu-i386-amd64/releases/download/v1.12.1/jammy-v1.12.1-amd64-lxcimage.tar.xz
    IMAGE="${OS}-${LATEST_VERSION}-${ARCHITECTURE}-lxcimage.tar.xz"
    DOWNLOAD_URL="${GITHUB_URL}/releases/download/${LATEST_VERSION}/${IMAGE}"
    wget "${DOWNLOAD_URL}" || {
        echo >&2 "${BN}: LXC image '${IMAGE}' cannot be downloaded!"
        exit 1
    }
  }
  xz -cd "${IMAGE}"|( cd "${OSDIR}" ; tar -xf - 2>/dev/null )
}

cleanUp () {
    rm -rf "${TMPDIR}"
    test -n "${RC}" && exit "${RC}"
}

trap cleanUp 0 1 2 3 4 5 6 7 8 9 10 12 13 14 15
mkdir "${TMPDIR}"
touch "${TMPDIR}/empty"

"${D}/init-gpg.sh"
"${D}/rebuild-ppas.sh" "${ARCHITECTURE}" "${OS}"

#
# replaceVariables <from >to
#
replaceVariables () {
  sed -e 's/\${\OS\}/'"${OS}/g" -e 's/\${\VERSION\}/'"${NEW_VERSION}/g" -e  's/\${\TIMESTAMP\}/'"${TIMESTAMP}/g"
}

#
# $1 ... dsc file
# $2 ... destination folder
#
copyDscAndIncludedFiles () {
    (
        DSC="$1"
        DESTINATION="$2"
        cp "${DSC}" "${DESTINATION}/." || {
            echo >&2 "${BN}: Copying '${DSC}' to folder '${DESTINATION}' failed"
            exit 1
        }
        SOURCE="$(dirname "${DSC}")"
        for f in $(sed -n -e '/^Files:/,/^[^ ]/ p' "${DSC}" | grep "^ " | cut -d " " -f 4-); do
            cp "${SOURCE}/${f}" "${DESTINATION}/." || {
                echo >&2 "${BN}: Copying '${SOURCE}/${f}' to folder '${DESTINATION}' failed"
                exit 1
            }
        done
    )
}

RC=0

myProot "${ROOTFS}" cat /etc/apt/sources.list >"${TMPDIR}/sources.list"
sed -e "s/^deb /deb-src /" -e "s/${OS}/${SOURCE_OS}/" <"${TMPDIR}/sources.list" >"${TMPDIR}/debsrc"
myProot "${ROOTFS}" tee /etc/apt/sources.list.d/deb-src.list <"${TMPDIR}/debsrc" >/dev/null

mkdir -p "${ROOTFS}/var/cache/lxc-ppa"
cp -r "${D}/ppas/${ARCHITECTURE}/${OS}"/*  "${ROOTFS}/var/cache/lxc-ppa"
cp "${D}/ppas/${ARCHITECTURE}/${OS}"/lxc.public.gpg "${ROOTFS}/etc/apt/trusted.gpg.d/."
echo "deb file:/var/cache/lxc-ppa/ ./"|tee "${ROOTFS}/etc/apt/sources.list.d/lxc-ppa.list"

myProot "${ROOTFS}" apt update
myProot "${ROOTFS}" apt upgrade -y
myProot "${ROOTFS}" apt install -y dpkg-dev devscripts equivs
myProot "${ROOTFS}" bash -c "mkdir -p /src"
while [ $# -gt 0 -a "${RC}" -eq 0 ]; do
    PACKAGE="$1"
    myExec "${ROOTFS}" bash -c "cd /src && rm -rf '${PACKAGE}'"
    myProot "${ROOTFS}" bash -c "cd /src && mkdir -p '${PACKAGE}' && cd '${PACKAGE}' && ls *dsc 2>/dev/null" >"${TMPDIR}/before"
    myProot "${ROOTFS}" bash -c "cd /src && cd '${PACKAGE}' && ls"      >"${TMPDIR}/before.ls"
    #
    # When we do have a "local" package underneath ppas/(arch)/(source_os)/srv,
    # then use this!
    #
    set -x
    LOCAL_PACKAGE="$(ls "${D}/ppas/${ARCHITECTURE}/${SOURCE_OS}/src/${PACKAGE}"*.dsc|sort -r -V|head -1)"
    if [ -e "${LOCAL_PACKAGE}" ]; then
        #cp "$(dirname "${LOCAL_PACKAGE}")/$(basename "${LOCAL_PACKAGE}" .dsc"* "${ROOTFS}/src/${PACKAGE}/."
        copyDscAndIncludedFiles "${LOCAL_PACKAGE}" "${ROOTFS}/src/${PACKAGE}/."
    else
        myProot "${ROOTFS}" bash -c "cd /src && cd '${PACKAGE}' && apt-get source --download-only '${PACKAGE}'"
    fi
    set +x
    myProot "${ROOTFS}" bash -c "cd /src && cd '${PACKAGE}' && ls *dsc" >"${TMPDIR}/after"
    myProot "${ROOTFS}" bash -c "cd /src && cd '${PACKAGE}' && ls" >"${TMPDIR}/after.ls"
    cmp "${TMPDIR}/before" "${TMPDIR}/after" >/dev/null 2>&1 || {
        (
            RC=0
            #set -x
            find "${ROOTFS}/src/${PACKAGE}" -mindepth 1 -maxdepth 1 -type d|xargs rm -rf
            find "${ROOTFS}/src/${PACKAGE}" -name "*.deb"|xargs rm -rf
            # 2025-01-03 - gocryptfs
            # ...
            # dpkg-source: info: extracting gocryptfs in gocryptfs-2.4.0
            # dpkg-source: info: unpacking gocryptfs_2.4.0.orig.tar.xz
            # tar: gocryptfs-2.4.0/tests/example_filesystems/content/longname_255_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: Cannot open: File name too long
            # tar: gocryptfs-2.4.0/tests/example_filesystems/v1.1-reverse-plaintextnames/longname_255_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: Cannot open: File name too long
            # tar: gocryptfs-2.4.0/tests/example_filesystems/v1.1-reverse/longname_255_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: Cannot open: File name too long
            # tar: gocryptfs-2.4.0/tests/example_filesystems/v1.3-reverse/longname_255_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: Cannot open: File name too long
            # tar: Exiting with failure status due to previous errors
            # ...
            myExec "${ROOTFS}" bash -c "cd /src && cd '${PACKAGE}' && dpkg-source -x *.dsc" || exit 1
            #( cd "${ROOTFS}/src/${PACKAGE}" && dpkg-source -x "${PACKAGE}"*dsc) || exit 1
            PACKAGE_FOLDER="$(myProot "${ROOTFS}" bash -c "cd /src && cd '${PACKAGE}'/*/. && pwd")"
            test "${USER_GROUP}" != "$(stat --format "%U:%G" "${ROOTFS}/${PACKAGE_FOLDER}")" && {
                sudo chown -R "${USER_GROUP}" "${ROOTFS}/${PACKAGE_FOLDER}"
            }
            test -n "${SOURCE_FROM_DIFFERENT_OS}" && {
                sed -i -e "s/debhelper-compat\s*([^)]*)/debhelper-compat (=${COMPAT})/" "${ROOTFS}/${PACKAGE_FOLDER}/debian/control"
            }
            if [ -d "${D}/patches/${OS}/${PACKAGE}" ]; then
                PATCH_FOLDER="${D}/patches/${OS}/${PACKAGE}"
                # We do have a patch for the package. Now the situation
                # might be quite difficult related to version number
                # and dependencies
                #
                # Save the changelog - it might have been modified since we created the patch
                myProot "${ROOTFS}" bash -c "cd '${PACKAGE_FOLDER}' && cat debian/changelog" >"${TMPDIR}/changelog" || exit 1
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
                    myProot "${ROOTFS}" bash -c "cd '${PACKAGE_FOLDER}' && patch -p1" <"${TMPDIR}/diff-without-changelog" || exit 1
                    # Adjust the changelog
                    replaceVariables <"${D}/patches/${OS}/${PACKAGE}/changelog.tpl" >"${TMPDIR}/changelog.start"
                    echo >>"${TMPDIR}/changelog.start"
                    cat "${TMPDIR}/changelog.start" "${TMPDIR}/changelog"| myProot "${ROOTFS}" bash -c "cd '${PACKAGE_FOLDER}' && tee debian/changelog" >/dev/null || exit 1
                }
                # Install dependencies
                echo "yes"|myProot "${ROOTFS}" bash -c "cd '${PACKAGE_FOLDER}' && LC_ALL=C mk-build-deps -i" || exit 1
                test -n "${PREPARE_BUILD}" && {
                    PREPARE_BUILD_EXPANDED="$(echo "${PREPARE_BUILD}"|replaceVariables)"
                    myProot "${ROOTFS}" bash -c "cd '${PACKAGE_FOLDER}' && eval ${PREPARE_BUILD_EXPANDED}" || exit 1
                }
            else
                #myProot "${ROOTFS}" bash -c "cd '${PACKAGE_FOLDER}' && apt-get build-dep -y '${PACKAGE}'" || RC=1
                echo "yes"|myProot "${ROOTFS}" bash -c "cd '${PACKAGE_FOLDER}' && LC_ALL=C mk-build-deps -i" || exit 1
            fi
            BUILD_DEPS_DEBS="$(myProot "${ROOTFS}" bash -c "cd '${PACKAGE_FOLDER}' && ls *build-deps_*")"
            for b in ${BUILD_DEPS_DEBS}; do
                p="$(myProot "${ROOTFS}" bash -c "cd '${PACKAGE_FOLDER}' && dpkg --info '${b}'" | grep "^\s*Package:\s*" | sed -e "s/^\s*Package:\s*//")"
                myProot "${ROOTFS}" apt purge -y "${p}"
                myProot "${ROOTFS}" rm -f "${PACKAGE_FOLDER}/${b}" || exit 1
            done
            sed -i -e "1 s/~${VERSION_MIDDLE}~${SOURCE_OS}/~${VERSION_MIDDLE}~${OS}/" "${ROOTFS}/${PACKAGE_FOLDER}/debian/changelog"
            test -z "$(head -1 "${ROOTFS}/${PACKAGE_FOLDER}/debian/changelog"|grep "~${VERSION_MIDDLE}~${OS}")" && {
                myProot "${ROOTFS}" bash -c "cd '${PACKAGE_FOLDER}' && LC_ALL=C DEBFULLNAME='${DEBFULLNAME}' DEBEMAIL='${DEBEMAIL}' debchange --distribution '${OS}' --local '~${VERSION_MIDDLE}~${OS}' 'Repackaged for ${OS}'" || RC=1
            }
            PACKAGE_FOLDER="$(myProot "${ROOTFS}" bash -c "cd /src && cd '${PACKAGE}'/*/. && pwd")"
            #PACKAGE_FOLDER="${PACKAGE_FOLDER}~${VERSION_MIDDLE}~${OS}"
            DPKG_BUILDPACKAGE_OPTS="--build=binary"
            test -n "${SOURCE_PACKAGE}" && DPKG_BUILDPACKAGE_OPTS=
            myExec "${ROOTFS}" bash -c "cd '${PACKAGE_FOLDER}' && LC_ALL=C ${BUILD_OPTIONS} dpkg-buildpackage ${DPKG_BUILDPACKAGE_OPTS}" || RC=1
            test "${RC}" -eq "0" || { echo >&2 "Probleme beim Auspacken oder bauen - EXIT"; exit 1; }
            test -d "${D}/ppas/${ARCHITECTURE}/${OS}" || mkdir -p "${D}/ppas/${ARCHITECTURE}/${OS}"
            cp "${ROOTFS}/src/${PACKAGE}"/*.deb "${D}/ppas/${ARCHITECTURE}/${OS}/."
            chown "$(id -un):$(id -gn)" "${D}/ppas/${ARCHITECTURE}/${OS}"/*.deb
            test -n "${SOURCE_PACKAGE}" && {
                test -d "${D}/ppas/${ARCHITECTURE}/${OS}/src" || mkdir -p "${D}/ppas/${ARCHITECTURE}/${OS}/src"
                cp $(find "${ROOTFS}/src/${PACKAGE}" -maxdepth 1 -type f -not -name "*.deb") "${D}/ppas/${ARCHITECTURE}/${OS}/src/."
                chown "$(id -un):$(id -gn)" "${D}/ppas/${ARCHITECTURE}/${OS}/src"/*
            }
            "${D}/rebuild-ppas.sh"
            cp "${D}/ppas/${ARCHITECTURE}/${OS}"/*  "${ROOTFS}/var/cache/lxc-ppa"
            myProot "${ROOTFS}" apt update
        ) || {
            #find "${ROOTFS}/src/${PACKAGE}" -mindepth 1 -maxdepth 1 -newer "${TMPDIR}/before"|xargs -t rm -rf
            test -z "${KEEP}" && (
                cd "${ROOTFS}/src/${PACKAGE}" || { echo >&2 "${BN}: Fehler mit '${ROOTFS}/src/${PACKAGE}'"; exit 1; }
                diff "${TMPDIR}/before.ls" "${TMPDIR}/after.ls"|grep "^>"|cut -c2-|xargs -t rm -f
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
myProot "${ROOTFS}" tee /etc/apt/sources.list <"${TMPDIR}/sources.list" >/dev/null

#
# Create the GPG key for the ppa
#
test "${RC}" -eq 0 && {
  "${D}/init-gpg.sh"
  (
    cd "${D}/ppas/${ARCHITECTURE}/${OS}"
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
