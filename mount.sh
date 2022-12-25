#!/bin/sh
BN="$(basename "$0")"
TARGET="$1"

for d in "${TARGET}" "${TARGET}/etc" "${TARGET}/bin"; do
    test -d "${d}" || { echo >&2 "${BN}: Illegal target folder '${TARGET}' - '${d}'"; exit 1; }
done

for d in dev proc sys; do
    test -d "${TARGET}/${d}" || mkdir "${TARGET}/${d}"
    mount --bind "/${d}" "${TARGET}/${d}"
done
mount --bind /dev/pts "${TARGET}/dev/pts"
