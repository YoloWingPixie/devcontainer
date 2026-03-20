#!/bin/bash
set -e

KUBECTL_VERSION=$(yq -r '.versions.kubectl' $CONFIG_FILE)

if [ "$KUBECTL_VERSION" = "stable" ]; then
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
else
    curl -LO "https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl"
fi

install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl
