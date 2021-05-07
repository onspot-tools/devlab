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

# First, collect all options
[CmdletBinding()]
Param(
  [Parameter()]
  [String]$l = "base",
  [String]$v = "v1",
)

# Build parameters
$REPONAME = "ramdootin/devlab"
$LANG = "$l"
$VERSION = "$v"

# Run parameters
$JPYPORT = 9000

# Adjust the image name and the dockerfile based on the language chosen
if ( $LANG -eq "base" ) {
    $IMGNAME=${REPONAME}  # For base devlab, we'll keep the image name simple
    $DOCKERFILE = "dfbase"
} else {
    $IMGNAME="${REPONAME}-${LANG}" 
    $DOCKERFILE = "lang/df$LANG"
}

Write-Output "Build parameters:"
Write-Output "Dockerfile: ${DOCKERFILE}"
Write-Output "Repo name: ${REPONAME}"
Write-Output "Language: ${LANG}"
Write-Output "Language version: ${VERSION}"

docker build -f ${DOCKERFILE} --tag ${IMGNAME}:${VERSION} --build-arg JPYPORT=${JPYPORT} --build-arg LANG=${LANG} --build-arg VER=${VERSION} .
