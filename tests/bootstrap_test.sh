#!/usr/bin/env bash

set -euo pipefail

ROOT="$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd -P)"
INSTALLER="$ROOT/install.sh"
FAILURES=0

assert_contains() {
  local output="$1"
  local expected="$2"
  local name="$3"
  if printf '%s' "$output" | grep -Fq -- "$expected"; then
    printf 'ok - %s\n' "$name"
  else
    printf 'not ok - %s (missing: %s)\n' "$name" "$expected"
    FAILURES=$((FAILURES + 1))
  fi
}

bash -n "$INSTALLER"
printf 'ok - installer has valid Bash syntax\n'
assert_contains "$("$INSTALLER" --help)" "--install-only" "documents install-only mode"

if grep -Eq 'apt(-get)? (full-upgrade|dist-upgrade)|brew upgrade($|[[:space:]]+--greedy)' "$INSTALLER"; then
  printf 'not ok - installer contains a full-system upgrade command\n'
  FAILURES=$((FAILURES + 1))
else
  printf 'ok - installer contains only targeted upgrades\n'
fi

output="$(
  DOTFILES_TEST_MODE=1 \
    DOTFILES_TEST_OS=Linux \
    DOTFILES_TEST_DISTRO=ubuntu \
    DOTFILES_TEST_ARCH=x86_64 \
    HOME="${TMPDIR:-/tmp}/dotfiles-test-linux-home" \
    bash "$INSTALLER" --dry-run --yes --no-apply 2>&1
)"
assert_contains "$output" "os=linux distro=ubuntu arch=amd64 wsl=0" "detects Ubuntu amd64"
assert_contains "$output" "apt-get install" "plans targeted APT reconciliation"
assert_contains "$output" "BlexMono Nerd Font" "plans font reconciliation"
assert_contains "$output" "IBMPlexMono.zip" "uses the Nerd Fonts IBM Plex Mono release asset"
assert_contains "$output" "com.logseq.Logseq" "plans Logseq reconciliation"
assert_contains "$output" "Docker Engine" "plans native Docker reconciliation"

assert_contains "$(cat "$ROOT/scripts/windows-host.ps1")" "/IBMPlexMono.zip" \
  "uses the Nerd Fonts IBM Plex Mono release asset on Windows"

output="$(
  DOTFILES_TEST_MODE=1 \
    DOTFILES_TEST_OS=Linux \
    DOTFILES_TEST_DISTRO=ubuntu \
    DOTFILES_TEST_ARCH=aarch64 \
    DOTFILES_TEST_WSL=1 \
    HOME="${TMPDIR:-/tmp}/dotfiles-test-wsl-home" \
    bash "$INSTALLER" --dry-run --install-only --yes --no-apply 2>&1
)"
assert_contains "$output" "arch=arm64 wsl=1" "detects WSL arm64"
assert_contains "$output" "Windows GUI apps manually" "reports unavailable host bridge in isolated test"

output="$(
  DOTFILES_TEST_MODE=1 \
    DOTFILES_TEST_OS=Darwin \
    DOTFILES_TEST_ARCH=arm64 \
    HOME="${TMPDIR:-/tmp}/dotfiles-test-macos-home" \
    bash "$INSTALLER" --dry-run --yes --no-apply 2>&1
)"
assert_contains "$output" "os=darwin distro=macos arch=arm64" "detects macOS arm64"
assert_contains "$output" "install Homebrew" "plans Homebrew bootstrap"

if [ "$FAILURES" -ne 0 ]; then
  exit 1
fi

printf 'All bootstrap tests passed.\n'
