#!/bin/sh
D="$(dirname "$0")"
D="$(realpath "${D}")"
BN="$(basename "$0")"
TARGET="$(realpath "$1")"

MOUNTS="dev dev/pts proc sys"
O_MOUNTS="$(echo "${MOUNTS}"|tr " " "\n"|sort -r|tr "\n" " ")"

test -z "${TARGET}" && {
    echo >&2 "${BN}: No target folder"
    exit 1
}

test -d "${TARGET}" || {
    echo >&2 "${BN}: Target folder '${TARGET}' does not exist"
    exit 1
}

RC=0
#set -x
for m in ${O_MOUNTS}; do
    if [ -n "$(mount -l|grep "${TARGET}/${m}")" ]; then
        umount "${TARGET}/${m}"           2>/dev/null
        chroot "${TARGET}" umount "/${m}" 2>/dev/null
    else
        echo >&2 "${BN}: Not mounted - '${m}'"
        RC=1
    fi
done
exit "$RC"
