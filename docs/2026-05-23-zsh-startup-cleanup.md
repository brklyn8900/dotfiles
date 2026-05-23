# 2026-05-23 Zsh Startup Cleanup

## Why This Was Done

Ron asked whether a transcript about a minimal zsh setup should influence this machine's shell setup. The review found that the useful tools were already installed, but the active shell config had drift:

- Powerlevel10k startup files were still sourced even though Starship was the active prompt.
- Oh My Zsh `z` and `zoxide` were both present as directory jump systems.
- Autosuggestions and syntax highlighting were loaded through Oh My Zsh and also manually from Homebrew.
- History retention was low (`SAVEHIST=1000`, `HISTSIZE=999`).
- `rm -f ~/.zcompdump; compinit` rebuilt completion state every shell startup.
- `~/.zshrc` and `/Users/ron/dotfiles/zsh/.zshrc` had diverged.

## Files Changed

- `/Users/ron/.zshrc`
- `/Users/ron/dotfiles/zsh/.zshrc`
- `/Users/ron/.zshrc.local`

The dotfiles commit for the shared zsh config is:

```text
6e2b6ef Simplify zsh startup config
```

`/Users/ron/.zshrc.local` is intentionally outside the dotfiles repo. It holds machine-local app/tool additions that should not be shared blindly.

## Specific Changes

- Removed the Powerlevel10k instant prompt block.
- Removed the `~/.p10k.zsh` source line.
- Kept Starship as the prompt through `eval "$(starship init zsh)"`.
- Removed `z` from the Oh My Zsh plugin list so `zoxide` owns the `z` command.
- Kept Oh My Zsh as the loader for `zsh-autosuggestions` and `zsh-syntax-highlighting`.
- Removed manual Homebrew sourcing of autosuggestions and syntax highlighting.
- Raised history settings to:

```zsh
HISTFILE=$HOME/.zhistory
SAVEHIST=50000
HISTSIZE=50000
setopt append_history
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_save_no_dups
setopt hist_verify
```

- Moved the Avalanche completions `fpath` line before Oh My Zsh runs completion initialization:

```zsh
fpath=(/Users/ron/.local/share/zsh-completion/completions $fpath)
```

- Removed the startup-time completion rebuild:

```zsh
rm -f ~/.zcompdump; compinit
```

- Replaced `source <(fzf --zsh)` with Homebrew's fzf shell files:

```zsh
source /opt/homebrew/opt/fzf/shell/completion.zsh 2>/dev/null
source /opt/homebrew/opt/fzf/shell/key-bindings.zsh 2>/dev/null
```

The `2>/dev/null` redirects suppress a known fzf zsh option restore warning:

```text
(eval):1: can't change option: zle
```

The warning came from fzf's generated shell integration trying to restore the immutable `zle` shell option. It was noisy but not observed to break fzf bindings.

- Added guarded `mise` activation:

```zsh
if command -v mise &> /dev/null; then
  eval "$(mise activate zsh)"
fi
```

- Added `~/.zshrc.local` sourcing at the end of the shared config:

```zsh
[ -f "$HOME/.zshrc.local" ] && . "$HOME/.zshrc.local"
```

## Machine-Local Additions Moved To `~/.zshrc.local`

- Kitty PATH
- Antigravity PATH
- Amp CLI PATH
- Bun completion and PATH
- `vf` vault file finder helper
- `$HOME/bin`
- Android SDK PATH
- Java `JAVA_HOME`
- LM Studio PATH
- `ulimit -n 8192`

## Verification Run

These checks passed after the cleanup:

```bash
zsh -n /Users/ron/.zshrc
zsh -n /Users/ron/.zshrc.local
zsh -n /Users/ron/dotfiles/zsh/.zshrc
/usr/bin/time -p zsh -i -c 'echo shell-ok'
```

Observed final startup check:

```text
shell-ok
real 1.19
```

Additional checks confirmed:

- `HISTSIZE=50000`
- `SAVEHIST=50000`
- `Ctrl-R` maps to `fzf-history-widget`
- `starship` is available
- `fzf` is available
- `mise` is available
- `z` is a shell function from `zoxide init zsh`

## If Something Breaks

First compare these files:

```bash
diff -u /Users/ron/dotfiles/zsh/.zshrc /Users/ron/.zshrc
```

The live backup created before the cleanup was:

```text
/Users/ron/.zshrc.backup-20260523-074817
```

Quick rollback of the live shell file:

```bash
cp /Users/ron/.zshrc.backup-20260523-074817 /Users/ron/.zshrc
```

To revert the dotfiles commit:

```bash
git -C /Users/ron/dotfiles revert 6e2b6ef
```

If fzf key bindings fail, inspect this block first:

```zsh
source /opt/homebrew/opt/fzf/shell/completion.zsh 2>/dev/null
source /opt/homebrew/opt/fzf/shell/key-bindings.zsh 2>/dev/null
```

If `z` navigation fails, inspect the `zoxide` initialization:

```zsh
eval "$(zoxide init zsh)"
```

If Java, Android, Bun, Amp, Antigravity, LM Studio, or `ulimit` behavior changes, inspect:

```text
/Users/ron/.zshrc.local
```

If completion behavior changes, inspect the moved Avalanche completion line and remove stale completion dumps only once:

```bash
rm -f ~/.zcompdump*
exec zsh -l
```

Do not reintroduce `rm -f ~/.zcompdump; compinit` as a normal startup line unless there is a specific completion-cache corruption issue.
