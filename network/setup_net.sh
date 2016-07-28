#!/bin/bash
# create a set of bridges for network testing

source network-details.sh

if [ -n "$(pgrep dhclient)" ] ; then 
    # ERROR, a dhclient process is already running
    echo "ERROR: ${0} depends on dhclient which is already running:"
    ps -ef | grep dhclient | grep -v grep 
    echo "Please stop the dhclient process above and try again."
    echo
    exit 1
fi

#create internet bridge and assign IP to it
echo "Creating internet bridge ${NET_BR}..."
brctl addbr ${NET_BR}
brctl addif ${NET_BR} ${NET_IF}
ip link set dev ${NET_BR} up
dhclient ${NET_BR}
ifconfig ${NET_IF} 0
ip route add 10.166.33.1 dev ${NET_BR}

# create management bridge and assign IP
echo "Creating ngmt network bridge ${MGMT_BR}..."
brctl addbr ${MGMT_BR}
brctl addif ${MGMT_BR} ${MGMT_IF}
ip link set dev ${MGMT_BR} up 
ip a a ${MGMT_SUBNET} dev ${MGMT_BR} 
ifconfig ${MGMT_IF} 0

## create tenant network bridge and assign interface
#echo "Creating tenant network bridge ${MGMT_BR}..."
#brctl addbr ${TENANT_BR}
#brctl addif ${TENANT_BR} ${TENANT_IF}
#ifconfig ${TENANT_IF} 0
#ip link set dev ${TENANT_BR} up 

echo "S3P network creation complete."
ip a s ${NET_BR}
ip a s ${MGMT_BR}
#ip a s ${TENANT_BR}
brctl show 
