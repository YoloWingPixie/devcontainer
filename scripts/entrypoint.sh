#!/bin/bash

DOCKER_SOCKET=/var/run/docker.sock

# If the Docker socket is mounted from the host, make it accessible to all users in the container
if [ -S "${DOCKER_SOCKET}" ]; then
  sudo chmod 666 "${DOCKER_SOCKET}"
fi

exec "$@"
