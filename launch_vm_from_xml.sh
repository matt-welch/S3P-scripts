#!/bin/bash

LAUNCH_LIST=$(ls *.xml)
RUNNING_LIST=$(virsh list | grep -e "^ [[:digit:]]" | tr -s ' ' | cut -d' ' -f3)

for XML_FNAME in $LAUNCH_LIST; do 
    DOMID=$(echo $XML_FNAME | tr -d ".xml") 
    if [[ "$RUNNING_LIST" == *"${DOMID}"* ]]; then
        #statements
        echo "Error: Domain $DOMID is already running $(echo $LAUNCH_LIST | grep $DOMID --color=always)"
    else
        echo "Launching VM with XML-file: $DOMID"
        # virsh create domain.xml
    fi
done
