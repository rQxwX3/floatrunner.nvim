---@diagnostic disable: undefined-global
local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality
local noeq = MiniTest.expect.no_equality

local T = new_set()

T["init"] = new_set({
	hooks = {
		pre_case = function()
			pcall(vim.api.nvim_del_keymap, "n", "floaterm_on")
			pcall(vim.api.nvim_del_user_command, "FloatRunner")
			package.loaded["floatrunner.init"] = nil
			package.loaded["floatrunner.config"] = nil
		end
	}
})


T["init"]["sets user options"] = function()
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


T["init"]["registers user commands"] = function()
	require("floatrunner.init").setup({})

	local cmds = vim.api.nvim_get_commands({})
	local user_cmd = cmds["FloatRunner"]

	noeq(user_cmd, nil)
	eq(user_cmd.nargs, "1")
end


T["init"]["creates user keymaps"] = function()
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


local tmpfile, tmpdir, builds, buildutils

T["buildutils"] = new_set({
	hooks = {
		pre_case = function()
			tmpfile = "/tmp/floatrunner-test/build-test.c"
			tmpdir = "/tmp/floatrunner-test"
			builds = { ["Makefile"] = "make" }
			buildutils = require("floatrunner.internal.buildutils")
			buildutils.builds_cache = {}

			vim.fn.mkdir(tmpdir, "p")
			vim.loop.chdir(tmpdir)
			vim.fn.writefile({ "# Dummy Makefile" }, tmpdir .. "/Makefile")
			vim.cmd("edit " .. tmpfile)
		end,

		post_case = function()
			os.execute("rm -rf " .. tmpdir)
			package.loaded["floatrunner.internal.buildutils"] = nil
		end
	}
})


T["buildutils"]["gets build command from builds"] = function()
	local result = buildutils.get_build_cmd(builds)

	noeq(result, nil)
	eq(result.path, tmpdir)
	eq(result.command, "make")
end


T["buildutils"]["caches build command"] = function()
	buildutils.get_build_cmd(builds)

	local cached = buildutils.get_cached_build(tmpdir)

	eq(cached, { command = "make", path = tmpdir })
end


T["buildutils"]["gets build command from cache"] = function()
	builds = { ["Makefile"] = "make from cache" }
	buildutils.get_build_cmd(builds)

	builds = { ["Makefile"] = "make" }

	local result = buildutils.get_build_cmd(builds)

	eq(result.command, "make from cache")
end


T["fileutils"] = new_set({
	hooks = {
		pre_case = function()
			tmpfile = "/tmp/floatrunner-test/build-test.c"
			tmpdir = "/tmp/floatrunner-test"

			vim.fn.mkdir(tmpdir, "p")
			vim.loop.chdir(tmpdir)
			vim.cmd("edit " .. tmpfile)
		end,

		post_case = function()
			os.execute("rm -rf " .. tmpdir)

			package.loaded["floatrunner.internal.fileutils"] = nil
		end
	}
})

T["fileutils"]["gets run command"] = function()
	local langs = { { exts = { "c" }, command = "command", argv = {} } }
	local res = require("floatrunner.internal.fileutils").get_run_cmd(langs)

	eq(res, "command")
end


local floatstate, cwd

T["floaterm"] = new_set({
	hooks = {
		pre_case = function()
			floatstate = { buf = -1, chan = -1, win = -1 }
			cwd = "/tmp/floatrunner-test"
			vim.fn.mkdir(cwd, "p")
		end,

		post_case = function()
			os.execute("rm -rf " .. tmpdir)

			if vim.api.nvim_buf_is_loaded(floatstate.buf) then
				vim.api.nvim_buf_delete(floatstate.buf, { force = true })
			end

			package.loaded["floatrunner.floaterm"] = nil
		end
	}
})


T["floaterm"]["creates valid buffer"] = function()
	require("floatrunner.floaterm").show_floaterm(floatstate)
	local bufs = vim.api.nvim_list_bufs()

	eq(vim.api.nvim_buf_is_valid(floatstate.buf), true)
	noeq(bufs[floatstate.buf], nil)
	eq(vim.api.nvim_get_option_value("buftype", { buf = floatstate.buf }), "terminal")
end


T["floaterm"]["creates valid window"] = function()
	require("floatrunner.floaterm").show_floaterm(floatstate)
	local wins = vim.api.nvim_list_wins()

	eq(vim.api.nvim_win_is_valid(floatstate.win), true)
end


T["floaterm"]["doesn't create terminal if one already exists"] = function()
	require("floatrunner.floaterm").show_floaterm(floatstate)
	local existing_floatstate = floatstate
	require("floatrunner.floaterm").show_floaterm(floatstate)
	eq(floatstate, existing_floatstate)
end


return T
