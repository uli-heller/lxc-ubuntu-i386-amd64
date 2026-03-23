How to build the 32bit image for resolute
=========================================

1. Build an initial image: `./create-image.sh -k -a i386 resolute`
2. Build the package "at": `./build.sh -a i386 -o resolute at`


Problems
--------

- ./build.sh: Zeile 278: /data/uli/lxc-ubuntu-i386-amd64/rebuild-ppa.sh: Datei oder Verzeichnis nicht gefunden
