#!/bin/bash

function getDomains ( ) {
    # get virsh domains
    _VM_LIST=$(virsh list | grep -e "^ [[:digit:]]" | tr -s ' ' | cut -d' ' -f3)
}

function dumpDomains ( ) {
    # dump virsh domains to xml 
    getDomains
    for _VM in $_VM_LIST; do
        echo "Collecting XML for virtual machine: $_VM ..."
        echo "VNC display: $(virsh vncdisplay $_VM)"
        virsh dominfo $_VM
        virsh dumpxml $_VM > ${_VM}.xml
    done
}

dumpDomains
