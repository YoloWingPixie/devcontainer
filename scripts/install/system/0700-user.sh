#!/bin/bash
set -e

USER_UID=$(yq -r '.user.uid' $CONFIG_FILE)
USER_GID=$(yq -r '.user.gid' $CONFIG_FILE)

useradd --uid $USER_UID --gid $USER_GID --shell /bin/zsh -m $USERNAME
echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/$USERNAME
chmod 0440 /etc/sudoers.d/$USERNAME

printf '[user]\ndefault=%s\n' "$USERNAME" > /etc/wsl.conf
