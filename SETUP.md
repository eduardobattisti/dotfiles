# Setup and Troubleshooting

## Installer modes

Preview without changing anything:

```sh
./install.sh --dry-run
```

Install missing applications without upgrading installed versions:

```sh
./install.sh --install-only
```

Reconcile packages but inspect dotfile changes separately:

```sh
./install.sh --no-apply
chezmoi diff
chezmoi apply
```

Use `DOTFILES_REPO` for a fork and the documented `DOTFILES_*_VERSION`
variables to override individual release channels.

## Linux

Debian/Ubuntu derivatives use targeted APT installs. Docker Engine uses
Docker's Ubuntu repository, WezTerm uses its official stable APT repository,
and Logseq uses Flathub.

Adding the user to the `docker` group requires logging out and back in. The
installer reports this instead of claiming Docker is immediately ready.

The installer puts user-managed binaries in `~/.local/bin` and Neovim releases
under `~/.local/opt`. It does not delete an older `/opt` Neovim or Flatpak
WezTerm.

## Windows and WSL

Run the Bash installer inside an Ubuntu-like WSL distribution. It invokes
PowerShell to reconcile these Windows-host packages through winget:

- WezTerm
- Logseq
- Docker Desktop
- chezmoi
- BlexMono Nerd Font

Windows chezmoi applies only the native WezTerm configuration. Zsh, Neovim,
Lazygit, and Lazydocker remain inside WSL.

After Docker Desktop installation, enable the distribution under:

```text
Docker Desktop > Settings > Resources > WSL Integration
```

If `powershell.exe` or `winget.exe` is unavailable from WSL, the installer
prints a manual follow-up and leaves the Linux setup intact.

## macOS

The macOS path bootstraps Homebrew after confirmation and uses formulas/casks
for the managed applications. It is not validated on physical macOS hardware.

## Chezmoi configuration

`.chezmoi.toml.tmpl` generates machine-local configuration. The installer
exports the chosen profile while running `chezmoi init`; `DOTFILES_EMAIL` can
optionally populate the non-secret email setting.

To regenerate machine-local chezmoi data after template changes:

```sh
chezmoi init
```

To validate before applying:

```sh
chezmoi execute-template --init < \
  "$(chezmoi source-path)/.chezmoi.toml.tmpl"
chezmoi diff
```

## Validation

Run the repository smoke tests:

```sh
bash tests/bootstrap_test.sh
```

If ShellCheck is installed:

```sh
shellcheck install.sh tests/bootstrap_test.sh \
  dot_local/bin/executable_dotfiles-open
```

The bootstrap never updates Neovim plugins or Mason tools. Update those from
inside Neovim only when desired.
