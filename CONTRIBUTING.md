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

Each file you add should also have the following license header:

```
# -*- mode: dockerfile -*-
#
# <brief one-line summary of what this file contains>
#
# <OPTIONAL - description - can be multi-line too>
#
# Copyright (c) <year-of-creation> <your-name>
# Licensed to you under the MIT License.
# See the LICENSE file in the project root for more information.
#
```
## What should get in your language-specific docker file
Adding a new language is actually very easy - when you just derive your dockerfile from the base `devlab` image: 

    from onspot/devlab:<latest-tag>

    ... add your specific instructions here ...

For example, for using the devlab v2.0 as your base, use this:

    from onspot/devlab:2.0

Beyond that, you only add your language-specific installation instructions. Devlab is based on OpenSUSE Leap 15.2 - so if your language requires some OS packages, you use `zypper` to install them.

# Adding developer tips
If you want to contribute to some developer tips, please feel free to add them in the file [DEVTIPS.md](DEVTIPS.md).