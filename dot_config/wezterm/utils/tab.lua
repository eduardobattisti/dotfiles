local wezterm = require("wezterm")
local theme = require("utils.theme")
local colors = theme.colors

local Tab = {}

local function get_process(tab)
	local PROCESS_ICONS = {
		["docker"] = {
			{ Foreground = { Color = colors.blue } },
			{ Text = "󰡨" },
		},
		["docker-compose"] = {
			{ Foreground = { Color = colors.blue } },
			{ Text = "󰡨" },
		},
		["nvim"] = {
			{ Foreground = { Color = colors.green } },
			{ Text = "" },
		},
		["bob"] = {
			{ Foreground = { Color = colors.blue } },
			{ Text = "" },
		},
		["vim"] = {
			{ Foreground = { Color = colors.green } },
			{ Text = "" },
		},
		["node"] = {
			{ Foreground = { Color = colors.green } },
			{ Text = "󰋘" },
		},
		["zsh"] = {
			{ Foreground = { Color = colors.orange } },
			{ Text = "" },
		},
		["bash"] = {
			{ Foreground = { Color = colors.gray } },
			{ Text = "" },
		},
		["htop"] = {
			{ Foreground = { Color = colors.yellow } },
			{ Text = "" },
		},
		["btop"] = {
			{ Foreground = { Color = colors.red } },
			{ Text = "" },
		},
		["cargo"] = {
			{ Foreground = { Color = colors.orange } },
			{ Text = wezterm.nerdfonts.dev_rust },
		},
		["go"] = {
			{ Foreground = { Color = colors.aqua } },
			{ Text = "" },
		},
		["git"] = {
			{ Foreground = { Color = colors.orange } },
			{ Text = "󰊢" },
		},
		["lazygit"] = {
			{ Foreground = { Color = colors.purple } },
			{ Text = "󰊢" },
		},
		["lua"] = {
			{ Foreground = { Color = colors.blue } },
			{ Text = "" },
		},
		["wget"] = {
			{ Foreground = { Color = colors.yellow } },
			{ Text = "󰄠" },
		},
		["curl"] = {
			{ Foreground = { Color = colors.yellow } },
			{ Text = "" },
		},
		["gh"] = {
			{ Foreground = { Color = colors.purple } },
			{ Text = "" },
		},
		["flatpak"] = {
			{ Foreground = { Color = colors.blue } },
			{ Text = "󰏖" },
		},
		["dotnet"] = {
			{ Foreground = { Color = colors.purple } },
			{ Text = "󰪮" },
		},
		["paru"] = {
			{ Foreground = { Color = colors.purple } },
			{ Text = "󰣇" },
		},
		["yay"] = {
			{ Foreground = { Color = colors.purple } },
			{ Text = "󰣇" },
		},
		["fish"] = {
			{ Foreground = { Color = colors.orange } },
			{ Text = "" },
		},
	}

	local process_name = string.gsub(tab.active_pane.foreground_process_name, "(.*[/\\])(.*)", "%2")
	-- local process_name = tab.active_pane.title

	if PROCESS_ICONS[process_name] then
		return PROCESS_ICONS[process_name]
	elseif process_name == "" then
		return {
			{ Foreground = { Color = colors.red } },
			{ Text = "󰌾" },
		}
	else
		return {
			{ Foreground = { Color = colors.blue } },
			{ Text = string.format("[%s]", process_name) },
		}
	end
end

local function get_current_working_dir(tab)
	-- CWD comming from windows
	local cwd_uri = tab.active_pane.current_working_dir

	if cwd_uri then
		local cwd = ""
		if type(cwd_uri) == "userdata" then
			-- Error happens here
			cwd = cwd_uri.file_path
		else
			cwd_uri = cwd_uri:sub(8)
			local slash = cwd_uri:find("/")
			if slash then
				cwd = cwd_uri:sub(slash):gsub("%%(%x%x)", function(hex)
					return string.char(tonumber(hex, 16))
				end)
			end
		end

		if cwd == os.getenv("HOME") then
			return "~"
		end

		return string.format("%s", string.match(cwd, "[^/]+$"))
	end
end

function Tab.setup(config)
	config.tab_bar_at_bottom = true
	config.use_fancy_tab_bar = false
	config.show_new_tab_button_in_tab_bar = false
	config.tab_max_width = 50
	config.hide_tab_bar_if_only_one_tab = true

	wezterm.on("format-tab-title", function(tab)
		local tab_title = get_current_working_dir(tab)

		-- if (tab.active_pane.user_vars ~= nil) then
		-- 	tab_title = tab.active_pane.user_vars
		-- end

		local elements = {
			{ Text = "  " },
			{ Attribute = { Intensity = "Half" } },
			{ Text = string.format("%s", tab.tab_index + 1) },
			{ Attribute = { Intensity = "Normal" } },
			{ Text = " " },
		}
		
		-- Add process icon elements
		local process_elements = get_process(tab)
		for _, element in ipairs(process_elements) do
			table.insert(elements, element)
		end
		
		-- Add remaining elements
		table.insert(elements, { Text = " " })
		table.insert(elements, { Foreground = { Color = colors.fg } })
		table.insert(elements, { Text = tab_title or "" })
		table.insert(elements, { Foreground = { Color = colors.bg } })
		table.insert(elements, { Text = " ▕" })
		
		return wezterm.format(elements)
	end)
end

return Tab
