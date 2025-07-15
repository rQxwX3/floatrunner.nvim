local floaterm = require "floatrunner.floaterm"
local fileutils = require "floatrunner.internal.fileutils"
local buildutils = require "floatrunner.internal.buildutils"
local defaults = require "floatrunner.defaults"

local M = {}

local state = {
	floaterm = {
		buf = -1,
		win = -1,
		chan = -1,
	}
}

local langs = defaults.langs
local maps = defaults.maps
local builds = defaults.builds

M.setup = function(opts)
	opts = opts or {}

	if opts then
		if opts.langs then langs = opts.langs end
		if opts.maps then maps = opts.maps end
	end

	vim.keymap.set("n", maps.floaterm_on, M.toggle_floaterm,
		{ noremap = true, silent = true })

	vim.keymap.set("n", maps.floatrun, M.floatrun,
		{ noremap = true, silent = true })

	vim.keymap.set("n", maps.floatbuild, M.floatbuild,
		{ noremap = true, silent = true })

	-- Do not set the keymap for term buffer unless it is floaterm
	vim.api.nvim_create_autocmd("TermOpen", {
		callback = function(event)
			if event.buf == state.floaterm.buf then
				vim.keymap.set("t", maps.floaterm_off, M.toggle_floaterm,
					{ buffer = event.buf, noremap = true, silent = true })
			end
		end,
	})
end


M.toggle_floaterm = function()
	if not floaterm.is_valid_floaterm(state.floaterm) then
		floaterm.show_floaterm(state.floaterm)
	else
		vim.api.nvim_win_close(state.floaterm.win, false)
	end
end


M.floatrun = function()
	local command = fileutils.getruncmd(langs)

	if command then
		floaterm.run_in_floaterm(state.floaterm, command)
	else
		vim.notify("Unable to get run command", vim.log.levels.WARN)
	end
end


M.floatbuild = function()
	local build = buildutils.getbuildcmd(builds)

	if not build then return end

	if build.path and build.command then
		--floaterm.run_in_floaterm(build.command, build.path, state.floaterm)
		return
	end

	if not build.path then
		vim.notify("Unable to get build path", vim.log.levels.WARN)
	else
		vim.notify("Unable to get build command", vim.log.levels.WARN)
	end
end


return M
