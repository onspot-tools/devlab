# Contribute to devlab!
Devlab is a big project. Obviously, it is not possible that the development environments for all languages are kept recent, and new versions of the languages are brought to devlab. It requires community to help keep these updated.

Within days of starting the project with just 5 languages - Python, Julia (as base languages), and individual devlabs with haskell, dotnet (C#, F# and VB), and Java - devlab got transitioned from a one-man-organisational (https://www.ramdoot.in) effort to one which got detached from any such "organisational tag" - to a generic name "onspot". To make this transition a strong transition, the github account in which code is maintained also got transitioned to [online-tools](https://github.com/onspot-tools/devlab.git) - originally maintained and developed at [ramdootin](https://github.com/ramdootin).

For contributions to the project, just raise a PR, and one of us will take it from there. Since we follow the [all-contributors](https://github.com/all-contributors/all-contributors) specifications, you can make it easier for us by adding your name as a contrubutor yourself before you commit and raise a PR - see the last section of this file to know how you can do that.

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

```dockerfile
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

```dockerfile
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

# Maintainer notes
This section serves more as notes for maintainers of onspot/devlab repositories. If you plan to rebuild all images, the following steps will easen out your effort, and also make sure that things do not go wrong.

The commands below assume your devlab development environment is Linux / Windows Subsystem for Linux (WSL). All effort is done to maintain the powershell version of the build-script too (`build.ps1`) - so, basically these instructions *may work* without changes also on Windows - they just have not been tested as much as being tested on Linux / WSL environments.

HINT:
Use of VSCode can greatly help in many of the steps below, without resorting to command-lines. Explained below are the command lines for the operations. 

In general, the following operations can be done directly from within VSCode:
- Switching to a branch (example, switching to a language branch)
- Tagging a specific commit
- Deleting a tag
- Merging brances

Now, for the set of operations to build the complete devlab suite:

1. Start with building osbase - this forms the base of all devlabs, including the base devlab. The best way to build it is by:
   - Tagging the latest commit on the master-branch with `osbase-<version>`. For example, `osbase-1.0`. Make sure that the tag does not already exist in github. 

         git tag -a osbase-<version>

     Note that it is also possible to reuse an existing tag if you want (eg: if you have done just a non-code change, such as adding info in README, etc.). In this case, you will have to first delete the existing tag both in your local machine and the remote github repo, and then retag with the same tag. For example, if your latest version of `osbase` is `osbase-1.0`. and you want to retag to 1.0, then:

     ```bash
     # Delete local tag
     git tag --delete osbase-1.0

     # Delete remote tag 
     git push origin :refs/tags/osbase-1.0

     # Reuse tag: retag with the tag
     git tag -a osbase-1.0
     ```
   - Push the code to github:

          git push origin master

   - Push also the tag of osbase:

         git push origin osbase-<version>

    These steps will automatically trigger the build of the osbase in dockerhub.

2. Wait until [onspot/osbase](https://hub.docker.com/repository/docker/onspot/osbase) is built completely in dockerhub. Note that whatever tag you use for tagging the code of osbase in git, the dockerhub image's tag is always `latest`.
3. Now, build the base-devlab:
   - Pull the built onspot/osbase to your devlab development system:

         docker pull onspot/osbase

   - Go to the devlab git repo-root, and build the base-devlab.

         ./build

   - Once the build is done and is successful, tag the git repo master branch with a tag:
   
         git tag -a base-<version>

     Of course, it is also possible to reuse tag as mentioned for `osbase` before. In general, we will avoid reuse of tags unless absolutely sure - and if we are sure that only non-code aspects such as README, DEVTIPS, etc. are touched with the commits.

   - Push the base-devlab also to dockerhub:

         docker push onspot/devlab
         docker push onspot/devlab:<version>

4. Once both osbase and the base-devlabs have been built and pushed to dockerhub, it is now time to build each of the other devlabs. We will basically not build them on our local machines: we will use dockerhub for building all of these images. For that, we will simply tag our code in git, and push the code (and their tags) to github. Dockerhub now is automatically triggered to build the images as soon as they are pushed into github. Since some of the languages depend on other, the order of building of these devlabs matter. Also, we build both the `latest` version of the images and their tagged versions. Currently, the following languages are independent of each other: so can be built in any order:

   java  
   rust  
   dotnet  
   haskell  

   These languages depend on atleast one of the languages above:

   scala (depends on java)

5. For each language to be built, follow this order:
   - Switch to the branch named with the language. For example, to build java, switch to `java`:

         git checkout java

    - Merge the master branch with this language branch. This will make all language branches to have the base-set of features provided by the base-devlab:

          git merge master 

      Ideally, there should be no merge conflicts, because language branches only add a dockerfile within the `lang` folder.

    - Tag the last commit with the tag of the form `<lang>-<image-version>-<base-devlab-version>` where:

      `<lang>` - Language we are building  
      `<image-version>` - Version of the devlab image. Generally, this is the same version as the compiler version of the language we are building. Certain languages come with an "update" tool (such as `rust` comes with `rustup`) - so, basically, it is possible to use any version of the compiler in these devlabs: and so we simply have `<image-version>` as a running serial number starting with 1.0.  
      `<base-devlab-version>` - This is the version of the base devlab from which this image is derived from. This is to be the same as the version you use with `FROM onspot/devlab:<version>` in the dockerfile of the language.

      Of course, tags can be reused, with the conditions explained above. Reusing of the tag will require to delete both local and remote tags - and this is also explained with an example of `osbase` above.

      The tagging itself is done with git:

          git tag -a <tag-as-described-above>

    - Push the code to github:

          git push

      This will automatically trigger a build of the `latest` version of the devlab image pertaining to the language.

      If you plan also to tag this latest version with a new tag, this automatic build will be overwritten by the tagged version as soon as you push the tag below.

    - Push the language tag as described above:

          git push origin <tag-as-described-above>

      This will now trigger another build in dockerhub, with a tag for the image. The image will also be automatically tagged as `latest` - so, basically, the tagged version and the `latest` version of the image will have the same digest.

6. Repeat this process for each language that you want to build.

# Adding yourself as a contributor to this project
[all-contributors](https://github.com/all-contributors/all-contributors) gives us an easy CLI for managing contributors. Install that as follows:

    npm i -g all-contributors-cli

This installs the all-contributors-cli as a global node tool. To add yourself as a contributor, you use this command:

    npx all-contributors add <your-github-uid> <contribution-type>

The various contribution types are mentioned in the [emoji key here](https://allcontributors.org/docs/en/emoji-key). For example, to add yourself as a contributor for code, documentation, fixing bugs and for answering questions on stackoverflow, etc., use this:

    npx all-contributors add <your-github-uid> code,doc,bug,question

That's it! This command will add you as the contributor to this project for the contribution types given in your command and also commit the code. The changes are done in the [README.md](README.md) file - the last part of that file will contain your github avatar and your contributions as emojies.