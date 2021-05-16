# Contribute to devlab!
Devlab is a big project. Obviously, it is not possible that the development environments for all languages are kept recent, and new versions of the languages are brought to devlab. It requires community to help keep these updated.

Within days of starting the project with just 5 languages - Python, Julia (as base languages), and individual devlabs with haskell, dotnet (C#, F# and VB), and Java - devlab got transitioned from a one-man-organisational (https://www.ramdoot.in) effort to one which got detached from any such "organisational tag" - to a generic name "onspot". To make this transition a strong transition, the github account in which code is maintained also got transitioned to [online-tools](https://github.com/onspot-tools/devlab.git) - originally maintained and developed at [ramdootin](https://github.com/ramdootin).

For contributions to the project, just raise a PR, and one of us will take it from there. Since we follow the [all-contributors](https://github.com/all-contributors/all-contributors) specifications, we'll add you as a contributor to this project! Of course, you can make this easier for us by adding your name as a contrubutor yourself before you commit and raise a PR - see the last section of this file to know how you can do that.

Ok, enough of history, now lets get on to job.

## Building this dockerfile
First, clone the github repo for devlab:

    git clone https://github.com/onspot-tools/devlab.git

Now, get into the cloned directory and use the `build` script for building your version of devlab. The instructions for building devlab are seen in the header of the build script. You can use either Linux / WSL (in which case, you will use `build` script) or powershell (in which case you will use `build.ps1`) for building devlab.

## Adding a new language environment
Most important: start with creating a git-branch for your new language:

    git checkout -b <lang>

Now, create a directory `lang` in the root of the repo, and add your language-specific docker file in that directory. *Name the dockerfile as `df<lang>`* - for example, a dockerfile for java would be `dfjava` in the newly created `lang` directory.   

## What should get in your language-specific docker file
Adding a new language is actually very easy - when you just derive your dockerfile from the base `devlab` image: 

    from onspot/devlab:<latest-tag>

    ... add your specific instructions here ...

For example, for using the devlab v1.0 as your base, use this:

    from onspot/devlab:1.0

Beyond that, you only add your language-specific installation instructions. Devlab is based on OpenSUSE Leap 15.2 - so if your language requires some OS packages, you use `zypper` to install them.

# Adding periodic tasks in your language devlab
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

# Adding yourself as a contributor to this project
[all-contributors](https://github.com/all-contributors/all-contributors) gives us an easy CLI for managing contributors. Install that as follows:

    npm i -g all-contributors-cli

This installs the all-contributors-cli as a global node tool. To add yourself as a contributor, you use this command:

    npx all-contributors add <your-github-uid> <contribution-type>

The various contribution types are mentioned in the [emoji key here](https://allcontributors.org/docs/en/emoji-key). For example, to add yourself as a contributor for code, documentation, fixing bugs and for answering questions on stackoverflow, etc., use this:

    npx all-contributors add <your-github-uid> code,doc,bug,question

That's it! This command will add you as the contributor to this project for the contribution types given in your command and also commit the code. The changes are done in the (README.md) file - the last part of that file will contain your github avatar and your contributions as emojies.