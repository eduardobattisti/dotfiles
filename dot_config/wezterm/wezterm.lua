-- These are the basic's for using wezterm.
-- Mux is the mutliplexes for windows etc inside of the terminal
-- Action is to perform actions on the terminal
local wezterm = require("wezterm")
local session_manager = require("wezterm-session-manager/session-manager")
local mux = wezterm.mux
local act = wezterm.action

-- TEST TABS
local tab = require("utils.tab")
local theme = require("utils.theme")
-- TEST TABS

-- require("events.tab-title").setup({ hide_active_tab_unseen = false, unseen_icon = "circle" })
-- require("events.right-status").setup({ date_format = "%a %H:%M:%S" })
-- require("events.left-status").setup()

-- These are vars to put things in later (i dont use em all yet)
local config = {}
local keys = {}
local mouse_bindings = {}
local launch_menu = {
	{
		domain = "CurrentPaneDomain",
	},
}

-- This is for newer wezterm vertions to use the config builder
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- Default config settings
-- These are the default config settins needed to use Wezterm
-- Just add this and return config and that's all the basics you need

-- Color scheme, Wezterm has 100s of them you can see here:
-- https://wezfurlong.org/wezterm/colorschemes/index.html
config.color_scheme = 'Everforest Dark Soft (Gogh)'
config.front_end = "OpenGL"
-- This is my chosen font, we will get into installing fonts on windows later
config.font = wezterm.font_with_fallback({
	"FiraCode Nerd Font Mono",
})

config.font_size = 12
config.launch_menu = launch_menu
-- makes my cursor blink
config.default_cursor_style = "SteadyBlock"
-- config.disable_default_key_bindings = true
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

-- this adds the ability to use ctrl+v to paste the system clipboard
config.keys = { { key = "V", mods = "CTRL", action = act.PasteFrom("Clipboard") } }

-- There are mouse binding to mimc Windows Terminal and let you copy
-- To copy just highlight something and right click. Simple
mouse_bindings = {
	{
		event = { Down = { streak = 3, button = "Left" } },
		action = wezterm.action.SelectTextAtMouseCursor("SemanticZone"),
		mods = "NONE",
	},
	{
		event = { Down = { streak = 1, button = "Right" } },
		mods = "NONE",
		action = wezterm.action_callback(function(window, pane)
			local has_selection = window:get_selection_text_for_pane(pane) ~= ""
			if has_selection then
				window:perform_action(act.CopyTo("ClipboardAndPrimarySelection"), pane)
				window:perform_action(act.ClearSelection, pane)
			else
				window:perform_action(act({ PasteFrom = "Clipboard" }), pane)
			end
		end),
	},
}

config.mouse_bindings = mouse_bindings
config.tab_bar_at_bottom = true

wezterm.on("save_session", function(window)
	session_manager.save_state(window)
end)

wezterm.on("load_session", function(window)
	session_manager.load_state(window)
end)

wezterm.on("restore_session", function(window)
	session_manager.restore_state(window)
end)

wezterm.on("update-right-status", function(window, _pane)
	window:set_right_status(window:active_workspace())
end)

wezterm.on("update-status", function(window)
	-- Grab the utf8 character for the "powerline" left facing
	-- solid arrow.
	local SOLID_LEFT_ARROW = utf8.char(0xe0b2)

	-- Grab the current window's configuration, and from it the
	-- palette (this is the combination of your chosen colour scheme
	-- including any overrides).
	local color_scheme = window:effective_config().resolved_palette
	local bg = color_scheme.background
	local fg = color_scheme.foreground

	window:set_right_status(wezterm.format({
		-- First, we draw the arrow...
		{ Background = { Color = "none" } },
		{ Foreground = { Color = bg } },
		{ Text = SOLID_LEFT_ARROW },
		-- Then we draw our text
		{ Background = { Color = bg } },
		{ Foreground = { Color = fg } },
		{ Text = " " .. wezterm.hostname() .. " " },
	}))
end)

config.window_background_opacity = 0.9

config.default_cursor_style = "SteadyBlock"
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
	{
		key = "LeftArrow",
		mods = "CTRL|SHIFT",
		action = act.ActivatePaneDirection("Left"),
	},
	{
		key = "RightArrow",
		mods = "CTRL|SHIFT",
		action = act.ActivatePaneDirection("Right"),
	},
	{
		key = "UpArrow",
		mods = "CTRL|SHIFT",
		action = act.ActivatePaneDirection("Up"),
	},
	{
		key = "DownArrow",
		mods = "CTRL|SHIFT",
		action = act.ActivatePaneDirection("Down"),
	},
	{
		key = "k",
		mods = "CTRL|ALT",
		action = act.ScrollByLine(-1),
	},
	{
		key = "j",
		mods = "CTRL|ALT",
		action = act.ScrollByLine(1),
	},
	{
		key = "|",
		mods = "LEADER|SHIFT",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "-",
		mods = "LEADER",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "g",
		mods = "LEADER",
		action = act.SpawnCommandInNewTab({
			args = { "lazygit" }
		})
	},
	{
		key = "a",
		mods = "LEADER|CTRL",
		action = wezterm.action.SendKey({ key = "a", mods = "CTRL" }),
	},
	{
		key = "V",
		mods = "CTRL",
		action = act.PasteFrom("Clipboard"),
	},
	{
		key = "-",
		mods = "LEADER",
		action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "\\",
		mods = "LEADER",
		action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "h",
		mods = "CTRL|SHIFT",
		action = act.AdjustPaneSize({ "Left", 5 }),
	},
	{
		key = "l",
		mods = "CTRL|SHIFT",
		action = act.AdjustPaneSize({ "Right", 5 }),
	},
	{
		key = "j",
		mods = "CTRL|SHIFT",
		action = act.AdjustPaneSize({ "Down", 5 }),
	},
	{
		key = "k",
		mods = "CTRL|SHIFT",
		action = act.AdjustPaneSize({ "Up", 5 }),
	},
	{
		key = "z",
		mods = "LEADER",
		action = act.TogglePaneZoomState,
	},
	{
		key = "c",
		mods = "LEADER",
		action = act.SpawnTab("CurrentPaneDomain"),
	},
	{
		key = "p",
		mods = "LEADER",
		action = act.ActivateTabRelative(-1),
	},
	{
		key = "n",
		mods = "LEADER",
		action = act.ActivateTabRelative(1),
	},
	{
		key = "l",
		mods = "LEADER",
		action = act.ShowLauncher,
	},
	{
		key = "w",
		mods = "CTRL|ALT",
		action = wezterm.action.CloseCurrentPane({ confirm = true }),
	},
	{
		key = "w",
		mods = "LEADER",
		action = act.PromptInputLine({
			description = wezterm.format({
				{ Attribute = { Intensity = "Bold" } },
				{ Foreground = { AnsiColor = "Fuchsia" } },
				{ Text = "Enter name for new workspace" },
			}),
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					window:perform_action(
						act.SwitchToWorkspace({
							name = line,
						}),
						pane
					)
				end
			end),
		}),
	},
	{
		key = "e",
		mods = "LEADER",
		action = act.PromptInputLine({
			description = "Enter new name for tab",
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},
	{ key = "S", mods = "LEADER", action = wezterm.action({ EmitEvent = "save_session" }) },
	{ key = "L", mods = "LEADER", action = wezterm.action({ EmitEvent = "load_session" }) },
	{ key = "r", mods = "LEADER", action = wezterm.action({ EmitEvent = "restore_session" }) },
}

for i = 1, 9 do
	table.insert(config.keys, {
		key = tostring(i),
		mods = "LEADER",
		action = act.ActivateTab(i - 1),
	})
end

-- This is used to make my foreground (text, etc) brighter than my background
config.foreground_text_hsb = {
	hue = 1.0,
	saturation = 1.2,
	brightness = 1.5,
}

config.wsl_domains = {
	{
		name = "WSL:Ubuntu-20.04",
		distribution = "Ubuntu-20.04",
		username = "eduardobattisti",
		default_cwd = "/home/eduardobattisti",
		default_prog = { "zsh", "-l" },
	},
}

-- IMPORTANT: Sets WSL2 UBUNTU-22.04 as the default when opening Wezterm
-- config.default_domain = "WSL:Ubuntu-20.04"

tab.setup(config)
theme.setup(config)

return config
