#!/bin/sh
BN="$(basename "$0")"
D="$(dirname "$0")"
D="$(cd "${D}" && pwd)"

ALL_PPAS="$1"
test -z "${ALL_PPAS}" && {
  ALL_PPAS="${D}/ppas"
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
Packages.bz2
Packages.gz
Packages.gpg
Release
Release.gpg
Sources
Sources.bz2
Sources.gz
Sources.gpg
lxc-public.asc
lxc-public.gpg
gpg-key-id
EOF

find "${ALL_PPAS}" -name "Sources" -or -name "Packages"|xargs -n1 dirname|sort -u >"${TMPDIR}/all-ppas"

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

trim () {
    sed -e 's/^\s*//' -e 's/\s*$//'
}

while read -r PPA; do
    rm -f "${TMPDIR}/required-files"
    touch "${TMPDIR}/required-files"
    PPA_PARENT="$(dirname "${PPA}")"
    PACKAGES="${PPA}/Packages"
    rm -f "${TMPDIR}/packages-dsc-files"
    test -s "${PACKAGES}" && {
        grep -E "^\s*Filename:\s*" "${PACKAGES}"|sed -e "s,^\s*Filename:\s*,," -e "s!^!${PPA_PARENT}/!" >>"${TMPDIR}/required-files"
        grep -E "^\s*(Package|Source|Version):" "${PACKAGES}" | while read -r l; do
            N="$(echo "${l}"|cut -d : -f 1|trim)"
            V="$(echo "${l}"|cut -d : -f 2-|trim)"
            test "${N}" = "Package" && {
                START="${V}"
            }
            test "${N}" = "Source" && {
                START="${V}"
            }
            test "${N}" = "Version" && {
                MIDDLE="$(echo "${V}"|cut -d : -f 2-|trim)"
                find "$(dirname "${PACKAGES}")" -name "${START}*${MIDDLE}*.dsc"|xargs -r -n1 basename
            }
        done | sort -u >"${TMPDIR}/packages-dsc-files"
    }
    SOURCES="${PPA}/Sources"
    test -s "${SOURCES}" && {
        rm -rf "${TMPDIR}/sources-splitted"
        mkdir "${TMPDIR}/sources-splitted"
        csplit --prefix="${TMPDIR}/sources-splitted/s." --suffix-format="%04d" "${SOURCES}" '/^\s*$/' '{*}' >/dev/null
        ls "${TMPDIR}/sources-splitted"/*|sort >"${TMPDIR}/sources-sorted"
        while read -r SRC; do
            test -s "${TMPDIR}/packages-dsc-files" && {
                FOUND=
                for dsc in $(grep -o ' [^ ]*\.dsc$' "${SRC}"|cut -c 2-|sort -u); do
                    test -z "${dsc}" && continue
                    grep "$(basename "${dsc}")" "${TMPDIR}/packages-dsc-files" >/dev/null && {
                        FOUND=y
                        break
                    }
                done
                test "${FOUND}" = "y" || continue
            }
            DIR="$(getParameter "${SRC}" "Directory")"
            sed -n -e '/^Files:/,/^[^ ]/ p' "${SRC}"|grep "^\s"|sed -e 's/^\s*[0-9a-f]*\s*[0-9]*\s*//' -e "s!^!${PPA_PARENT}/${DIR}/!" >"${TMPDIR}/additional-files"
            grep "\.dsc$" "${TMPDIR}/additional-files" >"${TMPDIR}/dsc-files"
            cat "${TMPDIR}/additional-files" >>"${TMPDIR}/required-files"
            while read -r DSC; do
                for a in amd64 i386 any; do
                    echo "${DSC}"|sed -e "s,\.dsc$,_${a}.changes," >>"${TMPDIR}/required-files"
                    echo "${DSC}"|sed -e "s,\.dsc$,_${a}.buildinfo," >>"${TMPDIR}/required-files"
                done
                sed -n -e '/^Files:/,/^[^ ]/ p' "${DSC}"|grep "^\s"|sed -e 's/^\s*[0-9a-f]*\s*[0-9]*\s*//' -e "s!^!${PPA_PARENT}/${DIR}/!" >"${TMPDIR}/additional-dsc-files"
                cat "${TMPDIR}/additional-dsc-files" >>"${TMPDIR}/required-files"
                grep "\.orig\.tar" "${TMPDIR}/additional-dsc-files" >"${TMPDIR}/orig-tar-files"
                while read -r ORIG; do
                    B_ORIG="$(basename "${ORIG}")"
                    D_ORIG="$(dirname "${ORIG}")"
                    echo "${D_ORIG}/$(echo "${B_ORIG}"|sed -e 's,\.orig\.,.,' -e 's,_,-,')" >>"${TMPDIR}/required-files"
                done <"${TMPDIR}/orig-tar-files"
                rm -f "${TMPDIR}/additional-dsc-files" "${TMPDIR}/orig-tar-files"
            done <"${TMPDIR}/dsc-files"
            rm -f "${TMPDIR}/additional-files" "${TMPDIR}/dsc-files"
        done <"${TMPDIR}/sources-sorted"
        rm -f "${TMPDIR}/sources-sorted"
        rm -rf "${TMPDIR}/sources-splitted"
    }
    find "${PPA}" -type f|sort >"${TMPDIR}/all-files"
    while read -r FILE; do
        B_FILE="$(basename "${FILE}")"
        N_FILE="$(echo "${FILE}"|sed -e 's!\.\(changes\|buildinfo\|virustotal.*\|urls\)$!!')"
        grep "^${B_FILE}$" "${TMPDIR}/do-not-delete" >/dev/null && continue
        grep "^${N_FILE}$" "${TMPDIR}/required-files" >/dev/null && continue
        grep "^${FILE}$" "${TMPDIR}/required-files" >/dev/null && continue
        echo "${FILE}"
    done <"${TMPDIR}/all-files"
    rm -f "${TMPDIR}/all-files"
    rm -f "${TMPDIR}/required-files"
done <"${TMPDIR}/all-ppas"

rm -f "${TMPDIR}/all-ppas"

cleanUp
exit "${RC}"
