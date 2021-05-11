#!/bin/bash

#
# Installs devlab in the user's PC
#
# Author: arvindd
# Created: 10.May.2021
#
# Copyright (c) 2021 Arvind Devarajan
# Licensed to you under the MIT License.
# See the LICENSE file in the project root for more information.
#

# List of all scripts to be downloaded
scripts=(
    https://raw.githubusercontent.com/ramdootin/devlab/master/scripts/devlab
    https://raw.githubusercontent.com/ramdootin/devlab/master/scripts/shell
)

# We need docker for our work. If docker not present, just inform and fail
docker -v 2>&1 > /dev/null
if [[ $? -ne 0 ]]; then
    echo "Docker not present, install docker before proceeding."
    echo "Go here to get docker: https://www.docker.com/"
    exit 1
fi

# Check if docker has been started, else just inform and fail
pgrep -f docker > /dev/null
if [[ $? -ne 0 ]]; then
    echo "Docker not started - start docker and then restart this script."
    exit 2
fi

# Check if we have wget or curl
wget --version 2>&1 > /dev/null && WGET=1 || WGET=0
curl --version 2>&1 > /dev/null && CURL=1 || CURL=0

# Create a devlab directory where we will pull the scripts
mkdir -p devlab
echo "${scripts[@]}"

if [[ ${WGET} -eq 1 ]]; then
    for s in "${scripts[@]}"; do
        wget $s -O devlab/`basename $s`
        chmod +x devlab/`basename $s`
    done
elif [[ ${CURL} -eq 1 ]]; then
    for s in "${scripts[@]}"; do
        curl $s -o devlab/`basename $s`
        chmod +x devlab/`basename $s`        
    done
else
    echo "curl or wget needed for installation. Unable to install devlab."
fi