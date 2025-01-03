#!/bin/sh
D="$(dirname "$0")"
D="$(realpath "${D}")"
BN="$(basename "$0")"
TARGET="$(realpath "$1")"
shift

test -z "${TARGET}" && {
    echo >&2 "${BN}: No target folder"
    exit 1
}

test -d "${TARGET}" || {
    echo >&2 "${BN}: Target folder '${TARGET}' does not exist"
    exit 1
}

for m in "${TARGET}" "${TARGET}/etc" "${TARGET}/bin"; do
    test -d "${m}" || { echo >&2 "${BN}: Illegal target folder '${TARGET}' - '${m}'"; exit 1; }
done

sudo true

sudo "${D}/mount.sh" "${TARGET}"
sudo chroot "${TARGET}" "$@"
sudo "${D}/umount.sh" "${TARGET}"
