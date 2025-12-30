-- DREAMBase/bootstrap.lua
--
-- Headless convenience: best-effort package.path extension for running DREAMBase code outside PZ.

local ok_debug, debug = pcall(require, "debug")
local ok_package, package = pcall(function()
	return package
end)

if not ok_package or type(package) ~= "table" then
	return {
		repoRoot = nil,
	}
end

local function resolve_repo_root()
	if not (ok_debug and type(debug) == "table" and type(debug.getinfo) == "function") then
		return nil
	end

	local ok, info = pcall(function()
		return debug.getinfo(1, "S")
	end)
	if not ok or type(info) ~= "table" then
		return nil
	end

	local source = info.source or ""
	if source:sub(1, 1) ~= "@" then
		return nil
	end

	local path = source:sub(2)
	local root = path:match("^(.*)/Contents/mods/DREAMBase/")
	return root
end

local repoRoot = resolve_repo_root()

local function prefix_path(path)
	package.path = table.concat({ path, package.path }, ";")
end

local function ensure_in_path(needle)
	if type(package.path) ~= "string" then
		return false
	end
	return package.path:find(needle, 1, true) ~= nil
end

local function extend()
	local rel = "Contents/mods/DREAMBase/42/media/lua/shared/?.lua"
	local full = repoRoot and (repoRoot .. "/" .. rel) or rel

	if not ensure_in_path(rel) and not (repoRoot and ensure_in_path(full)) then
		prefix_path(full)
	end
end

-- PZ disallows tampering with package.path; guard behind a writeability check.
local okWrite = pcall(function()
	local original = package.path
	package.path = original
end)

if okWrite then
	extend()
end

if type(_G) == "table" and type(_G.describe) == "function" then
	_G.DREAMBASE_HEADLESS = true
end

return {
	repoRoot = repoRoot,
}

