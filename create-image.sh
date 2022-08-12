#!/bin/sh
#
test -z "${BN}" && BN="$(basename "$0")"

usage () {
    echo "USAGE: ${BN} [-a x86_64|i686] [-k] osname [osdir]"
}

KEEP=
USAGE=
ARCHITECTURE=i686
while getopts 'a:k' opt; do
    case $opt in
	k)
	    KEEP=y
	    ;;
	a)
	    ARCHITECTURE="${OPTARG}"
	    ;;
	*)
	    USAGE=y
	    ;;
    esac
done
shift "$(expr "${OPTIND}" - 1)"

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

case "${ARCHITECTURE}" in
    i686)
	DEBOOTSTRAP_ARCHITECTURE=i386
	;;
    x86_64)
	DEBOOTSTRAP_ARCHITECTURE=amd64
	;;
    *)
	usage >&2
	exit 1
	;;
esac

mkdir -p "./${OSDIR}/rootfs"
debootstrap --download-only "--arch=${DEBOOTSTRAP_ARCHITECTURE}" --variant=minbase "${OS}" "./${OSDIR}/rootfs"
test -n "${KEEP}" && tar cf - "./${OSDIR}/rootfs" |xz -c9 >"${OS}-debootstrap-debs.tar.xz"

sudo debootstrap "--arch=${DEBOOTSTRAP_ARCHITECTURE}" --variant=minbase "${OS}" "./${OSDIR}/rootfs"
test -n "${KEEP}" && sudo tar cf - "./${OSDIR}/rootfs" |xz -c9 >"${OS}-debootstrap.tar.xz"

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
#sudo chroot "./${OSDIR}/rootfs" timedatectl set-timezone Europe/Berlin
sudo ./umount.sh "./${OSDIR}/rootfs"

echo >"./${OSDIR}/metadata.yaml"  "architecture: \"${ARCHITECTURE}\""
echo >>"./${OSDIR}/metadata.yaml" "creation_date: $(date +%s)"
echo >>"./${OSDIR}/metadata.yaml" "properties:"
echo >>"./${OSDIR}/metadata.yaml" "  description: \"Ubuntu ${OS} ${ARCHITECTURE} - Created by $(id -un)\""
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
)|xz -c9 >"${OS}-${VERSION}-${ARCHITECTURE}-lxcimage.tar.xz"

test -z "${KEEP}" && sudo rm -rf "./${OSDIR}"
