#!/bin/bash
set -exuo pipefail
#####################################################################################
# Script Name: oem-release.sh
# Description: upload iso files and the list of sha256 to
#              nitrokey.com/files/ci/[Device]/[Distribution]
# Usage:       set scp(ssh) server with user and path
#              create env-variable with private key:
#              $ssh_server_key(delete first and last line)
#              $ssh_port Port in hex has to be 8digits e.g:000008BF
#              $ssh_address e.g.: user@www.internet.com:/root/ci
# Run:         ./oem-release.sh [iso-file] 
#####################################################################################


artifacts_folder=artifacts
port=$(echo $(( 16#$ssh_port )))

# create ssh-key file
echo "-----BEGIN OPENSSH PRIVATE KEY-----" > ~/server_key
echo "$ssh_server_key" >> ~/server_key
echo "-----END OPENSSH PRIVATE KEY-----" >> ~/server_key
chmod 600 ~/server_key

# Upload artifacts folder
echo Upload Files:
echo uploading to $ssh_address/
find $artifacts_folder/ -type f -printf "%T@ %p\n" | sort -nr | cut -d\  -f2-
rsync -e "ssh -p $port -i ~/server_key"  -a $artifacts_folder/*nitropad*.iso $ssh_address/nitropad/qubes-oem/
rsync -e "ssh -p $port -i ~/server_key"  -a $artifacts_folder/*nitropc*.iso $ssh_address/nitropc/qubes-oem/