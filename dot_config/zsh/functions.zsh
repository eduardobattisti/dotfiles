# Custom functions

function open() {
  (xdg-open "${1:-.}" >/dev/null 2>&1 &)
}

# Auto-switch node version when entering a directory with .nvmrc
function auto_nvm() {
  [[ -f .nvmrc ]] && nvm use
}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd auto_nvm
