---@diagnostic disable: undefined-global
local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality
local noeq = MiniTest.expect.no_equality

local T = new_set()
T["setup()"] = new_set()

T["setup()"]["sets user options"] = function()
	require("floatrunner.init").setup({
		maps = { floaterm_on = "<space>tt" },
		builds = { ["Makefile"] = "make" },
		langs = { exts = { "c" }, command = "gcc %s", argv = { "%." } }
	})

	local config = require("floatrunner.config").get()

	eq(config.maps.floaterm_on, "<space>tt")
	eq(config.maps.floaterm_off, nil)
	eq(config.builds["Makefile"], "make")
	eq(config.builds["build.sh"], nil)
	eq(config.langs, { exts = { "c" }, command = "gcc %s", argv = { "%." } })
end


T["setup()"]["registers user commands"] = function()
	require("floatrunner.init").setup({})

	local cmds = vim.api.nvim_get_commands({})

	noeq(cmds["FloatRunner"], nil)
end

T["setup()"]["creates user keymaps"] = function()
	require("floatrunner.init").setup({
		maps = { floaterm_on = "floaterm_on" }
	})

	local found = false

	for _, keymap in ipairs(vim.api.nvim_get_keymap("n")) do
		if keymap.lhs == "floaterm_on" then
			found = true
		end
	end

	eq(found, true)
end

return T
