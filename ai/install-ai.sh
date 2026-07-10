#!/bin/bash
# Links the AI assistant configs (Claude Code + Codex) from this repo into
# place. Idempotent and standalone — safe to run on any machine (mac mini,
# MacBook, fresh setup) without the full install.sh (no brew, no packages).
#
# What it manages:
#   ai/claude/CLAUDE.md   -> ~/.claude/CLAUDE.md      (global agent guide)
#   ai/codex/AGENTS.md    -> ~/.codex/AGENTS.md       (global Codex guidance)
#   ai/codex/mcp-servers.toml -> appended to ~/.codex/config.toml (only if missing)
#
# What it deliberately does NOT touch (secrets / machine state):
#   ~/.codex/auth.json, ~/.claude.json, session/history/cache dirs.
set -e

DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"

link() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    echo "  ↪ backing up existing $dest -> $dest.pre-dotfiles"
    mv "$dest" "$dest.pre-dotfiles"
  fi
  ln -sf "$src" "$dest"
  echo "  ✓ $dest -> $src"
}

echo "🔗 Linking AI configs..."
link "$DOTFILES/ai/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
link "$DOTFILES/ai/codex/AGENTS.md" "$HOME/.codex/AGENTS.md"

echo "🔌 Ensuring Codex MCP servers..."
CODEX_CONFIG="$HOME/.codex/config.toml"
mkdir -p "$HOME/.codex"
touch "$CODEX_CONFIG"
for server in cil linear; do
  if grep -q "\[mcp_servers.$server\]" "$CODEX_CONFIG"; then
    echo "  ✓ mcp_servers.$server already registered"
  else
    echo "" >> "$CODEX_CONFIG"
    sed -n "/\[mcp_servers.$server\]/,/^$/p" "$DOTFILES/ai/codex/mcp-servers.toml" >> "$CODEX_CONFIG"
    echo "  + mcp_servers.$server appended"
  fi
done

echo ""
echo "✅ AI configs linked. Manual steps on a fresh machine:"
echo "  1. codex login            (auth is never in this repo)"
echo "  2. claude login / claude  (same)"
echo "  3. Verify CIL is reachable: curl -s -o /dev/null -w '%{http_code}\\n' http://192.168.68.200:7781/mcp  (406 = alive)"
