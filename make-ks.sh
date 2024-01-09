#!/usr/bin/env bash
KS_TEMPLATE=ks_template.cfg

command -v ksvalidator >/dev/null 2>&1 || { echo >&2 "Please install 'pykickstart' first.  Aborting."; exit 1; }


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
    echo "Usage: ./make-ks.sh en\|de"
    exit
fi

if ! ksvalidator ks.cfg; then
	echo "Error with the Kickstarter File"
	exit
fi
cp ks.cfg ks-$1.cfg

# copy ks file as ks.cfg on a usb drive that is formatet with the name QUBES_OEM see here
# https://github.com/QubesOS/qubes-lorax-templates/pull/19

# cp -r ../nitrokey ./

#Install diffrent top File that enables usb keyboard + sys-usb https://www.qubes-os.org/doc/usb-qubes/#how-to-create-a-usb-qube-for-use-with-a-usb-keyboard
#FIXME commentout for testing
#if [ $DEVICE == "nitropc" ];then
#    mv nitrokey/init.top_nitropc nitrokey/init.top
#else
#    rm nitrokey/init.top_nitropc
#fi

