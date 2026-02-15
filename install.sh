#!/bin/bash
set -e

echo "🚀 Setting up dev environment..."

# Install Homebrew if not present
if ! command -v brew &>/dev/null; then
  echo "📦 Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  
  # Add brew to PATH for Apple Silicon
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
fi

echo "📦 Installing packages..."
brew install neovim tmux starship
brew install --cask ghostty

# Install tmuxifier
if [[ ! -d "$HOME/.tmuxifier" ]]; then
  echo "📦 Installing tmuxifier..."
  git clone https://github.com/jimeh/tmuxifier.git ~/.tmuxifier
fi

# Install TPM (tmux plugin manager)
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
  echo "📦 Installing TPM..."
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# Get the directory this script lives in
DOTFILES="$(cd "$(dirname "$0")" && pwd)"

echo "🔗 Creating symlinks..."

# Ghostty
mkdir -p ~/.config/ghostty
ln -sf "$DOTFILES/ghostty/config" ~/.config/ghostty/config

# Neovim
rm -rf ~/.config/nvim
ln -sf "$DOTFILES/nvim" ~/.config/nvim

# Tmux
ln -sf "$DOTFILES/tmux.conf" ~/.tmux.conf

echo ""
echo "✅ Done! Remaining manual steps:"
echo "  1. Add to ~/.zshrc if not already there:"
echo '     export PATH="$HOME/.tmuxifier/bin:$PATH"'
echo '     eval "$(tmuxifier init -)"'
echo '     eval "$(starship init zsh)"'
echo "  2. Open tmux and press prefix + I to install tmux plugins"
echo "  3. Open nvim — Lazy will auto-install plugins on first launch"
echo ""
echo "🎨 Theme: Catppuccin Mocha everywhere"
