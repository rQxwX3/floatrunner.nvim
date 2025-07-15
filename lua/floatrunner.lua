local backend = require "backend"
local defaults = require "defaults"

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
	if not backend.is_valid_floaterm(state.floaterm) then
		state.floaterm = backend.create_floaterm(state.floaterm)
	else
		vim.api.nvim_win_hide(state.floaterm.win)
	end
end


M.floatrun = function()
	local cmdstring = backend.get_cmdstring(langs)

	if cmdstring then
		backend.run_in_floaterm(cmdstring, state.floaterm)
	else
		vim.notify("Unable to create cmdstring", vim.log.levels.WARN)
	end
end


return M
