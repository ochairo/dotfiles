return {
	{
		"nvimdev/dashboard-nvim",
		event = "VimEnter",
		opts = function(_, opts)
			local logo = [[
██╗   ██╗██╗███╗   ███╗
██║   ██║██║████╗ ████║
██║   ██║██║██╔████╔██║
╚██╗ ██╔╝██║██║╚██╔╝██║
 ╚████╔╝ ██║██║ ╚═╝ ██║
  ╚═══╝  ╚═╝╚═╝     ╚═╝
── Stevie Atari.1987 ──]]

			logo = string.rep("\n", 10) .. logo .. "\n\n"
			opts.config.header = vim.split(logo, "\n")
			opts.theme = "doom"
		end,
	},
}
