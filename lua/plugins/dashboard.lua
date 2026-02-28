return {
	"nvimdev/dashboard-nvim",
	event = "VimEnter",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {
		theme = "hyper",
		config = {
			header = {
				"",
				" ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗",
				" ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║",
				" ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║",
				" ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║",
				" ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║",
				" ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝",
				"",
			},
			shortcut = {
				{ icon = "  ", desc = "Lazy", key = "l", action = "Lazy" },
				{ icon = "  ", desc = "Find File", key = "f", action = "Telescope find_files" },
				{ icon = "  ", desc = "Grep", key = "g", action = "Telescope live_grep" },
				{ icon = "  ", desc = "Explorer", key = "e", action = "Neotree" },
				{ icon = "  ", desc = "Quit", key = "q", action = "qa" },
			},
			packages = { enable = true },
			project = { enable = true, limit = 8, icon = " ", label = "Recent Projects", action = "Telescope find_files cwd=" },
			mru = { limit = 10, icon = " ", label = "Recent Files" },
			footer = {},
		},
	},
}
