<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-1-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

# Introduction
devlab is a way to quickly set up development environments for various languages. On default, it contains a mode in which Jupyter starts with the said language enabled, but, it also offers a way to use it as a terminal for advanced usage / complete development environment.

This project contains the Docker files for building devlab and all the associated scripts (both for Linux and for Powershell).

# Base devlab
The base devlab starts a jupyter lab with Python, Julia and Javascript (Node.js) REPL. These languages will be available in every devlab, apart from specific other languages that devlab supports.

Although there is no Jupyter interface, when devlab is used as a shell, you also have access to all the C/C++ developer tools: gcc, c++, make, cmake, etc. 

THe shell version gives access to the command-line / REPLs of Python, Julia, nodejs (in the base devlab), and other tools based on the languages supported by your version of devlab.

# Installing devlab
The easiest way to get devlab on your PC is by using the install-scripts:

Linux / WSL:
```
curl -sSL https://raw.githubusercontent.com/onspot-tools/devlab/master/scripts/install.sh | sh
```

Powershell:
```
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/onspot-tools/devlab/master/scripts/install.ps1'))
```    

Either of these will create a directory called `devlab` where you invoked them, and will also pull in the devlab start-scripts (also called as devlab (Linux) / devlab.ps (powershell) into that directory.

To use devlab, get into that directory and start devlab. In the explanation that follows, we use only `devlab`, but everything also holds good for `devlab.ps1` too - for those who use docker-for-desktop and powershell.

# devlab script
The devlab script is the starting point for using devlab. To know how to use the script, just type `./devlab help` (UNIX) or `.\devlab.ps1 help` (Windows).

# Using devlab
As you would have seen with `devlab help`, on starting devlab, it can be used both as a terminal or a jupyter notebook. When started as notebook, it displays the running Jupyter's URL on screen.

When in shell, you will notice a directory "work". The work directory is for keeping your working files. These files are preserved even after you stop devlab - they will be in the "work" directory in the same directory where you started devlab from. Jupyter notebooks automatically keep the notebooks in this directory.

devlab creates docker named-volumes to preserve your files. The name of the volume follows a standard: 

    devlab-<lang>-<version>

The base devlab volume is named as devlab-base-<version>

If you would want to start afresh, just remove the relevant colume and then restart devlab:

    docker volume rm devlab-<lang>-<version>

If you would like to copy the files from the volumes into your host machine, or want to use the files from the volumes from other containers, just mount the volume where you want and use that - independant of devlab.

The whole of your home-directory is volume-mounted into one of these named-volumes. You can even create other directories under your home to keep files that will stay across devlab sessions.

## Adding Python packages
More python packages can be installed simply by using:

    conda install <package>

OR

    pip install <package>

## Normal user and root user
devlab is designed in such a way that you will be using it as a user `dev` with normal privileges. However:

- `zypper install <package>` installs OpenSUSE packages as root, automatically
- `rs` brings a root-shell for you

**Use both of these with care**, as you can really damage your system with these.

## Using devlab behind a proxy
Use of devlab behind a proxy server is a fully supported scenario. Proxy supporting only NTLM authentication is also possible, but only with a NTLM proxy helper like [px](https://github.com/genotrance/px), [cntlm](http://cntlm.sourceforge.net/) or [ntlmaps](http://ntlmaps.sourceforge.net/).

To use devlabs behind a proxy, before starting devlabs (via the devlab command explained above), make sure to define http_proxy and the https_proxy environment variables. That's it! Devlabs can now be used without any problems. Except when...

If your corporate proxy is an MITM proxy, it is likely that your IT team provides you the "trusted certificates" that are installed in all PCs that go through this proxy. For using devlabs behind such a proxy, in addition to the environment variables mentioned above, you need to create a directory called `trustedcerts` in the same level as your devlab script, and drop all your trusted certificates (in PEM-encoded form) in this directory. Devlab automatically mounts this directory into the container and uses the certificates you've dropped in that directory to connect to the external world.

Some language features (such as installing new packages / libraries for your language) need this external connection to work - and the combination of the environment variables and the `trustedcerts` directory will help in this connection behind your proxies.

## Using Visual Studio Code with devlab
Devlab can be used from [Visual Studio Code](https://code.visualstudio.com/) (VSCode) by using its remote-container connection - ensure that you have started devlab before connecting. Devlab runs with the container name `devlab` - simply connect to it from VSCode.

In combination with the [Jupyter plugin for VSCode](https://marketplace.visualstudio.com/items?itemName=ms-toolsai.jupyter), this makes it particularly very useful combination with devlab!

Additionally, for using VSCode with devlab behind a proxy, there are some VScode settings that are needed to be done: go to settings, search for "proxy", and then put in your proxy settings there (proxy name and port, SSL strictness, etc.)

## Running devlab on a port different from 9000
devlab runs on TCP port 9000 by default. If you want to change this, you need to edit the `devlab` script (in Linux / Unix, on Windows, this is the `devlap.ps1`). Search for the variable HPORT, and change that to what you would like devlab to run on.
# Contributing to devlab
Well, anybody is welcome to contributing to this project, and [All Contributors](https://allcontributors.org/) are recognised for their contribution! [Check out here](CONTRIBUTING.md) to know how you can contribute to making devlab the best place for developers to quickly get on to a development laboratory.

# Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="https://blog.ramdoot.in/"><img src="https://avatars.githubusercontent.com/u/1006084?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Arvind Devarajan</b></sub></a><br /><a href="https://github.com/onspot-tools/devlab/commits?author=arvindd" title="Code">💻</a> <a href="https://github.com/onspot-tools/devlab/commits?author=arvindd" title="Documentation">📖</a> <a href="https://github.com/onspot-tools/devlab/pulls?q=is%3Apr+reviewed-by%3Aarvindd" title="Reviewed Pull Requests">👀</a> <a href="https://github.com/onspot-tools/devlab/issues?q=author%3Aarvindd" title="Bug reports">🐛</a> <a href="#example-arvindd" title="Examples">💡</a> <a href="#ideas-arvindd" title="Ideas, Planning, & Feedback">🤔</a> <a href="#infra-arvindd" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="#maintenance-arvindd" title="Maintenance">🚧</a> <a href="#question-arvindd" title="Answering Questions">💬</a></td>
  </tr>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!