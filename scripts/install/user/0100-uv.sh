#!/bin/bash
set -e

curl -LsSf https://astral.sh/uv/install.sh | sh

for pkg in $(yq -r '.global_python_packages[]' $CONFIG_FILE); do
    uv tool install $pkg
done
