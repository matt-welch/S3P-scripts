#!/bin/bash

_FLAVOR="--flavor m1.tiny"
_IMAGE="--image cirros-0.3.4-x86_64-uec"
_NET_ID="c33bf8dc-58f0-4e75-ba92-370d069975a8"
_NETWORK="--nic net-id=${_NET_ID}"
_SECGRP="" # "--security-group default"
_KEYS="" # "--keyname demo-key"
_NAME="scriptedVM"
_MIN="--min-count 1"
_MAX="--max-count 2"

echo "Booting image(s) named: $_NAME ..."
echo "  with VM flavor $_FLAVOR "
echo "  with image $_IMAGE "
echo "  with network $_NETWORK "
echo
_MY_NOVA_CMD="nova boot $_FLAVOR $_IMAGE $_NETWORK $_MIN $_MAX $_SECGRP $_KEYS $_NAME"

echo "Launching VMs with the command: "
echo "  ${_MY_NOVA_CMD}"

eval $_MY_NOVA_CMD

nova list
