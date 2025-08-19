#!/usr/bin/env bash

command -v wget >/dev/null 2>&1 || { echo >&2 "Please install 'wget' first.  Aborting."; exit 1; }



if [[ "$1" == "de" ]]; then
	if [[ "$2" = "gpu" ]];then
		./make-ks.sh de gpu
	else
		./make-ks.sh de
	fi

elif [ "$1" = "en" ]; then
	if [[ "$2" = "gpu" ]];then
		./make-ks.sh en gpu
	else
		./make-ks.sh en
	fi
else
    echo "Usage:"
    echo "./make-image.sh en"
    echo "./make-image.sh en gpu"
    echo "./make-image.sh de "
    echo "./make-image.sh de gpu"
    exit
fi

set -xe

echo "Build: $1 $2"



QUBES_RELEASE="R4.2.4"
RELEASE_ISO_FILENAME="Qubes-${QUBES_RELEASE}-x86_64.iso"
if [ -z "$2" ];then
	CUSTOM_ISO_FILENAME="Qubes-${QUBES_RELEASE}-oem-x86_64-${1}.img"
else
	CUSTOM_ISO_FILENAME="Qubes-${QUBES_RELEASE}-oem-x86_64-${2}-${1}.img"
fi

if [ ! -f "${RELEASE_ISO_FILENAME}" ]; then
	wget -q "https://mirrors.edge.kernel.org/qubes/iso/${RELEASE_ISO_FILENAME}" -O unverified.iso
	wget -q "https://mirrors.edge.kernel.org/qubes/iso/${RELEASE_ISO_FILENAME}.asc"
	gpgv --keyring ./qubes-release-keyring.gpg "${RELEASE_ISO_FILENAME}.asc" unverified.iso
	mv unverified.iso "${RELEASE_ISO_FILENAME}"
fi

dd if=/dev/zero of=qubes_oem.img bs=1M count=500 
mv qubes_oem.img $CUSTOM_ISO_FILENAME 
#cat "${RELEASE_ISO_FILENAME}" qubes_oem.img > $CUSTOM_ISO_FILENAME
DEV_QUBES_IMG="$(sudo losetup -f -P --show $CUSTOM_ISO_FILENAME)"
#FIXME Start and End not acurate 
#echo -e "n \n\n\n\n w "|sudo  fdisk ${DEV_QUBES_IMG}
echo -e "n \n\n\n\n\n w "|sudo  fdisk ${DEV_QUBES_IMG}

PART="p1"
sudo mkfs.fat -F32 -v -I -n "QUBES_OEM" ${DEV_QUBES_IMG}${PART}
#sudo tune2fs -L QUBES_OEM ${DEV_QUBES_IMG}${PART}

if [[ -d /tmp/mnt ]] ; then
	sudo rm -rf /tmp/mnt
fi	

#

wget https://raw.githubusercontent.com/Nitrokey/nitrokey-udev-rules/main/41-nitrokey.rules -O nitrokey/41-nitrokey.rules

mkdir /tmp/mnt
sudo mount ${DEV_QUBES_IMG}${PART} /tmp/mnt
sudo cp ks.cfg /tmp/mnt
sudo cp -r nitrokey /tmp/mnt
sudo cp -r gpu_install /tmp/mnt
sudo umount /tmp/mnt
echo "write" |sudo sfdisk --wipe always ${DEV_QUBES_IMG}
sudo losetup -d ${DEV_QUBES_IMG}



