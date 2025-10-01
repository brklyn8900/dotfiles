#!/bin/bash
# VPS Terminal Setup Script
# This script installs all necessary tools and deploys dotfiles using GNU Stow

set -e  # Exit on error

echo "🚀 Starting VPS terminal setup..."
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

# Update system
print_step "Updating system packages..."
sudo apt update && sudo apt upgrade -y
print_success "System updated"

# Install core utilities
print_step "Installing core terminal tools..."
sudo apt install -y \
    git \
    curl \
    wget \
    build-essential \
    software-properties-common \
    stow \
    unzip
print_success "Core utilities installed"

# Install Zsh
print_step "Installing Zsh..."
sudo apt install -y zsh
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

# Install Starship prompt
print_step "Installing Starship..."
if ! command -v starship &> /dev/null; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y
    print_success "Starship installed"
else
    print_success "Starship already installed"
fi

# Install FZF (fuzzy finder)
print_step "Installing FZF..."
if [ ! -d "$HOME/.fzf" ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all --no-bash --no-fish
    print_success "FZF installed"
else
    print_success "FZF already installed"
fi

# Install Zoxide (smart cd)
print_step "Installing Zoxide..."
if ! command -v zoxide &> /dev/null; then
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    print_success "Zoxide installed"
else
    print_success "Zoxide already installed"
fi

# Install additional tools
print_step "Installing additional terminal tools..."
sudo apt install -y \
    ripgrep \
    fd-find \
    tree \
    htop \
    tmux \
    neovim
print_success "Additional tools installed"

# Install bat (better cat)
print_step "Installing bat..."
sudo apt install -y bat
# Create symlink if bat is installed as batcat
if command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
    mkdir -p ~/.local/bin
    ln -sf /usr/bin/batcat ~/.local/bin/bat
fi
print_success "Bat installed"

# Install eza (better ls) from latest release
print_step "Installing eza..."
if ! command -v eza &> /dev/null; then
    EZA_VERSION=$(curl -s https://api.github.com/repos/eza-community/eza/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
    wget -q "https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz" -O /tmp/eza.tar.gz
    sudo tar -xzf /tmp/eza.tar.gz -C /usr/local/bin
    rm /tmp/eza.tar.gz
    print_success "Eza installed"
else
    print_success "Eza already installed"
fi

# Install Zellij (terminal multiplexer)
print_step "Installing Zellij..."
if ! command -v zellij &> /dev/null; then
    wget -q "https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-unknown-linux-musl.tar.gz" -O /tmp/zellij.tar.gz
    sudo tar -xzf /tmp/zellij.tar.gz -C /usr/local/bin
    rm /tmp/zellij.tar.gz
    print_success "Zellij installed"
else
    print_success "Zellij already installed"
fi

# Install LazyGit (optional but useful)
print_step "Installing LazyGit..."
if ! command -v lazygit &> /dev/null; then
    LAZYGIT_VERSION=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
    wget -q "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" -O /tmp/lazygit.tar.gz
    sudo tar -xzf /tmp/lazygit.tar.gz -C /usr/local/bin lazygit
    rm /tmp/lazygit.tar.gz
    print_success "LazyGit installed"
else
    print_success "LazyGit already installed"
fi

# Clone and setup dotfiles
print_step "Setting up dotfiles..."
if [ ! -d "$HOME/dotfiles" ]; then
    read -p "Enter your dotfiles git repository URL: " DOTFILES_REPO
    git clone "$DOTFILES_REPO" "$HOME/dotfiles"
    cd "$HOME/dotfiles"

    # Stow all configs
    print_step "Stowing configurations..."
    stow zsh
    stow nvim
    stow zellij
    stow starship
    stow tmux
    stow git
    stow local

    print_success "Dotfiles stowed successfully"
else
    print_success "Dotfiles directory already exists"
fi

# Change default shell to zsh
print_step "Setting Zsh as default shell..."
if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s $(which zsh)
    print_success "Default shell changed to Zsh (restart required)"
else
    print_success "Zsh already default shell"
fi

echo ""
echo -e "${GREEN}🎉 VPS setup complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Log out and log back in (or restart) for shell changes to take effect"
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
