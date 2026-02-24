# Safespace

Dockerized [Claude Code](https://docs.anthropic.com/en/docs/claude-code) environment. Run Claude Code CLI in an isolated container with persistent auth and a shared project directory.

## Why

Claude Code works best with shell access, but running it directly on your host gives it broad system access. Safespace wraps it in a Docker container so it can only touch your `projects/` directory — nothing else on your machine.

## What's in the container

- **Node.js 22** (Debian Bookworm base)
- **Claude Code CLI** (`@anthropic-ai/claude-code`)
- **GitHub CLI** (`gh`) for git authentication over HTTPS
- **pnpm** via corepack
- **zsh** with Starship prompt

## Prerequisites

- Docker
- An Anthropic API key or Claude account (you'll authenticate inside the container)

## Quick start

```bash
# Clone the repo
git clone https://github.com/NieuVentures/safespace
cd safespace

# First run (builds the image automatically if needed)
./run.sh

# Pass arguments to Claude Code
./run.sh --model sonnet

# Drop into a shell instead of Claude Code
./shell.sh

# Force rebuild the image
./build.sh
```

On first run you'll need to authenticate:

1. **Claude Code**: follow the OAuth prompt, or set your API key
2. **GitHub CLI**: run `gh auth login` inside the container

Both persist in named Docker volumes across container restarts.

## Project files

Pull your github projects inside `projects/`. It's the only directory shared between your host and the container.

```
safespace/
├── run.sh            # Launch Claude Code in a container (start here)
├── shell.sh          # Launch an interactive shell in a container
├── build.sh          # Build (or rebuild) the Docker image
├── projects/         # Shared with container (your work goes here)
└── docker/           # Container internals (you don't need to touch these)
    ├── Dockerfile
    ├── entrypoint.sh
    ├── banner.sh
    └── common.sh     # Shared config and helpers for the scripts
```

## How it works

```
┌─ Host ─────────────────────────────────────────────────┐
│                                                        │
│  run.sh                                                │
│    ├── Builds Docker image (if needed)                 │
│    ├── Creates ephemeral container (--rm)              │
│    ├── Copies .gitconfig (git identity only)           │
│    └── Attaches terminal                               │
│                                                        │
│  Mounts:                                               │
│    projects/  ←──bind mount──→  /home/claude/projects  │
│    Named vol  ──────────────→  /home/claude/.claude    │
│    Named vol  ─────────────→  /home/claude/.config/gh  │
│                                                        │
├─ Container ───────────────────────────────────────────-┤
│                                                        │
│  entrypoint.sh (runs as root)                          │
│    ├── Fixes file ownership (docker cp → root:root)    │
│    ├── Sets up .claude.json symlink                    │
│    └── Drops to non-root `claude` user via `su`        │
│                                                        │
│  claude --dangerously-skip-permissions                 │
│    (safe because the container IS the sandbox)         │
│                                                        │
│  OR via shell.sh:                                      │
│  zsh (interactive terminal — run claude manually)      │
│                                                        │
└────────────────────────────────────────────────────────┘
```

**Key design choices:**

- **Ephemeral containers** (`--rm`): nothing persists except what's in volumes
- **Named Docker volumes** for auth: Claude and GitHub CLI tokens survive container recreation. You log in once inside the container.
- **No secrets copied**: no SSH keys, no `.git-credentials`, no API tokens in the image. Git auth is handled entirely by `gh` CLI over HTTPS.
- **Non-root execution**: Claude Code refuses `--dangerously-skip-permissions` as root. The entrypoint drops to user `claude` after fixing file ownership.

## Security model

- The container cannot see your home directory, SSH keys, or credentials
- Only `projects/` is bind-mounted (scoped, bidirectional)
- Auth tokens live in opaque Docker-managed named volumes, not host paths
- `--dangerously-skip-permissions` is safe here because Docker itself is the sandbox
- Containers are ephemeral (`--rm`) — non-volume state is destroyed on exit

## Terms of service

Safespace runs the **official Claude Code CLI** (`@anthropic-ai/claude-code`) inside a Docker container. This is permitted under Anthropic's [Consumer Terms of Service](https://www.anthropic.com/legal/consumer-terms) — the container is just an environment, like a VPS or cloud IDE.

**What's allowed:**

- Running the official Claude Code CLI in Docker for personal, interactive use
- Authenticating via OAuth (Free, Pro, Max plans) or API key — tokens stay within Claude Code
- Using `shell.sh` to drop into the container and run `claude` manually

**What's NOT allowed:**

- Using OAuth tokens outside of Claude Code (e.g. in custom scripts, third-party tools, or the Agent SDK) — use [API keys](https://platform.claude.com/) for those
- Running multiple containers in parallel to circumvent usage limits
- Building a service or product on top of consumer plan credentials
- Headless automation or batch processing beyond "ordinary, individual usage"

If your use case goes beyond personal interactive use, switch to **API key authentication** under Anthropic's [Commercial Terms](https://www.anthropic.com/legal/commercial-terms).

For full details, see Anthropic's [Claude Code legal and compliance docs](https://code.claude.com/docs/en/legal-and-compliance).
