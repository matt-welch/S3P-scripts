#!/bin/bash

source ../util/bash_colors.sh
source ./network_functions.sh 

DEVICE_HOME="/sys/bus/pci/devices"

function usage () {
    echo -e "\n\tUsage: $0 <device BB:DD.F> [num_vfs] \n"
    echo "Example devices: "
    show_net_devs

    echo -e "\nSystem Bridges:"
    brctl show 
}

if [[ -z "$1" ]] ; then 
    usage
    exit 1 
fi

DEVICE_BDF="$1"
DEVICE_PATH="${DEVICE_HOME}/0000:${DEVICE_BDF}"
TARGET="$DEVICE_PATH/sriov_numvfs" 
SRIOV_NUMVFS=$(cat $TARGET)
SRIOV_TOTALVFS=$(cat $DEVICE_PATH/sriov_totalvfs)
nocr=0

function showVFs(){
    echo "$TARGET (current) = $SRIOV_NUMVFS"
    echo "$DEVICE_PATH/sriov_totalvfs (maximum) = $SRIOV_TOTALVFS "
}

function errorMsg(){
    fcn_print_red "ERROR: " nocr
    echo " The maximum number of Virtual functions for device $DEVICE_BDF may not exceed ${SRIOV_TOTALVFS}"
}

function selectNumVFs(){
    VF_LIST=$(seq  0 $SRIOV_TOTALVFS)
    showVFs
    echo "Select how many virtual functions (VFs) you want enabled: "
    PS3="Desired number of VFs for $DEVICE_BDF = "
    select DESIRED_NUMVFS in $VF_LIST; do  
        if [[ -n $DESIRED_NUMVFS ]] ; then 
            fcn_print_red "$DESIRED_NUMVFS" nocr 
            echo " virtual functions has been selected."
            return $DESIRED_NUMVFS
        else
            errorMsg
            exit 1
        fi
    done
}

function setNumVFs(){
    echo SRIOV_NUMVFS = $SRIOV_NUMVFS
    echo DESIRED_NUMVFS = $DESIRED_NUMVFS
        fcn_print_red "Before change:"
        showVFs
        read -p "Are you sure you want to change the sriov_numvfs for this device to $DESIRED_NUMVFS? (y/N): " -n 1 input
        echo
        if [[ "$input" == "y" ]] ; then 
            echo "Setting the number of SRIOV Virtual Functions for device $DEVICE_BDF to $DESIRED_NUMVFS ..."
            sleep 2 
            echo $DESIRED_NUMVFS > $TARGET
            #while [ "$(cat $TARGET)" -ne "$DESIRED_NUMVFS" ] ; do 
            #    echo "Waiting for virtual functions to become available...."
            #    cat $TARGET
            #    sleep 0.5
            #done
            fcn_print_red "After change:"
            showVFs
        else
            echo "Aborted."
        fi
}

if [[ -z "$2" ]] ; then 
    # present selection on command line
    selectNumVFs 
else
    # use bash built-in character classes to verify numeric argument
    if [[ "$2" = *[[:digit:]]* ]]; then
        if (( "$2" < "0" )) ; then 
            fcn_print_red "The numvfs may not be negative. Aborting."
            exit 1 
        fi
    else
        fcn_print_red "The selected numvfs, \"$2\", is not numeric.  Aborting."
        exit 1
    fi
    DESIRED_NUMVFS="$2"
fi

# check if asking for too many vf's for this device
echo Available=$SRIOV_TOTALVFS Requested=$DESIRED_NUMVFS
if (( "$DESIRED_NUMVFS" <= "$SRIOV_TOTALVFS" )) ; then 
    echo "Setting $DESIRED_NUMVFS vfs for $DEVICE_BDF" 
    setNumVFs
else
    echo "Error" 
    errorMsg
fi


