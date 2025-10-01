# Dotfiles Setup Progress Log

**Date**: October 1, 2025
**Goal**: Replicate Mac terminal setup on Ubuntu VPS using GNU Stow

---

## ✅ Completed Tasks

### 1. Mac Setup - Dotfiles Repository Created
- **Location**: `~/dotfiles/`
- **Structure**:
  ```
  ~/dotfiles/
  ├── .git/                  # Git repository
  ├── .stow-local-ignore     # Files to exclude from stowing
  ├── README.md              # Complete documentation
  ├── vps-setup.sh          # Automated VPS setup script
  ├── zsh/                   # .zshrc, .aliases, .p10k.zsh
  ├── nvim/                  # .config/nvim/
  ├── zellij/                # .config/zellij/
  ├── starship/              # .config/starship.toml
  ├── tmux/                  # .config/tmux/
  ├── git/                   # .config/git/
  └── local/                 # .local/bin/env
  ```

### 2. Git Repository Setup
- ✅ Initialized git repo in `~/dotfiles/`
- ✅ All configs committed
- ✅ Pushed to GitHub: `https://github.com/brklyn8900/dotfiles.git`
- ✅ SSH authentication configured (using `git@github.com:brklyn8900/dotfiles.git`)

### 3. Tools & Configuration
**Installed on Mac**:
- ✅ GNU Stow (`brew install stow`)
- ✅ Tested stow functionality - symlinks working correctly

**Configs Backed Up**:
- ✅ Zsh (shell config, aliases, powerlevel10k)
- ✅ Neovim (complete lua config with plugins)
- ✅ Zellij (multiplexer with custom layouts)
- ✅ Starship (prompt configuration)
- ✅ Tmux (multiplexer config)
- ✅ Git (ignore rules)
- ✅ Local bin scripts

### 4. VPS Setup Script Created
**File**: `~/dotfiles/vps-setup.sh`

**What it installs**:
- Core: git, curl, wget, build-essential, stow
- Shell: zsh, oh-my-zsh
- Zsh plugins: zsh-autosuggestions, zsh-syntax-highlighting
- Zsh theme: powerlevel10k
- Prompt: starship
- Multiplexers: zellij, tmux
- CLI tools: fzf, zoxide, ripgrep, bat, eza, lazygit, tree, htop
- Editor: neovim

**What it does**:
1. Updates system packages
2. Installs all tools
3. Clones dotfiles repo
4. Stows all configurations
5. Sets zsh as default shell

---

## 🚧 In Progress / Issues

### VPS Setup Status
- ✅ Script running on VPS
- ⚠️ **Encountered**: SSH config prompt during `apt upgrade`
  - **Prompt**: "What to do about modified configuration file sshd_config?"
  - **Recommended**: "keep the local version currently installed" (to preserve working SSH)

- ⚠️ **Issue**: Starship prompt not showing after setup
  - **Cause**: Need to verify starship initialization in .zshrc
  - **Line 298 of .zshrc**: `eval "$(starship init zsh)"`

---

## 🔍 Troubleshooting Guide

### Starship Prompt Not Showing

**Check if starship is installed**:
```bash
which starship
starship --version
```

**Check if it's initialized in .zshrc**:
```bash
grep "starship init" ~/.zshrc
```

**Manual fix**:
```bash
# Ensure starship is in PATH
echo 'eval "$(starship init zsh)"' >> ~/.zshrc
source ~/.zshrc
```

**Check symlinks**:
```bash
ls -la ~/.zshrc
ls -la ~/.config/starship.toml
# Should point to ~/dotfiles/
```

### Verify Stow Setup

**Check what's stowed**:
```bash
cd ~/dotfiles
ls -la ~/ | grep " -> "
ls -la ~/.config/ | grep " -> "
```

**Re-stow if needed**:
```bash
cd ~/dotfiles
stow -R zsh starship
source ~/.zshrc
```

### Common Issues

**1. Config not loading**
```bash
# Check symlinks exist
ls -la ~/.zshrc ~/.aliases ~/.config/starship.toml

# If broken, restow
cd ~/dotfiles
stow -R zsh starship
```

**2. Tool not found**
```bash
# Check if installed
which <tool-name>

# If missing, install manually or re-run setup script
./vps-setup.sh
```

**3. Oh-My-Zsh conflicts**
```bash
# If oh-my-zsh was pre-installed, it might conflict
# Check if ZSH variable is set
echo $ZSH

# Should be: /home/<user>/.oh-my-zsh
```

---

## 📋 Next Steps

### Immediate (On VPS)

1. **Resolve SSH config prompt**
   - Choose "keep the local version currently installed"
   - Let script continue

2. **Fix Starship prompt**
   ```bash
   # After script completes, verify:
   which starship
   grep "starship init" ~/.zshrc

   # Test
   source ~/.zshrc

   # If still not working:
   cd ~/dotfiles
   stow -R starship
   source ~/.zshrc
   ```

3. **Verify all symlinks**
   ```bash
   ls -la ~/ | grep " -> "
   ls -la ~/.config/ | grep " -> "
   ```

4. **Test all tools**
   ```bash
   zsh --version
   nvim --version
   zellij --version
   starship --version
   fzf --version
   zoxide --version
   ```

5. **Configure Powerlevel10k** (if using it instead of starship)
   ```bash
   p10k configure
   ```

### Future Maintenance

**Updating configs**:
```bash
# On Mac: Edit configs in place (they're symlinked)
nvim ~/.zshrc

# Commit and push
cd ~/dotfiles
git add .
git commit -m "Update zsh config"
git push

# On VPS: Pull updates
cd ~/dotfiles
git pull
stow -R zsh  # Restow if needed
source ~/.zshrc
```

**Adding new configs**:
```bash
# On Mac
cd ~/dotfiles
mkdir newapp
mkdir -p newapp/.config/newapp
cp ~/.config/newapp/* newapp/.config/newapp/

# Stow it
stow newapp

# Commit
git add .
git commit -m "Add newapp config"
git push

# On VPS: Pull and stow
cd ~/dotfiles
git pull
stow newapp
```

---

## 🛠️ System Architecture

### How GNU Stow Works

```
~/dotfiles/zsh/.zshrc  ←--[symlink]--  ~/.zshrc
~/dotfiles/nvim/.config/nvim/  ←--[symlink]--  ~/.config/nvim/
```

**Key Points**:
- Configs live in `~/dotfiles/`
- Stow creates symlinks from home directory to dotfiles
- Edit either the symlink or the original - they're the same file
- Changes can be committed and pushed immediately
- Pull on other machines to sync configs

### Directory Structure Explained

Each package directory mirrors the home directory structure:

```
~/dotfiles/zsh/
├── .zshrc           # Will be linked to ~/.zshrc
├── .aliases         # Will be linked to ~/.aliases
└── .p10k.zsh       # Will be linked to ~/.p10k.zsh

~/dotfiles/starship/
└── .config/
    └── starship.toml  # Will be linked to ~/.config/starship.toml
```

When you run `stow zsh`, it creates:
- `~/.zshrc` → `~/dotfiles/zsh/.zshrc`
- `~/.aliases` → `~/dotfiles/zsh/.aliases`
- `~/.p10k.zsh` → `~/dotfiles/zsh/.p10k.zsh`

---

## 📝 Important Files Reference

### Configuration Files
- **Shell**: `~/dotfiles/zsh/.zshrc` - Main zsh configuration
- **Aliases**: `~/dotfiles/zsh/.aliases` - All custom aliases and functions
- **Prompt**: `~/dotfiles/starship/.config/starship.toml` - Starship theme
- **Editor**: `~/dotfiles/nvim/.config/nvim/init.lua` - Neovim entry point
- **Multiplexer**: `~/dotfiles/zellij/.config/zellij/config.kdl` - Zellij config

### Setup Files
- **VPS Script**: `~/dotfiles/vps-setup.sh` - Automated installation
- **Docs**: `~/dotfiles/README.md` - Complete documentation
- **Ignore**: `~/dotfiles/.stow-local-ignore` - Files to exclude from stowing

### Key Aliases (from .aliases)
```bash
v='nvim'                    # Quick nvim
n="nvim ."                  # Open nvim in current dir
l='ls -lha'                 # Better ls
gs='git status'             # Git status
zd='zellij --layout ...'    # Zellij with custom layout
ez='eza --git -lh'          # Better ls with eza
```

---

## 🔄 Workflow Summary

### Development Flow
1. **Make changes** on Mac (edit configs directly or via symlinks)
2. **Test locally** to verify changes work
3. **Commit and push** from `~/dotfiles/`
4. **Pull on VPS** and restow if needed
5. **Source config** to apply changes

### Adding New Machine
1. **Install stow**: `brew install stow` (Mac) or `apt install stow` (Linux)
2. **Clone repo**: `git clone git@github.com:brklyn8900/dotfiles.git ~/dotfiles`
3. **Run setup** (VPS): `./vps-setup.sh`
4. **Or stow manually** (Mac): `cd ~/dotfiles && stow zsh nvim zellij starship`

---

## 📊 Tools Inventory

### Already Installed (Mac)
- zsh, oh-my-zsh, powerlevel10k
- neovim with lua config
- zellij with custom layouts
- starship prompt
- fzf, zoxide, ripgrep, bat, eza
- tmux, lazygit, tree, htop
- git, gh (GitHub CLI)

### Installing on VPS (via script)
- All of the above + build tools
- GNU Stow for symlinking

### Desktop-only (NOT for VPS)
- ghostty, iterm2 (terminal emulators)
- zed, cursor, windsurf (editors)
- aerospace, raycast (window managers)
- Docker Desktop
- Flutter, Dart, Solana toolchains

---

## 🎯 Success Criteria

### Mac (✅ Complete)
- [x] Dotfiles organized with GNU Stow structure
- [x] Git repository initialized and pushed to GitHub
- [x] SSH authentication configured
- [x] Setup script created
- [x] Documentation written
- [x] Stow tested and working

### VPS (🚧 In Progress)
- [🚧] VPS setup script running
- [ ] All tools installed and working
- [ ] Starship prompt displaying correctly
- [ ] All symlinks created properly
- [ ] Shell defaults to zsh
- [ ] Can edit configs and push changes
- [ ] Neovim plugins working

---

## 💡 Tips & Best Practices

1. **Always commit before major changes**
   ```bash
   cd ~/dotfiles
   git add .
   git commit -m "Backup before experiment"
   ```

2. **Test stow in dry-run mode first**
   ```bash
   stow -n <package>  # Shows what would happen
   ```

3. **Use stow -R to restow after updates**
   ```bash
   cd ~/dotfiles
   git pull
   stow -R zsh nvim zellij starship
   ```

4. **Keep machine-specific configs separate**
   - Don't commit absolute paths that differ between machines
   - Use environment variables or conditionals in configs

5. **Backup before stowing on new machine**
   ```bash
   cp ~/.zshrc ~/.zshrc.backup
   ```

---

## 🔗 Resources

- **Dotfiles Repo**: https://github.com/brklyn8900/dotfiles
- **GNU Stow Manual**: https://www.gnu.org/software/stow/manual/
- **Original Guide**: https://www.josean.com/posts/how-to-manage-dotfiles-with-gnu-stow
- **Starship Docs**: https://starship.rs/
- **Oh My Zsh**: https://ohmyz.sh/

---

## 📞 Quick Reference Commands

```bash
# Stow operations
cd ~/dotfiles
stow <package>           # Stow a package
stow -D <package>        # Unstow a package
stow -R <package>        # Restow (remove and add)
stow -n <package>        # Dry run (simulation)

# Git operations
git add .
git commit -m "message"
git push
git pull

# Verify setup
ls -la ~/ | grep " -> "                    # Check home symlinks
ls -la ~/.config/ | grep " -> "            # Check .config symlinks
which starship nvim zellij fzf zoxide      # Check if tools installed

# Reload configs
source ~/.zshrc                            # Reload zsh config
exec zsh                                   # Restart zsh
```

---

**Status**: In progress - VPS setup script running, troubleshooting starship prompt issue.
