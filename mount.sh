#!/bin/sh
D="$(dirname "$0")"
D="$(realpath "${D}")"
BN="$(basename "$0")"
TARGET="$(realpath "$1")"

MOUNTS="dev dev/pts proc sys"
O_MOUNTS="${MOUNTS}"

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

RC=0
for m in ${O_MOUNTS}; do
    test -d "${TARGET}/${m}" || mkdir "${TARGET}/${m}"
    if [ -n "$(mount -l|grep "${TARGET}/${m}")" ]; then
        echo >&2 "${BN}: Already mounted - '${m}'"
        RC=1
    else
        mount --bind "/${m}" "${TARGET}/${m}"
    fi
done
exit "$RC"
