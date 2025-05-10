#!/bin/sh

export DEBIAN_FRONTEND=noninteractive # disable prompts
APT="apt-get -y"                      # auto‑yes + quiet

# Symlink distrobox shims
./dev-shims.sh

# Add ppa repositories
# fastfetch
add-apt-repository ppa:zhangsongcui3371/fastfetch
# gh
# Install GitHub CLI (gh) from official repo using 'stable' codename
(type -p wget >/dev/null || ($APT update && $APT install wget)) &&
  sudo mkdir -p -m 755 /etc/apt/keyrings &&
  out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg &&
  sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg <$out >/dev/null &&
  sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg &&
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" |
  sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null

# Update the container and install packages
$APT update
$APT upgrade
grep -v '^#' ./hyprome-dev.packages | xargs $APT install
