---@diagnostic disable: undefined-global
local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality
local noeq = MiniTest.expect.no_equality

local T = new_set()

T["setup()"] = new_set({
	hooks = {
		pre_case = function()
			pcall(vim.api.nvim_del_keymap, "n", "floaterm_on")
			pcall(vim.api.nvim_del_user_command, "FloatRunner")
			package.loaded["floatrunner.init"] = nil
			package.loaded["floatrunner.config"] = nil
		end
	}
})

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
	local user_cmd = cmds["FloatRunner"]

	noeq(user_cmd, nil)
	eq(user_cmd.nargs, "1")
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

T["utils"] = new_set({
	hooks = {
		pre_case = function()
			package.loaded["floatrunner.internal.fileutils"] = nil
			package.loaded["floatrunner.internal.buildutils"] = nil
		end
	}
})


T["utils"]["get_run_cmd()"] = function()
	vim.cmd("enew")

	vim.api.nvim_buf_set_name(0, "main.c")

	local langs = {
		{ exts = { "c" }, command = "command", argv = {} }
	}

	local res = require("floatrunner.internal.fileutils").get_run_cmd(langs)

	eq(res, "command")
end


T["utils"]["get_build_cmd()"] = function()
	local tmpfile = "/tmp/floatrunner-test/build-test.c"
	local tmpdir = "/tmp/floatrunner-test"

	vim.cmd("enew")

	vim.api.nvim_buf_set_name(0, tmpfile)
	vim.fn.mkdir("/tmp/floatrunner-test", "p")
	vim.loop.chdir(tmpdir)
	vim.fn.writefile({ "# Dummy Makefile" }, "/tmp/floatrunner-test/Makefile")

	local buildutils = require("floatrunner.internal.buildutils")

	buildutils.builds_cache = {}

	local builds = { ["Makefile"] = "make command" }

	vim.cmd("edit " .. tmpfile)

	local result = buildutils.get_build_cmd(builds)

	noeq(result, nil)
	eq(result.path, vim.fn.resolve(tmpdir))
	eq(result.command, "make command")

	local cached = buildutils.get_cached_build(tmpdir)
	eq(cached, result)
end

return T
