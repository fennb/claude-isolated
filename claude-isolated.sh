#!/bin/bash

set -e

IMAGE_NAME="claude-isolated:latest"
CONTAINER_NAME="claude-isolated-dev"

usage() {
  echo "Usage: $0 BRANCH_NAME" >&2
  exit 1
}

# Check for positional argument
if [ -z "$1" ]; then
  usage
fi

BRANCH_NAME="$1"

# Check if current directory is a git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  echo "Error: The current directory ($PWD) is not a git repository. Please run this script from within a git checkout." >&2
  exit 1
fi

# Build the Docker image
docker build -t "$IMAGE_NAME" .

# Run the container interactively, mounting necessary volumes
docker run --rm -it \
  --name "$CONTAINER_NAME" \
  -e BRANCH_NAME="$BRANCH_NAME" \
  -v "$PWD:/host-pwd" \
  -v "$HOME/.claude:/home/node/.claude" \
  -v "$HOME/.claude.json:/home/node/.claude.json" \
  -w /workspace \
  "$IMAGE_NAME" \
  zsh
