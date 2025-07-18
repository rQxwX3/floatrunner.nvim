---@class Options
---@field langs LangConfig[]
---@field builds BuildConfig[]
---@field maps MapConfig
---
---@class LangConfig
---@field exts		string[]		List of file extensions			
---@field command string			Command to run on file
---@field argv		string[]		Arguments for %s placeholders in command
---                           (use "%" for current file with NO extension,
---                           "%." to preserve extension)
---@class BuildConfig
---@field filename	string		Build file name (with extension)
---@field command		string		Command to run

---@class MapConfig
---@field floaterm_on		string		Show FloaTerm	
---@field floaterm_off	string		Hide FloaTerm
---@field floatrun			string		Run current file
---@field floatbuild		string		Build current project

return {}
