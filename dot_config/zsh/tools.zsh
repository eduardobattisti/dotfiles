# Tool initialization

# NVM — lazy loaded for faster startup
export NVM_DIR="$HOME/.nvm"
if [[ -r "$NVM_DIR/nvm.sh" ]]; then
  # Lazy-load nvm: define placeholder functions that load the real nvm on first use
  function nvm() {
    unfunction nvm node npm npx 2>/dev/null
    source "$NVM_DIR/nvm.sh" || return
    [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
    nvm "$@"
  }
  function node() { nvm --version >/dev/null 2>&1; unfunction node 2>/dev/null; command node "$@"; }
  function npm()  { nvm --version >/dev/null 2>&1; unfunction npm 2>/dev/null;  command npm "$@"; }
  function npx()  { nvm --version >/dev/null 2>&1; unfunction npx 2>/dev/null;  command npx "$@"; }

  # Resolve NVM's actual default alias, including lts/* and alias chains.
  # A subshell keeps lazy loading intact while exposing Node to editor subprocesses.
  local default_node cache_file="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/nvm-default"
  local dependency signature="$NVM_DIR" cached_signature
  local -A node_stat
  zmodload zsh/stat
  for dependency in "$NVM_DIR/nvm.sh" "$NVM_DIR/alias"/**/*(.N) "$NVM_DIR/versions/node"/*(/N); do
    zstat -H node_stat -- "$dependency" || continue
    signature+="|$dependency:${node_stat[mtime]}:${node_stat[size]}"
  done
  if [[ -r "$cache_file" ]]; then
    { IFS= read -r cached_signature; IFS= read -r default_node; } < "$cache_file"
  fi
  if [[ "$cached_signature" != "$signature" || ! -x "$default_node" ]]; then
    default_node=$(source "$NVM_DIR/nvm.sh" --no-use && nvm which default 2>/dev/null)
    if [[ -x "$default_node" ]]; then
      mkdir -p -- "${cache_file:h}"
      (umask 077; printf '%s\n%s\n' "$signature" "$default_node" > "${cache_file}.$$" && mv -- "${cache_file}.$$" "$cache_file")
    fi
  fi
  [[ -x "$default_node" ]] && path=("${default_node:h}" $path)
fi

# Starship prompt (should be last — after all PATH and env changes)
if (( $+commands[starship] )); then
  eval "$(starship init zsh)"
fi
