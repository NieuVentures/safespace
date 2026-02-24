#!/usr/bin/env bash
# Start an interactive shell in a safespace container.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/docker/common.sh"

ensure_image

echo "Starting $IMAGE_NAME container (shell mode)..."
CONTAINER_ID=$(create_container --shell)
copy_files "$CONTAINER_ID"
start_container "$CONTAINER_ID"
