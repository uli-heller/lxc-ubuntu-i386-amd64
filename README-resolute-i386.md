How to build the 32bit image for resolute
=========================================

1. Build an initial image: `./create-image.sh -k -a i386 resolute`
2. Build the package "at": `./build.sh -a i386 -o resolute at`
3. Build the package "python3-cffi": `./build.sh -a i386 -o resolute python3-cffi`
   (required by netplan.io)
4. Build the package "python3-coverage": `./build.sh -a i386 -o resolute python3-coverage`
   (required by netplan.io)
5. Build the package "python3-pytest-cov": `./build.sh -a i386 -o resolute python3-coverage`
   (required by netplan.io)
6. Create patch for netplan.io
7. Build the package "netplan.io": `./build.sh -a i386 -o resolute netplan.io`
8. Build the package "ethtool": `./build.sh -a i386 -o resolute ethtool`
   (required by netplan.io)
9. Build the package "logrotate": `./build.sh -a i386 -o resolute logrotate`
10. Build the package "jupp": `./build.sh -a i386 -o resolute jupp`
11. Build the package "joe-jupp": `./build.sh -a i386 -o resolute jupp`

Problems
--------

- ./build.sh: Zeile 278: /data/uli/lxc-ubuntu-i386-amd64/rebuild-ppa.sh: Datei oder Verzeichnis nicht gefunden
