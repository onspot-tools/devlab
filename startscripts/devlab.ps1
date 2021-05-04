# -*- mode: powershell -*-

# Starts the base image for use as a shell.
#
# Author: arvindd
# Created: 21.Apr.2021
#
# Copyright (c) 2021 Arvind Devarajan
# Licensed to you under the MIT License.
# See the LICENSE file in the project root for more information.
#

# First, check if we have an argument. 
if ($args.Count -ne 1) {
    # No arguments, so we we assume local.
    $progarg = "tmux"
} 
else {
    $progarg = $args[0]
}

# First, check if we are already running the devlab
$cnt = docker ps --filter "name=devlab" | Measure-Object -line
if ( $cnt.Lines -eq 2 ) {
    # devlab is already running; so either stop it or 
    # ask the user to stop it.
    if ( $progarg -eq "stop" ) {
        Write-Output "Stopped"
        docker stop devlab
        exit 0
    } else {
        Write-Output "devlab is already running."
        Write-Output "Stop it with 'devlab stop' before starting again."
        exit 1
    }
} else {
    # devlab is not running. We will not accept '--stop' as an argument
    # because, well, you cannot stop a stopped devlab :-)    
    if ( $progarg -eq "stop" ) {
        Write-Output "devlab is not running. Refusing to stop a stopped devlab."
        exit 1
    }
}  

# Build parameters
$IMGNAME = "ramdootin/devlab"
$LANG = "base"
$VERSION = "v1"

# Run parameters
$HNAME = "devlab"
$JPYPORT = 9000
$JPYPORT = 9000

# If we have a "trustedcerts" directory where we are running the devlab, just mount it
# to /opt/certs. This directory contains additional PEM certificates that may be needed to 
# access the internet when done behind a corporate proxy.
if ( Test-Path trustedcerts/* ) {
    $MOUNT_CERTS = "--mount type=bind,src=${PWD}/trustedcerts,dst=/opt/certs"
} else {
    $MOUNT_CERTS = ""
}

switch ($progarg) {
    notmux {
        docker run --rm -p ${JPYPORT}:${JPYPORT} -it --mount src=devlabvol,dst=/home/dev ${MOUNT_CERTS} --name ${HNAME} --hostname ${HNAME} ${IMGNAME}:${LANG}-${VERSION} /bin/zsh    
    }
    jupyter {
        Write-Output "Starting devlab..."    
        docker run --rm -p ${JPYPORT}:${JPYPORT} -d --mount src=devlabvol,dst=/home/dev ${MOUNT_CERTS} --name ${HNAME} --hostname localhost ${IMGNAME}:${LANG}-${VERSION} jupyter-lab        
    	Start-Sleep -Seconds 2
    	docker logs ${HNAME}
        Write-Output 'If the URL for accessing your jupyter notebook is not shown above,'
        Write-Output 'just use "docker logs devlab" to get it. You may need to use it'
        Write-Output 'multiple times until you get the URL.'
        }
    Default {
        docker run --rm -p ${JPYPORT}:${JPYPORT} -it --mount src=devlabvol,dst=/home/dev ${MOUNT_CERTS} --name ${HNAME} --hostname ${HNAME} ${IMGNAME}:${LANG}-${VERSION} starttmux
    }
}
