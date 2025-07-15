local M = {}

M.getbuildcmd = function(builds)
	local Path = require("plenary.path")
	local path = Path:new(vim.fn.expand("%:p")):parent()

	while path and path:absolute() ~= "/" do
		for _, build in ipairs(builds) do
			local candidate = path:joinpath(build.filename)

			if candidate:exists() then
				return {
					path = path:absolute(),
					command = build.command
				}
			end
		end

		path = path:parent()
	end

	return nil
end

return M
