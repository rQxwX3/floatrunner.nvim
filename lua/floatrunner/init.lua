local floaterm_types = require "floatrunner.types.floaterm-types"
local config_types = require "floatrunner.types.config-types"

local floaterm = require "floatrunner.floaterm"
local fileutils = require "floatrunner.internal.fileutils"
local buildutils = require "floatrunner.internal.buildutils"
local config = require "floatrunner.config"

local M = {}

---@type FloatState
local state = {
	buf = -1,
	win = -1,
	chan = -1,
}

---Sets up the plugin with either default or provided options
---@param opts Options
M.setup = function(opts)
	config.set(opts)

	local maps = config.get().maps

	vim.keymap.set("n", maps.floaterm_on, M.toggle_floaterm,
		{ noremap = true, silent = true })

	vim.keymap.set("n", maps.floatrun, M.floatrun,
		{ noremap = true, silent = true })

	vim.keymap.set("n", maps.floatbuild, M.floatbuild,
		{ noremap = true, silent = true })

	-- Do not set the keymap for term buffer unless it is floaterm
	vim.api.nvim_create_autocmd("TermOpen", {
		callback = function(event)
			if event.buf == state.buf then
				vim.keymap.set("t", maps.floaterm_off, M.toggle_floaterm,
					{ buffer = event.buf, noremap = true, silent = true })
			end
		end,
	})
end


---Shows or hide FloaTerm
M.toggle_floaterm = function()
	if not floaterm.is_valid_floaterm(state) then
		floaterm.show_floaterm(state)
	else
		vim.api.nvim_win_hide(state.win)
	end
end


---Runs the current file
M.floatrun = function()
	local command = fileutils.get_run_cmd(config.get().langs)

	if command then
		floaterm.run_in_floaterm(state, command)
	else
		vim.notify("Unable to get run command", vim.log.levels.WARN)
	end
end


---Builds the current project
M.floatbuild = function()
	local build = buildutils.get_build_cmd(config.get().builds)

	if not build then return end

	if build.path and build.command then
		floaterm.run_in_floaterm(state, build.command, build.path)
		return
	end

	if not build.path then
		vim.notify("Unable to get build path", vim.log.levels.WARN)
	else
		vim.notify("Unable to get build command", vim.log.levels.WARN)
	end
end


return M
