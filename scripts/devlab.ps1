# -*- mode: powershell -*-
#
# Starts the base image for use as a shell.
#
# The latest version of this script is available at:
#
# https://raw.githubusercontent.com/onspot-tools/devlab/master/startscripts/devlab.ps1
#
# If you already have devlab with you, the script is also in there:
#
# docker cp devlab:/opt/scripts/devlab.ps1 .
#
# will get this script out from a running devlab. Note that the
# script got from your devlab might not be the latest one published
# unless you have also pulled the latest devlab from dockerhub:
#
# docker pull onspot/devlab-<lang>:<version>
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
  [String]$v = "latest",
  [String]$p = "9000",  
  [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
  [String]$progarg = "lab"
)

function Usage {
@"
devlab [-l <lang>] [-v <version>] [-p <port>] <command>

Options:
-l <lang> - Language devlab to be started. Default: Python and Julia
-v <version> - Version of the language devlab to be started. Default: latest
-p <port> - Port on which devlab listens. Default: 9000

<command> can be one of:
tmux - Starts a zsh shell with tmux
lab - Starts the jupyter lab
nb OR notebook - Starts the jupyter notebook
shell - Starts (or connects to a running) devlab with a zsh shell without tmux
stop - Stops the started jupyter (lab or notebook)

If no command is given, default is "lab".
"@
}

# Build parameters
$REPONAME = "onspot/devlab"
$LANG = "$l"
$VERSION = "$v"

# Run parameters
$JPYPORT = 9000       # Port in which devlab runs (within the container)
$HPORT=$p             # Port in which devlab should run on the host machine

# Adjust the image name based on the language name
if ( $LANG -eq "base" ) {
    $IMGNAME=${REPONAME}  # For base devlab, we'll keep the image name simple
    ${CNAME}=devlab       # For base devlab, we'll keep the container name simple        
} else {
    $IMGNAME="${REPONAME}-${LANG}" 
    ${CNAME}="devlab-${LANG}"        
}

# First, check if we are already running the devlab
$cnt = docker ps --filter "name=^${CNAME}$" | Measure-Object -line
if ( $cnt.Lines -eq 2 ) {
    # devlab is already running; we only allow to shell into it
    # or stop it if asked for. For any other command, ask the user
    # to stop it.
    if ( $progarg -eq "shell" ) {
        docker exec -it ${CNAME} /bin/zsh
        exit 0
    } elseif ( $progarg -eq "stop" ) {
        Write-Host -NoNewline "Stopped "
        docker stop ${CNAME}
        exit 0
    } else {
        Write-Host "devlab is already running." -foreground red
        Write-Output "You can shell into it with 'devlab -l ${CNAME} shell'."
        Write-Output "OR stop it with 'devlab -l ${CNAME} stop' before starting again."
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

# If we have a "trustedcerts" directory where we are running the devlab, just mount it
# to /opt/certs. This directory contains additional PEM certificates that may be needed to 
# access the internet when done behind a corporate proxy.
if ( Test-Path trustedcerts/* ) {
    # Docker desktop in windows platform is not recognising --mount type bind.
    # We therefore will use the (old fashioned) -v for mounting trustedcerts only on windows.
    $MOUNT_CERTS = "-v${PWD}/trustedcerts:/opt/certs"
} else {
    $MOUNT_CERTS = ""
}

# Run devlab based on the above configurations. 
# The command to be run comes from the case-statement below.
function RunDevlab($cmd, $mode) {
    $args = "run --rm -p ${HPORT}:${JPYPORT} ${mode} --mount src=devlab-${LANG}-${VERSION},dst=/home/dev ${MOUNT_CERTS} --name ${CNAME} --hostname localhost ${IMGNAME}:${VERSION} ${cmd}"

    # Calling docker returns the container id. We capture that in a variable
    # cid, because, in Powershell, all "uncaptured" information is returned
    # when this function returns. We specifically only return $? below.
    $cid = & docker $args.split()
    
    # Return the error status of the above command
    $?    
}

# This function extracts jupyter information from the logs and prints the same on the console
# to be used by the user. Note that this function also adjusts for the port number based on where
# the devlab is listening.
function PrintJpyInfo($logs) {
    $lines = $logs | Select-String -notmatch "^\[" | ForEach-Object { $_ -replace "^\ \ \ \ ","" -replace ":${JPYPORT}/",":${HPORT}/" }
    $info = $lines -join "`r`n" | out-string
    Write-Output $info 

    # The above information must have contained the http URL of jupyter. If it did not contain, jupyter must have taken long time
    # to startup - so the URL can only be got from docker logs.
    if ( $info -notlike "*?token=*" ) {
        Write-Host 'Jupyter took unusually longer time to start.' -foreground red
        Write-Output "Use `"docker logs ${CNAME}`" to get the URLs to access Jupyter."

        if ( $JPYPORT -ne $HPORT ) {
            Write-Output "NOTE: *** In the URL, use $HPORT as the port number instead of $JPYPORT ***"
        }
    }
}

switch ($progarg) {
    "help" {
        Usage
        exit 0
    }
    "shell" {
        $ret = RunDevlab "/bin/zsh" "-it" 

        if (!$ret) {
            Write-Host 'devlab failed to start, see above for the error details.' -foreground red
            Write-Output "Errors due to binding of ports can be circumvented with -p <port> option,"
            Write-Output "where <port> should be a different port number than what is mentioned with the error above."
        }        
    }
    "lab" {
        Write-Output "Starting ${CNAME}..."    
        $ret = RunDevlab "jupyter lab --no-browser" "-d"   

        if ($ret) {
            Start-Sleep -Seconds 2
            PrintJpyInfo $(docker logs ${CNAME} 2>&1)            
        } else {
            Write-Host 'devlab failed to start, see above for the error details.' -foreground red
            Write-Output "Errors due to binding of ports can be circumvented with -p <port> option,"
            Write-Output "where <port> should be a different port number than what is mentioned with the error above."
        }                
    }
    {($_ -eq "nb") -or ($_ -eq "notebook")} {
        Write-Output "Starting ${CNAME} notebook..."    
        $ret = RunDevlab "jupyter notebook --no-browser" "-d"   

        if ($ret) {
            Start-Sleep -Seconds 2
            PrintJpyInfo $(docker logs ${CNAME} 2>&1)        
        } else {
            Write-Host 'devlab failed to start, see above for the error details.' -foreground red
            Write-Output "Errors due to binding of ports can be circumvented with -p <port> option,"
            Write-Output "where <port> should be a different port number than what is mentioned with the error above."            
        }
    }        
    "tmux" {
        $ret = RunDevlab "starttmux" "-it"

        if (!$ret) {
            Write-Host 'devlab failed to start, see above for the error details.' -foreground red
            Write-Output "Errors due to binding of ports can be circumvented with -p <port> option,"
            Write-Output "where <port> should be a different port number than what is mentioned with the error above."
        }        
    }
    Default {
        Write-Host "Invalid command. Usage:" -foreground red
        Usage
        exit 1
    }
}
