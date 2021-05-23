# Contribute to devlab!
Devlab is a big project. Obviously, it is not possible that the development environments for all languages are kept recent, and new versions of the languages are brought to devlab. It requires community to help keep these updated.

Within days of starting the project with just 5 languages - Python, Julia (as base languages), and individual devlabs with haskell, dotnet (C#, F# and VB), and Java - devlab got transitioned from a one-man-organisational (https://www.ramdoot.in) effort to one which got detached from any such "organisational tag" - to a generic name "onspot". To make this transition a strong transition, the github account in which code is maintained also got transitioned to [online-tools](https://github.com/onspot-tools/devlab.git) - originally maintained and developed at [ramdootin](https://github.com/ramdootin).

For contributions to the project, just raise a PR, and one of us will take it from there. Since we follow the [all-contributors](https://github.com/all-contributors/all-contributors) specifications, we'll add you as a contributor to this project! Of course, you can make this easier for us by adding your name as a contrubutor yourself before you commit and raise a PR - see the last section of this file to know how you can do that.

Ok, enough of history, now lets get on to job.

# devlab source code
First, clone the github repo for devlab:

    git clone https://github.com/onspot-tools/devlab.git

After you clone devlab, you will see many files that either are docker files or are files that get into the devlab container. Here's a brief of the docker files that you see:

In the root directory:
- dfosbase => Dockerfile for the OpenSUSE Leap 15.2 base, along with few OS packages that will be present in all the devlabs. 
- dfbase -> Dockerfile for the base-devlab: containing, in addition to base packages in osbase, also Python, JUlia and Jupyter (notbook and lab)

The OSbase is a large file, containing many packages apart from the base opensuse. The biggest package the texlive, which is needed for exporting notebooks into other formats. OSBase takes a long time to build - so, it is recommended to just pull the pre-built image from the dockerhub.

When you switch into any other git-branch, you will see a `lang` folder, in which docker files for individual language devlabs are put in. All these language devlabs derive from the dfbase - so will contain Python, Julia in addition to the specific language. Jupyter lab and notebook also come for free because they are derived from dfbase.
# Building devlab
As mentioned above, you can somply pull the pre-built osbase from dockerhub:

    docker pull onspot/osbase

Although the RECOMMENDED way is to pull the `osbase` before starting the build, please note that you can also skip this step as building `base` (explained below) will automatically pull this image before starting the build. 

If you DO want to build the `osbase` (warning: this will take really long time because it pulls in the complete texlive), just see the instructions in the header of the dockerfile - `dfosbase`. THIS IS REALLY NOT NEEDED!

The `base` forms the basis for all the other devlabs. Therefore, if any additions are needed for your versions of devlabs, this is the place you can add those additional packages. Since devlabs are based on opensuse, you will need to use `zypper` for adding new OS packages.

Now, you need to build the base devlab: use the `build` script for building your version of devlab. The instructions for building devlab are seen in the header of the build script. You can use either Linux / WSL (in which case, you will use `build` script) or powershell (in which case you will use `build.ps1`) for building devlab.

# Adding a new language environment
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
# What should get in your language-specific docker file
Adding a new language is actually very easy - when you just derive your dockerfile from the base `devlab` image. Just start with this template:

```
# Do each of the below steps, and keep uncommented steps as they are
FROM onspot/devlab:<latest-tag>

USER root 

# Step-1: Set some environment variables. These could be very specific to what you want. 

# Step-2: Install OS packages required for your language
# Depending on what you want, you may also need to use one of these utilities to
# pull language components: curl, wget, xz, tar, bz, zip, unzip
# RUN zypper -n <package>
# RUN curl -sSL <your path> -o <where you want the downloaded component to be saved>
# RUN wget -O <where you want the downloaded component to be saved>
# RUN tar xzvf <archive> OR tar xjvf <archive> OR tar xJvf <archive>

# Step-3: Adjust PATH: add your own PATH appended to the existing PATH:
# ENV PATH=<your path variables, with : between each of them>:${PATH}

USER dev
WORKDIR /home/dev

# Step-4: Install the Jupyter kernel for your language

# Finally, set this to identify your DEVLAB
ENV DEVLABLANG=${LANG}
```

For example, for using the devlab v3.0 as your base, use this:

    from onspot/devlab:3.0

# Adding developer tips
If you want to contribute to some developer tips, please feel free to add them in the file [DEVTIPS.md](DEVTIPS.md).