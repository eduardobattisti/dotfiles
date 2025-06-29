local Theme = {}

Theme.colors = {
	bg = "#2f383e", -- medium background
	fg = "#d3c6aa", -- foreground
	red = "#e67e80",
	green = "#a7c080",
	yellow = "#dbbc7f",
	blue = "#7fbbb3",
	purple = "#d699b6",
	aqua = "#83c092",
	gray = "#9da9a0",
	orange = "#e69875",

	bg0 = "#2b3339", -- darker background for inactive
	bg1 = "#3c474d", -- tab bar background
	bg2 = "#475258", -- hover background
	bg3 = "#56635f", -- scrollbar/thumbs
	bg4 = "#64706b", -- slightly lighter grey
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
