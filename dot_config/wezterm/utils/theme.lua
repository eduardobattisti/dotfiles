local Theme = {}

Theme.colors = {
	bg = "#282828", -- dark medium background
	fg = "#d4be98", -- foreground
	red = "#ea6962",
	green = "#a9b665",
	yellow = "#d8a657",
	blue = "#7daea3",
	purple = "#d3869b",
	aqua = "#89b482",
	gray = "#928374",
	orange = "#e78a4e",

	bg0 = "#1d2021", -- darker background for inactive
	bg1 = "#32302f", -- tab bar background
	bg2 = "#3c3836", -- hover background
	bg3 = "#45403d", -- scrollbar/thumbs
	bg4 = "#5a524c", -- slightly lighter grey
}

function Theme.setup(config)
	local c = Theme.colors

	config.colors = {
		split = c.bg3,
		foreground = c.fg,
		background = c.bg,
		cursor_bg = c.fg,
		cursor_border = c.bg4,
		cursor_fg = c.bg,
		selection_bg = c.bg3,
		visual_bell = c.bg1,
		scrollbar_thumb = c.bg3,
		compose_cursor = c.orange,
		indexed = {
			[16] = c.orange,
			[17] = c.gray,
		},
		ansi = {
			c.bg4, -- black
			c.red,
			c.green,
			c.yellow,
			c.blue,
			c.purple,
			c.aqua,
			c.fg,
		},
		brights = {
			c.bg3, -- bright black
			c.red,
			c.green,
			c.yellow,
			c.blue,
			c.purple,
			c.aqua,
			c.fg,
		},
		tab_bar = {
			background = c.bg1,
			active_tab = {
				bg_color = c.bg,
				fg_color = c.fg,
				intensity = "Bold",
				underline = "None",
				italic = false,
				strikethrough = false,
			},
			inactive_tab = {
				bg_color = c.bg1,
				fg_color = c.bg4,
			},
			inactive_tab_hover = {
				bg_color = c.bg2,
				fg_color = c.fg,
			},
			new_tab = {
				bg_color = c.bg2,
				fg_color = c.fg,
			},
			new_tab_hover = {
				bg_color = c.bg3,
				fg_color = c.orange,
			},
		},
	}
end

return Theme
