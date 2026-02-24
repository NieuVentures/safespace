FROM node:22-bookworm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    zsh \
    && rm -rf /var/lib/apt/lists/*

# Install pnpm globally
RUN corepack enable && corepack prepare pnpm@latest --activate

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# Install Starship prompt
RUN curl -sS https://starship.rs/install.sh | sh -s -- -y

# Install Claude Code CLI globally
RUN npm install -g @anthropic-ai/claude-code

# Configure Starship theme
RUN mkdir -p /root/.config && cat <<'EOF' > /root/.config/starship.toml
# Minimal, modern prompt
format = """
$directory\
$git_branch\
$git_status\
$nodejs\
$line_break\
$character"""

[character]
success_symbol = "[❯](bold purple)"
error_symbol = "[❯](bold red)"

[directory]
style = "bold cyan"
truncation_length = 3
truncation_symbol = "…/"

[git_branch]
symbol = " "
style = "bold green"

[git_status]
style = "bold yellow"
format = '([\[$all_status$ahead_behind\]]($style) )'

[nodejs]
symbol = " "
style = "bold green"
format = "[$symbol($version )]($style)"

[line_break]
disabled = false
EOF

# Set up zsh as default shell with sensible config
RUN cat <<'ZSHRC' > /root/.zshrc
# Enable colors
autoload -U colors && colors

# History
HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=5000
setopt appendhistory
setopt sharehistory
setopt hist_ignore_dups

# Completion
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# Key bindings
bindkey -e
bindkey '^[[A' up-line-or-search
bindkey '^[[B' down-line-or-search

# Aliases
alias ls='ls --color=auto'
alias ll='ls -lah --color=auto'
alias la='ls -A --color=auto'

# Starship prompt
eval "$(starship init zsh)"
ZSHRC

# Create non-root user (required: claude refuses --dangerously-skip-permissions as root)
RUN useradd -m -s /bin/zsh claude

# Copy configs to claude user's home, then clean up /root/ originals
RUN mkdir -p /home/claude/.config && \
    mv /root/.config/starship.toml /home/claude/.config/starship.toml && \
    mv /root/.zshrc /home/claude/.zshrc && \
    rm -rf /root/.config && \
    chown -R claude:claude /home/claude

ENV SHELL=/bin/zsh
ENV TERM=xterm-256color
ENV HOME=/home/claude

WORKDIR /home/claude/projects

# Entrypoint fixes .claude ownership (docker cp copies as root), then drops to claude user
COPY entrypoint.sh /entrypoint.sh
COPY banner.sh /banner.sh
RUN chmod +x /entrypoint.sh /banner.sh

ENTRYPOINT ["/entrypoint.sh"]
