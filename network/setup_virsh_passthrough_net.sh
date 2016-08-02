#!/bin/bash
NET_XML_DEF="passthrough.xml"
NET_NAME=$(sed -n 's:<name>\(.*\)</name>:\1:p' ${NET_XML_DEF} | tr -d ' ')
PF_DEV=$(grep "pf dev" ${NET_XML_DEF} | cut -d "'" -f 2 )

NUM_VFS=$(cat /sys/class/net/${PF_DEV}/device/sriov_numvfs)
if (( "${NUM_VFS}" == "0" )) ; then 
    echo "Error: The network device (${PF_DEV}) does not have any virtual functions (VFs) available for the ${NET_NAME} network"
    echo "Enable at least 21 (32 is preferred) virtual functions on ${PF_DEV} and try again."
    echo "A useful tool for enabling virtual functions is S3P-scripts/network/enable_vf_driver.sh"
else
    virsh net-define "$NET_XML_DEF"
    virsh net-autostart "$NET_NAME"
    virsh net-start "$NET_NAME"
    ifconfig $PF_DEV 192.168.2.1/16 up 
fi
