local wezterm = require("wezterm")
local platform = require("utils.platform")

local Status = {}

-- Git cache with timestamps
local git_cache = {}
local cache_ttl_seconds = 5

local function log_error(msg, err)
	wezterm.log_error("[Status] " .. msg .. ": " .. tostring(err))
end

-- Safe execution wrapper
local function safe_call(fn, fallback, err_msg)
	local success, result = pcall(fn)
	if not success then
		if err_msg then
			log_error(err_msg, result)
		end
		return fallback
	end
	return result
end

-- Branch and change counts from a single `git status` call (with caching).
-- Arguments are passed as a list, so the directory name is never parsed by a
-- shell, and the child process does not block the GUI thread.
local function get_git_info(cwd)
	if not cwd then
		return nil
	end

	local now = os.time()
	local cached = git_cache[cwd]
	if cached and (now - cached.timestamp) < cache_ttl_seconds then
		return cached.info
	end

	local info = safe_call(function()
		local ok, stdout = wezterm.run_child_process({
			platform.get_git_cmd(),
			"-C",
			cwd,
			"status",
			"--porcelain=v2",
			"--branch",
		})
		if not ok or not stdout then
			return nil
		end

		local result = { branch = nil, modified = 0, added = 0, deleted = 0, untracked = 0 }
		for line in stdout:gmatch("[^\r\n]+") do
			local head = line:match("^# branch%.head (.+)$")
			if head then
				result.branch = head
			elseif line:sub(1, 2) == "? " then
				result.untracked = result.untracked + 1
			else
				local xy = line:match("^[12u] (%S%S)")
				if xy then
					if xy:find("M") then
						result.modified = result.modified + 1
					elseif xy:find("A") then
						result.added = result.added + 1
					elseif xy:find("D") then
						result.deleted = result.deleted + 1
					end
				end
			end
		end

		if not result.branch or result.branch == "(detached)" then
			return nil
		end
		return result
	end, nil)

	git_cache[cwd] = { info = info, timestamp = now }
	return info
end

-- Format Git information
local function format_git(branch, status, colors)
	if not branch then
		return {}
	end

	local elements = {
		{ Foreground = { Color = colors.orange } },
		{ Text = " " .. branch },
	}

	if status then
		if status.modified > 0 then
			table.insert(elements, { Foreground = { Color = colors.yellow } })
			table.insert(elements, { Text = " ~" .. status.modified })
		end
		if status.added > 0 then
			table.insert(elements, { Foreground = { Color = colors.green } })
			table.insert(elements, { Text = " +" .. status.added })
		end
		if status.deleted > 0 then
			table.insert(elements, { Foreground = { Color = colors.red } })
			table.insert(elements, { Text = " -" .. status.deleted })
		end
		if status.untracked > 0 then
			table.insert(elements, { Foreground = { Color = colors.purple } })
			table.insert(elements, { Text = " ?" .. status.untracked })
		end
	end

	table.insert(elements, { Foreground = { Color = colors.fg } })
	table.insert(elements, { Text = " " })

	return elements
end

-- Get current working directory from pane
local function get_cwd_from_pane(pane)
	return platform.parse_cwd_uri(pane:get_current_working_dir())
end

-- Format git branch only (minimal mode)
local function format_git_minimal(branch, colors)
	if not branch then
		return {}
	end

	return {
		{ Foreground = { Color = colors.orange } },
		{ Text = " " .. branch },
		{ Foreground = { Color = colors.fg } },
		{ Text = " " },
	}
end

-- Setup status bar
-- opts.minimal: when true, skips leader/key-table indicators, shows only
--               git branch (no stats), and uses a simpler left status.
-- opts.show_git: when false, avoids spawning Git processes from status events.
function Status.setup(config, colors, opts)
	colors = colors or {}
	opts = opts or {}
	local minimal = opts.minimal or false
	local show_git = opts.show_git ~= false

	-- Right status with git info and workspace
	local function update_right_status(window, pane)
		local elements = {}

		if not minimal then
			-- Leader key indicator (full mode only)
			if window:leader_is_active() then
				table.insert(elements, { Foreground = { Color = colors.orange } })
				table.insert(elements, { Text = " 🔑 " })
			end
		end

		-- Get current working directory
		local cwd = get_cwd_from_pane(pane)

		-- Git information (caching active in both modes)
		if show_git and cwd then
			local info = get_git_info(cwd)
			if info then
				local git_elements
				if minimal then
					git_elements = format_git_minimal(info.branch, colors)
				else
					git_elements = format_git(info.branch, info, colors)
				end
				for _, element in ipairs(git_elements) do
					table.insert(elements, element)
				end
			end
		end

		if not minimal then
			-- Key table mode indicator (full mode only)
			local key_table = window:active_key_table()
			if key_table then
				table.insert(elements, { Foreground = { Color = colors.blue } })
				table.insert(elements, { Text = " 📋 " .. key_table .. " " })
			end
		end

		-- Workspace
		local workspace = window:active_workspace()
		local show_workspace = minimal or workspace ~= "default"

		if show_workspace then
			if #elements > 0 then
				table.insert(elements, { Foreground = { Color = colors.bg3 } })
				table.insert(elements, { Text = "│ " })
			end

			table.insert(elements, { Foreground = { Color = colors.blue } })
			table.insert(elements, { Text = workspace .. " " })
		end

		window:set_right_status(wezterm.format(elements))
	end

	-- Left status
	local function update_left_status(window, pane)
		local tab_count = #window:mux_window():tabs()
		local active_tab = window:active_tab()
		local tab_index = 0

		for i, t in ipairs(window:mux_window():tabs()) do
			if t:tab_id() == active_tab:tab_id() then
				tab_index = i
				break
			end
		end

		local elements = {}

		if minimal then
			-- Minimal: just tab count
			if tab_count > 1 then
				table.insert(elements, { Foreground = { Color = colors.yellow } })
				table.insert(elements, { Text = string.format(" %d/%d ", tab_index, tab_count) })
			end
		else
			-- Full: hostname + tab count
			local hostname = wezterm.hostname()
			table.insert(elements, { Foreground = { Color = colors.fg } })
			table.insert(elements, { Text = string.format(" %s ", hostname) })

			if tab_count > 1 then
				table.insert(elements, { Foreground = { Color = colors.bg3 } })
				table.insert(elements, { Text = "│ " })
				table.insert(elements, { Foreground = { Color = colors.yellow } })
				table.insert(elements, { Text = string.format("%d/%d ", tab_index, tab_count) })
			end
		end

		window:set_left_status(wezterm.format(elements))
	end

	-- "update-right-status" is deprecated; one handler updates both sides.
	wezterm.on("update-status", function(window, pane)
		update_right_status(window, pane)
		update_left_status(window, pane)
	end)

	-- Enhanced window title
	wezterm.on("format-window-title", function(tab, pane, tabs, panes, config)
		local zoomed = ""
		if tab.active_pane.is_zoomed then
			zoomed = "[Z] "
		end

		local index = ""
		if #tabs > 1 then
			index = string.format("[%d/%d] ", tab.tab_index + 1, #tabs)
		end

		local workspace = ""
		local workspace_name = tab.window.active_workspace or "default"
		if workspace_name ~= "default" then
			workspace = string.format("[%s] ", workspace_name)
		end

		return zoomed .. workspace .. index .. (tab.active_pane.title or "WezTerm")
	end)
end

return Status
