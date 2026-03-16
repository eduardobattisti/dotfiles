# Plugins configuration
# Load order matters: completions → autosuggestions → syntax highlighting

plugins=(
  git
  zsh-history-substring-search
  zsh-autosuggestions
  zsh-syntax-highlighting
)

# Autosuggestions config
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
