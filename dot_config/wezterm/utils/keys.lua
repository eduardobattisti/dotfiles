local wezterm = require("wezterm")
local act = wezterm.action
local platform = require("utils.platform")

local Keys = {}

-- Logging utilities
local function log_error(msg, err)
	wezterm.log_error("[Keys] " .. msg .. ": " .. tostring(err))
end

local function safe_call(fn, fallback)
	local success, result = pcall(fn)
	if not success then
		log_error("Action failed", result)
		return fallback
	end
	return result
end

-- Smart pane navigation that works with vim/nvim
local function is_vim(pane)
	-- Neovim sets this user var (nvim/lua/config/autocmds.lua). Unlike the
	-- foreground process name it is also available for WSL, SSH and
	-- multiplexer panes.
	return pane:get_user_vars().IS_NVIM == "true"
end

-- Run a terminal tool through a login, interactive shell so it sees the PATH
-- and environment from the shell configuration (~/.local/bin, Homebrew,
-- XDG_CONFIG_HOME). On Windows the command runs inside the default WSL domain.
function Keys.tool_args(tool)
	local shell = platform.is_windows and "zsh" or (os.getenv("SHELL") or "/bin/sh")
	return { shell, "-lic", "exec " .. tool }
end

local function spawn_tool(tool)
	return act.SpawnCommandInNewTab({ args = Keys.tool_args(tool) })
end

-- Check if vim is in insert mode
local function is_in_vim_insert_mode(pane)
	local title = safe_call(function()
		return pane:get_title()
	end, "")
	return title:find("INSERT") ~= nil or title:find("REPLACE") ~= nil
end

-- Create smart navigation function
local function navigate_pane_or_vim_split(key, direction)
	return wezterm.action_callback(function(window, pane)
		if is_vim(pane) then
			-- Send the key to vim/nvim
			window:perform_action({
				SendKey = { key = key, mods = "CTRL" },
			}, pane)
		else
			-- Navigate wezterm panes
			window:perform_action({ ActivatePaneDirection = direction }, pane)
		end
	end)
end

-- Create smart scrolling function for Ctrl+U and Ctrl+D (improved)
local function smart_scroll(key, scroll_action)
	return wezterm.action_callback(function(window, pane)
		if is_vim(pane) and not is_in_vim_insert_mode(pane) then
			-- Send the key to vim/nvim only in normal mode
			window:perform_action({
				SendKey = { key = key, mods = "CTRL" },
			}, pane)
		else
			-- Use WezTerm's scroll action
			window:perform_action(scroll_action, pane)
		end
	end)
end

-- Quick directory navigation
local function quick_select_directory()
	return act.QuickSelectArgs({
		label = "open directory",
		patterns = { [[(?:~|\.{1,2})?/[^\s]+]] },
		action = wezterm.action_callback(function(window, pane)
			local url = window:get_selection_text_for_pane(pane)
			if url then
				local dir = url
				if dir:sub(1, 1) == "~" then
					dir = platform.get_home_dir() .. dir:sub(2)
				end
				window:perform_action(act.SpawnCommandInNewTab({ cwd = dir }), pane)
			end
		end),
	})
end

-- Smart tab switching with workspace awareness
local function smart_tab_switch(direction)
	return wezterm.action_callback(function(window, pane)
		local tabs = window:mux_window():tabs()
		local current_idx = window:active_tab():tab_id()

		-- Find current tab index
		local current_pos = 1
		for i, tab in ipairs(tabs) do
			if tab:tab_id() == current_idx then
				current_pos = i
				break
			end
		end

		local new_pos
		if direction > 0 then
			new_pos = current_pos % #tabs + 1
		else
			new_pos = current_pos == 1 and #tabs or current_pos - 1
		end

		window:perform_action(act.ActivateTab(new_pos - 1), pane)
	end)
end

-- Workspace switcher with fuzzy matching
local function workspace_switcher()
	return wezterm.action_callback(function(window, pane)
		local workspaces = {}
		for _, workspace in ipairs(wezterm.mux.get_workspace_names()) do
			table.insert(workspaces, {
				id = workspace,
				label = workspace,
			})
		end

		window:perform_action(
			act.InputSelector({
				action = wezterm.action_callback(function(inner_window, inner_pane, id, label)
					if not id and not label then
						return
					end
					inner_window:perform_action(act.SwitchToWorkspace({ name = id }), inner_pane)
				end),
				title = "Select Workspace",
				choices = workspaces,
				fuzzy = true,
			}),
			pane
		)
	end)
end

-- Project launcher (platform-aware)
local function project_launcher()
	return wezterm.action_callback(function(window, pane)
		local projects = {}

		if platform.is_windows then
			-- Panes run inside WSL, so offer WSL paths and let its shell expand "~".
			for _, dir in ipairs({ "~/projects", "~/.config", "~/.local/share/chezmoi" }) do
				table.insert(projects, { id = dir, label = dir })
			end
		else
			local home = platform.get_home_dir()
			table.insert(projects, { id = home .. "/projects", label = "~/projects" })
			table.insert(projects, { id = home .. "/.config", label = "~/.config" })
			table.insert(projects, { id = home .. "/Documents", label = "~/Documents" })
			table.insert(projects, { id = home .. "/Downloads", label = "~/Downloads" })
			table.insert(projects, { id = "/tmp", label = "/tmp" })

			-- Bounded, non-blocking search for repositories. Arguments are passed
			-- as a list, so directory names are never parsed by a shell.
			safe_call(function()
				local _, stdout = wezterm.run_child_process({
					"find",
					home .. "/projects",
					home .. "/.local/share/chezmoi",
					"-maxdepth",
					"3",
					"-name",
					".git",
					"-prune",
				})
				for line in (stdout or ""):gmatch("[^\r\n]+") do
					local project_dir = line:gsub("/%.git$", "")
					local project_name = project_dir:match("([^/]+)$")
					if project_name and project_name ~= "" then
						table.insert(projects, {
							id = project_dir,
							label = "📁 " .. project_name .. " (" .. project_dir .. ")",
						})
					end
				end
			end)
		end

		window:perform_action(
			act.InputSelector({
				action = wezterm.action_callback(function(inner_window, inner_pane, id)
					if not id then
						return
					end
					local spawn
					if platform.is_windows then
						spawn = { args = { "zsh", "-lic", "cd " .. id .. " && exec zsh" } }
					else
						spawn = { cwd = id }
					end
					inner_window:perform_action(act.SpawnCommandInNewTab(spawn), inner_pane)
				end),
				title = "Select Project Directory",
				choices = projects,
				fuzzy = true,
			}),
			pane
		)
	end)
end

-- Enhanced copy mode with better defaults
local function enter_copy_mode()
	return act.Multiple({
		act.CopyMode("MoveToStartOfLine"),
		act.CopyMode("MoveToSelectionOtherEnd"),
	})
end

-- Quick command runner (platform-aware)
local function quick_command()
	return act.PromptInputLine({
		description = "Run command:",
		action = wezterm.action_callback(function(window, pane, line)
			if line then
				local cmd
				if platform.is_windows then
					cmd = { "powershell.exe", "-NoLogo", "-Command", line }
				else
					local shell = os.getenv("SHELL") or "sh"
					cmd = { shell, "-c", line }
				end

				window:perform_action(act.SpawnCommandInNewTab({ args = cmd }), pane)
			end
		end),
	})
end

-- Session management with names
local function named_session_save()
	return act.PromptInputLine({
		description = "Session name:",
		action = wezterm.action_callback(function(window, pane, line)
			if line then
				-- Save with custom name
				wezterm.emit("save_session", window, line)
			end
		end),
	})
end

-- Multi-pane layouts
local function create_layout(layout_type)
	return wezterm.action_callback(function(window, pane)
		local tab = window:active_tab()

		if layout_type == "ide" then
			-- Create IDE-like layout: main + sidebar + bottom
			tab:set_title("IDE Layout")
			window:perform_action(act.SplitHorizontal({ domain = "CurrentPaneDomain" }), pane)
			window:perform_action(act.SplitVertical({ domain = "CurrentPaneDomain" }), pane)
			-- Focus back to main pane
			window:perform_action(act.ActivatePaneDirection("Left"), pane)
		elseif layout_type == "terminal" then
			-- Create terminal layout: main + bottom split
			tab:set_title("Terminal Layout")
			window:perform_action(act.SplitVertical({ domain = "CurrentPaneDomain" }), pane)
		elseif layout_type == "quad" then
			-- Create quad layout: 2x2 grid
			tab:set_title("Quad Layout")
			window:perform_action(act.SplitHorizontal({ domain = "CurrentPaneDomain" }), pane)
			window:perform_action(act.SplitVertical({ domain = "CurrentPaneDomain" }), pane)
			window:perform_action(act.ActivatePaneDirection("Left"), pane)
			window:perform_action(act.SplitVertical({ domain = "CurrentPaneDomain" }), pane)
		end
	end)
end

-- Export key binding configurations
Keys.leader_key = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }

Keys.keys = {
	-- System integration (lowercase keys for better compatibility)
	{ key = "c", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },

	-- Smart pane navigation (works with vim/nvim)
	{ key = "h", mods = "CTRL", action = navigate_pane_or_vim_split("h", "Left") },
	{ key = "l", mods = "CTRL", action = navigate_pane_or_vim_split("l", "Right") },
	{ key = "k", mods = "CTRL", action = navigate_pane_or_vim_split("k", "Up") },
	{ key = "j", mods = "CTRL", action = navigate_pane_or_vim_split("j", "Down") },

	-- Standard pane navigation fallback
	{ key = "LeftArrow", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Left") },
	{ key = "RightArrow", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Right") },
	{ key = "UpArrow", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Up") },
	{ key = "DownArrow", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Down") },

	-- Pane resizing
	{ key = "h", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Left", 3 }) },
	{ key = "l", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Right", 3 }) },
	{ key = "k", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Up", 3 }) },
	{ key = "j", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Down", 3 }) },

	-- Enhanced scrolling (context-aware for vim/nvim)
	-- { key = "u", mods = "CTRL", action = smart_scroll("u", act.ScrollByPage(-0.5)) },
	-- { key = "d", mods = "CTRL", action = smart_scroll("d", act.ScrollByPage(0.5)) },
	{ key = "k", mods = "CTRL|ALT", action = act.ScrollByLine(-3) },
	{ key = "j", mods = "CTRL|ALT", action = act.ScrollByLine(3) },
	{ key = "Home", mods = "CTRL", action = act.ScrollToTop },
	{ key = "End", mods = "CTRL", action = act.ScrollToBottom },

	-- Leader-based bindings
	{ key = "|", mods = "LEADER|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "\\", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "_", mods = "LEADER|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

	-- Pane management
	{ key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
	{ key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },
	{ key = "!", mods = "LEADER|SHIFT", action = act.PaneSelect({ mode = "SwapWithActive" }) },
	{ key = "q", mods = "LEADER", action = act.PaneSelect },

	-- Tab management
	{ key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "n", mods = "LEADER", action = smart_tab_switch(1) },
	{ key = "p", mods = "LEADER", action = smart_tab_switch(-1) },
	{ key = "&", mods = "LEADER|SHIFT", action = act.CloseCurrentTab({ confirm = true }) },

	-- Enhanced tab navigation
	{ key = "Tab", mods = "CTRL", action = act.ActivateTabRelative(1) },
	{ key = "Tab", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },
	{ key = "[", mods = "LEADER", action = act.ActivateTabRelative(-1) },
	{ key = "]", mods = "LEADER", action = act.ActivateTabRelative(1) },

	-- Workspace management
	{ key = "w", mods = "LEADER", action = workspace_switcher() },
	{
		key = "W",
		mods = "LEADER|SHIFT",
		action = act.PromptInputLine({
			description = "New workspace name:",
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					window:perform_action(act.SwitchToWorkspace({ name = line }), pane)
				end
			end),
		}),
	},

	-- Quick applications and tools
	{ key = "g", mods = "LEADER", action = spawn_tool("lazygit") },
	{ key = "d", mods = "LEADER", action = spawn_tool("lazydocker") },
	{ key = "f", mods = "LEADER", action = spawn_tool("ranger") },
	{ key = "m", mods = "LEADER", action = spawn_tool("btop") },
	{ key = "v", mods = "LEADER", action = spawn_tool("nvim") },

	-- Project and directory navigation
	{ key = "o", mods = "LEADER", action = project_launcher() },
	{ key = "D", mods = "LEADER|SHIFT", action = quick_select_directory() },
	{ key = "y", mods = "LEADER", action = act.QuickSelect },

	-- Enhanced copy/search mode
	{ key = "Space", mods = "LEADER", action = enter_copy_mode() },
	{ key = "/", mods = "LEADER", action = act.Search({ CaseInSensitiveString = "" }) },
	{ key = "?", mods = "LEADER|SHIFT", action = act.Search({ CaseSensitiveString = "" }) },

	-- Session management
	{ key = "s", mods = "LEADER", action = named_session_save() },
	{ key = "S", mods = "LEADER|SHIFT", action = act.EmitEvent("save_session") },
	{ key = "r", mods = "LEADER", action = act.EmitEvent("restore_session") },
	{ key = "L", mods = "LEADER|SHIFT", action = act.EmitEvent("load_session") },

	-- Quick layouts
	{ key = "1", mods = "LEADER|ALT", action = create_layout("ide") },
	{ key = "2", mods = "LEADER|ALT", action = create_layout("terminal") },
	{ key = "3", mods = "LEADER|ALT", action = create_layout("quad") },

	-- Command and launcher
	{ key = ":", mods = "LEADER", action = quick_command() },
	{ key = "l", mods = "LEADER", action = act.ShowLauncher },
	{ key = "P", mods = "LEADER|SHIFT", action = act.ActivateCommandPalette },

	-- Font and UI
	{ key = "=", mods = "CTRL", action = act.IncreaseFontSize },
	{ key = "-", mods = "CTRL", action = act.DecreaseFontSize },
	{ key = "0", mods = "CTRL", action = act.ResetFontSize },
	{ key = "F11", mods = "NONE", action = act.ToggleFullScreen },

	-- Tab renaming and management
	{
		key = "e",
		mods = "LEADER",
		action = act.PromptInputLine({
			description = "Tab name:",
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},

	-- Debug and configuration. Behind the leader so plain F5/F12 reach
	-- applications such as nvim-dap.
	{ key = "F5", mods = "LEADER", action = act.ReloadConfiguration },
	{ key = "F12", mods = "LEADER", action = act.ShowDebugOverlay },

	-- Leader key passthrough
	{ key = "a", mods = "LEADER|CTRL", action = act.SendKey({ key = "a", mods = "CTRL" }) },

	-- Window management
	{ key = "N", mods = "CTRL|SHIFT", action = act.SpawnWindow },
}

-- Add number key bindings for tab navigation (both leader and alt)
for i = 1, 9 do
	table.insert(Keys.keys, {
		key = tostring(i),
		mods = "LEADER",
		action = act.ActivateTab(i - 1),
	})
	table.insert(Keys.keys, {
		key = tostring(i),
		mods = "ALT",
		action = act.ActivateTab(i - 1),
	})
end

return Keys
