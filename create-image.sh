#!/bin/bash
###
### BN
###
### Usage:
###   BN [-a amd64|i386] [-k] [-U] [-m moddir] [-p prefix] osname [osdir]"
###
### Options:
###   -a i386|amd64|x86_64|i686 ... target architecture
###   -k .......................... keep intermediate files
###   -U .......................... add my (Uli's) preferences (synonym for '-m uli-modifications -p 'uli')
###   -m moddir ................... add modifications of moddir
###   -p prefix ................... prefix for the name of the final container
###   osname ...................... focal or jammy
###
### Examples:
###   BN -a amd64 jammy ......... creates 'jammy-HEAD-amd64-lxcimage.tar.xz'
###   BN -a amd64 -k jammy ...... creates 'jammy-HEAD-amd64-lxcimage.tar.xz' and stores intermediate steps for faster re-execution
###
### "Special" Examples (not suitable for general use):
###   BN -a amd64 -U jammy ...... creates 'uli-jammy-HEAD-amd64-lxcimage.tar.xz'
###   BN -a amd64 -k -U jammy ... creates 'uli-jammy-HEAD-amd64-lxcimage.tar.xz' and stores intermediate steps for faster re-execution
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

LANG=C
export LANG

KEEP=
USAGE=
HELP=
ARCHITECTURE=i686
MODIFICATIONS_FOLDER=
MODIFICATIONS_PREFIX=
while getopts 'ha:kUp:m:' opt; do
    case $opt in
	k)
	    KEEP=y
	    ;;
	a)
	    ARCHITECTURE="${OPTARG}"
	    ;;
	p)
	    MODIFICATIONS_PREFIX="${OPTARG}"
	    ;;
	m)
	    MODIFICATIONS_FOLDER="${OPTARG}"
	    ;;
	U)
	    MODIFICATIONS_FOLDER="${D}/uli-modifications"
	    MODIFICATIONS_PREFIX="uli"
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
# OS=focal

VERSION="$(cat "${D}"/VERSION 2>/dev/null)"
test -z "${VERSION}" && VERSION="$(cd "${D}" && git describe --tags 2>/dev/null)"
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

test -z "${OSDIR}" && OSDIR="${OS}-${DEBOOTSTRAP_ARCHITECTURE}"

test -e "${OS}-${DEBOOTSTRAP_ARCHITECTURE}-01-debootstrap-debs.tar.lz4" || {
  mkdir -p "./${OSDIR}"
  sudo mkdir -p "./${OSDIR}/rootfs"
  sudo debootstrap --download-only "--arch=${DEBOOTSTRAP_ARCHITECTURE}" --variant=minbase "${OS}" "./${OSDIR}/rootfs"
  test -n "${KEEP}" && tar cf - "./${OSDIR}/rootfs" |lz4 -c >"${OS}-${DEBOOTSTRAP_ARCHITECTURE}-01-debootstrap-debs.tar.lz4"
}

test -e "${OS}-${DEBOOTSTRAP_ARCHITECTURE}-02-debootstrap-debootstrap.tar.lz4" || {
  sudo debootstrap "--arch=${DEBOOTSTRAP_ARCHITECTURE}" --variant=minbase "${OS}" "./${OSDIR}/rootfs"
  test -n "${KEEP}" && sudo tar cf - "./${OSDIR}/rootfs" |lz4 -c >"${OS}-${DEBOOTSTRAP_ARCHITECTURE}-02-debootstrap-debootstrap.tar.lz4"
}

ROOTFS="./${OSDIR}/rootfs"
test -e "${OS}-${DEBOOTSTRAP_ARCHITECTURE}-03-addons.tar.lz4" || {
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

  sudo mkdir -p "${ROOTFS}/var/cache/lxc-ppa"
  sudo cp "${D}/debs/${OS}/${DEBOOTSTRAP_ARCHITECTURE}"/*  "${ROOTFS}/var/cache/lxc-ppa" 2>/dev/null && {
      sudo cp "${D}/debs/${OS}/${DEBOOTSTRAP_ARCHITECTURE}"/lxc.public.gpg "${ROOTFS}/etc/apt/trusted.gpg.d/." 2>/dev/null && {
	  echo "deb file:/var/cache/lxc-ppa/ ./"|sudo tee "${ROOTFS}/etc/apt/sources.list.d/lxc-ppa.list"
      }
  }

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
  sudo chroot "./${OSDIR}/rootfs" apt-get install -y openssh-server

  sudo mkdir -p "./${OSDIR}/rootfs/etc/sudoers.d"
  sudo tee  "./${OSDIR}/rootfs/etc/sudoers.d/90-lxd" >/dev/null <<EOF
# User rules for ubuntu
ubuntu ALL=(ALL) NOPASSWD:ALL
EOF
  sudo chroot "./${OSDIR}/rootfs" useradd ubuntu -m
  sudo chroot "./${OSDIR}/rootfs" usermod -aG sudo ubuntu
  sudo chroot "./${OSDIR}/rootfs" chsh -s /bin/bash ubuntu

  sudo chroot "./${OSDIR}/rootfs" apt-get update
  sudo chroot "./${OSDIR}/rootfs" apt-get upgrade -y
  #sudo chroot "./${OSDIR}/rootfs" apt-get clean
  sudo ./umount.sh "./${OSDIR}/rootfs"

  test -n "${KEEP}" && sudo tar --one-file-system -cf - "./${OSDIR}/rootfs" |lz4 -c >"${OS}-${DEBOOTSTRAP_ARCHITECTURE}-03-addons.tar.lz4"
}

test -d "./${OSDIR}/rootfs" || {
    mkdir "./${OSDIR}"
    lz4 -cd "${OS}-${DEBOOTSTRAP_ARCHITECTURE}-03-addons.tar.lz4"|sudo tar -xf -
}

sudo ./mount.sh "./${OSDIR}/rootfs"
sudo tee "./${OSDIR}/rootfs/usr/local/bin/first-start.sh" >/dev/null <<'EOF'
#!/bin/sh
INIT=
test -d /etc/first-start || { mkdir -p /etc/first-start; INIT=complete; }
test -s /etc/machine-id && {
  test -z "${INIT}" && {
    cmp /etc/machine-id /etc/first-start/machine-id 2>/dev/null || INIT=new-machine-id
  }
}
test -n "${INIT}" && {
  rm -f /etc/ssh/ssh_host_*
  dpkg-reconfigure openssh-server
  cp /etc/machine-id /etc/first-start/machine-id
}
true
EOF
sudo chmod +x "./${OSDIR}/rootfs/usr/local/bin/first-start.sh"

sudo tee "./${OSDIR}/rootfs/lib/systemd/system/first-start.service" >/dev/null <<EOF
[Unit]
Before=systemd-user-sessions.service
Wants=network-online.target
After=network-online.target
ConditionPathExists=/usr/local/bin/first-start.sh

[Service]
Type=oneshot
ExecStart=/usr/local/bin/first-start.sh
#ExecStartPost=rm -rf /usr/local/bin/first-start.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

sudo chroot "./${OSDIR}/rootfs" systemctl enable /lib/systemd/system/first-start.service

test -d "${MODIFICATIONS_FOLDER}" && {
    sudo tee -a "./${OSDIR}/rootfs/usr/local/bin/first-start.sh" >/dev/null <<'EOF'
test "${INIT}" = "complete" && {
  timedatectl set-timezone Europe/Berlin
  sed -i -e 's/^#PasswordAuthentication.*$/PasswordAuthentication no/' "/etc/ssh/sshd_config"
}
true
EOF
    
    test -s "${MODIFICATIONS_FOLDER}/additional-packages" && {
        sudo chroot "./${OSDIR}/rootfs" xargs apt-get -y install <"${MODIFICATIONS_FOLDER}/additional-packages"
    }
    sudo chroot "./${OSDIR}/rootfs" apt-get -y clean
    sudo chroot "./${OSDIR}/rootfs" tee -a /etc/bash.bashrc >/dev/null <<'EOF'
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


    for u in root ubuntu; do
	sudo chroot "./${OSDIR}/rootfs" sudo -u "${u}" -i /bin/sh -c "test -d .ssh || { mkdir .ssh; chmod 700 .ssh; touch .ssh/authorized_keys; chmod 600 .ssh/authorized_keys; }"
	for p in "${MODIFICATIONS_FOLDER}/"*.pub; do
	    sudo chroot "./${OSDIR}/rootfs" sudo -u "${u}" -i /bin/sh -c "cat >>.ssh/authorized_keys" <"${p}"
	done
    done
}
sudo ./umount.sh "./${OSDIR}/rootfs"

echo >"./${OSDIR}/metadata.yaml"  "architecture: \"${ARCHITECTURE}\""
echo >>"./${OSDIR}/metadata.yaml" "creation_date: $(date +%s)"
echo >>"./${OSDIR}/metadata.yaml" "properties:"
echo >>"./${OSDIR}/metadata.yaml" "  description: \"Ubuntu ${OS} ${DEBOOTSTRAP_ARCHITECTURE} - Created by $(id -un)\""
echo >>"./${OSDIR}/metadata.yaml" "  os: \"ubuntu\""
echo >>"./${OSDIR}/metadata.yaml" "  release: \"${OS}\""
echo >>"./${OSDIR}/metadata.yaml" "  serial: \"$(date +%Y%m%d_%H:%M)\""
echo >>"./${OSDIR}/metadata.yaml" "  variant: default"
echo >>"./${OSDIR}/metadata.yaml" "templates:"
echo >>"./${OSDIR}/metadata.yaml" "  /etc/hosts:"
echo >>"./${OSDIR}/metadata.yaml" "    when:"
echo >>"./${OSDIR}/metadata.yaml" "    - create"
echo >>"./${OSDIR}/metadata.yaml" "    - copy"
echo >>"./${OSDIR}/metadata.yaml" "    - rename"
echo >>"./${OSDIR}/metadata.yaml" "    create_only: false"
echo >>"./${OSDIR}/metadata.yaml" "    template: hosts.tpl"
echo >>"./${OSDIR}/metadata.yaml" "    properties: {}"
echo >>"./${OSDIR}/metadata.yaml" "  /etc/machine-id:"
echo >>"./${OSDIR}/metadata.yaml" "    when:"
echo >>"./${OSDIR}/metadata.yaml" "    - create"
echo >>"./${OSDIR}/metadata.yaml" "    - copy"
echo >>"./${OSDIR}/metadata.yaml" "    - rename"
echo >>"./${OSDIR}/metadata.yaml" "    create_only: false"
echo >>"./${OSDIR}/metadata.yaml" "    template: machine-id.tpl"
echo >>"./${OSDIR}/metadata.yaml" "    properties: {}"
echo >>"./${OSDIR}/metadata.yaml" "  /var/lib/dbus/machine-id:"
echo >>"./${OSDIR}/metadata.yaml" "    when:"
echo >>"./${OSDIR}/metadata.yaml" "    - create"
echo >>"./${OSDIR}/metadata.yaml" "    - copy"
echo >>"./${OSDIR}/metadata.yaml" "    - rename"
echo >>"./${OSDIR}/metadata.yaml" "    create_only: false"
echo >>"./${OSDIR}/metadata.yaml" "    template: machine-id.tpl"
echo >>"./${OSDIR}/metadata.yaml" "    properties: {}"
echo >>"./${OSDIR}/metadata.yaml" "  /etc/hostname:"
echo >>"./${OSDIR}/metadata.yaml" "    when:"
echo >>"./${OSDIR}/metadata.yaml" "    - start"
echo >>"./${OSDIR}/metadata.yaml" "    create_only: false"
echo >>"./${OSDIR}/metadata.yaml" "    template: hostname.tpl"
echo >>"./${OSDIR}/metadata.yaml" "    properties: {}"
sudo chown root.root ./${OSDIR}/metadata.yaml

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

# https://systemd.io/BUILDING_IMAGES/
# - 1.: Remove the /etc/machine-id file or write the string uninitialized\n into it
# - 2. to 5.: Don't apply to containers, the files mentioned to not exist
cat >"./${OSDIR}/templates/machine-id.tpl" <<EOF
EOF
sudo chown -R root.root ./${OSDIR}/templates

PREFIX="${MODIFICATIONS_PREFIX}"
test -n "${PREFIX}" && {
    expr "${PREFIX}" : '.*-$' >/dev/null || PREFIX="${PREFIX}-"
}

#sudo rm -rf "${ROOTFS}/var/cache/lxc-ppa" "${ROOTFS}/etc/apt/trusted.gpg.d/lxc.public.gpg" "${ROOTFS}/etc/apt/sources.list.d/lxc-ppa.list"

(
    cd "./${OSDIR}"
    sudo tar --numeric-owner \
	 --exclude "rootfs/var/cache/lxc-ppa"\
	 --exclude "rootfs/etc/apt/trusted.gpg.d/lxc.public.gpg"\
	 --exclude "rootfs/etc/apt/sources.list.d/lxc-ppa.list"\
	 --exclude "rootfs/var/cache/apt/archives"\
	 --exclude "rootfs/proc/"\
	 -cpf - *
)|xz -T0 -c9 >"${PREFIX}${OS}-${VERSION}-${DEBOOTSTRAP_ARCHITECTURE}-lxcimage.tar.xz"

sudo rm -rf "./${OSDIR}"
