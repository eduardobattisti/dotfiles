# Chezmoi Dotfiles Configuration

This repository contains my personal dotfiles managed with [chezmoi](https://www.chezmoi.io/), a tool for managing your dotfiles across multiple diverse machines securely.

## 📁 Structure

```
~/.local/share/chezmoi/
├── dot_bashrc                    # Bash shell configuration
├── dot_zshrc                     # Zsh shell configuration with Oh My Zsh
└── dot_config/
    ├── starship.toml             # Starship prompt configuration
    ├── flameshot/                # Screenshot tool configuration
    ├── lazygit/                  # Git TUI configuration
    ├── nvim/                     # Neovim configuration
    ├── private_htop/             # System monitor configuration
    └── wezterm/                  # Terminal emulator configuration
```

## 🛠️ Applications Configured

### Shell & Terminal
- **Zsh**: Configured with Oh My Zsh using the `robbyrussell` theme
- **Bash**: Basic bash configuration
- **Starship**: Custom prompt with programming language indicators and git status
- **WezTerm**: Modern terminal emulator with advanced configuration

### Development Tools
- **Neovim**: Full IDE-like configuration with plugins
- **Git**: LazyGit TUI for enhanced git workflow
- **Node.js**: NVM integration for Node version management
- **Bun**: JavaScript runtime and package manager
- **Python**: Development environment setup

### System Tools
- **htop**: System process viewer (private configuration)
- **Flameshot**: Screenshot tool

### Cloud & Deployment
- **Fly.io**: Flyctl CLI tool integration

## 🚀 Installation

### Prerequisites
- Install [chezmoi](https://www.chezmoi.io/install/)

### Quick Setup
```bash
# Initialize chezmoi with this repository
chezmoi init https://github.com/yourusername/dotfiles.git

# Apply the configuration
chezmoi apply
```

### Manual Setup
```bash
# Clone this repository to your chezmoi source directory
git clone https://github.com/yourusername/dotfiles.git ~/.local/share/chezmoi

# Apply the dotfiles
chezmoi apply
```

## 🎨 Features

### Starship Prompt
- **Custom Format**: Clean, informative prompt with language indicators
- **Git Integration**: Branch and status information
- **Language Support**: Icons and versions for Python, Node.js, Rust, Go, and more
- **Theme**: Uses Catppuccin Frappé color palette
- **Performance**: Shows command duration for commands taking >500ms

### Zsh Configuration
- **Oh My Zsh**: Popular Zsh framework
- **Plugins**: 
  - `git`: Git aliases and functions
  - `zsh-history-substring-search`: Better history searching
- **Integrations**:
  - Starship prompt
  - NVM (Node Version Manager)
  - Bun package manager
  - Fly.io CLI tools

### Development Environment
- **Neovim**: Full configuration with modern plugins
- **Path Management**: Proper PATH setup for various tools
- **Version Managers**: NVM for Node.js versions

## 🔧 Customization

### Modifying Starship
Edit `dot_config/starship.toml` to customize your prompt. The current configuration includes:
- Directory path with custom icons
- Git branch and status
- Programming language versions
- Command execution time
- Custom color palette (Catppuccin Frappé)

### Adding New Configurations
1. Add your dotfile to the chezmoi source directory
2. Use chezmoi's naming convention (e.g., `dot_filename` for `.filename`)
3. Apply changes with `chezmoi apply`

## 📝 Management Commands

```bash
# Check what changes chezmoi would make
chezmoi diff

# Apply all changes
chezmoi apply

# Edit a file in your $EDITOR and apply changes
chezmoi edit ~/.zshrc

# Add a new file to chezmoi
chezmoi add ~/.newconfig

# Update from remote repository
chezmoi update

# See the current status
chezmoi status
```

## 🔒 Security

⚠️ **IMPORTANT SECURITY WARNINGS** ⚠️

### Current Security Issues in This Configuration:

1. **Git Repository Exposure (HIGH RISK)**
   - The `dot_config/nvim/dot_git` directory contains complete git history
   - Personal email addresses and commit information are exposed
   - SSH key fingerprints may be leaked

2. **Personal Information Leakage (MEDIUM RISK)**
   - Hardcoded username paths in shell configurations
   - System-specific installation paths are exposed

3. **Eval Command Usage (LOW-MEDIUM RISK)**
   - Shell configurations use `eval` commands for tool initialization
   - Potential security risk if tools are compromised

### Immediate Actions Required:

```bash
# 1. Remove git directories from chezmoi
rm -rf ~/.local/share/chezmoi/dot_config/nvim/dot_git

# 2. Create .chezmoiignore file
cat << EOF > ~/.local/share/chezmoi/.chezmoiignore
**/.git
**/.git/**
**/logs/
**/.env
**/.env.*
**/node_modules/
**/.DS_Store
EOF

# 3. Use chezmoi templates for personal info
# Replace hardcoded usernames with {{ .chezmoi.username }}
```

### Security Best Practices:

- **Never share this directory publicly** without reviewing all files
- Use **private repositories** for personal dotfiles
- Use `private_` prefix for sensitive configurations
- Use `encrypted_` prefix for files containing secrets
- Store sensitive data in chezmoi templates or external secret managers
- Regularly audit your dotfiles for exposed sensitive information

### Secure Chezmoi Features:

- **Templates**: Use `{{ .chezmoi.username }}` instead of hardcoded usernames
- **Private files**: Use `private_` prefix (like `private_htop/`)
- **Encrypted files**: Use `encrypted_` prefix for secrets
- **Data files**: Store user-specific data in `.chezmoi.yaml` or `.chezmoi.toml`
- **External sources**: Reference external secret managers

## 🤝 Contributing

Feel free to fork this repository and adapt it to your needs. If you have improvements or suggestions, please open an issue or pull request.

## 📚 Resources

- [Chezmoi Documentation](https://www.chezmoi.io/)
- [Starship Documentation](https://starship.rs/)
- [Oh My Zsh](https://ohmyz.sh/)
- [WezTerm Documentation](https://wezfurlong.org/wezterm/)

## 📄 License

This configuration is provided as-is for personal use. Feel free to adapt and modify according to your needs.