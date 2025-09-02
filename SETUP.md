# Chezmoi Dotfiles Setup Guide

This guide will help you set up your dotfiles on a new machine using chezmoi with secure, templated configurations.

## 🚀 Quick Setup (New Machine)

### 1. Install chezmoi
```bash
# Using curl
sh -c "$(curl -fsLS get.chezmoi.io)"

# Or using package manager (Ubuntu/Debian)
sudo apt install chezmoi

# Or using Homebrew (macOS/Linux)
brew install chezmoi
```

### 2. Initialize with this repository
```bash
# Replace with your actual repository URL
chezmoi init https://github.com/yourusername/dotfiles.git
```

### 3. Review what will be applied
```bash
chezmoi diff
```

### 4. Apply the configuration
```bash
chezmoi apply
```

During the first run, chezmoi will prompt you for:
- **Email address**: Your email for git and other tools
- **Neovim path**: Path to your Neovim installation (default: `/opt/nvim-linux64/bin`)
- **Oh My Zsh usage**: Whether you want to use Oh My Zsh (default: yes)

## 🔧 Manual Setup Steps

### Prerequisites
Make sure you have the following installed:

1. **Git**: `sudo apt install git` or `brew install git`
2. **Zsh**: `sudo apt install zsh` or `brew install zsh`
3. **Oh My Zsh** (optional but recommended):
   ```bash
   sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
   ```
4. **Starship prompt**:
   ```bash
   curl -sS https://starship.rs/install.sh | sh
   ```
5. **Node.js via NVM**:
   ```bash
   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
   ```

### Post-Installation Steps

1. **Set Zsh as default shell** (if not already):
   ```bash
   chsh -s $(which zsh)
   ```

2. **Install development tools** (as needed):
   ```bash
   # Neovim
   curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
   sudo tar -C /opt -xzf nvim-linux64.tar.gz
   
   # Bun (JavaScript runtime)
   curl -fsSL https://bun.sh/install | bash
   
   # Fly.io CLI
   curl -L https://fly.io/install.sh | sh
   ```

3. **Restart your shell** or source the configuration:
   ```bash
   source ~/.zshrc
   ```

## 🔄 Daily Usage

### Update dotfiles from repository
```bash
chezmoi update
```

### Edit a configuration file
```bash
# This opens the file in your editor and applies changes automatically
chezmoi edit ~/.zshrc
```

### Add a new file to chezmoi
```bash
chezmoi add ~/.newconfig
```

### Check what has changed
```bash
chezmoi diff
```

### Apply any pending changes
```bash
chezmoi apply
```

### Check status
```bash
chezmoi status
```

## 🛠️ Customization

### Machine-Specific Settings

The configuration uses templates to adapt to different machines. Key variables:

- `{{ .chezmoi.homeDir }}`: Your home directory
- `{{ .chezmoi.username }}`: Your username  
- `{{ .chezmoi.hostname }}`: Your machine hostname
- `{{ .email }}`: Your email address (prompted on first run)
- `{{ .useOhMyZsh }}`: Whether to enable Oh My Zsh features

### Adding New Templates

1. Create template files with `.tmpl` extension:
   ```bash
   chezmoi add --template ~/.config/newapp/config.yaml
   ```

2. Use template variables in the file:
   ```yaml
   user_email: {{ .email }}
   home_path: {{ .chezmoi.homeDir }}
   ```

3. Add prompts to `.chezmoi.toml.tmpl` for new variables:
   ```toml
   {{- $newVar := promptStringOnce . "newVar" "Enter new variable" "default" -}}
   ```

### Per-Machine Configuration

Create machine-specific files using hostname:
```bash
# This file only applies to machines with hostname "workstation"
chezmoi add --template ~/.config/app/workstation.conf
```

## 🔒 Security Best Practices

### What NOT to commit:
- Actual API keys, passwords, or tokens
- Private SSH keys
- Personal photos or documents
- Complete `.git` directories from other projects

### What TO template:
- File paths that include usernames
- Email addresses
- Machine-specific settings
- Directory paths

### Using Private Files:
For sensitive configurations, use the `private_` prefix:
```bash
chezmoi add ~/.config/private_app/secret.conf
```

This creates `private_dot_config/private_app/secret.conf` in your chezmoi source directory.

## 🐛 Troubleshooting

### Permission Issues
```bash
# Fix file permissions
chezmoi apply --force

# Check what chezmoi wants to do
chezmoi diff
```

### Template Errors
```bash
# Validate templates
chezmoi execute-template < ~/.local/share/chezmoi/dot_zshrc.tmpl

# Reset configuration
rm ~/.config/chezmoi/chezmoi.toml
chezmoi init --apply
```

### Clean Restart
```bash
# Remove local chezmoi data (keeps your source directory)
rm -rf ~/.local/share/chezmoi
chezmoi init https://github.com/yourusername/dotfiles.git
```

## 📚 Advanced Features

### Using Age Encryption
For encrypting sensitive files:
```bash
# Install age
sudo apt install age

# Generate key
age-keygen -o ~/.config/chezmoi/key.txt

# Add encrypted file
chezmoi add --encrypt ~/.config/app/secret.conf
```

### Git Integration
```bash
# Commit changes from chezmoi source directory
chezmoi cd
git add .
git commit -m "feat: update configuration"
git push
exit

# Or use chezmoi git commands
chezmoi git add .
chezmoi git commit -- -m "feat: update configuration" 
chezmoi git push
```

### Multiple Machines Sync
```bash
# On machine A: make changes and push
chezmoi edit ~/.zshrc
chezmoi cd
git push

# On machine B: pull and apply
chezmoi update
```

## 🔗 Useful Links

- [Chezmoi Documentation](https://www.chezmoi.io/)
- [Template Functions Reference](https://www.chezmoi.io/reference/templates/)
- [Starship Configuration](https://starship.rs/config/)
- [Oh My Zsh Plugins](https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins)