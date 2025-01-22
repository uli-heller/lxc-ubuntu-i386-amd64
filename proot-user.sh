#!/bin/sh

PATH="$(echo "${PATH}"|tr ":" "\n"|grep -v /home|tr "\n" ":"|sed -e 's/:$//')"
export PATH
exec proot -R "$@"
