# Dotfiles

My terminal configuration managed with [GNU Stow](https://www.gnu.org/software/stow/).

## 📦 What's Included

- **zsh**: Shell configuration with Oh My Zsh, plugins, and custom functions
- **nvim**: Neovim configuration with plugins
- **zellij**: Terminal multiplexer configuration with custom layouts
- **starship**: Cross-shell prompt configuration
- **tmux**: Terminal multiplexer configuration
- **git**: Git configuration
- **local**: Local bin scripts and environment setup

## 🚀 Quick Setup on VPS

### Automated Installation

```bash
# Clone this repository
git clone <your-repo-url> ~/dotfiles

# Run the automated setup script
cd ~/dotfiles
chmod +x vps-setup.sh
./vps-setup.sh
```

The script will:
- Install all required tools (zsh, neovim, zellij, starship, fzf, zoxide, etc.)
- Install Oh My Zsh with plugins
- Stow all configurations
- Set zsh as default shell

### Manual Installation

If you prefer manual control:

```bash
# 1. Install prerequisites
sudo apt update
sudo apt install -y git stow zsh neovim

# 2. Clone this repository
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles

# 3. Stow the configurations you want
stow zsh
stow nvim
stow zellij
stow starship
stow tmux
stow git
stow local

# 4. Install additional tools (see Tools section below)
```

## 🛠️ Tools Installed

### Core
- **zsh** - Shell
- **oh-my-zsh** - Zsh framework
- **starship** - Prompt
- **neovim** - Text editor

### Terminal Enhancement
- **zellij** - Terminal multiplexer
- **tmux** - Alternative multiplexer
- **fzf** - Fuzzy finder
- **zoxide** - Smart cd

### CLI Tools
- **ripgrep** - Fast grep
- **bat** - Better cat with syntax highlighting
- **eza** - Better ls with colors
- **lazygit** - Git TUI
- **tree** - Directory visualization
- **htop** - Process monitor

## 📝 Usage

### Stow Commands

```bash
# Stow a specific config
cd ~/dotfiles
stow <package-name>

# Example: stow nvim

# Unstow a config
stow -D <package-name>

# Restow (useful after updates)
stow -R <package-name>

# Stow everything at once
stow */
```

### Updating Configs

```bash
# Pull latest changes
cd ~/dotfiles
git pull

# Restow to apply updates
stow -R zsh nvim zellij starship
```

## 🎨 Customization

### Adding New Configs

1. Create a new directory in `~/dotfiles/`
2. Mirror the home directory structure inside it
   ```
   ~/dotfiles/myapp/
   └── .config/
       └── myapp/
           └── config.yml
   ```
3. Stow it: `stow myapp`

### Modifying Existing Configs

Since configs are symlinked, you can edit them in place:

```bash
# Edit the actual file (via symlink)
nvim ~/.zshrc

# Or edit directly in the repo
nvim ~/dotfiles/zsh/.zshrc

# Commit changes
cd ~/dotfiles
git add .
git commit -m "Update zsh config"
git push
```

## 🔧 Troubleshooting

### Stow Conflicts

If stow reports conflicts:

```bash
# Option 1: Backup existing files
mv ~/.zshrc ~/.zshrc.backup
stow zsh

# Option 2: Force adoption (use with caution)
stow --adopt zsh
git checkout .  # Restore original if needed
```

### Missing Dependencies

If a tool isn't working:

```bash
# Check if installed
which <tool-name>

# Install manually (Ubuntu/Debian)
sudo apt install <tool-name>

# Or use the setup script to reinstall everything
./vps-setup.sh
```

## 📚 Resources

- [GNU Stow Manual](https://www.gnu.org/software/stow/manual/)
- [Managing Dotfiles with GNU Stow](https://www.josean.com/posts/how-to-manage-dotfiles-with-gnu-stow)
- [Oh My Zsh](https://ohmyz.sh/)
- [Starship Prompt](https://starship.rs/)

## 📄 License

Personal dotfiles - feel free to use as reference or fork for your own setup.
