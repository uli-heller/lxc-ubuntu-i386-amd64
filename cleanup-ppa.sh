#!/bin/sh
BN="$(basename "$0")"
D="$(dirname "$0")"
D="$(cd "${D}" && pwd)"

ALL_PPAS="$1"
test -z "${ALL_PPAS}" && {
  ALL_PPAS="${D}/debs"
}

TMPDIR="/tmp/${BN}-$(date +%s+%N|sha256sum|cut -d " " -f 1)-$$~"

RC=0
cleanUp () {
    rm -rf "${TMPDIR}"
    exit "${RC}"
}

trap cleanUp 0 1 2 3 4 5 6 7 8 9 10 12 13 14 15

mkdir "${TMPDIR}"

cat >"${TMPDIR}/do-not-delete" <<EOF
InRelease
Packages
Packages.gpg
Release
Release.gpg
lxc-public.asc
lxc-public.gpg
EOF

find "${ALL_PPAS}" -mindepth 2 -type d -not -name src >"${TMPDIR}/all-ppas"

while read -r PPA; do
    PACKAGES="${PPA}/Packages"
    test -s "${PACKAGES}" || continue
    find "${PPA}" -name "*.deb" >"${TMPDIR}/all-debs"
    while read -r DEB; do
	grep -E "^\s*Filename:\s*(\./)?$(basename "${DEB}")\s*$" "${PACKAGES}" >/dev/null || echo "${DEB}"
    done <"${TMPDIR}/all-debs"
    rm -f "${TMPDIR}/all-debs"
done <"${TMPDIR}/all-ppas"
rm -f "${TMPDIR}/all-ppas"

#
# $1 ... filename
# $2 ... pname
#
getParameter () {
    (
	test -s "${1}" || exit 1
	L="$(grep "^\s*${2}:" "${1}")"
	test -n "${L}" || exit 1
	echo "${L}"|cut -d ":" -f 2-|tr -d " "
    )
}

find "${ALL_PPAS}" -mindepth 2 -type d -name src >"${TMPDIR}/src-ppas"
while read -r SRC_PPA; do
    rm -f "${TMPDIR}/dsc-files"
    find "${SRC_PPA}/.." -mindepth 1 -maxdepth 1 -type d -not -name src >"${TMPDIR}/ppas"
    while read -r PPA; do
	rm -f "${TMPDIR}/csplit."*
	PACKAGES="${PPA}/Packages"
	test -s "${PACKAGES}" || continue
	grep -E "^\s*(Package|Source|Version):\s*" "${PACKAGES}" >"${TMPDIR}/pkg-properties"
	csplit --prefix="${TMPDIR}/csplit." --suffix-format="%04d" "${TMPDIR}/pkg-properties" '/Package:/' '{*}' >/dev/null
	find "${TMPDIR}" -name "csplit.*"|sort >"${TMPDIR}/pkgs"
	while read -r PKG; do
	    PACKAGE="$(getParameter "${PKG}" Package)" || continue
	    SOURCE="$(getParameter "${PKG}" Source)" || SOURCE="${PACKAGE}"
	    VERSION="$(getParameter "${PKG}" Version)"
	    CLEAN_VERSION="$(echo "${VERSION}"|sed -e 's/^[^:]://')"
	    echo "${SOURCE}_${CLEAN_VERSION}.dsc" >>"${TMPDIR}/dsc-files"
	    #echo "P=${PACKAGE}, S=${SOURCE}, V=${CLEAN_VERSION}"
	done <"${TMPDIR}/pkgs"
	rm -f "${TMPDIR}/pkgs"
	rm -f "${TMPDIR}/csplit."*
    done <"${TMPDIR}/ppas"
    cp "${TMPDIR}/dsc-files" "${TMPDIR}/src-files"
    find "${SRC_PPA}" -type f -name "*.dsc" >"${TMPDIR}/dsc1"
    while read -r DSC; do
	grep "^$(basename "${DSC}")$" "${TMPDIR}/dsc-files" >/dev/null || continue	
	( cd "$(dirname "${DSC}")" && echo "$(basename "${DSC}" .dsc)"*.buildinfo ) >>"${TMPDIR}/src-files"
	( cd "$(dirname "${DSC}")" && echo "$(basename "${DSC}" .dsc)"*.changes ) >>"${TMPDIR}/src-files"
	for f in $(sed -n -e '/^Files:/,/^[^ ]/ p' "${DSC}" | grep "^ " | cut -d " " -f 4-); do
	    g="$(echo "${f}"|sed -e "s/\.orig\././" -e "s/_/-/")"
	    echo "${f}" >>"${TMPDIR}/src-files"
	    echo "${g}" >>"${TMPDIR}/src-files"
	    echo "${f}.virustotal.json" >>"${TMPDIR}/src-files"
	    echo "${g}.virustotal.json" >>"${TMPDIR}/src-files"
	done
    done <"${TMPDIR}/dsc1"
    rm -f "${TMPDIR}/dsc1"
    find "${SRC_PPA}" -type f|sort >"${TMPDIR}/all-files"
    while read -r F; do
	grep "^$(basename "${F}")$" "${TMPDIR}/do-not-delete" >/dev/null && continue
	grep "^$(basename "${F}")$" "${TMPDIR}/src-files" >/dev/null || realpath "${F}"
    done <"${TMPDIR}/all-files"
    rm -f "${TMPDIR}/all-files"
    rm -f "${TMPDIR}/src"
    rm -f "${TMPDIR}/dsc-files"
    rm -f "${TMPDIR}/ppas"
done <"${TMPDIR}/src-ppas"
rm -f "${TMPDIR}/src-ppas"

cleanUp
exit "${RC}"
