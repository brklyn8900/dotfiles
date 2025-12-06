#!/bin/bash
# macOS Terminal Setup Script
# This script installs all necessary tools and deploys dotfiles using GNU Stow

set -e  # Exit on error

echo "🚀 Starting macOS terminal setup..."
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_step() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

# Check for Homebrew
print_step "Checking for Homebrew..."
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add brew to path for Apple Silicon
    if [[ $(uname -m) == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    print_success "Homebrew installed"
else
    print_success "Homebrew already installed"
fi

# Update Homebrew
print_step "Updating Homebrew..."
brew update
print_success "Homebrew updated"

# Install core utilities
print_step "Installing core terminal tools..."
brew install \
    git \
    curl \
    wget \
    stow
print_success "Core utilities installed"

# Install Zsh (macOS has zsh by default, but ensure latest)
print_step "Installing/updating Zsh..."
brew install zsh
print_success "Zsh installed"

# Install Oh My Zsh
print_step "Installing Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    print_success "Oh My Zsh installed"
else
    print_success "Oh My Zsh already installed"
fi

# Install Zsh plugins
print_step "Installing Zsh plugins..."
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
fi

if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
fi
print_success "Zsh plugins installed"

# Install terminal tools via Homebrew
print_step "Installing terminal tools..."
brew install \
    starship \
    fzf \
    zoxide \
    ripgrep \
    fd \
    bat \
    eza \
    tree \
    htop \
    tmux \
    neovim \
    lazygit \
    zellij
print_success "Terminal tools installed"

# Setup FZF key bindings
print_step "Setting up FZF..."
if [ -f "$(brew --prefix)/opt/fzf/install" ]; then
    $(brew --prefix)/opt/fzf/install --all --no-bash --no-fish --no-update-rc
fi
print_success "FZF configured"

# Backup existing configs if they exist and aren't symlinks
print_step "Backing up existing configs..."
backup_if_exists() {
    if [ -e "$1" ] && [ ! -L "$1" ]; then
        mv "$1" "$1.backup.$(date +%Y%m%d%H%M%S)"
        echo "  Backed up $1"
    fi
}

backup_if_exists ~/.aliases
backup_if_exists ~/.zshrc
backup_if_exists ~/.config/nvim
backup_if_exists ~/.config/zellij
backup_if_exists ~/.config/starship.toml
backup_if_exists ~/.tmux.conf
backup_if_exists ~/.gitconfig
print_success "Backups complete"

# Stow all configs
print_step "Stowing configurations..."
cd "$HOME/dotfiles"

stow -v aliases 2>&1 | grep -v "^BUG" || true
stow -v zsh 2>&1 | grep -v "^BUG" || true
stow -v nvim 2>&1 | grep -v "^BUG" || true
stow -v zellij 2>&1 | grep -v "^BUG" || true
stow -v starship 2>&1 | grep -v "^BUG" || true
stow -v tmux 2>&1 | grep -v "^BUG" || true
stow -v git 2>&1 | grep -v "^BUG" || true
stow -v local 2>&1 | grep -v "^BUG" || true

print_success "Dotfiles stowed successfully"

# Change default shell to brew's zsh if not already
print_step "Setting Zsh as default shell..."
BREW_ZSH="$(brew --prefix)/bin/zsh"
if [ "$SHELL" != "$BREW_ZSH" ]; then
    # Add brew zsh to allowed shells if not present
    if ! grep -q "$BREW_ZSH" /etc/shells; then
        echo "$BREW_ZSH" | sudo tee -a /etc/shells
    fi
    chsh -s "$BREW_ZSH"
    print_success "Default shell changed to Zsh (restart terminal)"
else
    print_success "Zsh already default shell"
fi

echo ""
echo -e "${GREEN}🎉 macOS setup complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Restart your terminal for changes to take effect"
echo "2. Configure Powerlevel10k by running: p10k configure"
echo "3. Start using your terminal setup!"
echo ""
echo "Useful commands:"
echo "  - zellij: Terminal multiplexer"
echo "  - lazygit: Git TUI"
echo "  - fzf: Fuzzy finder (Ctrl+R for history search)"
echo "  - bat: Better cat with syntax highlighting"
echo "  - eza: Better ls"
echo ""
