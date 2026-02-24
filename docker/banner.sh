#!/bin/sh
# Display safespace container banner before Claude starts

# Colors
BOLD='\033[1m'
DIM='\033[2m'
CYAN='\033[36m'
PURPLE='\033[35m'
GREEN='\033[32m'
RESET='\033[0m'

# Get Claude Code version
CLAUDE_VERSION=$(claude --version 2>/dev/null || echo "unknown")

printf '\n'
printf '  %b%b ___        __                                %b\n' "$BOLD" "$PURPLE" "$RESET"
printf '  %b%b/ __| __ _ / _| ___  ___  _ __  __ _  __ ___ %b\n' "$BOLD" "$PURPLE" "$RESET"
printf '  %b%b\\__ \\/ _` |  _|/ -_)(_-< | ._ \\/ _` |/ _/ -_)%b\n' "$BOLD" "$PURPLE" "$RESET"
printf '  %b%b|___/\\__,_|_|  \\___|/__/ | .__/\\__,_|\\__\\___|%b\n' "$BOLD" "$PURPLE" "$RESET"
printf '  %b%b                          |_|                  %b\n' "$BOLD" "$PURPLE" "$RESET"
printf '\n'
printf '  %b%bContainerized Claude Code Environment%b\n' "$BOLD" "$CYAN" "$RESET"
printf '  %b%b──────────────────────────────────────%b\n' "$DIM" "$CYAN" "$RESET"
printf '  %b%bClaude Code%b  %s\n' "$BOLD" "$GREEN" "$RESET" "$CLAUDE_VERSION"
printf '  %b%bUser%b         %s\n' "$BOLD" "$GREEN" "$RESET" "$(whoami)"
printf '  %b%bWorkdir%b      %s\n' "$BOLD" "$GREEN" "$RESET" "$(pwd)"
printf '  %b%bNode%b         %s\n' "$BOLD" "$GREEN" "$RESET" "$(node --version 2>/dev/null)"
printf '\n'
