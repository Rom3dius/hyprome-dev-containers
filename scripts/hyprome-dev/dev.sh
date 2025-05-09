#!/bin/sh

export DEBIAN_FRONTEND=noninteractive     # disable prompts
APT="apt-get -yq --no-install-recommends" # auto‑yes + quiet

# Symlink distrobox shims
./dev-shims.sh

# Add ppa repositories
# fastfetch
add-apt-repository ppa:zhangsongcui3371/fastfetch
# gh
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key C99B11DEB97541F0
sudo apt-add-repository https://cli.github.com/packages

# Update the container and install packages
$APT update
$APT upgrade
grep -v '^#' ./dev.packages | xargs $APT install
