#!/bin/bash
set -e

HELM_VERSION=$(yq -r '.versions.helm' $CONFIG_FILE)

if [ "$HELM_VERSION" = "latest" ]; then
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
else
    export DESIRED_VERSION="v${HELM_VERSION}"
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi
