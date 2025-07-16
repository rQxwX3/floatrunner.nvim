local defaults = require "floatrunner.defaults"

local M = {
	opts = vim.deepcopy(defaults)
}

M.set = function(user_opts)
	user_opts = user_opts or {}

	M.opts = vim.tbl_deep_extend(
		"force", vim.deepcopy(defaults), user_opts
	)
end


M.get = function() return M.opts end

return M
