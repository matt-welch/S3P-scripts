#!/bin/bash

function replaceImagePath ( ) {
    # use sed to modify the image path in a libvirt XML definition
    # if $1 is not set, print error message
    DOMXML_FNAME="${1:?${USAGE_ERR_MSG}}"

    # save backup as .bak, replace paths to source file with NEW_IMAGE_STORE, leave filename alone
    sed -i.bak "s:\(<source file='\).*\(/.*.img\):\1${IMAGE_STORE}\2:g" $DOMXML_FNAME 

    # NOTE: to "undo" the action of this function, 
    #+ repeat it with the original paths in place of NEW_IMAGE_STORE above
}

function cloneDOMXML ( ) {
    # if $1 is not set, print error message
    NEW_DOM_NAME="${1:?${USAGE_ERR_MSG}}"
    OUTPUT="${NEW_DOM_NAME}.xml"
    echo "$0 :: [$(date)] :: cloning domain XML <$DOMAIN_REF.xml> to <$NEW_DOM_NAME.xml> ..."
    sed "s:${DOMAIN_REF}:${NEW_DOM_NAME}:" ${DOMAIN_REF}.xml > ${NEW_DOM_NAME}.xml 
}

function copyImage ( ) {
    # clone the original HDD image with rsync to show status: 
    SOURCE_IMAGE="${1:?${USAGE_ERR_MSG}}"
    NEW_IMAGE_PATH=$2
    echo "$0 :: [$(date)] :: cloning source image <$SOURCE_IMAGE> to <$NEW_IMAGE_PATH> ..."
    rsync --progress -av ${SOURCE_IMAGE} ${NEW_IMAGE_PATH}
    chown qemu:qemu ${NEW_IMAGE_PATH}
    echo "$0 :: [$(date)] :: cloning source image <$SOURCE_IMAGE> to <$NEW_IMAGE_PATH> is complete."
}

function sysprepImage ( ) {
    # use virt-sysprep to prepare the image
    # Note: SYSPREP_OPS variable may not end in a ','
    #SYSPREP_OPS="net-hostname,net-hwaddr,fs-uuids,dhcp-client-state" 
    #OPTIONS="--enable ${SYSPREP_OPS} " 
    # the set of SYSPREP_OPS above breaks the image and renders the VM unbootable
    #+ likely due to FS issues
    #virt-sysprep $OPTIONS -a ${NEW_IMAGE_PATH}
    NEW_HOSTNAME="${1:?${USAGE_ERR_MSG}}"
    OPTIONS="--hostname $NEW_HOSTNAME "
    echo "$0 :: [[$(date)] :: beginning virt-sysprep of <$NEW_IMAGE_PATH> with operations: $SYSPREP_OPS "
    # prevent libvirt from looking for virbr0 
    export LIBGUESTFS_BACKEND_SETTINGS=network_bridge=br0
    # Try running qemu directly without libvirt using this environment variable:
    export LIBGUESTFS_BACKEND=direct

    virt-customize ${OPTIONS} -a "${NEW_IMAGE_PATH}"
    echo "$0 :: [[$(date)] :: virt-sysprep of <$NEW_IMAGE_PATH> with operations: \"$SYSPREP_OPS\" is now complete."
}

# location of VM image store
IMAGE_STORE="/data/images"
SOURCE_IMAGE="${IMAGE_STORE}/vh-seed.img"
DOMXML_STORE="$(pwd)"
DOMAIN_REF="vh-seed"
DOMXML_SRC="${DOMAIN_REF}.xml"

USAGE_ERR_MSG="ERROR: a new domain name must be specified.  Usage:: $0 newName  "
# if no new domain name is provided ($1), print error message
NEW_DOM_NAME="${1:?${USAGE_ERR_MSG}}"
NEW_HOSTNAME="${NEW_DOM_NAME}"
NEW_IMAGE_NAME="${NEW_DOM_NAME}.img"
NEW_IMAGE_PATH="${IMAGE_STORE}/${NEW_IMAGE_NAME}"

# steps to clone an existing guest image: 
# 1) copy the image file (rsync)
# 2) modify the hostname in image (virt-customize)
if [[ -f "${NEW_IMAGE_PATH}" ]] ; then 
    # image file already exisis
    # ask the user if they want to continue
    read -p "Domain image \"$1\" already exists, replace it? [y/N]: " -n 1 input
    echo
    if [[ "$input" == "y" ]] ; then 
        copyImage "$SOURCE_IMAGE" "$NEW_IMAGE_PATH"
        sysprepImage $NEW_HOSTNAME
    else
        # ask the user if they want to re-do the sysprep on the existing image
        read -p "Perform virt-sysprep on existing image? [y/N]: " -n 1 input
        echo
        if [[ "$input" == "y" ]] ; then 
            sysprepImage $NEW_HOSTNAME
        fi
    fi
else
    copyImage "$SOURCE_IMAGE" "$NEW_IMAGE_PATH"
    sysprepImage $NEW_HOSTNAME
fi

# 3) copy the domxl 
# 4) modify the domain name in domxml (sed) 
cloneDOMXML $NEW_DOM_NAME 

