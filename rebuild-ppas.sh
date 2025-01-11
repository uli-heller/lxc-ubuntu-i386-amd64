#!/bin/sh
BN="$(basename "$0")"
D="$(dirname "$0")"
D="$(cd "${D}" && pwd)"

P_ARCHITECTURE="$1"
P_OS="$2"

P_FILES="InRelease lxc.public.asc lxc.public.gpg Packages Packages.gpg Release Release.gpg Sources Sources.gpg"

# $1 ... baseline file
# $2 ... compare files
findNewerFiles () {
    (
        RC=1
        BASELINE_FILE="$1"
        BASELINE_TIMESTAMP="$(stat --format "%Y" "${BASELINE_FILE}")"
        while [ $# -gt 0 ]; do
            COMPARE_FILE="$1"
            COMPARE_TIMESTAMP="$(stat --format "%Y" "${COMPARE_FILE}")"
            test "${COMPARE_TIMESTAMP}" -gt "${BASELINE_TIMESTAMP}" && {
                echo "${COMPARE_FILE}"
                RC=0
            }
            shift
        done
        exit "${RC}"
    )
}

#
# $1 ... Packages file
#
findMissingFiles () {
    (
        RC=0
        FOLDER="$(dirname "$1")"
        if [ -s "$1" ]; then
            for f in $(grep "Filename:" "$1"|cut -d " " -f 2-); do
                test -e "${FOLDER}/${f}" || {
                    echo "${FOLDER}/${f}"
                    RC=1
                }
            done
        else
            echo "$1"
            RC=1
        fi
        exit "${RC}"
    )
}

test -n "${P_ARCHITECTURE}" && {
    test -n "${P_OS}" && {
        mkdir -p "${D}/debs/${P_OS}/${P_ARCHITECTURE}"
    }
}

"${D}/init-gpg.sh"
for ppa in "${D}/ppas/"*/*; do
    OS="$(basename "${ppa}")"
    ARCHITECTURE="$(basename "$(dirname "${ppa}")")"
    UPDATE_THIS_PPA=
    NEWEST=
    for f in ${P_FILES}; do
        if [ ! -e "${ppa}/${f}" ]; then
            UPDATE_THIS_PPA=y
        else
            if [ -z "${NEWEST}" ]; then
                NEWEST="${f}"
            elif [ "$(stat --format "%Y" "${ppa}/${f}")" -gt "$(stat --format "%Y" "${ppa}/${NEWEST}")" ]; then
                NEWEST="${f}"
            fi
        fi
    done
    if [ -n "$(findNewerFiles "${ppa}/${NEWEST}" "${ppa}"/*)"  ]; then
        UPDATE_THIS_PPA=y
    fi
    if [ -n "$(findMissingFiles "${ppa}/Packages")" ]; then
        UPDATE_THIS_PPA=y
    fi
    test -n "${UPDATE_THIS_PPA}" && {
        (
            cd "${ppa}/.."
            SUBFOLDER="$(echo "${ppa}"|grep -o '/[^/]*$'|cut -c 2-)"
            dpkg-scanpackages "${SUBFOLDER}" >"${SUBFOLDER}/Packages"
            dpkg-scansources  "${SUBFOLDER}" >"${SUBFOLDER}/Sources"
            cd "${ppa}"
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
            rm -f "Packages.gpg"
            gpg --homedir "${D}/gpg" -abs --digest-algo SHA256 -u "$(cat "${D}/gpg/keyid")" -o "Packages.gpg" "Packages"
            rm -f "Sources.gpg"
            gpg --homedir "${D}/gpg" -abs --digest-algo SHA256 -u "$(cat "${D}/gpg/keyid")" -o "Sources.gpg" "Sources"
            rm -f "InRelease"
            apt-ftparchive -c "Release.tmp" release "." >"./Release"
            rm -f "Release.tmp"
            rm -f "Release.gpg"
            gpg --homedir "${D}/gpg" -abs --digest-algo SHA256 -u "$(cat "${D}/gpg/keyid")" -o "Release.gpg" "Release"
            gpg --homedir "${D}/gpg" -abs --digest-algo SHA256 -u "$(cat "${D}/gpg/keyid")" --clearsign -o "InRelease" "Release"
            cp "${D}/gpg/lxc.public.asc" .
            cp "${D}/gpg/lxc.public.gpg" .
        )
    }
done
