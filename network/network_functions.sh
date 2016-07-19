#!/bin/bash

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
