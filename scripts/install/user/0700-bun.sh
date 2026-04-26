#!/bin/bash
set -e

BUN_VERSION=$(yq -r '.versions.bun' $CONFIG_FILE)

if [ "$BUN_VERSION" = "latest" ]; then
    curl -fsSL https://bun.sh/install | bash
else
    curl -fsSL https://bun.sh/install | bash -s "bun-v${BUN_VERSION}"
fi
