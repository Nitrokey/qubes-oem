#!/usr/bin/env bash

command -v wget >/dev/null 2>&1 || { echo >&2 "Please install 'wget' first.  Aborting."; exit 1; }


set -xe

if [[ "$1" == "de" ]]; then
	if [[ "$2" = "gpu" ]];then
		./make-ks.sh de gpu
	else
		./make-ks.sh de
	fi
	cp ks-de.cfg ks.cfg

elif [ "$1" = "en" ]; then
	if [[ "$2" = "gpu" ]];then
		./make-ks.sh en gpu
	else
		./make-ks.sh en
	fi
	cp ks-en.cfg ks.cfg
else
    echo "Usage: ./make-update.sh en\|de [gpu]"
    exit
fi

echo "Build: $1 $2"



QUBES_RELEASE="R4.2.4"
RELEASE_ISO_FILENAME="Qubes-${QUBES_RELEASE}-x86_64.iso"
if [ -z "$2" ];then
	CUSTOM_ISO_FILENAME="Qubes-${QUBES_RELEASE}-oem-x86_64-${1}.img"
else
	CUSTOM_ISO_FILENAME="Qubes-${QUBES_RELEASE}-oem-x86_64-${2}-${1}.img"
fi


DEV_QUBES_IMG="$(sudo losetup -f -P --show $CUSTOM_ISO_FILENAME)"
#FIXME Start and End not acurate 
echo -e "n \n\n\n\n w "|sudo  fdisk ${DEV_QUBES_IMG}
sudo mkfs.ext4 ${DEV_QUBES_IMG}p4 
sudo tune2fs -L QUBES_OEM ${DEV_QUBES_IMG}p4

if [[ -d /tmp/mnt ]] ; then
	rm -rf /tmp/mnt
fi	

#

wget https://raw.githubusercontent.com/Nitrokey/nitrokey-udev-rules/main/41-nitrokey.rules -O nitrokey/41-nitrokey.rules

mkdir /tmp/mnt
sudo mount ${DEV_QUBES_IMG}p4 /tmp/mnt
sudo cp ks.cfg /tmp/mnt
sudo cp -r nitrokey /tmp/mnt
sudo cp -r gpu_install /tmp/mnt
sudo umount /tmp/mnt
echo "write" |sudo sfdisk --wipe always ${DEV_QUBES_IMG}
sudo losetup -d ${DEV_QUBES_IMG}



