TODO
====

Open
----

- Separation
  - Keep DEBs required to setup the container images here
  - Move additional DEBs to somewhere else

- Verify: Are the PPAs usable?

- Unify and/or rename:
  - 2025-01
    - debs <-- rename to ppa?
      - focal
        - amd64
	  - Packages
	- i386
	  - Packages
	- src <-- separate src for each arch?
	  - Sources
      - jammy
        - amd64
	- i386
	- src
      - noble
	- i386
  - dprepo
    - ubuntu
      - 20.04_x86_64
        - Packages
	- Sources
        - debs
        - src
      - 20.04_i686
        - Packages
	- Sources
        - debs
        - src
      - 22.04_x86_64
        - Packages
	- Sources
        - debs
        - src
      - 22.04_i686
        - Packages
	- Sources
        - debs
        - src
      - 24.04_x86_64
        - Packages
	- Sources
        - debs
        - src

Done
----

- For noble, joe-jupp and jupp packages are missing

  ```
  ./build.sh -a i386 -o noble jupp
  ./build.sh -a i386 -o noble joe-jupp
  ```

- sudo DEBIAN_FRONTEND="noninteractive" apt install -y tzdata

  Without the option `DEBIAN_FRONTEND="noninteractive"` we get lots of
  error messages related to Dialog etc. Fixed!

- logrotate and netplan.io and at for noble i386

  Without these packages, the container instance doesn't get an IP address.
  I created the packages and now there is an IP address

- Unable to use packages v1.11
  ```
  $ xz -cd dp-jammy-v1.11-amd64-lxcimage.tar.xz| tar tvf -
  tar: Das sieht nicht wie ein „tar“-Archiv aus.
  tar: Beende mit Fehlerstatus aufgrund vorheriger Fehler
  ```
  - Fixed by executing `./create-release.sh` again  
- Use only one way to specify the architecture
  - i386 and amd64
  - i686 and x86_64
- Same packages for i386 and amd64
  - i386 always has packages from debs/...
  - amd64 is missing some of them
- Simple building of DEBs - build.sh
- Fix error
  ```
  The following packages have unmet dependencies:
   joe-jupp : Depends: jupp (>= 3.1.37) but it is not installable
  E: Unable to correct problems, you have held broken packages.
  ```
- Fix error "E: Package 'at' has no installation candidate"
- /etc/machine-id
  - https://systemd.io/BUILDING_IMAGES/
  - https://linuxcontainers.org/lxd/docs/master/image-handling/#
- /etc/ssh/*host*key
- Encrypt modifications folder
- Enable multiple potential modifications
  - modifications folder
  - modifications prefix
- New version: HEAD -> v1.7-3-g197e1a5
- Added my personal preferences - option '-U'
- Skip already done steps
- ssh pubkeys for the container (root and ubuntu)
- /etc/ssh/sshd_config for the container
