#!/bin/bash
set -e

ARCH=$(uname -m)
VERSION=$(curl -fsSL https://api.github.com/repos/bootandy/dust/releases/latest | jq -r '.tag_name')
TMP=$(mktemp -d)

curl -fsSL "https://github.com/bootandy/dust/releases/download/${VERSION}/dust-${VERSION}-${ARCH}-unknown-linux-musl.tar.gz" \
    | tar -xz -C "$TMP"

find "$TMP" -name 'dust' -type f -exec install -m 0755 {} "$HOME/.local/bin/dust" \;
rm -rf "$TMP"
