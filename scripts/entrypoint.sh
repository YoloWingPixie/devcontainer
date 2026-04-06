#!/bin/bash

CONFIG="/home/yolowingpixie/config.yaml"
DOCKER_SOCKET=/var/run/docker.sock

# If the Docker socket is mounted from the host, make it accessible to all users in the container
if [ -S "${DOCKER_SOCKET}" ]; then
  sudo chmod 666 "${DOCKER_SOCKET}"
fi

# --- SSH Agent Setup ---
SSH_AUTH_SOCK="$HOME/.ssh/agent.sock"
export SSH_AUTH_SOCK

# Kill any stale agent on this socket
if [ -S "$SSH_AUTH_SOCK" ]; then
  rm -f "$SSH_AUTH_SOCK"
fi

eval "$(ssh-agent -a "$SSH_AUTH_SOCK")" > /dev/null 2>&1

# Read SSH key source directory from config (default ~/.ssh)
SSH_SOURCE_DIR=$(yq -r '.ssh_keys.source_dir // "~/.ssh"' "$CONFIG")
SSH_SOURCE_DIR="${SSH_SOURCE_DIR/#\~/$HOME}"

# Load each key defined in config.yaml
KEY_COUNT=$(yq '.ssh_keys.keys | length' "$CONFIG")
for i in $(seq 0 $((KEY_COUNT - 1))); do
  FILENAME=$(yq -r ".ssh_keys.keys[$i].filename" "$CONFIG")
  PURPOSE=$(yq -r ".ssh_keys.keys[$i].purpose" "$CONFIG")
  KEY_PATH="${SSH_SOURCE_DIR}/${FILENAME}"

  if [ -f "$KEY_PATH" ]; then
    ssh-add "$KEY_PATH" 2>/dev/null
    echo "ssh-agent: loaded ${FILENAME} (${PURPOSE})"

    # Configure git signing if this key is for signing
    if [ "$PURPOSE" = "signing" ]; then
      PUB_KEY_PATH="${KEY_PATH}.pub"
      if [ -f "$PUB_KEY_PATH" ]; then
        git config --global gpg.format ssh
        git config --global user.signingkey "$PUB_KEY_PATH"
        git config --global commit.gpgsign true
        git config --global tag.gpgsign true
        echo "git: configured signing with ${FILENAME}"
      else
        echo "warning: signing key ${FILENAME}.pub not found, skipping git sign config"
      fi
    fi
  else
    echo "warning: SSH key ${KEY_PATH} not found, skipping"
  fi
done

# --- Git User Config ---
GIT_USERNAME=$(yq -r '.git.username // ""' "$CONFIG")
GIT_EMAIL=$(yq -r '.git.email // ""' "$CONFIG")

if [ -n "$GIT_USERNAME" ]; then
  git config --global user.name "$GIT_USERNAME"
fi
if [ -n "$GIT_EMAIL" ]; then
  git config --global user.email "$GIT_EMAIL"
fi

exec "$@"
