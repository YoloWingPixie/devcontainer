#!/bin/bash
set -e

PYTHON_VERSION=$(yq -r '.versions.python' $CONFIG_FILE)
PYTHON_MAJOR_VERSION=${PYTHON_VERSION%%.*}

apt-get update && apt-get install -y \
    python${PYTHON_MAJOR_VERSION} \
    python${PYTHON_MAJOR_VERSION}-pip \
    python${PYTHON_MAJOR_VERSION}-venv \
    && ln -s /usr/bin/python${PYTHON_MAJOR_VERSION} /usr/bin/python \
    && rm -rf /var/lib/apt/lists/*
