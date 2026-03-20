#!/bin/bash
set -e

apt-get update && apt-get install -y yq \
    && apt-get install -y $(yq -r '.apt_packages[]' $CONFIG_FILE) \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
