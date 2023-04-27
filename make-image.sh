#!/usr/bin/env bash
KS_TEMPLATE=ks_template.cfg

command -v xorriso >/dev/null 2>&1 || { echo >&2 "Please install 'xorriso' first.  Aborting."; exit 1; }
command -v wget >/dev/null 2>&1 || { echo >&2 "Please install 'wget' first.  Aborting."; exit 1; }
set -xe
cp $KS_TEMPLATE ks.cfg

if [ "$1" = "de" ]; then
    sed -i s/KB_LANG/de/g ks.cfg 
    sed -i s/SYS_LANG/de_DE.UTF-8/g ks.cfg
    echo "Build DE"
elif [ "$1" = "en" ]; then
    sed -i s/KB_LANG/us/g ks.cfg 
    sed -i s/SYS_LANG/en_US.UTF-8/g ks.cfg
    echo "Build EN"
else
    echo "Usage: ./make-image.sh en\|de nitropc\|nitropad"
    exit
fi

if [ "$2" = "nitropad" ];then
    sed -i s/DISK_INSTALL/sda/g ks.cfg
    DEVICE="nitropad"
    echo "Bulid nitropad image"
elif [ "$2" = "nitropad-nx" ]; then
    sed -i s/DISK_INSTALL/nvme0n1/g ks.cfg
    DEVICE="nitropad-nx"
		echo "Build nitropad-nx image"	
elif [ "$2" = "nitropc" ];then
    sed -i s/DISK_INSTALL/nvme0n1/g ks.cfg
    DEVICE="nitropc"
    echo "Bulid nitropc image"
else
    echo "Usage: ./make-image.sh en\|de nitropc\|nitropad "
    exit
fi
# Basic parameters
QUBES_RELEASE="R4.1.2"
RELEASE_ISO_FILENAME="Qubes-${QUBES_RELEASE}-x86_64.iso"
CUSTOM_ISO_FILENAME="Qubes-${QUBES_RELEASE}-${DEVICE}-oem-x86_64-${1}.iso"

UNPACKED_IMAGE_PATH="./unpacked-iso/"
MBR_IMAGE_FILENAME="${RELEASE_ISO_FILENAME}.mbr"

if [ ! -f "${RELEASE_ISO_FILENAME}" ]; then
	wget -q "https://ftp.qubes-os.org/iso/${RELEASE_ISO_FILENAME}" -O unverified.iso
	wget -q "https://ftp.qubes-os.org/iso/${RELEASE_ISO_FILENAME}.asc"
    gpgv --keyring ./qubes-release-keyring.gpg "${RELEASE_ISO_FILENAME}.asc" unverified.iso
    mv unverified.iso "${RELEASE_ISO_FILENAME}"
fi

# It's easier to copy the MBR off the original image than to generate a new one
# that would be identical anyway
dd if="${RELEASE_ISO_FILENAME}" bs=446 count=1 of="${MBR_IMAGE_FILENAME}"

# Unpack ISO, make data writable
xorriso -osirrox on -indev  "${RELEASE_ISO_FILENAME}" -- -extract / "${UNPACKED_IMAGE_PATH}"
chmod -R u+w unpacked-iso/

pushd unpacked-iso
# Patch ISOLINUX configs to remove unnecessary choices and, more
# importantly, add kernel command line arguments that force Ubiquity into
# automatic mode
cp ../isolinux.cfg isolinux/
cp ../ks.cfg ./
cp -r ../nitrokey ./

#Install diffrent top File that enables usb keyboard + sys-usb https://www.qubes-os.org/doc/usb-qubes/#how-to-create-a-usb-qube-for-use-with-a-usb-keyboard
if [ $DEVICE == "nitropc" ];then
    mv nitrokey/init.top_nitropc nitrokey/init.top
else
    rm nitrokey/init.top_nitropc
fi
#nitopc efi boot
cp ../BOOTX64.cfg EFI/BOOT/
cp ../grub.cfg EFI/BOOT/
popd

# Build the new ISO
xorriso -as mkisofs -v -U -J -R -T \
    -isohybrid-mbr "${MBR_IMAGE_FILENAME}" \
    -m repoview \
    -m boot.iso \
    -b isolinux/isolinux.bin \
    -c isolinux/boot.cat \
    -no-emul-boot -boot-load-size 4 -boot-info-table \
    -eltorito-alt-boot \
    -e images/efiboot.img \
    -no-emul-boot \
    -V QUBES_OEM \
    -o "${CUSTOM_ISO_FILENAME}" \
	"${UNPACKED_IMAGE_PATH}"
