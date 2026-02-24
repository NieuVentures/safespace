#!/usr/bin/env bash
# Build (or rebuild) the safespace Docker image.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/docker/common.sh"

echo "Building $IMAGE_NAME image..."
docker build -t "$IMAGE_NAME" "$SCRIPT_DIR/docker"
