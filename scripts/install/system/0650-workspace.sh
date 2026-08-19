#!/bin/bash
set -euo pipefail

WORKSPACE_SOURCE=/tmp/addons/workspace
WORKSPACE_CONFIG_DIRECTORY=/etc/devcontainer
TMUX_PLUGIN_ROOT=/opt/tmux/plugins

STATE_DIRECTORY=$(yq -r '.workspace.state_directory' "$CONFIG_FILE")
SAVE_INTERVAL=$(yq -r '.workspace.tmux.save_interval_minutes' "$CONFIG_FILE")

if [[ ! "$STATE_DIRECTORY" =~ ^[a-zA-Z0-9._-]+$ ]]; then
    echo "workspace.state_directory must be a directory name" >&2
    exit 1
fi

if [[ ! "$SAVE_INTERVAL" =~ ^[1-9][0-9]*$ ]]; then
    echo "workspace.tmux.save_interval_minutes must be a positive integer" >&2
    exit 1
fi

install -d -m 0755 "$WORKSPACE_CONFIG_DIRECTORY" /usr/local/lib/devcontainer "$TMUX_PLUGIN_ROOT"
printf 'DEVCONTAINER_WORKSPACE_STATE_DIRECTORY=%q\nDEVCONTAINER_TMUX_SAVE_INTERVAL_MINUTES=%q\n' \
    "$STATE_DIRECTORY" "$SAVE_INTERVAL" > "$WORKSPACE_CONFIG_DIRECTORY/workspace.env"
chmod 0644 "$WORKSPACE_CONFIG_DIRECTORY/workspace.env"

install -m 0755 "$WORKSPACE_SOURCE/cdirs" /usr/local/bin/cdirs
install -m 0644 "$WORKSPACE_SOURCE/tmux.conf" /etc/tmux.conf
install -m 0755 "$WORKSPACE_SOURCE/tmux-workspace.sh" /usr/local/lib/devcontainer/tmux-workspace.sh

for plugin in resurrect continuum; do
    repository=$(yq -r ".workspace.tmux.plugins.${plugin}.repository" "$CONFIG_FILE")
    revision=$(yq -r ".workspace.tmux.plugins.${plugin}.revision" "$CONFIG_FILE")
    plugin_directory="$TMUX_PLUGIN_ROOT/tmux-$plugin"

    if [[ ! "$revision" =~ ^[0-9a-f]{40}$ ]]; then
        echo "workspace.tmux.plugins.${plugin}.revision must be a full commit SHA" >&2
        exit 1
    fi

    git init -q "$plugin_directory"
    git -C "$plugin_directory" remote add origin "$repository"
    git -C "$plugin_directory" fetch -q --depth=1 origin "$revision"
    git -C "$plugin_directory" checkout -q --detach FETCH_HEAD

    if [ "$(git -C "$plugin_directory" rev-parse HEAD)" != "$revision" ]; then
        echo "tmux plugin revision mismatch for $plugin" >&2
        exit 1
    fi

    rm -rf "$plugin_directory/.git"
done
