#!/bin/bash
# script to create a standard guest for S3P testing
INSTALL_MEDIA_CHKSUM="https://getfedora.org/static/checksums/Fedora-Server-23-x86_64-CHECKSUM"
INSTALL_MEDIA="https://mirror.chpc.utah.edu/pub/fedora/linux/releases/23/Server/x86_64/iso/Fedora-Server-netinst-x86_64-23.iso"
NAME=vhc1
MEM_MB=1024
N_VCPU=2
ISO_FILE=$(basename $INSTALL_MEDIA)
DISK_SIZE_GB=10
VIRT_TYPE="--hvm --virt-type kvm --arch x86_64"  
	#+ OR "--paravirt"  OR "--container"
PRINT_XML="" 
    # "--print-xml" # to print XML only and NOT define the guest
	#+ OR "" to create the guest and not print XML


if [[ ! -e "$ISO_FILE"  ]]; then
    echo "The install media < $ISO_FILE > is not present in $(pwd), downloading ..."
    wget $INSTALL_MEDIA
else
    virt-install --name $NAME  --memory $MEM_MB --vcpus $N_VCPU \
        --cdrom $ISO_FILE --os-variant 'auto' --disk size=$DISK_SIZE_GB \
        --network bridge=br0 --network bridge=br1 --network network=passthrough \
        --graphics vnc $VIRT_TYPE $PRINT_XML
fi
