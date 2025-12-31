-- DREAMBase/test/bootstrap.lua
--
-- Shared headless bootstrap for busted/unit runs across the DREAM ecosystem.
-- This module is intentionally safe to call multiple times.

local M = {}

local function canWritePackagePath()
	if type(package) ~= "table" then
		return false
	end
	if type(package.path) ~= "string" then
		return false
	end
	local ok = pcall(function()
		local original = package.path
		package.path = original
	end)
	return ok == true
end

local function ensureInPackagePath(fragment)
	if type(package) ~= "table" or type(package.path) ~= "string" then
		return false
	end
	return package.path:find(fragment, 1, true) ~= nil
end

local function prefixPackagePath(fragment)
	if not canWritePackagePath() then
		return
	end
	if ensureInPackagePath(fragment) then
		return
	end
	package.path = fragment .. ";" .. package.path
end

local function addLuaRoot(root)
	if type(root) ~= "string" or root == "" then
		return
	end
	prefixPackagePath(root .. "/?.lua")
	prefixPackagePath(root .. "/?/init.lua")
end

local function joinPath(a, b)
	if type(a) ~= "string" or a == "" then
		return b
	end
	if type(b) ~= "string" or b == "" then
		return a
	end
	if a:sub(-1) == "/" then
		return a .. b
	end
	return a .. "/" .. b
end

local function ensureGetDebug()
	if type(_G) ~= "table" then
		return
	end
	if rawget(_G, "getDebug") ~= nil then
		return
	end
	_G.getDebug = function()
		return false
	end
end

local function ensureModData()
	if type(_G) ~= "table" then
		return
	end
	if type(rawget(_G, "ModData")) == "table" and type(_G.ModData.getOrCreate) == "function" then
		return
	end
	local data = {}
	_G.ModData = {
		getOrCreate = function(key)
			if data[key] == nil then
				data[key] = {}
			end
			return data[key]
		end,
	}
end

local function ensureEvents()
	if type(_G) ~= "table" then
		return
	end
	if type(rawget(_G, "Events")) == "table" then
		return
	end
	_G.Events = {
		OnTick = {
			Add = function() end,
			Remove = function() end,
		},
	}
end

--- Apply shared test bootstrap.
--- @param opts table|nil { repoRoot?:string, luaRoots?:table, modId?:string }
function M.apply(opts)
	opts = opts or {}

	local repoRoot = opts.repoRoot
	local roots = {}

	if type(opts.luaRoots) == "table" then
		for i = 1, #opts.luaRoots do
			roots[#roots + 1] = opts.luaRoots[i]
		end
	end

	if type(opts.modId) == "string" and opts.modId ~= "" then
		local rel = "Contents/mods/" .. opts.modId .. "/42/media/lua/shared"
		roots[#roots + 1] = (type(repoRoot) == "string" and repoRoot ~= "") and joinPath(repoRoot, rel) or rel
	end

	for i = 1, #roots do
		addLuaRoot(roots[i])
	end

	ensureGetDebug()
	ensureModData()
	ensureEvents()

	if type(_G) == "table" and type(_G.describe) == "function" then
		_G.DREAMBASE_HEADLESS = true
	end
end

return M

