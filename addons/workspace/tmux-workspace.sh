#!/bin/bash
set -euo pipefail

source /etc/devcontainer/workspace.env

state_root="$HOME/.local/state/$DEVCONTAINER_WORKSPACE_STATE_DIRECTORY"
resurrect_directory="$state_root/tmux/resurrect"

mkdir -p "$resurrect_directory"
tmux set-option -gq @resurrect-dir "$resurrect_directory"
tmux set-option -gq @continuum-save-interval "$DEVCONTAINER_TMUX_SAVE_INTERVAL_MINUTES"
tmux set-option -gq @continuum-restore on

/opt/tmux/plugins/tmux-resurrect/resurrect.tmux
/opt/tmux/plugins/tmux-continuum/continuum.tmux
