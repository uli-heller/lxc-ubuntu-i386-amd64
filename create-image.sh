#!/bin/bash
###
### BN
###
### Usage:
###   BN [-a x86_64|i686] [-k] [-U] osname [osdir]"
###
### Options:
###   -a x86_64|i686 ............. target architecture
###   -k ......................... keep intermediate files
###   -U ......................... add my (Uli's) preferences
###   osname ..................... focal or jammy
###
### Examples:
###   BN -a x86_64 -U jammy ...... creates 'uli-jammy-HEAD-amd64-lxcimage.tar.xz'
###   BN -a x86_64 -k -U jammy ... creates 'uli-jammy-HEAD-amd64-lxcimage.tar.xz'
###
test -z "${BN}" && BN="$(basename "$0")"
D="$(dirname "$0")"
D="$(cd "${D}" && pwd)"

help () {
   sed -rn 's/^### ?//;T;p' "$0"|sed -e "s/BN/${BN}/g"
}

usage () {
    help|sed -n "/^Usage:/,/^\s*$/p"
}

KEEP=
USAGE=
HELP=
ARCHITECTURE=i686
ULI_MODIFICATIONS=
ULI_NAME=
while getopts 'ha:kU' opt; do
    case $opt in
	k)
	    KEEP=y
	    ;;
	a)
	    ARCHITECTURE="${OPTARG}"
	    ;;
	U)
	    ULI_MODIFICATIONS=y
	    ULI_NAME="uli-"
	    ;;
	h)
	    HELP=y
	    ;;
	*)
	    USAGE=y
	    ;;
    esac
done
shift "$(expr "${OPTIND}" - 1)"

test -n "${HELP}" && {
    help
    exit 0
}

test -n "${USAGE}" && {
    usage >&2
    exit 1
}

OS="$1"
OSDIR="$2"
test -z "${OSDIR}" && OSDIR="${OS}"
# OS=focal

D="$(dirname "$0")"
VERSION="$(cat "${D}"/VERSION 2>/dev/null)"
test -z "${VERSION}" && VERSION=HEAD

# Execute a first sudo command, so hopefully
# we don't have to ask for the sudo password
# later on
sudo true

RC=0
cleanUp () {
    sudo -n true 2>/dev/null && {
	sudo "${D}/umount.sh" "./${OSDIR}/rootfs" 2>/dev/null
    }
    exit "$RC"
}

trap cleanUp 0 1 2 3 4 5 6 7 8 9 10 12 13 14 15

case "${ARCHITECTURE}" in
    i686)
	DEBOOTSTRAP_ARCHITECTURE=i386
	;;
    x86_64)
	DEBOOTSTRAP_ARCHITECTURE=amd64
	;;
    i386|amd64)
	DEBOOTSTRAP_ARCHITECTURE="${ARCHITECTURE}"
	;;
    *)
	usage >&2
	exit 1
	;;
esac

mkdir -p "./${OSDIR}"
sudo mkdir -p "./${OSDIR}/rootfs"
test -e "${OS}-debootstrap-debs.tar.lz4" || {
  sudo debootstrap --download-only "--arch=${DEBOOTSTRAP_ARCHITECTURE}" --variant=minbase "${OS}" "./${OSDIR}/rootfs"
  test -n "${KEEP}" && tar cf - "./${OSDIR}/rootfs" |lz4 -c >"${OS}-debootstrap-debs.tar.lz4"
}

test -e "${OS}-debootstrap-debootstrap.tar.lz4" || {
  sudo debootstrap "--arch=${DEBOOTSTRAP_ARCHITECTURE}" --variant=minbase "${OS}" "./${OSDIR}/rootfs"
  test -n "${KEEP}" && sudo tar cf - "./${OSDIR}/rootfs" |lz4 -c >"${OS}-debootstrap-debootstrap.tar.lz4"
}

test -e "${OS}-mod1.txt" || {
  sudo mkdir -p "./${OSDIR}/rootfs/etc/netplan"
  sudo tee  "./${OSDIR}/rootfs/etc/netplan/netplan.yaml" >/dev/null <<EOF
network:
    version: 2
    ethernets:
        eth0:
            dhcp4: true
EOF

  sudo sed -i -e 's/$/ restricted universe multiverse/' "./${OSDIR}/rootfs/etc/apt/sources.list"
  SOURCE_LINE="$(head -1 "./${OSDIR}/rootfs/etc/apt/sources.list")"
  for r in updates backports security; do
    echo "${SOURCE_LINE}"|sed -e "s/${OS} main/${OS}-${r} main/"|sudo tee -a "./${OSDIR}/rootfs/etc/apt/sources.list"
  done
  test -n "${KEEP}" && date >"${OS}-mod1.txt"
}

test -e "${OS}-addons.tar.lz4" || {
  sudo ./mount.sh "./${OSDIR}/rootfs"
  sudo chroot "./${OSDIR}/rootfs" apt-get update
  sudo chroot "./${OSDIR}/rootfs" apt-get upgrade -y
  sudo chroot "./${OSDIR}/rootfs" apt-get install -y systemd-sysv iproute2
  sudo chroot "./${OSDIR}/rootfs" apt-get install -y apt-utils net-tools
  sudo chroot "./${OSDIR}/rootfs" apt-get install -y ca-certificates libpsl5 openssl publicsuffix
  sudo chroot "./${OSDIR}/rootfs" apt-get install -y less vim
  sudo chroot "./${OSDIR}/rootfs" bash -c "DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata"
  sudo chroot "./${OSDIR}/rootfs" apt-get install -y apt-transport-https
  #sudo chroot "./${OSDIR}/rootfs" apt-get install -y console-setup console-setup-linux # package not available?
  sudo chroot "./${OSDIR}/rootfs" apt-get install -y cron
  sudo chroot "./${OSDIR}/rootfs" apt-get install -y debconf-i18n
  sudo chroot "./${OSDIR}/rootfs" apt-get install -y distro-info
  sudo chroot "./${OSDIR}/rootfs" apt-get install -y fuse
  sudo chroot "./${OSDIR}/rootfs" apt-get install -y init
  #sudo chroot "./${OSDIR}/rootfs" apt-get install -y iputils-ping                      # package not available?
  #sudo chroot "./${OSDIR}/rootfs" apt-get install -y isc-dhcp-client                   # package not available?
  #sudo chroot "./${OSDIR}/rootfs" apt-get install -y isc-dhcp-common                   # package not available?
  #sudo chroot "./${OSDIR}/rootfs" apt-get install -y kbd                               # package not available?
  sudo chroot "./${OSDIR}/rootfs" bash -c "DEBIAN_FRONTEND=noninteractive apt-get install -y keyboad-configuration"
  sudo chroot "./${OSDIR}/rootfs" apt-get install -y language-pack-en
  sudo chroot "./${OSDIR}/rootfs" apt-get install -y language-pack-en-base
  sudo chroot "./${OSDIR}/rootfs" apt-get install -y logrotate                          # probably already installed via debs/...
  sudo chroot "./${OSDIR}/rootfs" apt-get install -y netplan.io                         # probably already installed via debs/...
  sudo chroot "./${OSDIR}/rootfs" apt-get install -y netbase
  #sudo chroot "./${OSDIR}/rootfs" apt-get install -y rsyslog                           # package not available?
  sudo chroot "./${OSDIR}/rootfs" apt-get install -y sudo
  sudo chroot "./${OSDIR}/rootfs" apt-get install -y whiptail

  sudo mkdir -p "./${OSDIR}/rootfs/etc/sudoers.d"
  sudo tee  "./${OSDIR}/rootfs/etc/sudoers.d/90-lxd" >/dev/null <<EOF
# User rules for ubuntu
ubuntu ALL=(ALL) NOPASSWD:ALL
EOF
  sudo chroot "./${OSDIR}/rootfs" useradd ubuntu -m
  sudo chroot "./${OSDIR}/rootfs" usermod -aG sudo ubuntu
  sudo chroot "./${OSDIR}/rootfs" chsh -s /bin/bash ubuntu

  # netplan.io
  # libnetplan0
  # python3-netifaces
  test -d "debs/${OS}/${ARCHITECTURE}" && {
    >"./install-packages-${OS}"
    for d in "debs/${OS}/${ARCHITECTURE}/"*; do
      b="$(basename "${d}")"
      sudo cp "${d}" "./${OSDIR}/rootfs/var/cache/apt/archives/${b}"
      echo "/var/cache/apt/archives/${b}" >>"./install-packages-${OS}"
    done
    xargs -t sudo chroot "./${OSDIR}/rootfs" apt-get install -y <"./install-packages-${OS}"
    rm -f "./install-packages-${OS}"
  }

  sudo chroot "./${OSDIR}/rootfs" apt-get update
  sudo chroot "./${OSDIR}/rootfs" apt-get upgrade -y
  sudo chroot "./${OSDIR}/rootfs" apt-get clean
  test -n "${KEEP}" && sudo tar --one-file-system -cf - "./${OSDIR}/rootfs" |lz4 -c >"${OS}-addons.tar.lz4"
  sudo ./umount.sh "./${OSDIR}/rootfs"
}

test -n "${ULI_MODIFICATIONS}" && {
    sudo ./mount.sh "./${OSDIR}/rootfs"
    sudo chroot "./${OSDIR}/rootfs" apt-get -y install joe apt-transport-https openssh-server net-tools
    sudo chroot "./${OSDIR}/rootfs" apt-get -y clean
    sudo chroot "./${OSDIR}/rootfs" tee -a /etc/bash.bashrc >/dev/null <<EOF
HISTFILESIZE=
HISTSIZE=
HISTTIMEFORMAT="[%F %T] "
# Change the file location because certain bash sessions truncate .bash_history file upon close.
# http://superuser.com/questions/575479/bash-history-truncated-to-500-lines-on-each-login
HISTFILE=~/.bash_eternal_history
# Force prompt to write history after every command.
# http://superuser.com/questions/20900/bash-history-loss
PROMPT_COMMAND="history -a; ${PROMPT_COMMAND:-true}"
# Log last command to syslog
log_command () {
 echo "${USER} $(HISTTIMEFORMAT='' builtin history 1|cut -c8-)" |  logger -t shell -p user.info
}
PROMPT_COMMAND="${PROMPT_COMMAND:-true};log_command"
EOF
    for f in /etc/skel/.bashrc /root/.bashrc /home/ubuntu/.bashrc; do
	test -e "./${OSDIR}/rootfs/${f}" && {
	    sudo chroot "./${OSDIR}/rootfs" sed -i 's/^\(HISTSIZE\|HISTFILESIZE\)/#\1/' "${f}"
	}
    done
    # sudo chroot "./${OSDIR}/rootfs" timedatectl set-timezone Europe/Berlin
    #   leads to
    #   System has not been booted with systemd as init system (PID 1). Can't operate.
    #   Failed to connect to bus: Host is down
    # so we do just set /etc/timezone
    echo "Europe/Berlin" | sudo tee "./${OSDIR}/rootfs/etc/timezone" >/dev/null

    sudo rm "./${OSDIR}/rootfs/etc/ssh/ssh_host"*
    sudo sed -i -e 's/^#PasswordAuthentication.*$/PasswordAuthentication no/' "./${OSDIR}/rootfs/etc/ssh/sshd_config"

    for u in root ubuntu; do
	sudo chroot "./${OSDIR}/rootfs" sudo -u "${u}" -i /bin/sh -c "test -d .ssh || { mkdir .ssh; chmod 700 .ssh; touch .ssh/authorized_keys; chmod 600 .ssh/authorized_keys; }"
	for p in "${D}/uli-modifications/"*.pub; do
	    sudo chroot "./${OSDIR}/rootfs" sudo -u "${u}" -i /bin/sh -c "cat >>.ssh/authorized_keys" <"${p}"
	done
    done
    sudo ./umount.sh "./${OSDIR}/rootfs"
}

echo >"./${OSDIR}/metadata.yaml"  "architecture: \"${ARCHITECTURE}\""
echo >>"./${OSDIR}/metadata.yaml" "creation_date: $(date +%s)"
echo >>"./${OSDIR}/metadata.yaml" "properties:"
echo >>"./${OSDIR}/metadata.yaml" "  description: \"Ubuntu ${OS} ${DEBOOTSTRAP_ARCHITECTURE} - Created by $(id -un)\""
echo >>"./${OSDIR}/metadata.yaml" "  os: \"ubuntu\""
echo >>"./${OSDIR}/metadata.yaml" "  release: \"${OS}\""
echo >>"./${OSDIR}/metadata.yaml" "  serial: \"$(date +%Y%m%d_%H:%M)\""
echo >>"./${OSDIR}/metadata.yaml" "  variant: default"
echo >>"./${OSDIR}/metadata.yaml" "templates:"
echo >>"./${OSDIR}/metadata.yaml" "  /etc/hostname:"
echo >>"./${OSDIR}/metadata.yaml" "    when:"
echo >>"./${OSDIR}/metadata.yaml" "    - create"
echo >>"./${OSDIR}/metadata.yaml" "    - copy"
echo >>"./${OSDIR}/metadata.yaml" "    create_only: false"
echo >>"./${OSDIR}/metadata.yaml" "    template: hostname.tpl"
echo >>"./${OSDIR}/metadata.yaml" "    properties: {}"
echo >>"./${OSDIR}/metadata.yaml" "  /etc/hosts:"
echo >>"./${OSDIR}/metadata.yaml" "    when:"
echo >>"./${OSDIR}/metadata.yaml" "    - create"
echo >>"./${OSDIR}/metadata.yaml" "    - copy"
echo >>"./${OSDIR}/metadata.yaml" "    create_only: false"
echo >>"./${OSDIR}/metadata.yaml" "    template: hosts.tpl"
echo >>"./${OSDIR}/metadata.yaml" "    properties: {}"

mkdir -p "./${OSDIR}/templates"
cat >"./${OSDIR}/templates/hosts.tpl" <<EOF
127.0.1.1	{{ container.name }}
127.0.0.1	localhost
::1		localhost ip6-localhost ip6-loopback
ff02::1		ip6-allnodes
ff02::2		ip6-allrouters
EOF

cat >"./${OSDIR}/templates/hostname.tpl" <<EOF
{{ container.name }}
EOF

(
    cd "./${OSDIR}"
    sudo tar -cpf - *
)|xz -c9 >"${ULI_NAME}${OS}-${VERSION}-${DEBOOTSTRAP_ARCHITECTURE}-lxcimage.tar.xz"

test -z "${KEEP}" && sudo rm -rf "./${OSDIR}"
