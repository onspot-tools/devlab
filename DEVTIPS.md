# Introduction to this file
This file is simply for capturing many developer tips that you think others may get benefitted from. This is simply a free-form text, so just add your tip to the end of the file.

Of course, if you find something that is either wrong, or have better ways to accomplish the same thing, don't feel shy to either modify the existing tip or even removing the same (don't be harsh to others!).

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

# Using VSCode for working with latex
Install the [Latex Workshop](https://marketplace.visualstudio.com/items?itemName=James-Yu.latex-workshop) extension - this makes it very easy to work with latex files using devlab. 

## Configuring Latex Workshop
On default, VSCode is configured to use pdflatex as your latex-to-pdf compiler. Unfortunately, pdflatex does not support Unicode directly, and so we need to use `xelatex` or `lualatex` for unicode support.

The good thing is that both of these are already available within devlab, and all you have to do is to configure VSCode's Latex Workshop to use the one that you want.

Edit the VSCode settings.json file and `lulatex` and `xelatex` to your tools list (if they are not yet existing):

```json
    "latex-workshop.latex.tools": [
       // Other tools...    
        {
            "name": "lualatexmk",
            "command": "latexmk",
            "args": [
                "-synctex=1",
                "-interaction=nonstopmode",
                "-file-line-error",
                "-lualatex",
                "-outdir=%OUTDIR%",
                "%DOC%"
            ],
            "env": {}
        },
        {
            "name": "xelatexmk",
            "command": "latexmk",
            "args": [
                "-synctex=1",
                "-interaction=nonstopmode",
                "-file-line-error",
                "-xelatex",
                "-outdir=%OUTDIR%",
                "%DOC%"
            ],
            "env": {}
        }
    ]      
```
Now, add build recepes (of they are not yet existing) that builds latex files using `xelatex` or `lulatex`. Note that the order of the recepes matter: on default, the Latex Workshop uses the first recepe to build:

```json
    "latex-workshop.latex.recipes": [
        {
            "name": "latexmk (lualatex)",
            "tools": [
                "lualatexmk"
            ]
        },
        {
            "name": "latexmk (xelatex)",
            "tools": [
                "xelatexmk"
            ]
        }, 
        
        // Other recepes
    ]
```

The above configures Latex Workshop to use `lualatex` for building. If you instead prefer `xelatex`, just flip the order of the two recepes above (such that `latexmk (xelatex)` comes first).

Additionally, you may need to install the powerline fonts to use unicode fonts for Latex. 

# Installing powerline fonts
For good use of latex that comes for free withing all devlabs, you may want to add powerline fonts for unicode support. Just install those fonts in your home directory using these instructions:

```shell
# clone
git clone https://github.com/powerline/fonts.git --depth=1
# install
cd fonts
./install.sh
# clean-up a bit
cd ..
rm -rf fonts
```
See [here](https://github.com/powerline/fonts) for more information.