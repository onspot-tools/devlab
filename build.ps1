#!/bin/bash

# Builds the docker file creating the base image of devlab
#
# Author: arvindd
# Created: 21.Apr.2021
#
# Copyright (c) 2021 Arvind Devarajan
# Licensed to you under the MIT License.
# See the LICENSE file in the project root for more information.
#

$NAME = arvindds/devlab
$VERSION = v1
$JPYPORT = 9000

docker build -f dfbase --tag ${NAME}:${VERSION} --build-arg JPYPORT=${JPYPORT} . 
