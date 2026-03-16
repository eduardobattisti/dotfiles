# Tool initialization

# NVM — lazy loaded for faster startup
export NVM_DIR="$HOME/.nvm"
if [[ -d "$NVM_DIR" ]]; then
  # Lazy-load nvm: define placeholder functions that load the real nvm on first use
  function nvm() {
    unfunction nvm node npm npx 2>/dev/null
    [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
    [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
    nvm "$@"
  }
  function node() { nvm --version >/dev/null 2>&1; unfunction node 2>/dev/null; command node "$@"; }
  function npm()  { nvm --version >/dev/null 2>&1; unfunction npm 2>/dev/null;  command npm "$@"; }
  function npx()  { nvm --version >/dev/null 2>&1; unfunction npx 2>/dev/null;  command npx "$@"; }

  # Add default node to PATH immediately (avoids lazy-load for simple commands)
  [[ -d "$NVM_DIR/versions/node" ]] && {
    local default_node
    default_node=$(ls -d "$NVM_DIR/versions/node/"* 2>/dev/null | sort -V | tail -1)
    [[ -n "$default_node" ]] && path=("$default_node/bin" $path)
  }
fi

# Bun
export BUN_INSTALL="$HOME/.bun"
[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"

# Fly.io
export FLYCTL_INSTALL="$HOME/.fly"

# Starship prompt (should be last — after all PATH and env changes)
eval "$(starship init zsh)"
