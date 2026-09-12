# Zed Configuration

Zed uses its native Vim mode with the VS Code base keymap. The custom bindings
keep the high-value Neovim workflow while using only documented Zed actions.
Zed installation, authentication, and application state are not managed here.
The extensions required by this configuration are installed declaratively with
Zed's `auto_install_extensions` setting.

## Laravel and Blade

The managed Laravel workflow combines these Zed extensions:

- Laravel Community Edition for framework-aware views, routes, configuration,
  translations, components, Livewire, Eloquent, hover, references, rename,
  completion, diagnostics, quick actions, and outlines.
- Blade for syntax highlighting, PHP/JavaScript/CSS injections, directive
  folding, indentation, tag matching, and the template outline.
- PHP/Intelephense for ordinary PHP symbols and types.
- Emmet and Tailwind CSS for template markup and class completion.

Zed explicitly classifies `*.blade.php` as `Blade`. PHP and Blade attach one
general PHP server (Intelephense) alongside the framework-aware Laravel server;
the other PHP servers are disabled to avoid duplicate results.

As in Neovim, PHP and Blade formatting is manual. Use `Space c f`. Blade runs
`blade-formatter --stdin`, installed by the workstation bootstrap. A project can
customize it with `.bladeformatterrc.json`, using camel-case keys such as
`indentSize` and `wrapLineLength`.

After the first apply, start Zed with network access once so it can install the
declared extensions and their language servers. Then run `lsp: restart` or
restart Zed. Laravel features require opening the Laravel project directory,
not an isolated PHP or Blade file.

## Core workflow

`Space` is the leader only in Vim normal mode. Zed's which-key popup displays
the available continuation keys.

| Area | Keys | Behavior |
|---|---|---|
| Mode/save | `jk`, `Ctrl+s` | Leave insert mode; save |
| Panes | `Ctrl+h/j/k/l` | Focus left/down/up/right |
| Resize | `Ctrl+Alt+h/j/k/l` | Resize toward the selected direction |
| Splits | `Space -`, `Space \|` | Split below; split right |
| Layout | `Space w e/m/c` | Equalize; zoom editor; close pane |
| Buffers | `Shift+h/l`, `[b`/`]b` | Previous/next tab |
| Buffer actions | `Space b b/n/p/d/o` | Alternate/next/previous/close/close others |
| Find | `Space f f/g/b/d`, `Space /` | Files/project/tabs/diagnostics; buffer replace |
| LSP | `gd/gr/gi/gt` | Definition/references/implementation/type definition |
| Code | `Space l a/r/k`, `Space c f` | Actions/rename/signature help/format |
| Diagnostics | `[d`, `]d` | Previous/next diagnostic |
| Git changes | `[h`, `]h` | Previous/next hunk |
| Git actions | `Space g g/b`, `Space h s/r/d` | Panel/blame; stage/restore/diff |
| Panels | `Space e`, `Space t f` | Project panel; terminal |
| Tasks | `Space t r/n` | Task picker; nearest runnable |
| Debug | `Space d b` | Toggle breakpoint |
| Display | `Space z` | Toggle centered layout |

Inside docks, `Ctrl+w h/j/k/l` moves between panes and panels using Zed's
documented dock-navigation pattern. Search views use `Ctrl+n/p`; the project
panel supports `j/k`, `a`, `Shift+a`, `r`, `d`, `x`, `c`, and `p` while it is
not editing a name.

The former Zed bindings `Space c a`, `Space r n`, and `Space f m` remain as
compatibility aliases.

## Edit predictions

GitHub Copilot remains Zed's prediction provider and keeps its normal eager and
Tab behavior. Neovim-compatible controls are also available:

| Keys | Behavior |
|---|---|
| `Alt+l` | Accept prediction |
| `Alt+]` / `Alt+[` | Next/previous prediction |
| `Ctrl+]` | Hide suggestions |

Provider credentials stay in Zed's credential storage and are never committed.

## Native alternatives

Zed does not reproduce plugin UIs one-for-one. Its file finder, project search,
diagnostics view, Git panel, tasks, debugger, project panel, and tab switcher
replace the corresponding Telescope, Trouble, LazyGit/Gitsigns, Overseer,
Neotest/DAP, Neo-tree, and buffer-picker flows. No binding is added where Zed
does not expose a documented equivalent.

## Validation

After an update:

1. Parse `settings.json` as JSON and `keymap.json` as JSON-with-comments.
2. Check each action against <https://zed.dev/docs/all-actions>.
3. Run Zed with `--foreground`; there must be no settings, keymap, action, or
   context errors in the foreground output or in `zed: open log`.
4. Open `zed: open keymap`, use its conflict filter, and verify custom bindings
   resolve to the intended actions. Overrides of base Vim/VS Code bindings are
   intentional; conflicting custom bindings are not.
5. Use `dev: open key context view` in normal mode, insert mode, search, the
   project panel, terminal, and docks. Leader mappings must appear only in Vim
   normal mode, and an insert-mode `Space z` must type text normally.
6. Smoke-test search navigation, pane operations, buffers, LSP actions, Git
   hunks, tasks, breakpoint toggling, and prediction controls.

For a pre-apply check, copy the candidate files under a temporary
`XDG_CONFIG_HOME/zed` and launch a separate instance with a temporary
`--user-data-dir`. This validates Zed's real parser without touching the normal
profile.
