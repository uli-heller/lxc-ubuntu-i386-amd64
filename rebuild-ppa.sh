#°/bin/sh
BN="$(basename "$0")"
D="$(dirname "$0")"
D="$(cd "${D}" && pwd)"

P_ARCHITECTURE="$1"
P_OS="$2"

test -n "${P_ARCHITECTURE}" && {
    test -n "${P_OS}" && {
        mkdir -p "${D}/debs/${P_OS}/${P_ARCHITECTURE}"
    }
}

"${D}/init-gpg.sh"
for ppa in "${D}/debs/"*/*; do
    ARCHITECTTURE="$(basename "${ppa}")"
    OS="$(basename "$(dirname "${ppa}")")"
    UPDATE_THIS_PPA=
    if [ ! -e "${ppa}/lxc.public.gpg" ]; then
        UPDATE_THIS_PPA=y
    elif [ -n "$(find "${ppa}" -newer "${ppa}/lxc.public.gpg")"  ]; then
        UPDATE_THIS_PPA=y
    fi
    test -n "${UPDATE_THIS_PPA}" && {
        (
            cd "${ppa}"
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
            rm -f "Packages.gpg"
            gpg --homedir "${D}/gpg" -abs --digest-algo SHA256 -u "$(cat "${D}/gpg/keyid")" -o "Packages.gpg" "Packages"
            rm -f "InRelease"
            gpg --homedir "${D}/gpg" -abs --digest-algo SHA256 -u "$(cat "${D}/gpg/keyid")" --clearsign -o "InRelease" "Release"
            cp "${D}/gpg/lxc.public.asc" .
            cp "${D}/gpg/lxc.public.gpg" .
        )
    }
done
