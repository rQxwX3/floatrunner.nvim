local Path = require("plenary.path")

local M = {}

M.builds_cache = {}

M.get_cached_build = function(init_path)
	for _, item in ipairs(M.builds_cache) do
		if item.init_path == init_path:absolute() then
			return item.build
		end
	end

	return nil
end

M.cache_build = function(init_path, build)
	table.insert(M.builds_cache, {
		init_path = init_path:absolute(),
		build = build
	})
end


M.get_build_cmd = function(builds)
	local init_path = Path:new(vim.fn.expand("%:p")):parent()

	local cached = M.get_cached_build(init_path)
	if cached then return cached end

	local search_path = init_path

	while search_path and search_path:absolute() ~= "/" do
		for _, build in ipairs(builds) do
			local candidate = search_path:joinpath(build.filename)

			if candidate:exists() then
				local new_build = {
					path = search_path:absolute(),
					command = build.command
				}

				M.cache_build(init_path, new_build)

				return new_build
			end
		end

		search_path = search_path:parent()
	end

	return nil
end

return M
