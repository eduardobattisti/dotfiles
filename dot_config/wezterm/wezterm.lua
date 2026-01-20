local wezterm = require("wezterm")
local session_manager = require("wezterm-session-manager/session-manager")
local mux = wezterm.mux
local act = wezterm.action

-- Custom modules
local platform = require("utils.platform")
local tab = require("utils.tab")
local theme = require("utils.theme")

local keys_module = require("utils.keys")
local status_module = require("utils.status")

-- Configuration object
local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- ===========================
-- APPEARANCE & THEME
-- ===========================

config.front_end = "WebGpu" -- More efficient than OpenGL
config.webgpu_power_preference = "HighPerformance"

-- Font configuration
config.font = wezterm.font_with_fallback({
  {
    family = "IBM Plex Mono",
    weight = "Regular",
    harfbuzz_features = {
      "calt=1", -- Contextual alternates (ligatures)
      "clig=1", -- Contextual ligatures
      "liga=1", -- Standard ligatures
    },
  },
  { family = "JetBrains Mono", weight = "Regular" },
  { family = "Source Code Pro", weight = "Regular" },
  -- Emoji and symbol fallbacks
  { family = "Noto Color Emoji" },
  { family = "Segoe UI Emoji" }, -- Windows
  { family = "Apple Color Emoji" }, -- macOS
})
config.font_size = platform.get_default_font_size()

-- Better font rendering
config.freetype_load_target = "Normal"
config.freetype_render_target = "Normal"

-- Window appearance
config.window_background_opacity = 0.9
config.window_padding = platform.get_window_padding()

-- Better window management
config.window_decorations = "RESIZE"
config.window_close_confirmation = "NeverPrompt"
config.skip_close_confirmation_for_processes_named = {
  "bash",
  "sh",
  "zsh",
  "fish",
  "tmux",
  "nvim",
  "vim",
}

-- Cursor configuration
config.default_cursor_style = "SteadyBlock"
config.cursor_blink_rate = 500

-- Tab bar configuration
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.show_new_tab_button_in_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true

-- Text rendering improvements
config.foreground_text_hsb = {
  hue = 1.0,
  saturation = 1.2,
  brightness = 1.5,
}

-- Window sizing
config.initial_cols = 120
config.initial_rows = 30

-- Tiling desktop environment support (Linux)
if platform.is_linux then
  config.tiling_desktop_environments = {
    "X11 LG3D",
    "X11 bspwm",
    "X11 i3",
    "X11 dwm",
  }
end

-- ===========================
-- LEADER KEY CONFIGURATION
-- ===========================

config.leader = keys_module.leader_key
config.keys = keys_module.keys

-- ===========================
-- MOUSE BINDINGS
-- ===========================

-- Wayland clipboard workaround
config.enable_wayland = true

-- Selection behavior - automatically copy on select
config.selection_word_boundary = " \t\n{}[]()\"'`,;:@"

config.mouse_bindings = {
  -- Copy on select (single click drag and release)
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "NONE",
    action = act.CompleteSelection("Clipboard"),
  },
  -- Double-click select word and copy
  {
    event = { Up = { streak = 2, button = "Left" } },
    mods = "NONE",
    action = act.CompleteSelection("Clipboard"),
  },
  -- Triple click selects line and copy
  {
    event = { Down = { streak = 3, button = "Left" } },
    mods = "NONE",
    action = act.SelectTextAtMouseCursor("Line"),
  },
  {
    event = { Up = { streak = 3, button = "Left" } },
    mods = "NONE",
    action = act.CompleteSelection("Clipboard"),
  },
  -- Right click: copy if selection exists, otherwise paste
  {
    event = { Down = { streak = 1, button = "Right" } },
    mods = "NONE",
    action = wezterm.action_callback(function(window, pane)
      local has_selection = window:get_selection_text_for_pane(pane) ~= ""
      if has_selection then
        window:perform_action(act.CopyTo("Clipboard"), pane)
        window:perform_action(act.ClearSelection, pane)
      else
        window:perform_action(act.PasteFrom("Clipboard"), pane)
      end
    end),
  },
  -- Ctrl+click opens links
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "CTRL",
    action = act.OpenLinkAtMouseCursor,
  },
}

-- Additional key bindings for special Copy/Paste keys (some keyboards have dedicated keys)
table.insert(config.keys, { key = "Copy", mods = "NONE", action = act.CopyTo("Clipboard") })
table.insert(config.keys, { key = "Paste", mods = "NONE", action = act.PasteFrom("Clipboard") })

-- ===========================
-- LAUNCH MENU (Cross-platform)
-- ===========================

local function get_launch_menu()
  local menu = {}

  if platform.is_windows then
    table.insert(menu, {
      label = "PowerShell",
      args = { "powershell.exe", "-NoLogo" },
    })
    table.insert(menu, {
      label = "CMD",
      args = { "cmd.exe" },
    })

    -- Add WSL distributions
    local wsl_distros = platform.detect_wsl_distros()
    for _, distro in ipairs(wsl_distros) do
      table.insert(menu, {
        label = "WSL - " .. distro,
        args = { "wsl.exe", "-d", distro },
      })
    end
  else
    table.insert(menu, {
      label = "Bash",
      args = { "bash", "-l" },
    })
    table.insert(menu, {
      label = "Zsh",
      args = { "zsh", "-l" },
    })
    table.insert(menu, {
      label = "Fish",
      args = { "fish", "-l" },
    })
  end

  -- Universal tools (if available)
  table.insert(menu, {
    label = "LazyGit",
    args = { "lazygit" },
  })
  table.insert(menu, {
    label = "System Monitor",
    args = platform.is_windows and { "btop" } or { "btop" },
  })
  table.insert(menu, {
    label = "File Manager",
    args = { "ranger" },
  })

  return menu
end

config.launch_menu = get_launch_menu()

-- ===========================
-- WSL DOMAINS (Auto-detected on Windows)
-- ===========================

if platform.is_windows then
  local wsl_distros = platform.detect_wsl_distros()
  if #wsl_distros > 0 then
    config.wsl_domains = {}
    for _, distro in ipairs(wsl_distros) do
      table.insert(config.wsl_domains, {
        name = "WSL:" .. distro,
        distribution = distro,
        default_cwd = "~",
      })
    end
    -- Optionally set first distro as default
    -- config.default_domain = "WSL:" .. wsl_distros[1]
  end
end

-- ===========================
-- EVENT HANDLERS
-- ===========================

-- Session management events
wezterm.on("save_session", function(window)
  session_manager.save_state(window)
end)

wezterm.on("load_session", function(window)
  session_manager.load_state(window)
end)

wezterm.on("restore_session", function(window)
  session_manager.restore_state(window)
end)

-- Option 1: Use enhanced status bar (recommended)
-- Note: Simplified for WSL compatibility - removed battery, RAM, time/date monitoring
status_module.setup(config, theme.colors)

-- ===========================
-- PERFORMANCE OPTIMIZATIONS
-- ===========================

config.scrollback_lines = 5000
config.enable_scroll_bar = true
config.max_fps = 60
config.animation_fps = 30

-- ===========================
-- INITIALIZE CUSTOM MODULES
-- ===========================

-- Setup custom tab and theme modules
tab.setup(config)
theme.setup(config)

-- ===========================
-- ADDITIONAL FEATURES
-- ===========================

-- Automatically enter copy mode on scroll
config.alternate_buffer_wheel_scroll_speed = 3

-- Bell configuration
config.audible_bell = "Disabled"
config.visual_bell = {
  fade_in_duration_ms = 75,
  fade_out_duration_ms = 75,
  target = "CursorColor",
}

-- Hyperlink detection
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Add rule for selecting file paths
table.insert(config.hyperlink_rules, {
  regex = [[\b\w+://(?:[\w.-]+)\.[a-z]{2,15}\S*\b]],
  format = "$0",
})

-- Unicode and emoji support
config.unicode_version = 14

-- DPI configuration (platform-specific)
if platform.is_windows then
  config.dpi = 96
end

-- ===========================
-- RETURN CONFIGURATION
-- ===========================

return config
