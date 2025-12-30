-- DREAMBase/events.lua -- event interop helpers.

local moduleName = ...
local Events = {}
if type(moduleName) == "string" then
	---@diagnostic disable-next-line: undefined-field
	local loaded = package.loaded[moduleName]
	if type(loaded) == "table" then
		Events = loaded
	else
		---@diagnostic disable-next-line: undefined-field
		package.loaded[moduleName] = Events
	end
end

local U = require("DREAMBase/util")

if Events.subscribeEvent == nil then
	--- Subscribe to a PZ/Starlit event source (Add/Remove or addListener/removeListener).
	--- @param eventSource table
	--- @param handler function
	--- @return function|nil unsubscribe
	function Events.subscribeEvent(eventSource, handler)
		return U.subscribeEvent(eventSource, handler)
	end
end

return Events

