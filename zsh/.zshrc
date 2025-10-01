# =============================================================================
# POWERLEVEL10K INSTANT PROMPT (Keep at top)
# =============================================================================
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# =============================================================================
# CORE PATH SETUP
# =============================================================================
# Base PATH setup
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# Homebrew (Mac only)
if [[ "$OSTYPE" == "darwin"* ]]; then
  export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
fi

# =============================================================================
# OH-MY-ZSH CONFIGURATION
# =============================================================================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""  # Disabled to use Starship

# Plugins
plugins=(z git zsh-autosuggestions zsh-syntax-highlighting sudo)

source $ZSH/oh-my-zsh.sh

# =============================================================================
# SSL/OPENSSL CONFIGURATION (Mac only)
# =============================================================================
if [[ "$OSTYPE" == "darwin"* ]]; then
  export PATH="/opt/homebrew/opt/openssl@3/bin:$PATH"
  export LDFLAGS="-L/opt/homebrew/opt/openssl@3/lib"
  export CPPFLAGS="-I/opt/homebrew/opt/openssl@3/include"
  export PKG_CONFIG_PATH="/opt/homebrew/opt/openssl@3/lib/pkgconfig"
  export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@3)"
fi

# =============================================================================
# GPG CONFIGURATION
# =============================================================================
# Required for GPG signing to work properly in terminal
export GPG_TTY=$(tty)

# =============================================================================
# NODE.JS ENVIRONMENT
# =============================================================================
# n configuration
export N_PREFIX="$HOME/.n"
export PATH="$N_PREFIX/bin:$PATH"

# Node 16 environment setup
export NPM_GLOBAL_NODE16="$HOME/.npm-global-node16"
n16() {
    n 16
    export PATH="$HOME/.npm-global-node16/bin:$PATH"
    hash -r
    echo "Switched to Node $(node -v)"
}

# nvm configuration
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# pnpm configuration
if [[ "$OSTYPE" == "darwin"* ]]; then
  export PNPM_HOME="$HOME/Library/pnpm"
else
  export PNPM_HOME="$HOME/.local/share/pnpm"
fi
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# =============================================================================
# RUBY ENVIRONMENT
# =============================================================================
# rbenv configuration
if command -v rbenv >/dev/null 2>&1; then
  eval "$(rbenv init -)"
fi

# =============================================================================
# PYTHON ENVIRONMENT
# =============================================================================
if [[ "$OSTYPE" == "darwin"* ]]; then
  export PATH="/opt/homebrew/opt/python@3.11/libexec/bin:$PATH"
  export PATH="$HOME/Library/Python/3.11/bin:$PATH"
else
  export PATH="$HOME/.local/bin:$PATH"
fi

# =============================================================================
# DEVELOPMENT TOOLS & FRAMEWORKS (Mac only)
# =============================================================================
if [[ "$OSTYPE" == "darwin"* ]]; then
  # Flutter & Dart
  export PATH="/opt/homebrew/opt/dart/libexec:$PATH"
  [ -d "$HOME/flutter" ] && export PATH="$HOME/flutter/bin:$PATH"

  # Sphinx documentation
  export PATH="/opt/homebrew/opt/sphinx-doc/bin:$PATH"

  # Windsurf
  [ -d "$HOME/.codeium/windsurf" ] && export PATH="$HOME/.codeium/windsurf/bin:$PATH"

  # Docker
  [ -d "/Applications/Docker.app" ] && export PATH="$PATH:/Applications/Docker.app/Contents/Resources/bin"

  # PostgreSQL
  export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"
fi

# Cross-platform tools
# Solana
[ -d "$HOME/.local/share/solana" ] && export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"

# Foundry
[ -d "$HOME/.foundry" ] && export PATH="$HOME/.foundry/bin:$PATH"

# Rust/Cargo
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# Custom tools (Mac only)
if [[ "$OSTYPE" == "darwin"* ]]; then
  [ -d "$HOME/devstuff/wallets/testenet" ] && export PATH="$HOME/devstuff/wallets/testenet:$PATH"
fi

# =============================================================================
# CUSTOM FUNCTIONS
# =============================================================================
check_env() {
  if [ -z "$1" ]; then
    echo "Error: check_env requires a parameter" >&2
    return 1
  fi

  if [[ ! -f .env ]]; then
    echo "Error: .env file not found" >&2
    return 1
  fi

  # Get the value using grep, removing comments and extracting the value after =
  value=$(grep "^$1=" .env | sed 's/^[^=]*=//')

  if [[ -z "$value" ]]; then
    echo "Error: $1 not set in .env" >&2
    return 1
  fi

  echo "$value"
  return 0
}

curr_dir() {
  basename "$PWD"
  return $?
}

get_app() {
  local prod_app=$(check_env "PROD_APP") && local staging_app=$(check_env "STAGING_APP") || return 1
  case "$1" in
    "staging") echo "$staging_app" ;;
    *) echo "$prod_app" ;;
  esac
}

get_db_name() {
  case "$1" in
    "staging") echo "$(curr_dir)_staging" ;;
    "production") echo "$(curr_dir)_production" ;;
    *) echo "$(curr_dir)_development" ;;
  esac
}

shell() {
  local app=$(get_app "$1") || return 1
  setenv "$1"
  heroku run bash -a "$app"
  graytab
  return $?
}

logs() {
  if [ -z "$1" ] && [[ -f "log/development.log" ]]; then
    tail -F log/development.log
    return $?
  else
    local app=$(get_app "$1") || return 1
    setenv "$1"
    heroku logs --tail -a "$app"
    graytab
    return $?
  fi
}

ttp() {
  local app=$(get_app production) || return 1
  setenv production
  heroku logs --tail -a "$app"
  graytab
  return $?
}

tts() {
  local app=$(get_app staging) || return 1
  setenv staging
  heroku logs --tail -a "$app"
  graytab
  return $?
}

tt() {
  logs "$1"
}

alias releases='        local app=$(get_app) || return 1; heroku releases -a "$app"'

# FZF initialization
if command -v fzf &> /dev/null; then
  if [[ "$OSTYPE" == "darwin"* ]]; then
    source <(fzf --zsh)
  else
    [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
  fi
fi

#-------------------------------------------------------------------------------
# 10. TERMINAL APPEARANCE
#-------------------------------------------------------------------------------
# Make tab red
redtab() {
  graytab
  echo -ne '\033]6;1;bg;red;brightness;255\a'
  return 0
}

# Make tab orange
orangetab() {
  graytab
  echo -ne '\033]6;1;bg;red;brightness;255\a'
  echo -ne '\033]6;1;bg;green;brightness;165\a'
  echo -ne '\033]6;1;bg;blue;brightness;0\a'
  return 0
}

# Make tab black/default
graytab() {
  echo -ne "\033]6;1;bg;*;default\a"
  return 0
}

setenv() {
  [ "$1" = "production" ] && redtab
  [ "$1" = "staging" ] && orangetab
  return 0
}

# rtl() {
#   local app=$(get_app "production") || return 1

#   # Get database name
#   local db_name="$(get_db_name)"

#   # Force drop the database using our custom rake task
#   echo "Dropping database $db_name..."
#   DISABLE_DATABASE_ENVIRONMENT_CHECK=1 rails db:force_drop

#   # Use direct pg_dump and pg_restore approach to avoid heroku pg:pull database creation issues
#   echo "Dumping database from $app..."
#   local heroku_db_url=$(heroku config:get DATABASE_URL -a "$app")
#   local temp_dump="/tmp/${db_name}_restore.dump"

#   # Dump from Heroku
#   pg_dump "$heroku_db_url" --no-owner --no-acl -F c -f "$temp_dump" || {
#     echo "Failed to dump from Heroku";
#     return 1;
#   }

#     # Create local database
#   echo "Creating local database..."
#   createdb -U "$USER" "$db_name" || { echo "Failed to create database"; return 1; }

#   # Restore to local database
#   echo "Restoring to local database..."
#   pg_restore --no-owner --no-acl -d "$db_name" "$temp_dump" && {
#     echo "Database restore completed successfully!"
#     rm -f "$temp_dump"
#     return 0
#   } || {
#     echo "Database restore failed."
#     rm -f "$temp_dump"
#     return 1
#   }
# }

# =============================================================================
# ALIASES
# =============================================================================
if [ -f ~/.aliases ]; then
    . ~/.aliases
fi

# =============================================================================
# FINAL INITIALIZATION
# =============================================================================
# Local environment
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

# Powerlevel10k configuration (Mac only, optional)
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export GPG_TTY=$(tty)

# Zoxide initialization
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi

# Starship prompt initialization
if command -v starship &> /dev/null; then
  eval "$(starship init zsh)"
fi
