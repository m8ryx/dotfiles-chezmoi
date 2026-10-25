-- Was a dependency of avante.nvim; kept on its own so markdown files still render.
return {
	"MeanderingProgrammer/render-markdown.nvim",
	ft = { "markdown" },
	opts = {
		file_types = { "markdown" },
	},
}
