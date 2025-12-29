local wezterm = require("wezterm")
local platform = require("utils.platform")

local Status = {}

-- Git cache with timestamps
local git_cache = {}
local cache_timeout_ms = 2000 -- 2 seconds

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

-- Get current Git branch (with caching)
local function get_git_branch(cwd)
	if not cwd then
		return nil
	end

	-- Check cache
	local now = os.time()
	local cached = git_cache[cwd]
	if cached and cached.branch_timestamp and (now - cached.branch_timestamp) < (cache_timeout_ms / 1000) then
		return cached.branch
	end

	-- Fetch from git
	local branch = safe_call(function()
		local git_cmd = platform.get_git_cmd()
		local cmd = string.format('cd "%s" && %s branch --show-current 2>/dev/null', cwd, git_cmd)

		if platform.is_windows then
			cmd = string.format('cd /d "%s" && %s branch --show-current 2>nul', cwd, git_cmd)
		end

		local handle = io.popen(cmd)
		if not handle then
			return nil
		end

		local result = handle:read("*a")
		handle:close()

		if result then
			result = result:gsub("\n", ""):gsub("\r", "")
			if result ~= "" then
				return result
			end
		end
		return nil
	end, nil)

	-- Update cache
	if not git_cache[cwd] then
		git_cache[cwd] = {}
	end
	git_cache[cwd].branch = branch
	git_cache[cwd].branch_timestamp = now

	return branch
end

-- Get Git status info (with caching)
local function get_git_status(cwd)
	if not cwd then
		return nil
	end

	-- Check cache
	local now = os.time()
	local cached = git_cache[cwd]
	if cached and cached.status_timestamp and (now - cached.status_timestamp) < (cache_timeout_ms / 1000) then
		return cached.status
	end

	-- Fetch from git
	local status = safe_call(function()
		local git_cmd = platform.get_git_cmd()
		local cmd = string.format('cd "%s" && %s status --porcelain 2>/dev/null', cwd, git_cmd)

		if platform.is_windows then
			cmd = string.format('cd /d "%s" && %s status --porcelain 2>nul', cwd, git_cmd)
		end

		local handle = io.popen(cmd)
		if not handle then
			return nil
		end

		local output = handle:read("*a")
		handle:close()

		if not output or output == "" then
			return nil
		end

		local modified = 0
		local added = 0
		local deleted = 0
		local untracked = 0

		for line in output:gmatch("[^\r\n]+") do
			local status_char = line:sub(1, 2)
			if status_char:match("^M") or status_char:match("^.M") then
				modified = modified + 1
			elseif status_char:match("^A") or status_char:match("^.A") then
				added = added + 1
			elseif status_char:match("^D") or status_char:match("^.D") then
				deleted = deleted + 1
			elseif status_char:match("^%?%?") then
				untracked = untracked + 1
			end
		end

		return {
			modified = modified,
			added = added,
			deleted = deleted,
			untracked = untracked,
		}
	end, nil)

	-- Update cache
	if not git_cache[cwd] then
		git_cache[cwd] = {}
	end
	git_cache[cwd].status = status
	git_cache[cwd].status_timestamp = now

	return status
end

-- Format Git information
local function format_git(branch, status, colors)
	if not branch then
		return {}
	end

	local elements = {
		{ Foreground = { Color = colors.orange or "#e69875" } },
		{ Text = " " .. branch },
	}

	if status then
		if status.modified > 0 then
			table.insert(elements, { Foreground = { Color = colors.yellow or "#dbbc7f" } })
			table.insert(elements, { Text = " ~" .. status.modified })
		end
		if status.added > 0 then
			table.insert(elements, { Foreground = { Color = colors.green or "#a7c080" } })
			table.insert(elements, { Text = " +" .. status.added })
		end
		if status.deleted > 0 then
			table.insert(elements, { Foreground = { Color = colors.red or "#e67e80" } })
			table.insert(elements, { Text = " -" .. status.deleted })
		end
		if status.untracked > 0 then
			table.insert(elements, { Foreground = { Color = colors.purple or "#d699b6" } })
			table.insert(elements, { Text = " ?" .. status.untracked })
		end
	end

	table.insert(elements, { Foreground = { Color = colors.fg or "#d3c6aa" } })
	table.insert(elements, { Text = " " })

	return elements
end

-- Get current working directory from pane
local function get_cwd_from_pane(pane)
	local cwd_uri = pane:get_current_working_dir()
	if not cwd_uri then
		return nil
	end

	local cwd = ""
	if type(cwd_uri) == "userdata" then
		cwd = cwd_uri.file_path
	else
		-- Parse file:// URI
		cwd_uri = tostring(cwd_uri)
		if cwd_uri:sub(1, 7) == "file://" then
			cwd_uri = cwd_uri:sub(8)

			-- Handle Windows paths (file:///C:/...)
			if platform.is_windows and cwd_uri:match("^/[A-Za-z]:") then
				cwd_uri = cwd_uri:sub(2)
			end

			local slash = cwd_uri:find("/")
			if slash then
				cwd = cwd_uri:sub(slash):gsub("%%(%x%x)", function(hex)
					return string.char(tonumber(hex, 16))
				end)
			end
		end
	end

	return cwd ~= "" and cwd or nil
end

-- Setup status bar
function Status.setup(config, colors)
	colors = colors or {}

	-- Right status with git info and workspace
	wezterm.on("update-right-status", function(window, pane)
		local elements = {}

		-- Leader key indicator
		if window:leader_is_active() then
			table.insert(elements, { Foreground = { Color = colors.orange or "#e69875" } })
			table.insert(elements, { Text = " 🔑 " })
		end

		-- Get current working directory
		local cwd = get_cwd_from_pane(pane)

		-- Git information
		if cwd then
			local branch = get_git_branch(cwd)
			if branch then
				local git_status = get_git_status(cwd)
				local git_elements = format_git(branch, git_status, colors)
				for _, element in ipairs(git_elements) do
					table.insert(elements, element)
				end
			end
		end

		-- Key table mode indicator
		local key_table = window:active_key_table()
		if key_table then
			table.insert(elements, { Foreground = { Color = colors.blue or "#7fbbb3" } })
			table.insert(elements, { Text = " 📋 " .. key_table .. " " })
		end

		-- Workspace
		local workspace = window:active_workspace()
		if workspace ~= "default" then
			-- Add separator if we have other info
			if #elements > 0 then
				table.insert(elements, { Foreground = { Color = colors.bg3 or "#56635f" } })
				table.insert(elements, { Text = "│ " })
			end

			table.insert(elements, { Foreground = { Color = colors.blue or "#7fbbb3" } })
			table.insert(elements, { Text = workspace .. " " })
		end

		window:set_right_status(wezterm.format(elements))
	end)

	-- Left status with hostname and tab count
	wezterm.on("update-status", function(window, pane)
		local hostname = wezterm.hostname()
		local tab_count = #window:mux_window():tabs()
		local active_tab = window:active_tab()
		local tab_index = 0

		-- Find current tab index
		for i, tab in ipairs(window:mux_window():tabs()) do
			if tab:tab_id() == active_tab:tab_id() then
				tab_index = i
				break
			end
		end

		local elements = {
			{ Foreground = { Color = colors.fg or "#d3c6aa" } },
			{ Text = string.format(" %s ", hostname) },
		}

		if tab_count > 1 then
			table.insert(elements, { Foreground = { Color = colors.bg3 or "#56635f" } })
			table.insert(elements, { Text = "│ " })
			table.insert(elements, { Foreground = { Color = colors.yellow or "#dbbc7f" } })
			table.insert(elements, { Text = string.format("%d/%d ", tab_index, tab_count) })
		end

		window:set_left_status(wezterm.format(elements))
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

