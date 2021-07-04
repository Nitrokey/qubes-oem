#!/usr/bin/env bash

command -v xorriso >/dev/null 2>&1 || { echo >&2 "Please install 'xorriso' first.  Aborting."; exit 1; }
command -v wget >/dev/null 2>&1 || { echo >&2 "Please install 'wget' first.  Aborting."; exit 1; }

set -xe

# Basic parameters
#
QUBES_RELEASE="R4.0.4"
#QUBES_RELEASE="R4.1.0-alpha20201014"
RELEASE_ISO_FILENAME="Qubes-${QUBES_RELEASE}-x86_64.iso"
CUSTOM_ISO_FILENAME="Qubes-${QUBES_RELEASE}-nitrokey-oem-x86_64.iso"

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
cp ../BOOTX64.cfg EFI/BOOT/
cp ../BOOTX64.EFI EFI/BOOT/
cp ../efiboot.img images/
cp ../xen.gz images/pxeboot
cp ../grub.cfg EFI/BOOT/
cp -r ../nitrokey ./
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
