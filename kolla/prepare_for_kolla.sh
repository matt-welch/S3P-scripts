#!/bin/bash

# setup Kolla dependencies based on http://docs.openstack.org/developer/kolla/quickstart.html
# check that the kernel is v 4.2+
function check_kernel_version ( ) {
    # makes sure kernel versin is greater than 4.2
    echo "Current Kernel version should be greater than 4.2"
    uname -r 
}

function install_system_packages ( ) {
    # ensures system packages are ready for kolla
    PACKAGES="gcc-c++ \
        redhat-rpm-config \
        gcc \
        gcc-c++ \
        python-pip \
        python-devel \
        ansible \
        openssl-devel \
        libffi-devel "
    
    # install necessary system packages
    dnf install $(echo $PACKAGES)
}

function install_docker ( ) {
    # installs Docker container engine
    DOCKER_VERSION=$(docker --version | grep -o "[0-9]\.[0-9]\{1,2\}\.[0-9]\{1,2\}")    
    DKR_VER=$( echo $DOCKER_VERSION | cut -d '.' -f 2 ) 
    INSTALL_DOCKER=yes

    # install docker from docker.io if minor version is less than 11 (docker ver 1.11)
    if [ "$DKR_VER" -lt "11" ] ; then 
        MESSAGE="Docker version ($DKR_VER) appears outdated, do you want to update from get.docker.io? [y,N] "
        read -p $MESSAGE -n 1 
        if [[ "$input" == "y" ]] ; then 
            INSTALL_DOCKER=yes
            echo "I would have installed Docker here"
        else
            INSTALL_DOCKER=no
            echo "Docker installation aborted."
        fi
    else
        INSTALL_DOCKER=no
        echo "Docker installation aborted: Docker version $DOCKER_VERSION is already installed."
    fi

    if [[ "$INSTALL_DOCKER" == "foo" ]]; then
        curl -sSL https://get.docker.io | bash
        # Create the drop-in unit directory for docker.service
        mkdir -p /etc/systemd/system/docker.service.d
        # Create the drop-in unit file
cat > /etc/systemd/system/docker.service.d/kolla.conf <<ENDDKRSVC
[Service]
MountFlags=shared
ENDDKRSVC

        # Run these commands to reload the daemon
        systemctl daemon-reload
        systemctl restart docker
    fi
}

function install_python_packages ( ) {
    # installs necessary python packages to support kolla
    # install python packages with pip
    PIP_PKGS="pip \
        docker-py \
        ansible \
        python-openstackclient \
        python-neutronclient"
    
    pip install -U $(echo $PIP_PKGS)
}

function install_kolla ( ) {
    # clones kolla from github and installs with pip
    echo -e "\nCloning kolla from github..."
    cd ~
    git clone https://git.openstack.org/openstack/kolla
    pip install kolla/
    cd kolla/
    cp -r  etc/kolla /etc/
}

function enable_NTP ( ) {
    # makes sure NTP is installed and running
    dnf install ntp
    systemctl enable ntpd.service
    systemctl start ntpd.service
}

function disable_libvirt ( ) {
    # Libvirt is started by default on many operating systems. 
    # Disable libvirt on any machines that will be deployment targets. 
    # Only one copy of libvirt may be running at a time.
    systemctl stop libvirtd.service
    systemctl disable libvirtd.service
}

if [ "$0" != *"bash"* ] ; then 
    # sourcing script from bash to run individual functions, do nothing now
    check_kernel_version
    install_system_packages
    install_docker
    install_python_packages
    #install_kolla
    enable_NTP
    disable_libvirt
fi
