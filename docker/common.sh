#!/usr/bin/env bash
# Shared config and helpers — sourced by other scripts, never run directly.

IMAGE_NAME="safespace"
CLAUDE_HOME="/home/claude"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Named volumes for auth that requires interactive login (OAuth tokens live in system keychains,
# not in files, so we can't docker-cp them from the host). Users log in once inside the container
# and the tokens persist across ephemeral --rm containers via these Docker-managed volumes.
# Named volumes are NOT host bind mounts — they're opaque Docker storage, safe by design.
VOLUMES=(
    -v "$SCRIPT_DIR/projects:$CLAUDE_HOME/projects"
    -v "safespace-claude-config:$CLAUDE_HOME/.claude"
    -v "safespace-gh-config:$CLAUDE_HOME/.config/gh"
)

ensure_image() {
    echo "Building $IMAGE_NAME image..."
    docker build -t "$IMAGE_NAME" "$SCRIPT_DIR/docker"
}

create_container() {
    docker create -it --rm --init \
        --name "safespace-$(date +%s)" \
        "${VOLUMES[@]}" \
        "$IMAGE_NAME" \
        "$@"
}

copy_files() {
    local container_id="$1"
    # Copy ONLY git identity (name/email) for commits. Nothing else.
    # Auth is handled entirely by gh CLI via the safespace-gh-config named volume.
    # NEVER copy .ssh/ (private keys) or .git-credentials (plaintext tokens) into containers.
    if [[ -f "$HOME/.gitconfig" ]]; then
        docker cp "$HOME/.gitconfig" "$container_id:$CLAUDE_HOME/.gitconfig"
    fi
}

start_container() {
    exec docker start -ai "$1"
}
