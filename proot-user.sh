#!/bin/sh
#set -x
#
# When running under ubuntu-20.04, this works: ./proot-user build-proot-jammy-amd64/rootfs/
# When running under ubuntu-24.04, you'll get: '-sh: 35: Syntax error: "(" unexpected (expecting "}")'
# ... so you have to use:                       ./proot-user build-proot-jammy-amd64/rootfs/ bash
#
exec proot -R "$@"
