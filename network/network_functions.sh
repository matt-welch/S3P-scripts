#!/bin/bash

function virsh_remove_default_network ( ) {
    # remove the 'default' network from virsh/libvirt
    # this is not a "safe" function so it will not work if the network is in use
    NET_NAME="default"
    if [ -n "$(virsh net-list --all | grep $NET_NAME )" ] ; then 
        virsh net-destroy $NET_NAME # stop the network
        virsh net-undefine $NET_NAME # remove it from the available networks
    fi
}

function remove_virbr0 ( ) {
    # function removes the standard libvirt bridge
    BR_NAME=virbr0
    BR_IF=virbr0-nic
    ifconfig ${BR_NAME} 0 
    ip link set dev ${BR_NAME} down
    brctl delif ${BR_NAME} ${BR_IF}
    brctl delbr ${BR_NAME}
    ip link del ${BR_IF}
}

function show_net_devs ( ) {
# display network adapter information for the tenant network
    SYSFS_CLASS_NET="/sys/class/net"
    echo -e "Interface\tPCI Address\tSysFS Path"
    for INTERFACE in $(ls $SYSFS_CLASS_NET | grep -v lo); do 
        _DEV_PATH="${SYSFS_CLASS_NET}/$INTERFACE"
        _PCI_ADDR=$(basename $(readlink ${_DEV_PATH}/device ) )
        echo -e "$INTERFACE\t$_PCI_ADDR\t$_DEV_PATH"
    done
}

