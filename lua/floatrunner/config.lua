local types = require "floatrunner.types.config-types"
local defaults = require "floatrunner.defaults"

local M = {
	opts = vim.deepcopy(defaults)
}

---Sets configuration to user options
---@param user_opts? Options
M.set = function(user_opts)
	user_opts = user_opts or {}

	M.opts = vim.tbl_deep_extend(
		"force", vim.deepcopy(defaults), user_opts
	)
end


---Return configuration to caller
---@return Options
M.get = function() return M.opts end

return M
