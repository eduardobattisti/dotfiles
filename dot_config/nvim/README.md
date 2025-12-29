# Neovim Configuration

A modular, fast, and modern Neovim configuration.

## Features

- **Lazy-loaded plugins** with [lazy.nvim](https://github.com/folke/lazy.nvim)
- LSP, Treesitter, autocompletion, and more
- Modular structure for easy customization
- Custom Treesitter queries
- Health checks and diagnostics
- Sensible defaults for editing, navigation, and development

## Getting Started

1. **Install Neovim** (version >= 0.9.4 recommended)
2. **Clone this repo** to your config directory:
   ```sh
   git clone <this-repo-url> ~/.config/nvim
   ```
3. **Start Neovim**  
   The first launch will automatically install plugins.

## Directory Structure

```
nvim/
├── after/queries/         # Custom Treesitter queries
├── lua/
│   ├── config/            # Core settings, mappings, LSP config
│   │   ├── autocmds.lua
│   │   ├── init.lua
│   │   ├── mappings.lua
│   │   ├── options.lua
│   │   └── lsp/
│   │       ├── servers/   # LSP server configs
│   │       └── utils.lua
│   ├── plugins/           # One file per plugin
│   ├── utils/             # Utility scripts (e.g., health checks)
│   └── init.lua
├── init.lua               # Entry point
├── lazy-lock.json         # Plugin lockfile
└── README.md
```

## Customization

- **Add plugins:**  
  Create a new file in `lua/plugins/` with your plugin spec.
- **Change settings:**  
  Edit files in `lua/config/` for options, mappings, and autocmds.
- **LSP servers:**  
  Add or modify configs in `lua/config/lsp/servers/`.

## Credits & Inspiration

- Based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)
- Uses [lazy.nvim](https://github.com/folke/lazy.nvim) for plugin management

---

Feel free to fork and adapt for your own workflow!