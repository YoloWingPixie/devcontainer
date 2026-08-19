#!/bin/bash
set -euo pipefail

CODEX_ENABLED=$(yq -r '.addons.codex.enabled // false' "$CONFIG_FILE")
if [ "$CODEX_ENABLED" != "true" ]; then
    exit 0
fi

CODEX_VERSION=$(yq -r '.addons.codex.version' "$CONFIG_FILE")
CODEX_INSTALLER_URL=$(yq -r '.addons.codex.installer_url' "$CONFIG_FILE")
CODEX_INSTALLER_SHA256=$(yq -r '.addons.codex.installer_sha256' "$CONFIG_FILE")
CODEX_INSTALLER=/tmp/codex-install.sh
CODEX_CONFIG_SOURCE=/tmp/addons/codex
CODEX_CONFIG_DIR="/home/${USERNAME}/.codex"

curl -fsSL "$CODEX_INSTALLER_URL" -o "$CODEX_INSTALLER"
printf '%s  %s\n' "$CODEX_INSTALLER_SHA256" "$CODEX_INSTALLER" | sha256sum -c -
CODEX_NON_INTERACTIVE=true sh "$CODEX_INSTALLER" --release "$CODEX_VERSION"
rm -f "$CODEX_INSTALLER"

install -d -m 0700 "$CODEX_CONFIG_DIR"
install -m 0600 "$CODEX_CONFIG_SOURCE/config.toml" "$CODEX_CONFIG_DIR/config.toml"
