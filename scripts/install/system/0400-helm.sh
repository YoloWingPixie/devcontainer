#!/bin/bash
set -e

curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" | tee /etc/apt/sources.list.d/helm-stable-debian.list

HELM_VERSION=$(yq -r '.versions.helm' $CONFIG_FILE)

if [ "$HELM_VERSION" = "latest" ]; then
    apt-get update && apt-get install -y helm
else
    apt-get update && apt-get install -y helm=$HELM_VERSION
fi

apt-get clean && rm -rf /var/lib/apt/lists/*
