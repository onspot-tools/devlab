# -*- mode: powershell -*-
#
# Builds the docker file creating the base image of devlab.
# The dockerfile used for building depends on the git-branch in which
# the command is invoked: since each branch is a language name, the 
# dockerfile used is lang/df<branch>. Exception only in the "master"
# branch, where the build is used for building the base-image with
# the dockerfile dfbase.
#
# For example, when `build` is invoked in a branch named `haskell`,
# the dockerfile used is lang/dfhaskell. 
#
# Usage:
#
# build [-n]
#
# Where:
# -n - Disables caching during build [Default: Cache is used]
#
# Copyright (c) 2021 Arvind Devarajan
# Licensed to you under the MIT License.
# See the LICENSE file in the project root for more information.
#

# Check if we have a "no-cache" option -n.
if (${args}.Count -eq 1) {
    if (${args}[0] -ne "-n") {
        echo "Usage: $MyInvocation.MyCommand.Name [-n]"
        exit 1
    } else {
        $cache="--no-cache"
    }
}

# Take the name of the current git-branch as our language
$LANG = & git branch --show-current
if ($LANG == "master") {
    $LANG = "base"
}

# Build parameters
$REPONAME = "onspot/devlab"
$CACHEOPT = $cache 

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

# Calculate the build version based on git tag:
# If the latest commit has a tag, use that as the version of the docker image
# If the latest commit has no tag, then, there is no version for the image: it just gets "latest" as the default version.
$lasttag = & git describe --abbrev=0 --tags
$lastcommit = & git describe --tags
if ("$lasttag" -eq "$lastcommit") {
    # Our commit has a tag; so use that as the version
    # The tag is of the form "<lang>-<version>", so take only
    # the <version> part of the tag.
    # The version string is of the form:
    # <lang>-<langversion>-<base-dockerfile-version>
    $VERSION=$lasttag -replace '^[^-]*-'
} else {
  $VERSION=${VERSION:=latest}
}

if ($lasttag -notlike "*${lang}*") {
    VERSION="latest"
}

Write-Output "Build parameters:"
Write-Output "Dockerfile: ${DOCKERFILE}"
Write-Output "Repo name: ${REPONAME}"
Write-Output "Language: ${LANG}"
Write-Output "Language version: ${VERSION}"
Write-Output "Using cache: " if ($n) "No" else "Yes"

docker build -f ${DOCKERFILE} ${CACHEOPT} --tag ${IMGNAME}:${VERSION} --build-arg JPYPORT=${JPYPORT} --build-arg LANG=${LANG} .

# If we built a docker with a tag, then also tag the same as the "latest" image
if ("$VERSION" -ne "latest") {
    docker tag ${IMGNAME}:${VERSION} "${IMGNAME}:latest"
}