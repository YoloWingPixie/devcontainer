#!/bin/bash
set -e

# Enable universe repository for additional packages (eza, duf, du-dust, zoxide, etc.)
apt-get update && apt-get install -y software-properties-common
add-apt-repository -y universe

apt-get update && apt-get install -y yq \
    && apt-get install -y $(yq -r '.apt_packages[]' $CONFIG_FILE) \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
