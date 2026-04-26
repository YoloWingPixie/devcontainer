#!/bin/bash
set -e

GO_VERSION=$(yq -r '.versions.go' $CONFIG_FILE)

if [ "$GO_VERSION" = "latest" ]; then
    GO_VERSION=$(curl -fsSL "https://go.dev/VERSION?m=text" | head -1 | sed 's/^go//')
fi

curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" -o /tmp/go.tar.gz
tar -C /usr/local -xzf /tmp/go.tar.gz
rm /tmp/go.tar.gz
