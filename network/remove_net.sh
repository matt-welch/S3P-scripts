#!/bin/bash
# tear down the network in teh opposite order that it's setup
# see setup_net.sh 

source network-details.sh

if [ -n "$(pgrep dhclient)" ] ; then 
    # ERROR, a dhclient process is already running
    echo "ERROR: ${0} depends on dhclient which is already running:"
    ps -ef | grep -v grep  | grep dhclient --color
    echo "Please stop the dhclient process above and try again."
    echo
    exit 1
fi

## remove interface then destroy tenant network bridge
#ip link set dev ${TENANT_BR} down 
#brctl delif ${TENANT_BR} ${TENANT_IF}
#brctl delbr ${TENANT_BR}

# remove interface and bridge for management network
ip link set dev ${MGMT_BR} down 
brctl delif ${MGMT_BR} ${MGMT_IF}
brctl delbr ${MGMT_BR}
ip link set dev ${MGMT_IF} down

# remove interface and bridge for internet network
ifconfig ${NET_BR} 0 
ip link set dev ${NET_BR} down
brctl delif ${NET_BR} ${NET_IF}
brctl delbr ${NET_BR}
ip link set dev ${NET_IF} up 
dhclient ${NET_IF}
