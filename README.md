# S3P_scripts

S3P is a sub-project of OpenDaylight for testing Stability, Scalability,
Security, and Performance.

These scripts are intended to simplify the process of managing large sets of
virtual machines to enable scale testing for OpenDaylight S3P.

## installation
Steps required to bring up virtual machines:

1. Ensure IOMMU and VT-d are enabled on the physical host systems (for virtual functions)
  1. enable VT-x in the BIOS :: Advanced | Processor Configuration | Intel (R) Virtualization
  2. enable VT-d in the BIOS :: Advanced | Integrated IO Configuration | Intel (R) VT for Directed I/O
  3. add `intel_iommu=on` to the kernel command line
2. prepare the networks for the VMs
  1. verify network interfaces, bridges, and subnets in S3P-scripts/network/network-details.sh
  2. run `S3P-scripts/network/setup_net.sh` to create bridges and assign interfaces
  3. enable virtual functions for the PF of the passthrough network
	  * `S3P-scripts/network/enable_vf_driver.sh` is a useful tool for enabling VFs
  4. run S3P-scripts/network/setup_virsh_passthrough_net.sh to create a passthrough network
3. define virtual machines with virsh and libvirt domxml definitions in S3P-scripts/domain_defs/
  1. a single VM image (e.g. vh-seed.img) may be cloned and given a new name with 
	  * `S3P-scripts/domain_defs/clone_domain.sh newDomName`
  2. TODO: need better explanation of "virsh define" for a set of XML
4.  Launch Virtual machines with TODO


##TODO:
networking::VM::VF-adapter doesn't DHCP -> customize /etc/sysconfig/network-scripts? assign IP based on vh#?

