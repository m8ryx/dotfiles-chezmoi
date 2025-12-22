return {
	"robitx/gp.nvim",
	config = function()
		local conf = {
			-- For customization, refer to Install > Configuration in the Documentation/Readme
			providers = {
				googleai = {
					disable = false,
					secret = os.getenv("GOOGlEAI_API_KEY"),
					endpoint = "https://generativelanguage.googleapis.com/v1beta/models/{{model}}:streamGenerateContent?key={{secret}}",
				},
				openai = {
					disable = true,
				},
			},
			agents = {
				{
					name = "ChatGPT3-5",
					disable = true,
				},
				{
					name = "gemini-2.5-flash-lite",
					provider = "googleai",
					chat = true,
					command = true,
					model = { model = "gemini-2.5-flash-lite" },
					system_prompt = require("gp.defaults").chat_system_prompt,
				},
			},
		}
		require("gp").setup(conf)

		-- Setup shortcuts here (see Usage > Shortcuts in the Documentation/Readme)
	end,
}
