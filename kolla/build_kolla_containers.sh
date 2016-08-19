#!/bin/bash
REGISTRY="10.166.33.147:4000" 
BUILD_CONTAINERS=no
USE_REMOTE_REPO=no

BUILD_TEMPLATES=""
if [[ $BUILD_CONTAINERS == 'yes' ]]; then
    echo "Building OpenStack containers with kolla..."
else
    echo "Building kolla templates (Dockerfiles) only."
    BUILD_TEMPLATES="--template-only"
fi
REMOTE_REPO=""
if [[ $USE_REMOTE_REPO == 'yes' ]]; then
    echo "Containers will be pushed to the remote docker repository at $REGISTRY"
    REMOTE_REPO="--registry $REGISTRY --push "
else
    echo "No remote repository will be used to push containers"
fi
kolla-build --base centos --type binary --debug $BUILD_TEMPLATES $REMOTE_REPO
# fedora base image produced an error
