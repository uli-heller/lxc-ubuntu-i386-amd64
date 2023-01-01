TODO
====

Open
----

No open TODOs!

Done
----

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
