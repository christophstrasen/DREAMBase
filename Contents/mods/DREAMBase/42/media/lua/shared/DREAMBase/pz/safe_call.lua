-- DREAMBase/pz/safe_call.lua -- safe pcall wrapper for engine method invocations.

local moduleName = ...
local SafeCall = {}
if type(moduleName) == "string" then
	---@diagnostic disable-next-line: undefined-field
	local loaded = package.loaded[moduleName]
	if type(loaded) == "table" then
		SafeCall = loaded
	else
		---@diagnostic disable-next-line: undefined-field
		package.loaded[moduleName] = SafeCall
	end
end
SafeCall._internal = SafeCall._internal or {}

if SafeCall.safeCall == nil then
	--- @param obj any
	--- @param methodName string
	--- @param ... any
	--- @return any|nil
	function SafeCall.safeCall(obj, methodName, ...)
		if obj and type(obj[methodName]) == "function" then
			local ok, value = pcall(obj[methodName], obj, ...)
			if ok then
				return value
			end
		end
		return nil
	end
end

SafeCall._internal.safeCall = SafeCall.safeCall

return SafeCall

