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
D="$(cd "${D}" && pwd)"

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

RC=0
sudo "${D}/mount.sh" "${ROOTFS}"
sudo chroot "${ROOTFS}" cat /etc/apt/sources.list >"${TMPDIR}/sources.list"
sed -e "s/^deb /deb-src /" <"${TMPDIR}/sources.list" >"${TMPDIR}/debsrc"
sudo chroot "${ROOTFS}" tee -a /etc/apt/sources.list <"${TMPDIR}/debsrc" >/dev/null
sudo chroot "${ROOTFS}" apt update
sudo chroot "${ROOTFS}" apt upgrade -y
sudo chroot "${ROOTFS}" apt install -y dpkg-dev devscripts equivs
sudo chroot "${ROOTFS}" bash -c "mkdir -p /src"
while [ $# -gt 0 -a "${RC}" -eq 0 ]; do
    PACKAGE="$1"
    sudo chroot "${ROOTFS}" bash -c "cd /src && mkdir -p '${PACKAGE}' && cd '${PACKAGE}' && ls *dsc" >"${TMPDIR}/before"
    sudo chroot "${ROOTFS}" bash -c "cd /src && cd '${PACKAGE}' && apt-get source --download-only '${PACKAGE}'"
    sudo chroot "${ROOTFS}" bash -c "cd /src && cd '${PACKAGE}' && ls *dsc" >"${TMPDIR}/after"
    cmp "${TMPDIR}/before" "${TMPDIR}/after" >/dev/null 2>&1 || {
	(
	    set -x
	    sudo find "${ROOTFS}/src/${PACKAGE}" -mindepth 1 -maxdepth 1 -type d|sudo xargs rm -rf
	    sudo find "${ROOTFS}/src/${PACKAGE}" -name "*.deb"|sudo xargs rm -rf
	    sudo chroot "${ROOTFS}" bash -c "cd /src && cd '${PACKAGE}' && apt-get source '${PACKAGE}'" || exit 1
	    PACKAGE_FOLDER="$(sudo chroot "${ROOTFS}" bash -c "cd /src && cd '${PACKAGE}'/*/. && pwd")"
	    if [ -e "${D}/patches/${OS}/${PACKAGE}/"*diff ]; then
		# We do have a patch for the package. Now the situation
		# might be quite difficult related to version number
		# and dependencies
		#
		# Save the changelog - it might have been modified since we created the patch
		sudo chroot "${ROOTFS}" bash -c "cd '${PACKAGE_FOLDER}' && cat debian/changelog" >"${TMPDIR}/changelog" || exit 1
		# Modify the patch - skip changelog
		sed -e '/^diff.*changelog$/,/^diff/ d' "${D}/patches/${OS}/${PACKAGE}/"*diff >"${TMPDIR}/diff-without-changelog"
		# Apply the modified patch
		sudo chroot "${ROOTFS}" bash -c "cd '${PACKAGE_FOLDER}' && patch -p1" <"${TMPDIR}/diff-without-changelog" || exit 1
		# Adjust the changelog
		VERSION_SEARCH="$(grep "^VERSION_SEARCH=" "${D}/patches/${OS}/${PACKAGE}/changelog.parameters"|cut -d= -f2-)"
		VERSION_REPLACE="$(grep "^VERSION_REPLACE=" "${D}/patches/${OS}/${PACKAGE}/changelog.parameters"|cut -d= -f2-)"
		OLD_VERSION="$(head -1 "${ROOTFS}/${PACKAGE_FOLDER}/debian/changelog"|grep -o '(.*)'|tr -d '()')"
		NEW_VERSION="$(echo "${OLD_VERSION}"|sed "s/${VERSION_SEARCH}/${VERSION_REPLACE}/")"
		sed -e 's/\${\OS\}/'"${OS}/g" -e 's/\${\VERSION\}/'"${NEW_VERSION}/g" -e  's/\${\TIMESTAMP\}/'"$(date -R)/g" "${D}/patches/${OS}/${PACKAGE}/changelog.tpl" >"${TMPDIR}/changelog.start"
		echo >>"${TMPDIR}/changelog.start"
		cat "${TMPDIR}/changelog.start" "${TMPDIR}/changelog"| sudo chroot "${ROOTFS}" bash -c "cd '${PACKAGE_FOLDER}' && tee debian/changelog" >/dev/null || exit 1
		# Install dependencies
		sudo chroot "${ROOTFS}" bash -c "cd '${PACKAGE_FOLDER}' && mk-build-deps -i" || exit 1
	    else
		sudo chroot "${ROOTFS}" bash -c "cd '${PACKAGE_FOLDER}' && apt-get build-dep -y '${PACKAGE}'" || exit 1
	    fi
	    sudo chroot "${ROOTFS}" bash -c "cd '${PACKAGE_FOLDER}' && dpkg-buildpackage"
	    test -d "${D}/debs/${OS}/${ARCHITECTURE}" || mkdir -p "${D}/debs/${OS}/${ARCHITECTURE}"
	    sudo cp "${ROOTFS}/src/${PACKAGE}"/*.deb "${D}/debs/${OS}/${ARCHITECTURE}/."
	    sudo chown "$(id -un):$(id -gn)" "${D}/debs/${OS}/${ARCHITECTURE}"/*.deb
	) || {
	    sudo find "${ROOTFS}/src/${PACKAGE}" -mindepth 1 -maxdepth 1 -newer "${TMPDIR}/before"|sudo xargs rm -rf
	    RC=1
	}
    }
    rm -rf "${TMPDIR}/before" "${TMPDIR}/after"
    shift
done
sudo chroot "${ROOTFS}" tee /etc/apt/sources.list <"${TMPDIR}/sources.list" >/dev/null
sudo "${D}/umount.sh" "${ROOTFS}"

#
# Create the GPG key for the ppa
#
test "${RC}" -eq 0 && {
  test -d "${D}/gpg" || {
    mkdir -p "${D}/gpg"
    chmod 700 "${D}/gpg"

    cat >"${D}/gpg/lxcppa-root-and-subkey" <<EOF
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Subkey-Usage: sign
Expire-Date: 0
Name-Real: LXC PPA Temporary Key
Name-Comment: Used only when creating a container
%no-protection
%transient-key
#Passphrase: lxc-is-great
%commit
EOF

    gpgconf --homedir "${D}/gpg" --kill gpg-agent
    gpg --homedir "${D}/gpg" --batch --full-generate-key "${D}/gpg/lxcppa-root-and-subkey"

    KEY_KEYID="$(gpg --homedir "${D}/gpg" --list-keys --with-subkey-fingerprint|grep -A1 "^pub"|tail -1|tr -d " ")"
    SUBKEY_KEYID="$(gpg --homedir "${D}/gpg" --list-keys --with-subkey-fingerprint|grep -A1 "^sub"|tail -1|tr -d " ")"

    gpg --homedir "${D}/gpg" --output "${D}/gpg/lxc.public.gpg"    --export                "${KEY_KEYID}"
    gpg --homedir "${D}/gpg" --output "${D}/gpg/lxc.public.asc"    --armor --export        "${KEY_KEYID}"
    gpg --homedir "${D}/gpg" --output "${D}/gpg/lxc.secret.gpg"    --export-secret-key     "${KEY_KEYID}"
    gpg --homedir "${D}/gpg" --output "${D}/gpg/lxc.subsecret.gpg" --export-secret-subkeys "${KEY_KEYID}"
    gpg --homedir "${D}/gpg" --batch --yes --delete-secret-keys "${KEY_KEYID}"
    gpg --homedir "${D}/gpg" --import "${D}/gpg/lxc.subsecret.gpg"
    gpgconf --homedir "${D}/gpg" --kill gpg-agent
    echo "${KEY_KEYID}" >"${D}/gpg/keyid"
    echo "${SUBKEY_KEYID}" >"${D}/gpg/subkeyid"
    rm "${D}/gpg/lxcppa-root-and-subkey"
  }

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
  )
}
cleanUp
