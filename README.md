# Introduction
devlab is a way to quickly set up development environments for various languages. On default, it contains a mode in which Jupyter starts with the said language enabled, but, it also offers a way to use it as a terminal for advanced usage / complete development environment.

This project contains the Docker files for building devlab and all the associated scripts (both for Linux and for Powershell).

# Installing devlab
The easiest way to get devlab on your PC is by using the install-scripts:

Linux / WSL:
    curl -sSL https://raw.githubusercontent.com/ramdootin/devlab/master/scripts/install.sh | sh

Powershell:
    iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/ramdootin/devlab/master/scripts/install.ps1'))

Either of these will create a directory called `devlab` where you invoked them, and will also pull in the devlab start-scripts (also called as devlab (Linux) / devlab.ps (powershell) into that directory.

To use devlab, get into that directory and start devlab. In the explanation that follows, we use only `devlab`, but everything also holds good for `devlab.ps1` too - for those who use docker-for-desktop and powershell.

# devlab script
The devlab script is the starting point for using devlab, and has the following usage:

    devlab [-l <lang>] [-v <version>] [notmux | jupyter | stop]

where:
-l <lang> - Use devlab for a specific language. Default: devlab comes up with Python and JUlia.
-v <version> - Use devlab for a specific version of a language. Default: Version 1

The other commands are explained below.
## Starting devlab
The devlab can be started with any of the following options:

    ./devlab

This simply starts devlab as a terminal, with `tmux` configured for showing two vertical panes.

    ./devlab notmux

Similar to the above, but does not start a tmux.

    ./devlab jupyter

Starts devlab in a daemon mode, which serves Jupyter Lab. It is now possible to use devab in two ways:

- Use a browser, navigate to the location shown by the command above, to use it as a Jupyter notebook
- Shell into devlab to use it as a normal terminal. `./shell` helps to shell into a running devlab.

## Stopping devlab
Use this command to stop devlab:

    ./devlab stop

# Using devlab
After starting devlab, it can be used both as a terminal or a jupyter notebook as explained above. Inside the devlab, you will be seeing two directories: `bin` and `work` (there might be more depending on what version of devlab you are using). `bin` contains a command `starttmux` start starts a pre-configured tmux for you - if you require. Note that starting devlab without any option automatically starts `tmux` for you too, unless you have specifically used `notmux` command not to start tmux.

The work directory is for keeping your working files. These files are preserved even after you stop devlab - they will be in the "work" directory in the same directory where you started devlab from.

devlab creates docker named-volumes to preserve your files. The name of the volume follows a standard: 

    devlab-<lang>-<version>

The base devlab volume is named as devlab-base-<version>

If you would want to start afresh, just remove the relevant colume and then restart devlab:

    docker volume rm devlab-<lang>-<version>

If you would like to copy the files from the volumes into your host machine, or want to use the files from the volumes from other containers, just mount the volume where you want and use that - independant of devlab.

# Adding Python packages
More python packages can be installed simply by using:

    `pip install <package>`

# Normal user and root user
devlab is designed in such a way that you will be using it as a user `dev` with normal privileges. However:

- `zypper install <package>` installs OpenSUSE packages as root, automatically
- `rs` brings a root-shell for you

**Use both of these with care**, as you can really damage your system with these.

# Building this dockerfile
First, clone the github repo for devlab:

    git clone https://github.com/ramdootin/devlab.git

Now, get into the cloned directory and use the `build` script for building your version of devlab. The instructions for building devlab are seen in the header of the build script. You can use either Linux / WSL (in which case, you will use `build` script) or powershell (in which case you will use `build.ps1`) for building devlab.

# Extending devlab to add your own development environment
The devlab is based on OpenSUSE Leap 15.2. Extending to add your specific development environment needs that you use `zypper` to install your OS packages.

You can use the Dockerfile as the starting template to add your own development environment. The best way is to first build devlab to create the base image, and then create a Dockerfile for your own development environment like this:

    from ramdootin/devlab:1

    ... add your specific instructions here ...

# Adding periodic tasks in your setup
Since the complete environment is within a docker container running OpenSUSE, the best way to run a task periodically is by using `cron`. However, docker poses some problems with using `cron`, so a special setup is needed for adding `cron` entries in `crontab`.

For the purposes of this explanation, let us assume that you want to periodically execute the script `dotask` that does a specific task that you want to be done periodically.

## Step-1: Making sure cron jobs get your environment variables
Unfortunately, cron jobs do not automatically get your environment variables. The best way to handle this situation is to create a file `.env` in your root directory during system startup (eg. in your .zshrc), and then source this file again in the script that is run by `cron`.

First, create a `.env` file - add this line in your `.zshrc` (to make this permanant, you will have to add a statement it in your Dockerfile that adds this line in your `.zshrc`):

    env > ~/.env

Then source this in the script `dotask`, add this line in the very begining:

    . ~/.env

The above line sources the environment variables creaed by the startup file.

## Step-2: Adding a crontab line if it is not yet present
In your `dotask` script, you will additionally need to check if a cron-entry is already present; if not, need to add that entry in the script. Also, cron does not start automatically inside a docker: hence need to start that manually. 

The function below will do all these for you:

    function setup_cron {
        # Add cron entry to run `dotask` every hour from 9 to 6, every day.
        # The redirection to null is done to avoid the message 
        # "the user has no crontab entries" when added for the first time.
        (crontab -l 2>/dev/null; echo "0 09-18 * * * ~/dotask)

        # Start cron if not yet started
        ps -aef | awk '{print $8}' | grep -q cron
        if [ $? -ne 0 ]; then cron; fi
    }

All you have to now do is to call the above function, also in your `dotask` script, if the cron entries are not yet added:

    crontab -l 2>/dev/null | grep -q dotask
    if [ $? -ne 0 ]; then
        # We do not have the cron entry in the crontab. This means the script is started for
        # the first time. Just set up cron in this system.
        setup_cron
    fi

## Step-3: Start your task the first time during login
Well, we have now set up a task to be started periodically. Who starts it the first time? We, of course!

Add this line in your startup script (`.zshrc`) too:

    ~/dotask

Starting this script for the first time, automatically sets up the cron entries needed for every other time.