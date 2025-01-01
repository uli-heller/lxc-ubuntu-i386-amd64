#!/bin/sh
BN="$(basename "$0")"
TARGET="$1"

test -z "${TARGET}" && {
    echo >&2 "${BN}: Kein Zielverzeichnis angegeben"
    exit 1
}

test -d "${TARGET}" || {
    echo >&2 "${BN}: Zielverzeichnis '${TARGET}' existiert nicht"
    exit 1
}

#set -x
for m in dev/pts dev proc sys; do
    umount "${TARGET}/${m}"           2>/dev/null
    chroot "${TARGET}" umount "/${m}" 2>/dev/null
done
