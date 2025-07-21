local types = require "floatrunner.types.config-types"

local M = {}

---Sets configuration to user options
---@param user_opts? Options
M.set = function(user_opts)
	M.opts = user_opts or {}
end

---Returns configuration to caller
---@return Options
M.get = function() return M.opts end

return M
