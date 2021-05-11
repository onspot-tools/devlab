# -*- mode: powershell -*-

#
# Installs devlab in the user's PC.
#
# iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/ramdootin/devlab/master/scripts/install.ps1'))
#
# Author: arvindd
# Created: 10.May.2021
#
# Copyright (c) 2021 Arvind Devarajan
# Licensed to you under the MIT License.
# See the LICENSE file in the project root for more information.
#

# List of all scripts to be downloaded
$scripts = @(
    "https://raw.githubusercontent.com/ramdootin/devlab/master/scripts/devlab.ps1",
    "https://raw.githubusercontent.com/ramdootin/devlab/master/scripts/shell.ps1"
)

# We need docker for our work. If docker not present, just inform and fail
if ((Get-Command "docker.exe" -ErrorAction SilentlyContinue) -eq $null) {
    Write-Output "Docker not present, install docker before proceeding."
    Write-Output "Go here to get docker: https://hub.docker.com/editions/community/docker-ce-desktop-windows"
    exit 1
}

# Check if docker has been started, else just inform and fail
if ((Get-Process com.docker.proxy -ErrorAction SilentlyContinue) -eq $null) {
    Write-Output "Docker not started - start docker and then restart this script."
    exit 2
}

# Create a devlab directory where we will pull the scripts
If(!(Test-Path devlab))
{
      New-Item -ItemType Directory -Force -Path devlab
}


${scripts} | ForEach-Object {
    $sname = Split-Path ${PSItem} -leaf
    Invoke-RestMethod -Uri ${PSItem} -Method Get | Out-File devlab/${sname}
}

Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force
Write-Output 'devlab is installed in the directory "devlab". Go to that directory and start devlab, or add that directory in your PATH.'
Write-Output 'NOTE: In order to run scripts, your execution policy is made unrestricted. To set it to your default run this command:'
Write-Output 'Set-ExecutionPolicy Default -Scope CurrentUser -Force'
Write-Output 'Note that by setting it to default, you may no longer be able to run the devlab script.'