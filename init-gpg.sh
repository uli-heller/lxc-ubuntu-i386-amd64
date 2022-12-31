#!/bin/bash
BN="$(basename "$0")"
D="$(dirname "$0")"
D="$(cd "${D}" && pwd)"

test -d "${D}/gpg" || {
    mkdir -p "${D}/gpg"
    chmod 700 "${D}/gpg"

    cat >"${D}/gpg/lxcppa-root-and-subkey" <<EOF
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Subkey-Usage: sign
Expire-Date: 0
Name-Real: LXC PPA Temporary Key
Name-Comment: Used only when creating a container
%no-protection
%transient-key
#Passphrase: lxc-is-great
%commit
EOF

    gpgconf --homedir "${D}/gpg" --kill gpg-agent
    gpg --homedir "${D}/gpg" --batch --full-generate-key "${D}/gpg/lxcppa-root-and-subkey"

    KEY_KEYID="$(gpg --homedir "${D}/gpg" --list-keys --with-subkey-fingerprint|grep -A1 "^pub"|tail -1|tr -d " ")"
    SUBKEY_KEYID="$(gpg --homedir "${D}/gpg" --list-keys --with-subkey-fingerprint|grep -A1 "^sub"|tail -1|tr -d " ")"

    gpg --homedir "${D}/gpg" --output "${D}/gpg/lxc.public.gpg"    --export                "${KEY_KEYID}"
    gpg --homedir "${D}/gpg" --output "${D}/gpg/lxc.public.asc"    --armor --export        "${KEY_KEYID}"
    gpg --homedir "${D}/gpg" --output "${D}/gpg/lxc.secret.gpg"    --export-secret-key     "${KEY_KEYID}"
    gpg --homedir "${D}/gpg" --output "${D}/gpg/lxc.subsecret.gpg" --export-secret-subkeys "${KEY_KEYID}"
    gpg --homedir "${D}/gpg" --batch --yes --delete-secret-keys "${KEY_KEYID}"
    gpg --homedir "${D}/gpg" --import "${D}/gpg/lxc.subsecret.gpg"
    gpgconf --homedir "${D}/gpg" --kill gpg-agent
    echo "${KEY_KEYID}" >"${D}/gpg/keyid"
    echo "${SUBKEY_KEYID}" >"${D}/gpg/subkeyid"
    rm "${D}/gpg/lxcppa-root-and-subkey"
}
