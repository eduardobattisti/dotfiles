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

1. **Install Neovim** (version >= 0.11)
2. **Apply the configuration through chezmoi:**
   ```sh
   chezmoi apply ~/.config/nvim
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

## AI workflow (CLI + in-editor)

- CLI agents handle prompts, analysis, refactoring, and other assisted tasks.
- Neovim uses [Minuet](https://github.com/milanglacier/minuet-ai.nvim) only for
  inline suggestions. Chat and agent panels remain CLI-only.
- Suggestions are manual by default. Use `Alt+]`/`Alt+[` to request or cycle,
  `Alt+l` to accept, and `Ctrl+]` to dismiss.

Select a backend per machine in the unmanaged `~/.config/zsh/.secrets` file:

```sh
# One of: openai, claude, gemini, codestral, openai_compatible,
# openai_fim_compatible, ollama, none
export NVIM_AI_PROVIDER=gemini
export GEMINI_API_KEY='machine-local-secret'

# Optional: automatically request suggestions while typing.
export NVIM_AI_AUTO_TRIGGER=1
```

Built-in Minuet providers read their standard environment variables:
`OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, `GEMINI_API_KEY`, or
`CODESTRAL_API_KEY`. For an OpenAI-compatible service, configure:

```sh
export NVIM_AI_PROVIDER=openai_compatible
export NVIM_AI_API_KEY_ENV=OPENROUTER_API_KEY
export OPENROUTER_API_KEY='machine-local-secret'
export NVIM_AI_ENDPOINT='https://openrouter.ai/api/v1/chat/completions'
export NVIM_AI_MODEL='provider/model-name'
export NVIM_AI_PROVIDER_NAME=OpenRouter
```

`NVIM_AI_API_KEY_ENV` contains the name of the key variable, never the key
itself. Restart Neovim after changing backends. Within a running Minuet session,
`:Minuet change_model` can select another configured model.

## Credits & Inspiration

- Based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)
- Uses [lazy.nvim](https://github.com/folke/lazy.nvim) for plugin management

---

Feel free to fork and adapt for your own workflow!
