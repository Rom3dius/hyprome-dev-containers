#!/bin/bash

# Run shim setup
./dev-shims.sh

# Add COPRs
dnf -y copr enable cdayjr/yadm

# Update and install packages using dnf
dnf -y update
dnf -y install $(grep -v '^#' ./hyprome-dev.packages | xargs)

# Optional: Clean up
dnf clean all
