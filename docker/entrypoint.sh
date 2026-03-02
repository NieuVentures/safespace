#!/bin/sh
CLAUDE_HOME="/home/claude"

# Fix ownership of files copied via docker cp (copies as root:root)
chown claude:claude "$CLAUDE_HOME/.gitconfig" 2>/dev/null || true

# Fix ownership of named volumes (Docker creates them as root on first use)
chown -R claude:claude \
    "$CLAUDE_HOME/.claude" \
    "$CLAUDE_HOME/.config/gh" \
    2>/dev/null || true

# .claude.json must live at ~/.claude.json but we can't named-volume-mount a single file.
# Symlink it into the persistent .claude/ volume so it survives container recreation.
# Validate existing file is valid JSON; reset if corrupted (e.g. empty from prior bug).
CLAUDE_JSON="$CLAUDE_HOME/.claude/.claude.json"
if [ ! -s "$CLAUDE_JSON" ] || ! node -e "JSON.parse(require('fs').readFileSync(process.argv[1],'utf8'))" "$CLAUDE_JSON" 2>/dev/null; then
    echo '{}' > "$CLAUDE_JSON"
fi
chown claude:claude "$CLAUDE_JSON"
ln -sf "$CLAUDE_HOME/.claude/.claude.json" "$CLAUDE_HOME/.claude.json"
chown -h claude:claude "$CLAUDE_HOME/.claude.json"

# Update Claude Code to latest version (runs as root before dropping privileges)
npm update -g @anthropic-ai/claude-code --loglevel=warn

# Drop to claude user, preserving TERM for proper terminal rendering
export TERM="${TERM:-xterm-256color}"

# Install plugins as claude user (idempotent — safe to run on every start)
su claude -c "claude mcp marketplace add mksglu/claude-context-mode 2>/dev/null || true"
su claude -c "claude install context-mode@claude-context-mode 2>/dev/null || true"

# --shell flag: drop into an interactive shell instead of launching claude
if [ "${1:-}" = "--shell" ]; then
    shift
    exec su claude -c "cd '$CLAUDE_HOME/projects' && /banner.sh && exec zsh"
fi

# Build a properly quoted command string for su -c
# Show banner before launching Claude
CMD="cd '$CLAUDE_HOME/projects' && /banner.sh && exec claude --dangerously-skip-permissions"
for arg in "$@"; do
    CMD="$CMD '$(printf '%s' "$arg" | sed "s/'/'\\\\''/g")'"
done

exec su claude -c "$CMD"
