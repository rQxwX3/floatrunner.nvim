local types = require "floatrunner.types.floaterm-types"

---@class FloaTermModule
local M = {}

---Check if FloaTerm has valid Window and Buffer
---@param floatstate FloatState
---@return boolean
M.is_valid_floaterm = function(floatstate)
	return vim.api.nvim_buf_is_valid(floatstate.buf) and
			vim.api.nvim_win_is_valid(floatstate.win)
end


---Runs a command in FloaTerm
---@param floatstate	FloatState
---@param command			string				Command to be run
---@param cwd?				string				Directory in which command should be run
M.run_in_floaterm = function(floatstate, command, cwd)
	cwd = cwd or vim.loop.cwd()

	if not vim.api.nvim_buf_is_valid(floatstate.buf) or vim.loop.cwd() ~= cwd then
		M.create_termbuf(floatstate, cwd)
	end

	vim.api.nvim_create_autocmd("TermEnter", {
		once = true,
		callback = function()
			vim.defer_fn(function()
				vim.fn.chansend(floatstate.chan, command .. "\n")
			end, 50)
		end
	})

	M.show_floaterm(floatstate)
end


---Shows FloaTerm to the user
---@param floatstate FloatState
M.show_floaterm = function(floatstate)
	if M.is_valid_floaterm(floatstate) then return end

	if not vim.api.nvim_buf_is_valid(floatstate.buf) then
		M.create_termbuf(floatstate)
	end

	local height = math.floor(vim.o.lines * 0.8)
	local width = math.floor(vim.o.columns * 0.8)
	local col = math.floor((vim.o.columns - width) / 2)
	local row = math.floor((vim.o.lines - height) / 2)

	local win_config = {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		style = "minimal",
		border = "rounded"
	}

	floatstate.win = vim.api.nvim_open_win(
		floatstate.buf, true, win_config
	)

	vim.cmd("startinsert")
end


---Creates Buffer for FloaTerm
---@param floatstate	FloatState
---@param cwd?				string				Current working directory for FloaTerm
M.create_termbuf = function(floatstate, cwd)
	cwd = cwd or vim.loop.cwd()

	floatstate.buf = vim.api.nvim_create_buf(false, true)

	vim.api.nvim_buf_call(floatstate.buf, function()
		floatstate.chan = vim.fn.jobstart(os.getenv("SHELL") or "sh",
			{ term = true, cwd = cwd }
		)
	end)
end

return M
