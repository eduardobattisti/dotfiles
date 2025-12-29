-- Platform detection and utilities for cross-platform compatibility
local wezterm = require("wezterm")
local Platform = {}

-- Detect operating system
Platform.is_windows = wezterm.target_triple:find("windows") ~= nil
Platform.is_linux = wezterm.target_triple:find("linux") ~= nil
Platform.is_mac = wezterm.target_triple:find("darwin") ~= nil

-- Get home directory in a cross-platform way
function Platform.get_home_dir()
	if Platform.is_windows then
		return os.getenv("USERPROFILE") or os.getenv("HOME")
	end
	return os.getenv("HOME")
end

-- Normalize path separators for the current platform
function Platform.normalize_path(path)
	if Platform.is_windows then
		return path:gsub("/", "\\")
	end
	return path:gsub("\\", "/")
end

-- Get the appropriate shell command wrapper for the platform
function Platform.shell_command(cmd)
	if Platform.is_windows then
		return { "powershell.exe", "-NoLogo", "-Command", cmd }
	end
	return { "sh", "-c", cmd }
end

-- Detect available WSL distributions (Windows only)
function Platform.detect_wsl_distros()
	local distros = {}

	if not Platform.is_windows then
		return distros
	end

	local success, output = pcall(function()
		local handle = io.popen("wsl.exe --list --quiet 2>nul")
		if not handle then
			return ""
		end
		local result = handle:read("*a")
		handle:close()
		return result
	end)

	if success and output then
		for line in output:gmatch("[^\r\n]+") do
			-- Remove any Unicode BOM and trim whitespace
			local distro = line:gsub("^%s*", ""):gsub("%s*$", ""):gsub("[\0-\31]", "")
			if distro ~= "" then
				table.insert(distros, distro)
			end
		end
	end

	return distros
end

-- Get appropriate Git executable for the platform
function Platform.get_git_cmd()
	if Platform.is_windows then
		return "git.exe"
	end
	return "git"
end

-- Get session storage directory
function Platform.get_session_dir()
	if Platform.is_windows then
		local appdata = os.getenv("LOCALAPPDATA")
		if appdata then
			return appdata .. "\\wezterm\\sessions"
		end
		return Platform.get_home_dir() .. "\\.wezterm\\sessions"
	end

	local xdg_data = os.getenv("XDG_DATA_HOME")
	if xdg_data then
		return xdg_data .. "/wezterm/sessions"
	end

	return Platform.get_home_dir() .. "/.local/share/wezterm/sessions"
end

-- Create directory if it doesn't exist
function Platform.ensure_dir(path)
	local cmd
	if Platform.is_windows then
		cmd = string.format('if not exist "%s" mkdir "%s"', path, path)
		os.execute(cmd)
	else
		cmd = string.format('mkdir -p "%s"', path)
		os.execute(cmd)
	end
end

-- Safe file operations with error handling
function Platform.safe_read_file(path)
	local file = io.open(path, "r")
	if not file then
		return nil, "Could not open file: " .. path
	end

	local content = file:read("*a")
	file:close()
	return content
end

function Platform.safe_write_file(path, content)
	local file = io.open(path, "w")
	if not file then
		return false, "Could not write to file: " .. path
	end

	file:write(content)
	file:close()
	return true
end

-- Get appropriate font size for platform/DPI
function Platform.get_default_font_size()
	if Platform.is_windows then
		return 11
	elseif Platform.is_mac then
		return 13
	else
		return 12
	end
end

-- Get appropriate window padding for platform
function Platform.get_window_padding()
	if Platform.is_windows then
		return { left = 4, right = 4, top = 4, bottom = 4 }
	elseif Platform.is_mac then
		return { left = 8, right = 8, top = 8, bottom = 8 }
	else
		return { left = 2, right = 2, top = 2, bottom = 2 }
	end
end

return Platform
