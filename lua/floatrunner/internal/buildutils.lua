local config_types = require "floatrunner.types.config-types"

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
		if item.init_path == init_path then
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
		init_path = init_path,
		build = build
	})
end


---Finds and return command to build the project
---@param builds BuildsMap			--Map of set build configurations
---@return BuildConfig | nil		--Build configuration to use or nil
M.get_build_cmd = function(builds)
	if not builds then return nil end

	local init_path = vim.fn.expand("%:p:h")

	local cached = M.get_cached_build(init_path)
	if cached then return cached end

	local new_build = {}
	local buildfiles = {}

	for filename, command in pairs(builds) do
		table.insert(buildfiles, filename)
	end

	local buildfile_path = vim.fs.find(
		buildfiles, { path = init_path, upward = true, type = "file", stop = "~" }
	)[1]

	if buildfile_path then
		local path = vim.fn.fnamemodify(buildfile_path, ":p:h")
		local filename = vim.fn.fnamemodify(buildfile_path, ":t")

		new_build = { path = path, command = builds[filename] }

		M.cache_build(init_path, new_build)
	end

	return new_build
end

return M
