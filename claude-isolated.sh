#!/bin/bash

set -e

IMAGE_NAME="claude-isolated:latest"
CONTAINER_NAME="claude-isolated-dev"

usage() {
  echo "Usage: $0 BRANCH_NAME [COMMAND...]" >&2
  exit 1
}

# Check for positional argument
if [ -z "$1" ]; then
  usage
fi

BRANCH_NAME="$1"
shift

# If no command is given, default to 'claude'
if [ $# -eq 0 ]; then
  CMD=(claude)
else
  CMD=("$@")
fi

# Check if current directory is a git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  echo "Error: The current directory ($PWD) is not a git repository. Please run this script from within a git checkout." >&2
  exit 1
fi

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Build the Docker image
docker build -t "$IMAGE_NAME" -f "$SCRIPT_DIR/Dockerfile" "$SCRIPT_DIR"

# Run the container interactively, mounting necessary volumes
docker run --rm -it \
  --name "$CONTAINER_NAME" \
  -e BRANCH_NAME="$BRANCH_NAME" \
  -v "$PWD:/origin-repository" \
  -v "$HOME/.claude:/home/node/.claude" \
  -v "$HOME/.claude.json:/home/node/.claude.json" \
  -v "$HOME/.gitconfig:/home/node/.gitconfig" \
  -w /workspace \
  "$IMAGE_NAME" \
  "${CMD[@]}"
