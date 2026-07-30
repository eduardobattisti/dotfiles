# Custom functions

function open() {
  local opener
  case "$OSTYPE" in
    darwin*) opener="open" ;;
    *) opener="xdg-open" ;;
  esac

  if command -v "$opener" >/dev/null 2>&1; then
    command "$opener" "${1:-.}" >/dev/null 2>&1 &
  else
    print -u2 "No supported file opener found"
    return 1
  fi
}

# Auto-switch node version when entering a directory with .nvmrc
function auto_nvm() {
  [[ -f .nvmrc ]] && nvm use
}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd auto_nvm
