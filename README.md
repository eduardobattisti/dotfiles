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
| Editor | Neovim with lazy.nvim, Treesitter, Telescope, completion, formatting/linting, DAP, Mason/LSP, PHP/Blade, TypeScript/Vue, Tailwind, and optional multi-provider inline AI suggestions; optional Zed configuration with a matching Vim workflow |
| Git and containers | Lazygit, Docker Engine/Compose or Docker Desktop under WSL, and Lazydocker |
| Desktop | Logseq, Flameshot, and DBeaver Community; Logseq graphs, DBeaver connections/credentials, and application state remain unmanaged |
| CLI utilities | Git, ripgrep, fd, fzf, bat, jq, ranger, btop, build tools, and clipboard providers |

The default `workstation` profile also installs Node LTS through NVM and
PHP/Composer. On physical Linux workstations it adds Flameshot and DBeaver
Community; native Windows reconciliation installs both through winget. Bun,
Fly.io, htop, Neovim plugins, and Mason-managed tools are not updated by the
bootstrap.

## Repository layout

```text
.
├── .chezmoi.toml.tmpl       # Machine-local chezmoi data
├── .chezmoiignore           # OS-specific target selection
├── .chezmoiremove           # Cleanup list for retired target files
├── .chezmoitemplates/       # Shared cross-platform file contents
├── AppData/Roaming/         # Native Windows configuration targets
├── dot_zshrc.tmpl           # Modular Zsh entrypoint
├── dot_bashrc.tmpl          # Bash fallback
├── dot_config/
│   ├── zsh/                 # Zsh modules
│   ├── wezterm/             # Terminal modules and keybinding reference
│   ├── nvim/                # Neovim configuration and lazy lockfile
│   ├── zed/                 # Optional Zed settings and Vim-style key map
│   ├── lazygit/             # Lazygit UI and commands
│   ├── lazydocker/          # Lazydocker UI and commands
│   ├── flameshot/           # Linux target for the shared screenshot config
│   └── starship.toml        # Prompt theme
├── dot_local/bin/           # Portable user commands
├── scripts/windows-host.ps1 # Native Windows side of WSL setup
├── tests/bootstrap_test.sh  # Cross-platform smoke tests
└── install.sh               # Bootstrap and reconciliation entrypoint
```

Files named `dot_*`, `private_*`, and `executable_*` use chezmoi source-state
attributes; they become normal dotted, private, or executable targets in the
home directory.

Flameshot uses one canonical `.chezmoitemplates/flameshot.ini` template. Thin
target templates render it to `~/.config/flameshot/flameshot.ini` on Linux and
`%APPDATA%\flameshot\flameshot.ini` on Windows. The templated
`.chezmoiignore` selects only the target appropriate for the current operating
system, following chezmoi's shared-content/different-location pattern.

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

Zed itself is not installed or updated by the bootstrap. When Zed is installed
separately on Linux or macOS, chezmoi applies its settings and Neovim-compatible
key map. See [dot_config/zed/README.md](dot_config/zed/README.md) for the key
reference and validation flow.

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

- `workstation` is the default and includes Node, PHP/Composer, and btop. On
  physical Linux it also includes Flameshot and DBeaver Community.
- `core` keeps the shell, terminal, editor, Git/Docker tools, Logseq, font, and
  their strict dependencies, while omitting workstation language extras.
- `--dry-run` reports planned package, release, and chezmoi actions without
  applying them.
- `--install-only` fills missing items without upgrading existing versions.

## Per-machine inline AI

Neovim keeps AI assistance limited to inline suggestions. Minuet provides
OpenAI, Claude, Gemini, Codestral, Ollama, and OpenAI-compatible backends. Chat
and agent workflows remain in the CLI. Inline AI is disabled by default.

Choose a backend independently on each machine in the unmanaged
`~/.config/zsh/.secrets` file:

```sh
# Example
export NVIM_AI_PROVIDER=gemini
export GEMINI_API_KEY='machine-local-secret'

# Optional; suggestions are manual unless this is enabled.
export NVIM_AI_AUTO_TRIGGER=1
```

Valid provider values are `openai`, `claude`, `gemini`, `codestral`,
`openai_compatible`, `openai_fim_compatible`, `ollama`, and `none`. Compatible
endpoints can additionally use `NVIM_AI_API_KEY_ENV`, `NVIM_AI_ENDPOINT`,
`NVIM_AI_MODEL`, and `NVIM_AI_PROVIDER_NAME`.

Never place an API key directly in a managed file. `.chezmoiignore` excludes
`.secrets`, dotenv files, private keys, and common credential stores.

After changing providers:

```sh
source ~/.zshrc
chezmoi apply ~/.config/nvim
```

Restart Neovim. Use `Alt+]`/`Alt+[` to request or cycle suggestions, `Alt+l` to
accept, and `Ctrl+]` to dismiss. See
[dot_config/nvim/README.md](dot_config/nvim/README.md#ai-workflow-cli--in-editor)
for compatible-endpoint and model examples.

## Platform behavior

- Debian, Ubuntu, Pop!_OS, and Ubuntu-based WSL distributions are supported.
- Linux installs Flameshot from APT in the `workstation` profile and applies
  its configuration under `~/.config/flameshot`.
- Linux installs or updates DBeaver Community from its official stable Debian
  release in the `workstation` profile. WSL leaves the database GUI on Windows.
- Linux uses native WezTerm, Flatpak Logseq, and Docker's official APT
  repository.
- In WSL, CLI tools live in Linux. PowerShell/winget manages native Windows
  WezTerm, Flameshot, DBeaver Community, Logseq, Docker Desktop, BlexMono Nerd
  Font, and Windows chezmoi.
- Windows-side chezmoi applies the native WezTerm configuration and the shared
  Flameshot configuration under `%APPDATA%\flameshot`.
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
chezmoi edit ~/.config/zed/keymap.json
```

Machine-local secrets may be placed in `~/.config/zsh/.secrets`. Logseq graphs,
Docker data, DBeaverData connections and credentials, Neovim plugins, Mason
caches, generated WezTerm sessions, and other application state must not be
committed.

See [SETUP.md](SETUP.md) for troubleshooting and
[dot_config/wezterm/KEYBINDINGS.md](dot_config/wezterm/KEYBINDINGS.md) for the
terminal key map.
