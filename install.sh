#!/usr/bin/env bash
#
# Bootstrap and reconcile Eduardo's development environment.
# Bash 3.2 compatible so the same entry point works on Linux, WSL, and macOS.

set -euo pipefail

readonly DEFAULT_REPO="https://github.com/eduardobattisti/dotfiles.git"
readonly SCRIPT_VERSION="1"

PROFILE="workstation"
DRY_RUN=0
ASSUME_YES=0
INSTALL_ONLY=0
APPLY_DOTFILES=1
BOOTSTRAP_REEXECUTED="${DOTFILES_BOOTSTRAP_REEXECUTED:-0}"
TEST_MODE="${DOTFILES_TEST_MODE:-0}"
REPO_URL="${DOTFILES_REPO:-$DEFAULT_REPO}"
WINDOWS_HOST_DONE=0

OS=""
DISTRO=""
ARCH=""
IS_WSL=0
SCRIPT_DIR=""
TMP_ROOT=""

CURRENT_ITEMS=""
MISSING_ITEMS=""
OUTDATED_ITEMS=""
MANUAL_ITEMS=""

usage() {
  cat <<'EOF'
Usage: ./install.sh [options]

Reconcile the applications managed by this dotfiles repository: install
missing applications, update outdated applications, then apply chezmoi.

Options:
  --profile PROFILE  workstation (default) or core
  --dry-run          report changes without modifying the machine
  --install-only     install missing applications but do not upgrade
  --yes              accept package, sudo, shell, and host-change prompts
  --no-apply         do not run chezmoi apply
  -h, --help         show this help

Environment:
  DOTFILES_REPO              override the chezmoi Git repository URL
  DOTFILES_NVIM_VERSION      override the Neovim release tag
  DOTFILES_LAZYGIT_VERSION   override the Lazygit release tag
  DOTFILES_LAZYDOCKER_VERSION override the Lazydocker release tag
  DOTFILES_STARSHIP_VERSION  override the Starship release tag
  DOTFILES_NERD_FONT_VERSION override the Nerd Fonts release tag
EOF
}

log() {
  printf '[dotfiles] %s\n' "$*"
}

warn() {
  printf '[dotfiles] WARNING: %s\n' "$*" >&2
}

die() {
  printf '[dotfiles] ERROR: %s\n' "$*" >&2
  exit 1
}

append_item() {
  local variable_name="$1"
  local item="$2"
  local current_value
  eval "current_value=\${$variable_name}"
  if [ -n "$current_value" ]; then
    printf -v "$variable_name" '%s\n%s' "$current_value" "$item"
  else
    printf -v "$variable_name" '%s' "$item"
  fi
}

record_current() {
  append_item CURRENT_ITEMS "$1"
}

record_missing() {
  append_item MISSING_ITEMS "$1"
}

record_outdated() {
  append_item OUTDATED_ITEMS "$1"
}

record_manual() {
  append_item MANUAL_ITEMS "$1"
}

confirm() {
  local prompt="$1"
  local input_path="/dev/stdin"
  local output_path="/dev/stdout"
  if [ "$ASSUME_YES" -eq 1 ]; then
    return 0
  fi
  if [ ! -t 0 ] && [ -r /dev/tty ]; then
    input_path="/dev/tty"
    output_path="/dev/tty"
  elif [ ! -t 0 ]; then
    die "$prompt Re-run with --yes in a non-interactive shell."
  fi
  printf '%s [y/N] ' "$prompt" >"$output_path"
  local reply
  read -r reply <"$input_path"
  case "$reply" in
    y|Y|yes|YES) return 0 ;;
    *) return 1 ;;
  esac
}

run() {
  if [ "$DRY_RUN" -eq 1 ] || [ "$TEST_MODE" -eq 1 ]; then
    printf '[dry-run]'
    printf ' %q' "$@"
    printf '\n'
    return 0
  fi
  "$@"
}

sudo_run() {
  if [ "$(id -u)" -eq 0 ]; then
    run "$@"
  else
    run sudo "$@"
  fi
}

cleanup() {
  if [ -n "${TMP_ROOT:-}" ] && [ -d "$TMP_ROOT" ]; then
    rm -rf "$TMP_ROOT"
  fi
}

trap cleanup EXIT INT TERM

parse_args() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --profile)
        [ "$#" -ge 2 ] || die "--profile requires a value"
        PROFILE="$2"
        shift 2
        ;;
      --dry-run)
        DRY_RUN=1
        shift
        ;;
      --install-only)
        INSTALL_ONLY=1
        shift
        ;;
      --yes)
        ASSUME_YES=1
        shift
        ;;
      --no-apply)
        APPLY_DOTFILES=0
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        die "unknown option: $1"
        ;;
    esac
  done

  case "$PROFILE" in
    core|workstation) ;;
    *) die "unsupported profile '$PROFILE'; expected core or workstation" ;;
  esac
}

detect_platform() {
  local uname_s uname_m
  uname_s="${DOTFILES_TEST_OS:-$(uname -s)}"
  uname_m="${DOTFILES_TEST_ARCH:-$(uname -m)}"

  case "$uname_s" in
    Linux|linux) OS="linux" ;;
    Darwin|darwin) OS="darwin" ;;
    *) die "unsupported operating system: $uname_s" ;;
  esac

  case "$uname_m" in
    x86_64|amd64) ARCH="amd64" ;;
    arm64|aarch64) ARCH="arm64" ;;
    *) die "unsupported CPU architecture: $uname_m" ;;
  esac

  if [ "$OS" = "linux" ]; then
    if [ -n "${DOTFILES_TEST_DISTRO:-}" ]; then
      DISTRO="$DOTFILES_TEST_DISTRO"
    elif [ -r /etc/os-release ]; then
      # shellcheck disable=SC1091
      . /etc/os-release
      DISTRO="${ID:-unknown}"
      case " ${ID:-} ${ID_LIKE:-} " in
        *" ubuntu "*|*" debian "*) ;;
        *) die "unsupported Linux distribution '$DISTRO'; Debian/Ubuntu derivatives are required" ;;
      esac
    else
      die "cannot identify Linux distribution"
    fi

    if [ "${DOTFILES_TEST_WSL:-0}" -eq 1 ] ||
      grep -qi microsoft /proc/sys/kernel/osrelease 2>/dev/null ||
      [ -n "${WSL_INTEROP:-}" ]; then
      IS_WSL=1
    fi
  else
    DISTRO="macos"
  fi

  log "platform: os=$OS distro=$DISTRO arch=$ARCH wsl=$IS_WSL profile=$PROFILE"
}

command_version() {
  local command_name="$1"
  if ! command -v "$command_name" >/dev/null 2>&1; then
    return 1
  fi
  "$command_name" --version 2>/dev/null | head -n 1 || true
}

normalize_version() {
  printf '%s' "$1" |
    sed -E 's/^[^0-9]*//; s/[^0-9].*$//' 2>/dev/null || printf '%s' "$1"
}

github_latest_tag() {
  local repository="$1"
  if [ "$TEST_MODE" -eq 1 ]; then
    printf 'v999.0.0\n'
    return
  fi
  curl -fsSL "https://api.github.com/repos/${repository}/releases/latest" |
    sed -n 's/.*"tag_name":[[:space:]]*"\([^"]*\)".*/\1/p' |
    head -n 1
}

needs_release_update() {
  local command_name="$1"
  local installed_version="$2"
  local wanted_version="$3"

  if ! command -v "$command_name" >/dev/null 2>&1; then
    return 0
  fi
  [ -n "$installed_version" ] || return 0
  [ -n "$wanted_version" ] || return 1
  case "$installed_version" in
    *"${wanted_version#v}"*) return 1 ;;
    *) return 0 ;;
  esac
}

ensure_tmp_root() {
  if [ -z "$TMP_ROOT" ]; then
    TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-bootstrap.XXXXXX")"
  fi
}

download() {
  local url="$1"
  local output="$2"
  log "download: $url"
  run curl --fail --location --retry 3 --output "$output" "$url"
}

ensure_home_dirs() {
  run mkdir -p "$HOME/.local/bin" "$HOME/.local/opt"
}

ensure_linux_packages() {
  local packages=(
    ca-certificates curl git zsh build-essential make unzip tar xz-utils
    ripgrep fd-find fzf bat jq fontconfig wl-clipboard xclip gnupg
    ranger
  )
  if [ "$IS_WSL" -eq 0 ]; then
    packages+=(flatpak)
  fi
  if [ "$PROFILE" = "workstation" ]; then
    packages+=(php-cli php-mbstring php-xml php-curl btop flameshot)
  fi

  local missing="" package
  for package in "${packages[@]}"; do
    if dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q 'install ok installed'; then
      record_current "apt:$package"
    else
      missing="$missing $package"
      record_missing "apt:$package"
    fi
  done

  if [ "$INSTALL_ONLY" -eq 0 ]; then
    local simulated_upgrades
    simulated_upgrades="$(apt-get --just-print install "${packages[@]}" 2>/dev/null |
      sed -n 's/^Inst \([^ ]*\).*/\1/p' || true)"
    for package in $simulated_upgrades; do
      record_outdated "apt:$package"
    done
  fi

  if [ -n "$missing" ] || [ "$INSTALL_ONLY" -eq 0 ]; then
    log "refreshing APT metadata and reconciling declared packages"
    sudo_run apt-get update
    # apt-get install upgrades named packages to the current candidate without
    # upgrading unrelated operating-system packages.
    sudo_run apt-get install -y "${packages[@]}"
  fi

  ensure_home_dirs
  if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
    run ln -sfn "$(command -v fdfind)" "$HOME/.local/bin/fd"
  fi
  if ! command -v bat >/dev/null 2>&1 && command -v batcat >/dev/null 2>&1; then
    run ln -sfn "$(command -v batcat)" "$HOME/.local/bin/bat"
  fi
}

install_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    record_current "homebrew"
    return
  fi
  record_missing "homebrew"
  confirm "Install Homebrew using its official installer?" || die "Homebrew is required on macOS"
  if [ "$DRY_RUN" -eq 1 ] || [ "$TEST_MODE" -eq 1 ]; then
    log "[dry-run] install Homebrew"
    return
  fi
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

ensure_macos_packages() {
  install_homebrew
  local formulae="git zsh starship neovim lazygit lazydocker ripgrep fd fzf bat jq fontconfig ranger"
  local casks="wezterm logseq docker"
  if [ "$PROFILE" = "workstation" ]; then
    formulae="$formulae php composer btop"
    casks="$casks flameshot"
  fi

  local package
  for package in $formulae; do
    if brew list --formula "$package" >/dev/null 2>&1; then
      record_current "brew:$package"
      if [ "$INSTALL_ONLY" -eq 0 ]; then
        run brew upgrade "$package"
      fi
    else
      record_missing "brew:$package"
      run brew install "$package"
    fi
  done
  for package in $casks; do
    if brew list --cask "$package" >/dev/null 2>&1; then
      record_current "brew-cask:$package"
      if [ "$INSTALL_ONLY" -eq 0 ]; then
        run brew upgrade --cask "$package"
      fi
    else
      record_missing "brew-cask:$package"
      run brew install --cask "$package"
    fi
  done
}

install_release_binary() {
  local name="$1"
  local repository="$2"
  local wanted_tag="$3"
  local asset="$4"
  local binary_path="$5"
  local installed_version="$6"
  local archive_kind="${7:-tar}"
  local url="https://github.com/${repository}/releases/download/${wanted_tag}/${asset}"

  if ! needs_release_update "$name" "$installed_version" "$wanted_tag"; then
    record_current "$name:${wanted_tag#v}"
    return
  fi
  if command -v "$name" >/dev/null 2>&1; then
    record_outdated "$name:${installed_version:-unknown}->${wanted_tag#v}"
    [ "$INSTALL_ONLY" -eq 0 ] || return 0
  else
    record_missing "$name:${wanted_tag#v}"
  fi

  ensure_tmp_root
  local archive="$TMP_ROOT/$asset"
  local extract_dir="$TMP_ROOT/${name}-extract"
  download "$url" "$archive"
  run mkdir -p "$extract_dir"
  case "$archive_kind" in
    zip) run unzip -q -o "$archive" -d "$extract_dir" ;;
    tar) run tar -xzf "$archive" -C "$extract_dir" ;;
    *) die "unknown archive type '$archive_kind' for $name" ;;
  esac
  if [ "$DRY_RUN" -eq 0 ] && [ "$TEST_MODE" -eq 0 ]; then
    local found
    found="$(find "$extract_dir" -type f -name "$binary_path" -perm -u+x | head -n 1)"
    [ -n "$found" ] || die "$binary_path was not found in $asset"
    install -m 0755 "$found" "$HOME/.local/bin/$name"
  else
    log "[dry-run] install $binary_path as $HOME/.local/bin/$name"
  fi
}

ensure_neovim_linux() {
  local tag version arch_name asset installed
  tag="${DOTFILES_NVIM_VERSION:-$(github_latest_tag neovim/neovim)}"
  [ -n "$tag" ] || die "could not resolve the stable Neovim release"
  version="${tag#v}"
  case "$ARCH" in
    amd64) arch_name="x86_64" ;;
    arm64) arch_name="arm64" ;;
  esac
  asset="nvim-linux-${arch_name}.tar.gz"
  installed="$(command_version nvim || true)"

  if ! needs_release_update nvim "$installed" "$tag"; then
    record_current "nvim:$version"
    return
  fi
  if command -v nvim >/dev/null 2>&1; then
    record_outdated "nvim:${installed:-broken}->$version"
    [ "$INSTALL_ONLY" -eq 0 ] || return 0
  else
    record_missing "nvim:$version"
  fi

  ensure_tmp_root
  local archive="$TMP_ROOT/$asset"
  download "https://github.com/neovim/neovim/releases/download/${tag}/${asset}" "$archive"
  log "installing Neovim $version under ~/.local/opt"
  if [ "$DRY_RUN" -eq 0 ] && [ "$TEST_MODE" -eq 0 ]; then
    local destination="$HOME/.local/opt/nvim-$version"
    rm -rf "$destination"
    mkdir -p "$destination"
    tar -xzf "$archive" --strip-components=1 -C "$destination"
    ln -sfn "$destination/bin/nvim" "$HOME/.local/bin/nvim"
  else
    log "[dry-run] extract $asset to $HOME/.local/opt/nvim-$version"
  fi
}

ensure_github_binaries_linux() {
  ensure_home_dirs

  local tag version asset installed arch_name os_name
  case "$ARCH" in
    amd64) arch_name="x86_64" ;;
    arm64) arch_name="arm64" ;;
  esac
  if [ "$OS" = "darwin" ]; then os_name="Darwin"; else os_name="Linux"; fi

  tag="${DOTFILES_LAZYGIT_VERSION:-$(github_latest_tag jesseduffield/lazygit)}"
  version="${tag#v}"
  asset="lazygit_${version}_${os_name}_${arch_name}.tar.gz"
  installed="$(command_version lazygit || true)"
  install_release_binary lazygit jesseduffield/lazygit "$tag" "$asset" lazygit "$installed"

  tag="${DOTFILES_LAZYDOCKER_VERSION:-$(github_latest_tag jesseduffield/lazydocker)}"
  version="${tag#v}"
  asset="lazydocker_${version}_${os_name}_${arch_name}.tar.gz"
  installed="$(command_version lazydocker || true)"
  install_release_binary lazydocker jesseduffield/lazydocker "$tag" "$asset" lazydocker "$installed"

  tag="${DOTFILES_STARSHIP_VERSION:-$(github_latest_tag starship/starship)}"
  version="${tag#v}"
  if [ "$OS" = "darwin" ]; then
    asset="starship-${arch_name/amd64/x86_64}-apple-darwin.tar.gz"
  elif [ "$ARCH" = "amd64" ]; then
    asset="starship-x86_64-unknown-linux-musl.tar.gz"
  else
    asset="starship-aarch64-unknown-linux-musl.tar.gz"
  fi
  installed="$(command_version starship || true)"
  install_release_binary starship starship/starship "$tag" "$asset" starship "$installed"
}

ensure_nerd_font() {
  local tag version marker font_dir
  tag="${DOTFILES_NERD_FONT_VERSION:-$(github_latest_tag ryanoasis/nerd-fonts)}"
  [ -n "$tag" ] || die "could not resolve the stable Nerd Fonts release"
  version="${tag#v}"
  if [ "$OS" = "darwin" ]; then
    font_dir="$HOME/Library/Fonts"
  else
    font_dir="$HOME/.local/share/fonts"
  fi
  marker="$font_dir/.blexmono-nerd-font.version"

  if [ -f "$marker" ] && [ "$(cat "$marker")" = "$version" ]; then
    record_current "font:BlexMono-Nerd-$version"
    return
  fi
  if find "$font_dir" -maxdepth 1 -iname 'BlexMonoNerdFont*.ttf' -print -quit 2>/dev/null | grep -q .; then
    record_outdated "font:BlexMono-Nerd->$version"
    [ "$INSTALL_ONLY" -eq 0 ] || return 0
  else
    record_missing "font:BlexMono-Nerd-$version"
  fi

  ensure_tmp_root
  local archive="$TMP_ROOT/IBMPlexMono.zip"
  local extract_dir="$TMP_ROOT/IBMPlexMono"
  download "https://github.com/ryanoasis/nerd-fonts/releases/download/${tag}/IBMPlexMono.zip" "$archive"
  run mkdir -p "$font_dir" "$extract_dir"
  run unzip -q -o "$archive" -d "$extract_dir"
  if [ "$DRY_RUN" -eq 0 ] && [ "$TEST_MODE" -eq 0 ]; then
    find "$extract_dir" -type f \( -name '*.ttf' -o -name '*.otf' \) -exec cp {} "$font_dir/" \;
    printf '%s\n' "$version" >"$marker"
    if command -v fc-cache >/dev/null 2>&1; then
      fc-cache -f "$font_dir"
    fi
  else
    log "[dry-run] install BlexMono Nerd Font $version in $font_dir"
  fi
}

ensure_oh_my_zsh() {
  local omz="$HOME/.oh-my-zsh"
  if [ -d "$omz/.git" ]; then
    record_current "oh-my-zsh (updates intentionally excluded)"
  else
    record_missing "oh-my-zsh"
    run git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$omz"
  fi

  local plugin name url
  for plugin in \
    "zsh-history-substring-search|https://github.com/zsh-users/zsh-history-substring-search.git" \
    "zsh-autosuggestions|https://github.com/zsh-users/zsh-autosuggestions.git" \
    "zsh-syntax-highlighting|https://github.com/zsh-users/zsh-syntax-highlighting.git"; do
    name="${plugin%%|*}"
    url="${plugin#*|}"
    if [ -d "$omz/custom/plugins/$name/.git" ]; then
      record_current "zsh-plugin:$name (updates intentionally excluded)"
    else
      record_missing "zsh-plugin:$name"
      run mkdir -p "$omz/custom/plugins"
      run git clone --depth=1 "$url" "$omz/custom/plugins/$name"
    fi
  done
}

ensure_nvm_node() {
  [ "$PROFILE" = "workstation" ] || return 0
  local nvm_dir="$HOME/.nvm"
  local tag
  tag="$(github_latest_tag nvm-sh/nvm)"
  [ -n "$tag" ] || die "could not resolve the stable NVM release"
  if [ -s "$nvm_dir/nvm.sh" ]; then
    local current_tag
    current_tag="$(git -C "$nvm_dir" describe --tags --exact-match 2>/dev/null || true)"
    if [ "$current_tag" = "$tag" ]; then
      record_current "nvm:${tag#v}"
    elif [ "$INSTALL_ONLY" -eq 0 ]; then
      record_outdated "nvm:${current_tag:-unknown}->${tag#v}"
      run git -C "$nvm_dir" fetch --depth=1 origin "refs/tags/$tag:refs/tags/$tag"
      run git -C "$nvm_dir" checkout --quiet "$tag"
    fi
  else
    record_missing "nvm:${tag#v}"
    run git clone --depth=1 --branch "$tag" https://github.com/nvm-sh/nvm.git "$nvm_dir"
  fi

  if [ "$DRY_RUN" -eq 1 ] || [ "$TEST_MODE" -eq 1 ]; then
    log "[dry-run] install or update latest Node.js LTS through NVM"
    return
  fi
  # shellcheck source=/dev/null
  . "$nvm_dir/nvm.sh"
  if [ "$INSTALL_ONLY" -eq 1 ] && command -v node >/dev/null 2>&1; then
    record_current "node:$(node --version)"
  else
    nvm install --lts --latest-npm
    nvm alias default 'lts/*'
  fi
}

ensure_composer() {
  [ "$PROFILE" = "workstation" ] || return 0
  local latest installed
  if [ "$TEST_MODE" -eq 1 ]; then
    latest="999.0.0"
  else
    latest="$(curl -fsSL https://getcomposer.org/versions |
      jq -r '.stable[0].version // empty')"
  fi
  [ -n "$latest" ] || die "could not resolve the stable Composer release"
  installed="$(composer --version --no-ansi 2>/dev/null |
    sed -n 's/^Composer version \([^ ]*\).*/\1/p' | head -n1 || true)"

  if [ "$installed" = "$latest" ]; then
    record_current "composer:$latest"
    return
  fi
  if [ -n "$installed" ]; then
    record_outdated "composer:$installed->$latest"
    [ "$INSTALL_ONLY" -eq 0 ] || return 0
  else
    record_missing "composer:$latest"
  fi

  if [ "$DRY_RUN" -eq 1 ] || [ "$TEST_MODE" -eq 1 ]; then
    log "[dry-run] verify Composer installer signature and install $latest to ~/.local/bin/composer"
    return
  fi

  ensure_tmp_root
  local installer="$TMP_ROOT/composer-setup.php"
  local expected actual
  expected="$(curl -fsSL https://composer.github.io/installer.sig)"
  curl -fsSL https://getcomposer.org/installer -o "$installer"
  actual="$(php -r "echo hash_file('sha384', '$installer');")"
  [ "$expected" = "$actual" ] || die "Composer installer signature verification failed"
  php "$installer" --quiet --install-dir="$HOME/.local/bin" --filename=composer --version="$latest"
}

ensure_docker_linux() {
  if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
    record_current "docker:$(docker --version | head -n1)"
    if [ "$INSTALL_ONLY" -eq 1 ]; then
      return
    fi
  else
    record_missing "docker-engine-and-compose"
  fi

  if [ "$IS_WSL" -eq 1 ]; then
    ensure_windows_host
    if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
      record_current "docker-desktop-wsl-integration"
    else
      record_manual "Enable this WSL distribution in Docker Desktop: Settings > Resources > WSL Integration"
    fi
    return
  fi

  log "reconciling Docker Engine from Docker's Ubuntu repository"
  if [ "$DRY_RUN" -eq 1 ] || [ "$TEST_MODE" -eq 1 ]; then
    log "[dry-run] configure Docker APT repository and install/upgrade Docker Engine + Compose"
    return
  fi

  # shellcheck disable=SC1091
  . /etc/os-release
  local codename="${UBUNTU_CODENAME:-${VERSION_CODENAME:-}}"
  [ -n "$codename" ] || die "cannot determine Ubuntu codename for Docker repository"
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg |
    sudo tee /etc/apt/keyrings/docker.asc >/dev/null
  sudo chmod a+r /etc/apt/keyrings/docker.asc
  printf 'Types: deb\nURIs: https://download.docker.com/linux/ubuntu\nSuites: %s\nComponents: stable\nArchitectures: %s\nSigned-By: /etc/apt/keyrings/docker.asc\n' \
    "$codename" "$(dpkg --print-architecture)" |
    sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  if ! id -nG "$USER" | tr ' ' '\n' | grep -qx docker; then
    if confirm "Add $USER to the docker group? This takes effect after logging out."; then
      sudo usermod -aG docker "$USER"
      record_manual "Log out and back in to activate Docker group membership"
    fi
  fi
}

ensure_wezterm_linux() {
  local has_wezterm=0
  if command -v wezterm >/dev/null 2>&1; then
    has_wezterm=1
    record_current "wezterm:$(wezterm --version 2>/dev/null | head -n1)"
  else
    record_missing "wezterm-native"
  fi

  if [ "$INSTALL_ONLY" -eq 1 ] && [ "$has_wezterm" -eq 1 ]; then
    return
  fi

  log "reconciling WezTerm from its official stable APT repository"
  if [ "$DRY_RUN" -eq 1 ] || [ "$TEST_MODE" -eq 1 ]; then
    log "[dry-run] configure https://apt.fury.io/wez and install/upgrade wezterm"
    return
  fi
  curl -fsSL https://apt.fury.io/wez/gpg.key |
    sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
  printf '%s\n' 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' |
    sudo tee /etc/apt/sources.list.d/wezterm.list >/dev/null
  sudo chmod 0644 /usr/share/keyrings/wezterm-fury.gpg
  sudo apt-get update
  sudo apt-get install -y wezterm
}

ensure_logseq_linux() {
  if flatpak --user info com.logseq.Logseq >/dev/null 2>&1; then
    record_current "flatpak:com.logseq.Logseq"
    if [ "$INSTALL_ONLY" -eq 0 ]; then
      run flatpak --user update -y com.logseq.Logseq
    fi
  else
    record_missing "flatpak:com.logseq.Logseq"
    run flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    run flatpak --user install -y flathub com.logseq.Logseq
  fi
}

ensure_windows_host() {
  [ "$IS_WSL" -eq 1 ] || return 0
  [ "$WINDOWS_HOST_DONE" -eq 0 ] || return 0
  WINDOWS_HOST_DONE=1
  local powershell
  powershell="$(command -v powershell.exe 2>/dev/null || command -v pwsh.exe 2>/dev/null || true)"
  if [ -z "$powershell" ]; then
    record_manual "PowerShell is unavailable from WSL; install Windows GUI apps manually"
    return
  fi
  local windows_script="$SCRIPT_DIR/scripts/windows-host.ps1"
  [ -f "$windows_script" ] || die "missing Windows host helper: $windows_script"
  local args=(-NoLogo -NoProfile -ExecutionPolicy Bypass -File "$(wslpath -w "$windows_script")" -Repository "$REPO_URL")
  [ "$DRY_RUN" -eq 1 ] && args+=(-DryRun)
  [ "$INSTALL_ONLY" -eq 1 ] && args+=(-InstallOnly)
  [ "$ASSUME_YES" -eq 1 ] && args+=(-Yes)
  run "$powershell" "${args[@]}"
}

ensure_chezmoi() {
  local latest installed
  latest="$(github_latest_tag twpayne/chezmoi)"
  [ -n "$latest" ] || die "could not resolve the stable chezmoi release"
  if command -v chezmoi >/dev/null 2>&1; then
    installed="$(chezmoi --version | head -n1)"
    if ! needs_release_update chezmoi "$installed" "$latest"; then
      record_current "chezmoi:${latest#v}"
      return
    fi
    record_outdated "chezmoi:${installed:-unknown}->${latest#v}"
    [ "$INSTALL_ONLY" -eq 0 ] || return 0
  else
    record_missing "chezmoi:${latest#v}"
  fi

  if [ "$OS" = "darwin" ] && command -v brew >/dev/null 2>&1; then
    run brew install chezmoi
  else
    if [ "$DRY_RUN" -eq 1 ] || [ "$TEST_MODE" -eq 1 ]; then
      log "[dry-run] install chezmoi to $HOME/.local/bin"
    else
      sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
    fi
  fi
}

bootstrap_repository_if_needed() {
  if [ -f "$SCRIPT_DIR/.chezmoi.toml.tmpl" ] || [ "$TEST_MODE" -eq 1 ]; then
    return
  fi
  [ "$BOOTSTRAP_REEXECUTED" -eq 0 ] || die "could not locate the checked-out bootstrap"

  log "initializing chezmoi repository: $REPO_URL"
  run chezmoi init "$REPO_URL"
  if [ "$DRY_RUN" -eq 1 ]; then
    log "[dry-run] re-execute install.sh from the chezmoi source directory"
    exit 0
  fi
  local source_script
  source_script="$(chezmoi source-path)/install.sh"
  [ -x "$source_script" ] || chmod +x "$source_script"
  DOTFILES_BOOTSTRAP_REEXECUTED=1 exec "$source_script" "$@"
}

apply_dotfiles() {
  [ "$APPLY_DOTFILES" -eq 1 ] || return 0
  if ! command -v chezmoi >/dev/null 2>&1; then
    [ "$DRY_RUN" -eq 1 ] && log "[dry-run] chezmoi init/apply" && return
    die "chezmoi is unavailable"
  fi

  local source_path
  source_path="$(chezmoi source-path 2>/dev/null || true)"
  if [ -z "$source_path" ] || [ ! -d "$source_path" ]; then
    run chezmoi init "$REPO_URL"
  fi

  # Regenerate machine-local data if the repository template changed. This is
  # required on the audited machine, whose current chezmoi config is missing.
  run chezmoi init
  if [ "$DRY_RUN" -eq 1 ]; then
    run chezmoi diff --no-pager
  else
    run chezmoi apply --verbose
  fi
}

maybe_change_shell() {
  [ "$OS" = "linux" ] || return 0
  command -v zsh >/dev/null 2>&1 || return 0
  local zsh_path current_shell
  zsh_path="$(command -v zsh)"
  current_shell="${SHELL:-}"
  [ "$current_shell" = "$zsh_path" ] && return
  if confirm "Change the default shell to $zsh_path?"; then
    run chsh -s "$zsh_path"
    record_manual "Start a new login session to use Zsh as the default shell"
  else
    record_manual "Default shell remains ${current_shell:-unknown}"
  fi
}

verify_installation() {
  log "verifying managed commands"
  local required="git zsh nvim lazygit lazydocker starship docker"
  [ "$PROFILE" = "workstation" ] && required="$required node php composer btop"
  local command_name
  for command_name in $required; do
    if command -v "$command_name" >/dev/null 2>&1; then
      record_current "verified:$command_name"
    else
      record_manual "Verification pending: $command_name is not currently on PATH"
    fi
  done

  if command -v fc-match >/dev/null 2>&1; then
    local matched_font
    matched_font="$(fc-match -f '%{family}' 'BlexMono Nerd Font Mono' 2>/dev/null || true)"
    case "$matched_font" in
      *BlexMono*) record_current "verified:BlexMono Nerd Font Mono" ;;
      *) record_manual "Font cache has not resolved BlexMono Nerd Font Mono yet" ;;
    esac
  fi

  if command -v zsh >/dev/null 2>&1 && [ -f "$HOME/.zshrc" ]; then
    if zsh -dfn "$HOME/.zshrc"; then
      record_current "verified:zsh-syntax"
    else
      record_manual "Zsh syntax verification failed"
    fi
  fi
}

print_section() {
  local title="$1"
  local content="$2"
  [ -n "$content" ] || return 0
  printf '\n%s:\n%s\n' "$title" "$content"
}

print_summary() {
  printf '\n[dotfiles] Reconciliation summary (installer v%s)\n' "$SCRIPT_VERSION"
  print_section "Current/verified" "$CURRENT_ITEMS"
  print_section "Missing at inventory time" "$MISSING_ITEMS"
  print_section "Updated or update available" "$OUTDATED_ITEMS"
  print_section "Manual follow-up" "$MANUAL_ITEMS"
}

main() {
  parse_args "$@"
  local script_parent
  script_parent="$(dirname -- "$0")"
  if ! SCRIPT_DIR="$(CDPATH='' cd -- "$script_parent" 2>/dev/null && pwd -P)"; then
    SCRIPT_DIR="$(pwd)"
  fi
  detect_platform
  export PATH="$HOME/.local/bin:$PATH"
  export DOTFILES_PROFILE="$PROFILE"
  if [ "$DRY_RUN" -eq 0 ]; then
    confirm "Reconcile the managed $PROFILE development stack on this machine?" ||
      die "reconciliation cancelled"
  fi

  if [ "$OS" = "linux" ]; then
    ensure_linux_packages
  else
    ensure_macos_packages
  fi

  ensure_chezmoi
  bootstrap_repository_if_needed "$@"
  ensure_oh_my_zsh

  if [ "$OS" = "linux" ]; then
    ensure_neovim_linux
    ensure_github_binaries_linux
    if [ "$IS_WSL" -eq 0 ]; then
      ensure_nerd_font
      ensure_wezterm_linux
      ensure_logseq_linux
    fi
    ensure_docker_linux
  else
    # Homebrew owns application and CLI upgrades on macOS; the font remains a
    # user-local upstream asset.
    ensure_nerd_font
  fi

  ensure_nvm_node
  ensure_composer
  if [ "$IS_WSL" -eq 1 ]; then
    ensure_windows_host
  fi
  apply_dotfiles
  maybe_change_shell
  verify_installation
  print_summary
}

main "$@"
