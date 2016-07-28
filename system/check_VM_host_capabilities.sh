#!/bin/bash

echo "Checking for VMX/SVM support in the CPU (output=positive): "
grep -E "vmx|smv" /proc/cpuinfo --color

echo 
echo "Checking for DMAR and IOMMU (output=positive): "
dmesg | grep -e DMAR -e IOMMU --color

