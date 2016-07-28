#!/bin/bash

function domid_from_xml ( ) {
    DOMID=${1%".xml"}  # trim shortest match from end
    echo $DOMID
}

function get_running_vm_list ( ) {
    # get a list of currently running VMs
    virsh list | grep -e "^ [[:digit:]]" | tr -s ' ' | cut -d' ' -f3
}

function get_all_vm_list ( ) {
    # list all defined VMs
    virsh list --all | grep -e "^ [[:digit:]]" -e "^ -" | tr -s ' ' | cut -d' ' -f3
}

function launch_vm_from_filename ( ) {
    # launch a VM given a libvirt XML file 
    local _XML_FNAME=$1
    define_vm_from_xml $_XML_FNAME
    local _DOMID=$(domid_from_xml $_XML_FNAME)
    start_vm $_DOMID
}

function define_vm_from_xml ( ) {
    # creates a new domain (VM) definition from a libvirt XML definition
    # use virsh define to error-check the xml
    XML_FNAME=$1
    DOMID=$(domid_from_xml $XML_FNAME)
    RUNNING_LIST=$(get_running_vm_list)
    if [[ "$RUNNING_LIST" == *"${DOMID}"* ]]; then
        #statements
        echo "Error: Domain $DOMID already exists $(echo $LAUNCH_LIST | grep $DOMID --color=always)"
        echo "NOTE:: The domain may be removed (undefined) with \"virsh undefine $DOMID\""
        virsh list --all
    else
        virsh define $XML_FNAME 
    fi
}

function start_vm ( ) {
    # use virsh to start a VM that has already been defined
    # assumes VM is defined, available, and not running
    local _DOMID="$1"
    virsh start $_DOMID
}

function launch_vm_with_virsh ( ) {
    # args: $1 = DOMID, a virsh domain (VM) name
    XML_FNAME=$1
    DOMID=$(domid_from_xml $XML_FNAME)
    RUNNING_LIST=$(get_running_vm_list)
    if [[ "$RUNNING_LIST" == *"${DOMID}"* ]]; then
        #statements
        echo "Error: Domain $DOMID already exists $(echo $LAUNCH_LIST | grep $DOMID --color=always)"
        echo "NOTE:: The domain may be removed (undefined) with \"virsh undefine $DOMID\""
        virsh list --all
    else
        echo "Launching VM with XML-file: $XML_FNAME"
        define_vm_from_xml $XML_FNAME
        start_vm $DOMID
    fi
}

function launch_vm_list ( ) {
    LAUNCH_LIST=$(ls *.xml)
    for XML_FNAME in $LAUNCH_LIST; do 
        #DOMID=$(echo $XML_FNAME | tr -d ".xml") 
        DOMID=$(domid_from_xml "$XML_FNAME")
        echo "Launching VM: ${DOMID} ..."
        launch_vm_with_virsh "$XML_FNAME"
    done
}


