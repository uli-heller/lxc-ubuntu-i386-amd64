#!/bin/sh
D="$(dirname "${0}")"
BN="$(basename "${0}")"
export BN

exec "${D}/create-image.sh" -a "amd64" "$@"
