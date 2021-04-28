#
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

$NAME = "devlab"
$VERSION = v1
$JPYPORT = 9000

# All our work gets into work directory
If(!(test-path work))
{
      New-Item -ItemType Directory -Force -Path work
}

switch ($progarg) {
    --notmux {
        docker run --rm -p ${JPYPORT}:${JPYPORT} -it --mount type=bind,src=${PWD}/work,dst=/home/dev/work --name ${NAME} --hostname ${NAME} ${NAME}:${VERSION} /bin/zsh
    }
    --jupyter {
        docker run --rm -p ${JPYPORT}:${JPYPORT} -d --mount type=bind,src=${PWD}/work,dst=/home/dev/work --name ${NAME} --hostname localhost ${NAME}:${VERSION} jupyter-lab        
    }
    Default {
        docker run --rm -it -p ${JPYPORT}:${JPYPORT} --mount type=bind,src=${PWD}/work,dst=/home/dev/work --name ${NAME} --hostname ${NAME} ${NAME}:${VERSION}
    }
}
