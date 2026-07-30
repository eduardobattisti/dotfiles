# Development Dotfiles

Personal development environment managed by
[chezmoi](https://www.chezmoi.io/). The repository is the source of truth for
the shell, terminal, editor, Git/Docker TUIs, and the cross-platform installer
that keeps their applications present and current.

## Current setup

| Area | Applications and behavior |
|---|---|
| Shell | Zsh, Oh My Zsh, Starship, lazy-loaded NVM, completions, aliases, keybindings, and a minimal Bash fallback |
| Terminal | WezTerm with Gruvbox Material, BlexMono Nerd Font, smart pane navigation, workspaces, layouts, status/tab modules, and session persistence |
| Editor | Neovim with lazy.nvim, Treesitter, Telescope, completion, formatting/linting, DAP, Mason/LSP, PHP/Blade, TypeScript/Vue, Tailwind, and optional inline Copilot suggestions |
| Git and containers | Lazygit, Docker Engine/Compose or Docker Desktop under WSL, and Lazydocker |
| Desktop | Logseq and Flameshot; Logseq graphs and application state remain unmanaged |
| CLI utilities | Git, ripgrep, fd, fzf, bat, jq, ranger, btop, build tools, and clipboard providers |

The default `workstation` profile also installs Node LTS through NVM and
PHP/Composer. Bun, Fly.io, htop, Neovim plugins, and Mason-managed tools are not
updated by the bootstrap.

## Repository layout

```text
.
├── .chezmoi.toml.tmpl       # Machine-local chezmoi data
├── .chezmoiignore           # OS-specific target selection
├── .chezmoiremove           # Cleanup list for retired target files
├── dot_zshrc.tmpl           # Modular Zsh entrypoint
├── dot_bashrc.tmpl          # Bash fallback
├── dot_config/
│   ├── zsh/                 # Zsh modules
│   ├── wezterm/             # Terminal modules and keybinding reference
│   ├── nvim/                # Neovim configuration and lazy lockfile
│   ├── lazygit/             # Lazygit UI and commands
│   ├── lazydocker/          # Lazydocker UI and commands
│   ├── flameshot/           # Screenshot configuration
│   └── starship.toml        # Prompt theme
├── dot_local/bin/           # Portable user commands
├── scripts/windows-host.ps1 # Native Windows side of WSL setup
├── tests/bootstrap_test.sh  # Cross-platform smoke tests
└── install.sh               # Bootstrap and reconciliation entrypoint
```

Files named `dot_*`, `private_*`, and `executable_*` use chezmoi source-state
attributes; they become normal dotted, private, or executable targets in the
home directory.

## Fresh machine

Review the installer first:

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
re-executes its checked-out copy, reconciles the managed applications, applies
the dotfiles, and verifies the resulting environment.

## Reconcile an existing machine

```sh
chezmoi cd
./install.sh
```

A normal run installs missing applications and updates outdated managed
applications to their stable channels. Updates are targeted: it does not run a
full operating-system upgrade.

Useful options:

```text
--profile workstation|core
--dry-run
--install-only
--yes
--no-apply
```

- `workstation` is the default and includes Node, PHP/Composer, btop, and
  Flameshot.
- `core` keeps the shell, terminal, editor, Git/Docker tools, Logseq, font, and
  their strict dependencies, while omitting workstation language extras.
- `--dry-run` reports planned package, release, and chezmoi actions without
  applying them.
- `--install-only` fills missing items without upgrading existing versions.

## Platform behavior

- Debian, Ubuntu, Pop!_OS, and Ubuntu-based WSL distributions are supported.
- Linux uses native WezTerm, Flatpak Logseq, and Docker's official APT
  repository.
- In WSL, CLI tools live in Linux. PowerShell/winget manages native Windows
  WezTerm, Logseq, Docker Desktop, BlexMono Nerd Font, and Windows chezmoi.
- Windows-side chezmoi applies only the native WezTerm configuration.
- macOS uses Homebrew and is implemented as a best-effort, untested path.
- Other Linux families exit with an explicit unsupported-system message.

Existing legacy installations are reported but never uninstalled
automatically. Repository files listed in `.chezmoiremove`, however, are known
retired configuration targets and are removed during `chezmoi apply`.

## Daily workflow

```sh
chezmoi status
chezmoi diff
chezmoi apply
chezmoi update
```

Package reconciliation is intentionally separate from `chezmoi apply`; only
`install.sh` installs or upgrades applications.

Edit the source through chezmoi:

```sh
chezmoi edit ~/.zshrc
chezmoi edit ~/.config/wezterm/wezterm.lua
chezmoi edit ~/.config/nvim/init.lua
```

Machine-local secrets may be placed in `~/.config/zsh/.secrets`. Logseq graphs,
Docker data, Neovim plugins, Mason caches, generated WezTerm sessions, and other
application state must not be committed.

See [SETUP.md](SETUP.md) for troubleshooting and
[dot_config/wezterm/KEYBINDINGS.md](dot_config/wezterm/KEYBINDINGS.md) for the
terminal key map.
