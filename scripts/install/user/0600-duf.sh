#!/bin/bash
set -e

ARCH=$(dpkg --print-architecture)
VERSION=$(curl -fsSL https://api.github.com/repos/muesli/duf/releases/latest | jq -r '.tag_name' | sed 's/v//')

curl -fsSL "https://github.com/muesli/duf/releases/download/v${VERSION}/duf_${VERSION}_linux_${ARCH}.deb" -o /tmp/duf.deb
sudo dpkg -i /tmp/duf.deb
rm /tmp/duf.deb
