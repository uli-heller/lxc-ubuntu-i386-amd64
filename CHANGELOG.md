CHANGELOG
=========

v1.11
-----
- Use --numeric-owner for tar file creation
- Change ownership of metadata.yaml and templates
- Fixed warnings when creating an amd64 image
- Fixed local warnings for perl

v1.10
-----

- Recreated all DEBs using 'build.sh'
- Install DEBs via local PPA

v1.9
----

- Fixed warning about package 'at' for special images (uli and dp)
- Fixed issues related to joe, joe-jupp and jupp on i386

v1.8
----

- create-image.sh:
  - new option '-m moddir'
  - new option '-p prefix'
  - new version: HEAD -> v1.7-3-g197e1a5
  - machine-id: Initialize on create, copy, rename
  - ssh host keys: Recreate for new machine-ids
  - added openssh-server to all images
- dp-modifications: Added Steffen's pubkey

v1.7
----

- build.sh: Started to work on rebuilding a deb package
- create-image.sh: New option '-U' to add my personal preferences to the images
  - Install joe, apt-transport-https, net-tools and at
  - Prepare openssh for installation
  - Added my personal SSH key
  - Prepare timezone for initialization
  - Fix sshd_config - no password logins
- create-image.sh: New option '-h' to show a helpful message

v1.6
----

- Fixed README.md - use new naming, add version and architecture to imported image name
- Fixed description of lxc image - use debootstrap architectures (i686/x86_64 -> i386/amd64)
- Changed login shell to /bin/bash for user "ubuntu" [fixes #1]
- Renamed again lxc-ubuntu-i686-amd64 -> lxc-ubuntu-i386-amd64

v1.5
----

- create-image.sh, create-64bit-image.sh: New scripts
- Changed image names: Added architecture
- Renamed: lxc-ubuntu-32bit -> lxc-ubuntu-i686-amd64

v1.4
----

- build.sh: New script
- install.sh: New script
- Added "logrotate"
- Use xz compression

v1.3
----

- Set hostname to container name
- Remove isc-dhcp-client

v1.2
----

- Added lots of debs, for example "sudo"
- Added user "ubuntu"

v1.1
----

- Added description for focal debs
- Use freshly created focal debs

v1.0
----

- Created images for Ubuntu-20.04 (focal) and 22.04 (jammy)
- Added description on how to build missing debs
- Added screenshort from virustotal

v0.5
----

- Reduced image size

v0.4
----

- Fixed naming issues

v0.3
----

- Created exported LXC image

v0.2
----

- Some initial work related to Ubuntu-20.04 (focal)

v0.1
----

- A first release (experimental)
