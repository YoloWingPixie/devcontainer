#!/bin/bash
set -euo pipefail

source /etc/devcontainer/workspace.env

STATE_ROOT="$HOME/.local/state/$DEVCONTAINER_WORKSPACE_STATE_DIRECTORY"
ZSH_CONFIG_DIRECTORY="$HOME/.config/zsh"

install -d -m 0700 "$STATE_ROOT"
install -d -m 0755 "$ZSH_CONFIG_DIRECTORY"
install -m 0644 /tmp/addons/workspace/workspace.zsh "$ZSH_CONFIG_DIRECTORY/workspace.zsh"
