Verify usability of PPAs
========================

ppas
----

TLDR: After restructuring, ppas work ok for both DEBs and SRC-DEBs!

Restructure the folders underneath "debs" into "ppas"

- debs/jammy/amd64 -> ppas/amd64/jammy/debs
- debs/jammy/src -> ppas/amd64/jammy/src
- rebuild-ppa.sh -> rebuild-debs.sh
- rebuild-ppa.sh -> rebuild-ppas.sh
- Fix rebuild-ppas.sh

Verification process:

- change into proot filesystem

  ```
  $ ./proot.sh build-proot-jammy-amd64/rootfs -b ppas:/ppas bash
  groups: cannot find name for group ID 108
  groups: cannot find name for group ID 113
  groups: cannot find name for group ID 10000
  To run a command as administrator (user "root"), use "sudo <command>".
  See "man sudo_root" for details.

  root:/# ls /ppas
  focal  jammy  noble
  ```

#- add certificate/key
#
#  ```
#  root:/# gpg --dearmor -o /etc/apt/keyrings/dprepo-proot.gpg </dprepo/uli_key_2022.asc
#  ```
  
- add ppa

  ```
  root:/# cat >/etc/apt/sources.list.d/ppas-proot.list <<EOF
  deb file:/ppas/amd64 jammy/
  deb-src file:/ppas/amd64 jammy/
  EOF
  ```

- verify ppas

  ```
  root:/# apt update
  Get:1 file:/var/cache/lxc-ppa ./ InRelease [2234 B]
  Get:2 file:/ppas/amd64 jammy/ InRelease [2994 B]
  Get:1 file:/var/cache/lxc-ppa ./ InRelease [2234 B]
  Get:2 file:/ppas/amd64 jammy/ InRelease [2994 B]
  Hit:3 http://archive.ubuntu.com/ubuntu jammy InRelease
  Hit:4 http://archive.ubuntu.com/ubuntu jammy-updates InRelease
  Hit:5 http://archive.ubuntu.com/ubuntu jammy-backports InRelease
  Hit:6 http://archive.ubuntu.com/ubuntu jammy-security InRelease
  Hit:7 http://archive.ubuntu.com/ubuntu noble InRelease
  Hit:8 http://archive.ubuntu.com/ubuntu noble-updates InRelease
  Hit:9 http://archive.ubuntu.com/ubuntu noble-backports InRelease
  Hit:10 http://archive.ubuntu.com/ubuntu noble-security InRelease
  Reading package lists... Done
  Building dependency tree... Done
  Reading state information... Done
  All packages are up to date.
  ```

  No errors or warnings - good!

- verify deb package

  ```
  root:/# apt policy gocryptfs
  gocryptfs:
    Installed: (none)
    Candidate: 2.4.0.54-1ubuntu0.24.04.2~uh~jammy2
    Version table:
       2.4.0.54-1ubuntu0.24.04.2~uh~jammy2 500
          500 file:/ppas/amd64 jammy/ Packages
       2.4.0.51-1ubuntu0.24.04.2~uh~jammy1 500
          500 file:/var/cache/lxc-ppa ./ Packages
       1.8.0-1ubuntu0.1 500
          500 http://archive.ubuntu.com/ubuntu jammy-updates/universe amd64 Packages
          500 http://archive.ubuntu.com/ubuntu jammy-security/universe amd64 Packages
       1.8.0-1build1 500
          500 http://archive.ubuntu.com/ubuntu jammy/universe amd64 Packages

  root:/# apt install -y gocryptfs
  ...
  Selecting previously unselected package gocryptfs.
  (Reading database ... 63432 files and directories currently installed.)
  Preparing to unpack .../gocryptfs_2.4.0.54-1ubuntu0.24.04.2~uh~jammy2_amd64.deb ...
  Unpacking gocryptfs (2.4.0.54-1ubuntu0.24.04.2~uh~jammy2) ...
  Setting up gocryptfs (2.4.0.54-1ubuntu0.24.04.2~uh~jammy2) ...
  Processing triggers for man-db (2.10.2-1) ...

  root:/# apt purge -y gocryptfs
  ...
  (Reading database ... 63441 files and directories currently installed.)
  Removing gocryptfs (2.4.0.54-1ubuntu0.24.04.2~uh~jammy2) ...
  Processing triggers for man-db (2.10.2-1) ...
  ```

- verify src package

  ```
  root:/# cd /tmp
  root:/tmp# mkdir s
  root:/tmp# cd s
  
  root:/tmp/s# apt source gocryptfs
  Reading package lists... Done
  NOTICE: 'gocryptfs' packaging is maintained in the 'Git' version control system at:
  https://salsa.debian.org/go-team/packages/gocryptfs.git
  Please use:
  git clone https://salsa.debian.org/go-team/packages/gocryptfs.git
  to retrieve the latest (possibly unreleased) updates to the package.
  Need to get 0 B/1392 kB of source archives.
  Get:1 file:/ppas/amd64 jammy/ gocryptfs 2.4.0.54-1ubuntu0.24.04.2~uh~jammy2 (dsc) [1907 B]
  Get:2 file:/ppas/amd64 jammy/ gocryptfs 2.4.0.54-1ubuntu0.24.04.2~uh~jammy2 (tar) [1380 kB]
  Get:3 file:/ppas/amd64 jammy/ gocryptfs 2.4.0.54-1ubuntu0.24.04.2~uh~jammy2 (diff) [10.8 kB]
  dpkg-source: info: extracting gocryptfs in gocryptfs-2.4.0.54
  dpkg-source: info: unpacking gocryptfs_2.4.0.54.orig.tar.gz
  dpkg-source: info: unpacking gocryptfs_2.4.0.54-1ubuntu0.24.04.2~uh~jammy2.debian.tar.xz

  root:/tmp/s# cd /tmp
  root:/tmp# rm -rf s
  ```
  
- cleanup ppa

  ```
  root:/# rm -f /etc/apt/sources.list.d/ppas-proot.list
  root:/# apt update
  ...
  ```
  
- exit proot filesystem

  ```
  root:/# exit
  $
  ```

debs
----

TLDR: Source do NOT work!

Verification process (only part of due to errors):

- change into proot filesystem

  ```
  $ ./proot.sh build-proot-jammy-amd64/rootfs -b debs:/debs bash
  groups: cannot find name for group ID 108
  groups: cannot find name for group ID 113
  groups: cannot find name for group ID 10000
  To run a command as administrator (user "root"), use "sudo <command>".
  See "man sudo_root" for details.

  root:/# ls /debs
  focal  jammy  noble
  ```

- add ppa

  - variant A

    ```
    root:/# cat >/etc/apt/sources.list.d/debs-proot.list <<EOF
    deb file:/debs/jammy amd64/
    deb-src file:/debs/jammy src/
    EOF
    ```

    Leads to: `W: Conflicting distribution: file:/debs/jammy amd64/ InRelease (expected amd64/ but got jammy)`

  - variant B

    ```
    root:/# cat >/etc/apt/sources.list.d/debs-proot.list <<EOF
    deb file:/debs/jammy/amd64 ./
    deb-src file:/debs/jammy/src/ ./
    EOF
    ```

    Leads to: `W: Skipping acquire of configured file 'Sources' as repository 'file:/debs/jammy/src ./ InRelease' does not seem to provide it (sources.list entry misspelt?)`

dprepo
------

TLDR: "dprepo" works OK für DEBs and SRCs!

Prerequisites for the verification:

- ssh access to dprepo
- proot file system - build-proot-jammy-amd64

Verification process:

- mount dprepo

  ```
  $ mkdir dprepo
  $ sshfs dprepo:///var/www/html/dprepo dprepo
  ``

- change into proot filesystem

  ```
  $ ./proot.sh build-proot-jammy-amd64/rootfs -b dprepo:/dprepo bash
  groups: cannot find name for group ID 108
  groups: cannot find name for group ID 113
  groups: cannot find name for group ID 10000
  To run a command as administrator (user "root"), use "sudo <command>".
  See "man sudo_root" for details.

  root:/# ls /dprepo
  chrome-extensions  datenschutz-public  firefox-extensions  intern  obsolet  test-delete  ubuntu
  ```

- add certificate/key

  ```
  root:/# gpg --dearmor -o /etc/apt/keyrings/dprepo-proot.gpg </dprepo/uli_key_2022.asc
  ```
  
- add ppa

  ```
  root:/# cat >/etc/apt/sources.list.d/dprepo-proot.list <<EOF
  deb [signed-by=/etc/apt/keyrings/dprepo-proot.gpg] file:/dprepo/ubuntu 22.04_x86_64/
  deb-src [signed-by=/etc/apt/keyrings/dprepo-proot.gpg] file:/dprepo/ubuntu 22.04_x86_64/
  EOF
  ```

- verify ppas

  ```
  root:/# apt update
  Get:1 file:/dprepo/ubuntu 22.04_x86_64/ InRelease [4197 B]
  Get:2 file:/var/cache/lxc-ppa ./ InRelease [2234 B]
  Get:1 file:/dprepo/ubuntu 22.04_x86_64/ InRelease [4197 B]
  Hit:3 http://archive.ubuntu.com/ubuntu jammy InRelease
  Get:4 http://archive.ubuntu.com/ubuntu jammy-updates InRelease [128 kB]
  Get:2 file:/var/cache/lxc-ppa ./ InRelease [2234 B]            
  Get:5 file:/dprepo/ubuntu 22.04_x86_64/ Sources [8646 B]       
  Get:6 http://archive.ubuntu.com/ubuntu jammy-backports InRelease [127 kB]
  Get:7 http://archive.ubuntu.com/ubuntu jammy-security InRelease [129 kB]
  Get:8 file:/dprepo/ubuntu 22.04_x86_64/ Packages [20.8 kB]
  Hit:9 http://archive.ubuntu.com/ubuntu noble InRelease   
  Get:10 http://archive.ubuntu.com/ubuntu noble-updates InRelease [126 kB]
  Get:11 http://archive.ubuntu.com/ubuntu noble-backports InRelease [126 kB] 
  Get:12 http://archive.ubuntu.com/ubuntu noble-security InRelease [126 kB]
  Fetched 763 kB in 3s (282 kB/s)     
  Reading package lists... Done
  Building dependency tree... Done
  Reading state information... Done
  3 packages can be upgraded. Run 'apt list --upgradable' to see them.
  ```

  No errors or warnings - good!

- verify deb package

  ```
  root:/# apt policy restic
  restic:
    Installed: (none)
    Candidate: 0.17.3-2dp11~jammy1
    Version table:
       0.17.3-2dp11~jammy1 500
          500 file:/dprepo/ubuntu 22.04_x86_64/ Packages
       0.12.1-2ubuntu0.3 500
          500 http://archive.ubuntu.com/ubuntu jammy-updates/universe amd64 Packages
          500 http://archive.ubuntu.com/ubuntu jammy-security/universe amd64 Packages
       0.12.1-2 500
          500 http://archive.ubuntu.com/ubuntu jammy/universe amd64 Packages  

  root:/# apt install restic
  ...
  Selecting previously unselected package restic.
  (Reading database ... 63422 files and directories currently installed.)
  Preparing to unpack .../restic_0.17.3-2dp11~jammy1_amd64.deb ...
  Unpacking restic (0.17.3-2dp11~jammy1) ...
  Setting up restic (0.17.3-2dp11~jammy1) ...
  Processing triggers for man-db (2.10.2-1) ...

  root:/# apt purge -y restic
  ...
  Removing restic (0.17.3-2dp11~jammy1) ...
  Processing triggers for man-db (2.10.2-1) ...
  ```

- verify src package

  ```
  root:/# cd /tmp
  root:/tmp# mkdir s
  root:/tmp# cd s
  
  root:/tmp/s# apt source restic
  Reading package lists... Done
  NOTICE: 'restic' packaging is maintained in the 'Git' version control system at:
  https://salsa.debian.org/go-team/packages/restic.git
  Please use:
  git clone https://salsa.debian.org/go-team/packages/restic.git
  to retrieve the latest (possibly unreleased) updates to the package.
  Need to get 0 B/24.1 MB of source archives.
  Get:1 file:/dprepo/ubuntu 22.04_x86_64/ restic 0.17.3-2dp11~jammy1 (dsc) [1252 B]
  Get:2 file:/dprepo/ubuntu 22.04_x86_64/ restic 0.17.3-2dp11~jammy1 (tar) [24.1 MB]
  Get:3 file:/dprepo/ubuntu 22.04_x86_64/ restic 0.17.3-2dp11~jammy1 (diff) [12.1 kB]
  dpkg-source: info: extracting restic in restic-0.17.3
  dpkg-source: info: unpacking restic_0.17.3.orig.tar.gz
  dpkg-source: info: unpacking restic_0.17.3-2dp11~jammy1.debian.tar.xz
  dpkg-source: info: using patch list from debian/patches/series
  dpkg-source: info: applying 0001-privacy-breach.patch

  root:/tmp/s# cd /tmp
  root:/tmp# rm -rf s
  ```
  
- cleanup ppa

  ```
  root:/# rm -f /etc/apt/sources.list.d/dprepo-proot.list
  root:/# rm -f /etc/apt/keyrings/dprepo-proot.gpg
  root:/# apt update
  ...
  ```
  
- exit proot filesystem

  ```
  root:/# exit
  $
  ```

- umount dprepo

  ```
  $ fusermount -u dprepo
  ```
