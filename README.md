# Development Dotfiles

Personal development environment managed by
[chezmoi](https://www.chezmoi.io/). The repository contains configurations for
Zsh, Starship, WezTerm, Neovim, Lazygit, Lazydocker, Flameshot, htop, and the
bootstrap that installs or updates their applications.

## Fresh machine

Review the installer before running it:

```sh
curl -fsSL \
  https://raw.githubusercontent.com/eduardobattisti/dotfiles/main/install.sh
```

Run the default workstation setup:

```sh
curl -fsSL \
  https://raw.githubusercontent.com/eduardobattisti/dotfiles/main/install.sh |
  bash
```

For a non-interactive run:

```sh
curl -fsSL \
  https://raw.githubusercontent.com/eduardobattisti/dotfiles/main/install.sh |
  bash -s -- --yes
```

The bootstrap installs chezmoi when needed, initializes this repository,
re-executes the checked-out copy of itself, reconciles the managed
applications, and applies the dotfiles.

## Reconcile an existing machine

Run from the chezmoi source directory:

```sh
chezmoi cd
./install.sh
```

Every normal run:

1. detects the operating system, distribution, architecture, and WSL;
2. reports current, missing, and outdated managed applications;
3. installs missing applications;
4. updates outdated managed applications to their stable channels;
5. applies chezmoi; and
6. verifies commands, Zsh syntax, Docker, and the terminal font.

Updates are targeted. The script does **not** perform a full operating-system
upgrade and does not update Neovim plugins, Mason packages, Oh My Zsh, or Zsh
plugins.

Useful options:

```text
--profile workstation|core
--dry-run
--install-only
--yes
--no-apply
```

`workstation` is the default. It includes Node LTS through NVM, PHP/Composer,
btop, and Flameshot. `core` omits those workstation extras. Bun and Fly.io are
intentionally not installed.

## Supported platforms

- Debian, Ubuntu, Pop!_OS, and Ubuntu-based WSL distributions are supported.
- Under WSL, CLI tools live in Linux. PowerShell/winget manages native Windows
  WezTerm, Logseq, Docker Desktop, BlexMono Nerd Font, and Windows chezmoi.
- macOS uses Homebrew and is implemented as a best-effort, untested path.
- Other Linux distribution families exit with an explicit unsupported-system
  message.

Linux uses native WezTerm and Flatpak Logseq. Existing Flatpak/native
duplicates and old `/opt` installations are reported but never removed
automatically.

## Daily chezmoi workflow

```sh
chezmoi status
chezmoi diff
chezmoi apply
chezmoi update
```

Package reconciliation is intentionally separate from `chezmoi apply`; only
`install.sh` installs or upgrades applications.

Machine-local secrets may be placed in `~/.config/zsh/.secrets`. Logseq graphs,
application state, Docker data, Neovim plugins, and Mason caches are not managed
by this repository.

See [SETUP.md](SETUP.md) for troubleshooting and platform details.
