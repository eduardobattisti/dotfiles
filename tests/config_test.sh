#!/usr/bin/env bash
set -euo pipefail
repo=$(cd -- "$(dirname -- "$0")/.." && pwd)
scratch=$(mktemp -d /tmp/dotfiles-config-test.XXXXXX)

# Render with no generated chezmoi config: existing machines must still work.
chezmoi --source "$repo" --config "$scratch/chezmoi.toml" cat "$HOME/.zshrc" > "$scratch/zshrc"
zsh -n "$scratch/zshrc"
for file in "$repo"/dot_config/zsh/*.zsh; do zsh -n "$file"; done
chezmoi --source "$repo" --config "$scratch/chezmoi.toml" managed > "$scratch/managed"
rg -q 'config/nvim/lua/utils/buffer_policy.lua' "$scratch/managed"
printf 'PASS template rendering without generated config and Zsh syntax\n'

nvim_bin=${NVIM_BIN:-nvim}
"$nvim_bin" -u NONE -i NONE --headless "+lua for _, f in ipairs(vim.fn.glob('$repo/dot_config/**/*.lua', false, true)) do assert(loadfile(f), f) end" +qa
printf 'PASS Lua syntax\n'

# A partially staged file with spaces must retain its unstaged changes.
git init -q "$scratch/repo"
git -C "$scratch/repo" config user.name 'Config Test'
git -C "$scratch/repo" config user.email 'test@example.invalid'
printf 'first\nsecond\nthird\nfourth\nfifth\nsixth\nseventh\neighth\n' > "$scratch/repo/file with spaces"
git -C "$scratch/repo" add .
git -C "$scratch/repo" commit -qm initial
sed -i '1s/first/staged/' "$scratch/repo/file with spaces"
git -C "$scratch/repo" add .
sed -i '$s/eighth/unstaged/' "$scratch/repo/file with spaces"
git -C "$scratch/repo" stash push --staged -qm "user's staged change"
rg -q '^unstaged$' "$scratch/repo/file with spaces"
rg -q '^first$' "$scratch/repo/file with spaces"
git -C "$scratch/repo" diff --cached --quiet
printf 'PASS staged-only stash preserves unstaged edits\n'
printf 'Test artifacts: %s\n' "$scratch"
