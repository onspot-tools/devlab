# Introduction
devlab is a way to quickly set up development environments for various languages. On default, it contains a mode in which Jupyter starts with the said language enabled, but, it also offers a way to use it as a terminal for advanced usage / complete development environment.

This project contains the Docker files for building devlab and all the associated scripts (both for Linux and for Powershell).

# Getting pre-built docker images of devlab
Get get a prebuilt devlab (included with Python3 and Julia), do this:

    docker pull ramdootin/devlab:1

The above also forms the basis for other languages: so, using any of them below will also give you the base languages python and julia. For getting devlab with other languages, use the following generic form:

    docker pull ramdootin/devlab-${lang}:${version}

For example, to get the base docker image that contains Haskell (with GHC version 8.10.4), do this:

    docker pull ramdootin/devlab:base-v1

The best way to run the docker images is by using the `devlav` script. Depending on whether you are using Linux or Windows machine for working on docker, download just these scripts in an empty directory, and follow the instructions in the rest of this readme to use devlab.

devlab script for use in linux or Windows-Subsytem-for-Linux (WSL) - [https://raw.githubusercontent.com/ramdootin/devlab/master/devlab](click here)
devlab.ps script for used in Powershell (Windows or Linux): [https://raw.githubusercontent.com/ramdootin/devlab/master/devlab.ps1](click here)

For more adventurous, clone this entire git repo and use these scripts found in the root-directory. You can later use this repo for also extending devlab with your own dev-environments (see the instructions below).

# Starting devlab
The devlab can be started with any of the following options:

    ./devlab

This simply starts devlab as a terminal, with `tmux` configured for showing two vertical panes.

    ./devlab --notmux

Similar to the above, but does not start a tmux.

    ./devlab --jupyter

Starts devlab in a daemon mode, which serves Jupyter Lab. It is now possible to use devab in two ways:

- Use a browser, navigate to the location shown by the command above, to use it as a Jupyter notebook
- Shell into devlab to use it as a normal terminal. `./shell` helps to shell into a running devlab.

# Stopping devlab
Use this command to stop devlab:

    ./devlab --stop

# Using devlab
After starting devlab, it can be used both as a terminal or a jupyter notebook as explained above. Inside the devlab, you will be seeing two directories: `bin` and `work` (there might be more depending on what version of devlab you are using). `bin` contains a command `starttmux` start starts a pre-configured tmux for you - if you require. Note that starting devlab without any option automatically starts `tmux` for you too, unless you have specifically used `--notmux` option not to start tmux.

The work directory is for keeping your working files. These files are preserved even after you stop devlab - they will be in the "work" directory in the same directory where you started devlab from.

# Adding Python packages
More python packages can be installed simply by using:

    `pip install <package>`

# Normal user and root user
devlab is designed in such a way that you will be using it as a user `dev` with normal privileges. However:

- `zypper install <package>` installs OpenSUSE packages as root, automatically
- `rs` brings a root-shell for you

**Use both of these with care**, as you can really damage your system with these.

# Building this dockerfile
Use the command `./build` to build this dockerfile as this will make sure that the various arguments to be passed to the dockerfile is correctly passed on.

The build generates the devlab image.

# Extending devlab to add your own development environment
The devlab is based on OpenSUSE Leap 15.2. Extending to add your specific development environment needs that you use `zypper` to install your OS packages.

You can use the Dockerfile as the starting template to add your own development environment. The best way is to first build devlab to create the base image, and then create a Dockerfile for your own development environment like this:

    from devlab/base:v1

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