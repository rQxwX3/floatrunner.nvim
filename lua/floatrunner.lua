local backend = require "backend"


local M = {}


local state = {
	floaterm = {
		buf = -1,
		win = -1,
		chan = -1,
	}
}


M.setup = function()
	vim.keymap.set("n", "<leader>tt", M.toggle_floaterm)
	vim.keymap.set("t", "<esc><esc>", M.toggle_floaterm, {
		buffer = state.floaterm.buf
	})
	vim.keymap.set("n", "<leader>cc", M.compile_run_c)
end


M.toggle_floaterm = function()
	if not backend.is_valid_floaterm(state.floaterm) then
		state.floaterm = backend.create_floaterm(state.floaterm)
	else
		vim.api.nvim_win_hide(state.floaterm.win)
	end
end


M.compile_run_c = function()
	local cfile = vim.fn.expand("%:t")
	local objfile = vim.fn.expand("%:r")

	local cmdstring = string.format("gcc %s -o %s && ./%s", cfile, objfile, objfile)

	backend.run_in_floaterm(cmdstring, state.floaterm)
end


return M
