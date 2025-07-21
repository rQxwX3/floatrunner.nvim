local config_types = require "floatrunner.types.config-types"

local Path = require("plenary.path")

local M = {}

---@class CachedBuild
---@field init_path		string				Absolute path to the current file
---@field build				BuildConfig		Build configuration

---@type CachedBuild[]
M.builds_cache = {}

---Gets build config from cache (is present)
---@param init_path		string		Absolute path to the current file
---@return						BuildConfig | nil
M.get_cached_build = function(init_path)
	for _, item in ipairs(M.builds_cache) do
		if item.init_path == init_path:absolute() then
			return item.build
		end
	end

	return nil
end


---Puts build config to cache
---@param init_path string			Absolute path to the current file
---@param build			BuildConfig	Build configuration to cache
M.cache_build = function(init_path, build)
	table.insert(M.builds_cache, {
		init_path = init_path:absolute(),
		build = build
	})
end


---Finds and return command to build the project
---@param builds BuildConfig[]		List of set build configurations
---@return BuildConfig | nil
M.get_build_cmd = function(builds)
	if not builds then return nil end

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
