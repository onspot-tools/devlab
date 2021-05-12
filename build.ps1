# -*- mode: powershell -*-
#
# Builds the docker file creating the base image of devlab
#
# Usage:
#
# build [-n] [-l <lang>] [-v <version>]
#
# Where:
# -n - Disables caching during build [Default: Cache is used]
# -l <lang> - devlab for a language <lang> is built.
#             Note that build uses lang/df<lang> as dockerfile for this language.
#             Default: No language, and base devlab is built with dockerfile dfbase.
# -v <version> - Version of the devlab for a specific language. Default: 1 
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
  [string]$n = ""
)

# Build parameters
$REPONAME = "ramdootin/devlab"
$LANG = "$l"
$CACHEOPT = if ($n) "--no-cache" else $n 

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
lasttag = & git describe --abbrev=0 --tags
lastcommit = & git describe --tags
if ("$lasttag" -eq "$lastcommit") {
    # Our commit has a tag; so use that as the version
    VERSION=${lasttag}
} else {
  VERSION=${VERSION:=latest}
}

Write-Output "Build parameters:"
Write-Output "Dockerfile: ${DOCKERFILE}"
Write-Output "Repo name: ${REPONAME}"
Write-Output "Language: ${LANG}"
Write-Output "Language version: ${VERSION}"
Write-Output "Using cache: " if ($n) "No" else "Yes"

docker build -f ${DOCKERFILE} ${CACHEOPT} --tag ${IMGNAME}:${VERSION} --build-arg JPYPORT=${JPYPORT} --build-arg LANG=${LANG} .
