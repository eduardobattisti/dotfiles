local wezterm = require("wezterm")

local Status = {}

-- Get current Git branch
local function get_git_branch(cwd)
	if not cwd then
		return nil
	end

	local success, result = pcall(function()
		local handle = io.popen(string.format("cd '%s' && git branch --show-current 2>/dev/null", cwd))
		local branch = handle:read("*a"):gsub("\n", "")
		handle:close()

		if branch and branch ~= "" then
			return branch
		end
		return nil
	end)

	return success and result or nil
end

-- Get Git status info
local function get_git_status(cwd)
	if not cwd then
		return nil
	end

	local success, result = pcall(function()
		local handle = io.popen(string.format("cd '%s' && git status --porcelain 2>/dev/null", cwd))
		local status = handle:read("*a")
		handle:close()

		if status then
			local modified = 0
			local added = 0
			local deleted = 0
			local untracked = 0

			for line in status:gmatch("[^\r\n]+") do
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
		end
		return nil
	end)

	return success and result or nil
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
	local cwd_uri = pane.current_working_dir
	if not cwd_uri then
		return nil
	end

	local cwd = ""
	if type(cwd_uri) == "userdata" then
		cwd = cwd_uri.file_path
	else
		cwd_uri = cwd_uri:sub(8) -- Remove "file://"
		local slash = cwd_uri:find("/")
		if slash then
			cwd = cwd_uri:sub(slash):gsub("%%(%x%x)", function(hex)
				return string.char(tonumber(hex, 16))
			end)
		end
	end

	return cwd ~= "" and cwd or nil
end

-- Setup status bar
function Status.setup(config, colors)
	colors = colors or {}

	-- Right status with git info only
	wezterm.on("update-right-status", function(window, pane)
		local elements = {}

		-- Get current working directory
		local cwd = get_cwd_from_pane(pane)

		-- Git information
		if cwd then
			local branch = get_git_branch(cwd)
			local git_status = get_git_status(cwd)
			local git_elements = format_git(branch, git_status, colors)
			for _, element in ipairs(git_elements) do
				table.insert(elements, element)
			end
		end

		-- Workspace only (no date/time)
		local workspace = window:active_workspace()

		-- Add separator if we have git info
		if #elements > 0 then
			table.insert(elements, { Foreground = { Color = colors.bg3 or "#56635f" } })
			table.insert(elements, { Text = "│ " })
		end

		-- Workspace
		table.insert(elements, { Foreground = { Color = colors.blue or "#7fbbb3" } })
		table.insert(elements, { Text = workspace .. " " })

		window:set_right_status(wezterm.format(elements))
	end)

	-- Left status with hostname only
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
		if #wezterm.mux.get_workspace_names() > 1 then
			workspace = string.format("[%s] ", tab.window.active_workspace or "default")
		end

		return zoomed .. workspace .. index .. (tab.active_pane.title or "WezTerm")
	end)
end

return Status