#!/bin/bash
# script to create a standard guest for S3P testing
NAME=cont1
MEM_MB=512
N_VCPU=2
VIRT_TYPE="--container" 
	#+ OR "--paravirt"  OR "--container" OR "--hvm --virt-type kqemu --arch x86_64"
PRINT_XML="--print-xml --dry-run" 
    # "--print-xml" # to print XML only and NOT define the guest
	#+ OR "" to create the guest and not print XML

virt-install --connect lxc:/// --name $NAME --memory $MEM_MB --vcpus $N_VCPU --init /bin/bash \
    --network bridge=br0 --network bridge=br1

# Using the "passthrough" vf network is not allowed with containers ???
# --network network=passthrough 
