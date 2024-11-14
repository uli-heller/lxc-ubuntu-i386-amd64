#!/bin/sh
#
# create-release.sh
#

D="$(dirname "$0")"
D="$(cd "${D}" && pwd)"
BN="$(basename "$0")"

DBN="$(basename "${D}")"

TMPDIR="/tmp/${BN}-$(openssl rand -hex 10)-$$~"

cleanUp () {
    rm -rf "${TMPDIR}"
    test -n "${RC}" && exit "${RC}"
}

trap cleanUp 0 1 2 3 4 5 6 7 8 9 10 12 13 14 15

mkdir -p "${TMPDIR}"

#set -x
HASH="$(git rev-parse HEAD)"
TAG="$(git describe --tags "${HASH}")"
TARXZ="${DBN}-${TAG}.tar.xz"

mkdir -p "${TMPDIR}/${DBN}-${TAG}"
cp -a "${D}/." "${TMPDIR}/${DBN}-${TAG}/."
(
    cd "${TMPDIR}/${DBN}-${TAG}"
    git clean -fdx
    rm -rf ".git*"
    echo "${TAG}" >"VERSION"
) >/dev/null 2>&1
(
    cd "${TMPDIR}"
    # --transform "s,^[.],${DBN}-${TAG},"
    tar --exclude '.git*' --exclude '*~' --exclude "${BN}" ${NO_VIRUS} -cf - "./${DBN}-${TAG}"
)|xz -c9 >"${TARXZ}"
sha256sum "${TARXZ}" >"${TARXZ}.sha256"
sha1sum "${TARXZ}" >"${TARXZ}.sha1"

ls -1 "${TARXZ}"*

for r in noble jammy focal; do for a in amd64 i386; do ./create-image.sh -k -a ${a} ${r}; done; done

# Below, images not for general usage are created
for r in noble jammy focal; do for a in amd64 i386; do ./create-image.sh -U -k -a ${a} ${r}; done; done
for r in noble jammy focal; do for a in amd64 i386; do ./create-image.sh -m dp-modifications -p dp -k -a ${a} ${r}; done; done

cleanUp
exit 0
