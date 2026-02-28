return {
	"nickjvandyke/opencode.nvim",
	version = "*",
	config = function()
		vim.g.opencode_opts = {}
		vim.o.autoread = true
	end,
	keys = {
		{
			"<leader>oa",
			function()
				require("opencode").ask("@this: ", { submit = true })
			end,
			mode = { "n", "x" },
			desc = "Ask opencode",
		},
		{
			"<leader>os",
			function()
				require("opencode").select()
			end,
			mode = { "n", "x" },
			desc = "Select opencode action",
		},
		{
			"<leader>ot",
			function()
				require("opencode").toggle()
			end,
			mode = { "n", "t" },
			desc = "Toggle opencode",
		},
		{
			"go",
			function()
				return require("opencode").operator("@this ")
			end,
			mode = { "n", "x" },
			desc = "Add range to opencode",
			expr = true,
		},
		{
			"goo",
			function()
				return require("opencode").operator("@this ") .. "_"
			end,
			desc = "Add line to opencode",
			expr = true,
		},
		{
			"<leader>ou",
			function()
				require("opencode").command("session.half.page.up")
			end,
			desc = "Scroll opencode up",
		},
		{
			"<leader>od",
			function()
				require("opencode").command("session.half.page.down")
			end,
			desc = "Scroll opencode down",
		},
	},
}
