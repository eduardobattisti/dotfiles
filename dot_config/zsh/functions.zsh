# Custom functions

# Open a file, directory or URL with the platform opener (macOS, Linux, WSL).
function open() {
  if (( $+commands[dotfiles-open] )); then
    command dotfiles-open "${1:-.}" >/dev/null 2>&1 &!
  else
    print -u2 "dotfiles-open not found in PATH"
    return 1
  fi
}

# Auto-switch node version when entering a directory with .nvmrc
function auto_nvm() {
  [[ -f .nvmrc ]] && nvm use
}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd auto_nvm
