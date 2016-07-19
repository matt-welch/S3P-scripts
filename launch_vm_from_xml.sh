#!/bin/bash

function launch_vm_with_virsh ( ) {
    # args: $1 = DOMID, a virsh domain (VM) name
    DOMID=$1
    RUNNING_LIST=$(virsh list | grep -e "^ [[:digit:]]" | tr -s ' ' | cut -d' ' -f3)
    if [[ "$RUNNING_LIST" == *"${DOMID}"* ]]; then
        #statements
        echo "Error: Domain $DOMID is already running $(echo $LAUNCH_LIST | grep $DOMID --color=always)"
    else
        echo "Launching VM with XML-file: $DOMID"
        # virsh create domain.xml
    fi
}

function launch_vm_list ( ) {
    LAUNCH_LIST=$(ls *.xml)
    for XML_FNAME in $LAUNCH_LIST; do 
        DOMID=$(echo $XML_FNAME | tr -d ".xml") 
        launch_vm_with_virsh "$DOMID"
    done
}

launch_vm_list 

