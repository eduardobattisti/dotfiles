# WezTerm Enhanced Configuration - Key Bindings Reference

## Leader Key
**Ctrl+A** - Leader key (timeout: 1 second)

To send Ctrl+A to the terminal itself, use **Leader + Ctrl+A**

---

## 🚀 Quick Applications

| Key Combination | Action |
|----------------|--------|
| `Leader + g` | Open LazyGit |
| `Leader + f` | Open Ranger (file manager) |
| `Leader + m` | Open btop (system monitor) |
| `Leader + v` | Open Neovim |

---

## 🖼️ Panes

### Navigation
| Key Combination | Action |
|----------------|--------|
| `Ctrl + h/j/k/l` | Smart pane navigation (works with vim/nvim) |
| `Ctrl+Shift + ←/↓/↑/→` | Navigate panes (fallback) |
| `Leader + h/j/k/l` | Navigate panes (tmux-style) |

### Splitting
| Key Combination | Action |
|----------------|--------|
| `Leader + \` | Split horizontally |
| `Leader + \|` | Split horizontally (alternative) |
| `Leader + -` | Split vertically |
| `Leader + _` | Split vertically (alternative) |

### Resizing
| Key Combination | Action |
|----------------|--------|
| `Ctrl+Shift + h/j/k/l` | Resize pane (3 units) |

### Management
| Key Combination | Action |
|----------------|--------|
| `Leader + z` | Toggle pane zoom |
| `Leader + x` | Close current pane (with confirmation) |
| `Leader + q` | Select pane interactively |
| `Leader + !` | Swap pane with active |

---

## 📋 Tabs

### Basic Operations
| Key Combination | Action |
|----------------|--------|
| `Leader + c` | Create new tab |
| `Leader + n` | Next tab (smart) |
| `Leader + p` | Previous tab (smart) |
| `Leader + &` | Close current tab (with confirmation) |

### Navigation
| Key Combination | Action |
|----------------|--------|
| `Tab` | Next tab |
| `Ctrl+Shift + Tab` | Previous tab |
| `Leader + [` | Previous tab |
| `Leader + ]` | Next tab |
| `Leader + 1-9` | Go to tab N |
| `Alt + 1-9` | Go to tab N (quick access) |

### Management
| Key Combination | Action |
|----------------|--------|
| `Leader + e` | Rename current tab |

---

## 🌐 Workspaces

| Key Combination | Action |
|----------------|--------|
| `Leader + w` | Switch workspace (with fuzzy finder) |
| `Leader + W` | Create new workspace |

---

## 📜 Scrolling & Navigation

| Key Combination | Action |
|----------------|--------|
| `Ctrl + u` | Scroll up half page |
| `Ctrl + d` | Scroll down half page |
| `Ctrl+Alt + k` | Scroll up 3 lines |
| `Ctrl+Alt + j` | Scroll down 3 lines |
| `Ctrl + Home` | Scroll to top |
| `Ctrl + End` | Scroll to bottom |

---

## 📝 Copy & Search Mode

| Key Combination | Action |
|----------------|--------|
| `Leader + Space` | Enter enhanced copy mode |
| `Leader + /` | Search (case insensitive) |
| `Leader + ?` | Search (case sensitive) |

---

## 🔧 System & Clipboard

| Key Combination | Action |
|----------------|--------|
| `Ctrl + V` | Paste from clipboard |
| `Ctrl + C` | Copy to clipboard |

---

## 🎨 Font & Display

| Key Combination | Action |
|----------------|--------|
| `Ctrl + =` | Increase font size |
| `Ctrl + -` | Decrease font size |
| `Ctrl + 0` | Reset font size |
| `F11` | Toggle fullscreen |

---

## 🚀 Launchers & Selectors

| Key Combination | Action |
|----------------|--------|
| `Leader + l` | Show launcher |
| `Leader + P` | Command palette |
| `Leader + o` | Project launcher (with Git repos) |
| `Leader + D` | Quick directory selector |
| `Leader + :` | Quick command runner |

---

## 🏗️ Quick Layouts

| Key Combination | Action |
|----------------|--------|
| `Leader + Alt + 1` | IDE layout (main + sidebar + bottom) |
| `Leader + Alt + 2` | Terminal layout (main + bottom split) |
| `Leader + Alt + 3` | Quad layout (2x2 grid) |

---

## 💾 Session Management

| Key Combination | Action |
|----------------|--------|
| `Leader + s` | Save session (with custom name) |
| `Leader + S` | Save session (default name) |
| `Leader + r` | Restore session |
| `Leader + L` | Load session |

---

## 🐛 Debug & Configuration

| Key Combination | Action |
|----------------|--------|
| `F5` | Reload configuration |
| `F12` | Show debug overlay |
| `Ctrl+Shift + N` | New window |

---

## 🖱️ Mouse Actions

| Action | Result |
|--------|--------|
| Triple click | Select semantic zone (word, URL, path) |
| Right click | Context menu (copy if selection, paste if none) |
| Ctrl + click | Open link |

---

## 💡 Pro Tips

1. **Smart Navigation**: The `Ctrl + h/j/k/l` bindings work seamlessly with vim/nvim - they'll navigate vim splits when in vim, or WezTerm panes otherwise.

2. **Project Launcher**: `Leader + o` automatically finds Git repositories in your home directory and common project locations.

3. **Quick Commands**: Use `Leader + :` to run any command in a new tab without typing the full spawn command.

4. **Workspace Workflow**: Create workspaces for different projects/contexts and switch between them with `Leader + w`.

5. **Copy Mode**: `Leader + Space` enters an enhanced copy mode that starts at the line beginning - perfect for selecting command output.

6. **Tab Numbers**: Both `Leader + N` and `Alt + N` work for tab navigation - use whichever feels more comfortable.

7. **Session Persistence**: Save your current window/pane layout with `Leader + s` and restore it later with `Leader + r`.

---

## 🔄 Fallback Options

If the enhanced key bindings module fails to load, the configuration automatically falls back to basic key bindings:

- `Leader + c` - New tab
- `Leader + x` - Close pane
- `Ctrl + V` - Paste
- Arrow key navigation with `Ctrl+Shift`

---

## 📂 Configuration Structure

```
~/.config/wezterm/
├── wezterm.lua           # Main configuration
├── utils/
│   ├── keys.lua         # Enhanced key bindings
│   ├── status.lua       # Enhanced status bar
│   ├── tab.lua          # Tab customization
│   └── theme.lua        # Color theme
├── validate_config.lua   # Configuration validator
└── KEYBINDINGS.md       # This file
```

Run `wezterm --config-file validate_config.lua start` to validate your configuration.