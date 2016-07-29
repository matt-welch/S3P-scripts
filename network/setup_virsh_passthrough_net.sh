#!/bin/bash
virsh net-define passthrough.xml
virsh net-autostart passthrough
virsh net-start passthrough
