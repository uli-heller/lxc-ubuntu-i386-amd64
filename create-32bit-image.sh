#!/bin/sh
#
OS="$1"
OSDIR="$2"
test -z "${OSDIR}" && OSDIR="${OS}"
# OS=focal


debootstrap --download-only --arch=i386 --variant=minbase "${OS}" "./${OSDIR}"
tar cf - "./${OSDIR}" |xz -c9 >"${OS}-debootstrap-debs.tar.xz"

sudo debootstrap --arch=i386 --variant=minbase "${OS}" "./${OSDIR}"
sudo tar cf - "./${OSDIR}" |xz -c9 >"${OS}-debootstrap.tar.xz"

sudo mkdir -p "./${OSDIR}/etc/netplan"
sudo tee  "./${OSDIR}/etc/netplan/netplan.yaml" <<EOF
network:
    version: 2
    ethernets:
        eth0:
            dhcp4: true
EOF

sudo sed -i -e 's/$/ restricted universe multiverse/' "./${OSDIR}/etc/apt/sources.list"
SOURCE_LINE="$(head -1 "./${OSDIR}/etc/apt/sources.list")"
for r in updates backports security; do
  echo "${SOURCE_LINE}"|sed -e "s/${OS} main/${OS}-${r} main/"|sudo tee -a "./${OSDIR}/etc/apt/sources.list"
done

sudo ./mount.sh "./${OSDIR}"
sudo chroot "./${OSDIR}" apt-get update
sudo chroot "./${OSDIR}" apt-get upgrade -y
sudo chroot "./${OSDIR}" apt-get install -y uidmap systemd-sysv iproute2
sudo chroot "./${OSDIR}" apt-get install -y apt-utils net-tools
sudo chroot "./${OSDIR}" apt-get install -y ca-certificates libpsl5 openssl publicsuffix

>"${TMPDIR}/install-packages"
for d in debs/*; do
    b="$(basename "${d}")"
    sudo cp "${d}" "./${OSDIR}/var/cache/apt/archives/${b}"
    echo "/var/cache/apt/archives/${b}" >>"${TMPDIR}/install-packages"
done
xargs sudo chroot "./${OSDIR}" apt-get install -y <"${TMPDIR}/install-packages"
rm -f "${TMPDIR}/install-packages"

sudo chroot "./${OSDIR}" apt-get update
sudo chroot "./${OSDIR}" apt-get upgrade -y
sudo chroot "./${OSDIR}" apt-get install -y netplan.io
# netplan.io
# libnetplan0
# python3-netifaces
sudo ./umount.sh "./${OSDIR}"

echo >metadata.yaml  "architecture: \"i386\""
echo >>metadata.yaml "creation_date: $(date +%s)"
echo >>metadata.yaml "properties:"
echo >>metadata.yaml "  description: \"Created by $(id -un)\""
echo >>metadata.yaml "  os: \"ubuntu\""
echo >>metadata.yaml "  release: \"${OS}\""

tar -cf - metadata.yaml |gzip -c9 >"metadata-${OS}.tar.gz"
(cd "./${OSDIR}" && sudo tar -cpf - .)|gzip -c9 >"${OS}-lxc.tar.gz"
