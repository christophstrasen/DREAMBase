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

local function assertPZEvent(eventSource)
	U.assertf(type(eventSource) == "table", "eventSource must be a table")
	U.assertf(type(eventSource.Add) == "function", "eventSource.Add must be a function")
	U.assertf(type(eventSource.Remove) == "function", "eventSource.Remove must be a function")
end

local function assertLuaEvent(eventSource)
	U.assertf(type(eventSource) == "table", "eventSource must be a table")
	U.assertf(type(eventSource.addListener) == "function", "eventSource.addListener must be a function")
	U.assertf(type(eventSource.removeListener) == "function", "eventSource.removeListener must be a function")
end

if Events.fromPZEvent == nil then
	--- Build a situationStream from a PZ event source (Add/Remove).
	--- @param eventSource table
	--- @param mapEventToCandidate function
	--- @return table situationStream
	function Events.fromPZEvent(eventSource, mapEventToCandidate)
		assertPZEvent(eventSource)
		return {
			subscribe = function(_, onNext)
				local handler = function(...)
					if not onNext then
						return
					end
					local candidate = mapEventToCandidate(...)
					if candidate ~= nil then
						onNext(candidate)
					end
				end

				local ok = pcall(eventSource.Add, handler)
				if not ok then
					ok = pcall(eventSource.Add, eventSource, handler)
				end
				if not ok then
					error("pz_event_subscribe_failed", 2)
				end

				return {
					unsubscribe = function()
						local okRemove = pcall(eventSource.Remove, handler)
						if not okRemove then
							pcall(eventSource.Remove, eventSource, handler)
						end
					end,
				}
			end,
		}
	end
end

local function subscribeLuaEvent(eventSource, handler)
	local ok, token = pcall(eventSource.addListener, eventSource, handler)
	if not ok then
		ok, token = pcall(eventSource.addListener, handler)
	end
	if not ok then
		return nil
	end
	return function()
		local removeArg = token ~= nil and token or handler
		local okRemove = pcall(eventSource.removeListener, eventSource, removeArg)
		if not okRemove then
			pcall(eventSource.removeListener, removeArg)
		end
	end
end

if Events.fromLuaEvent == nil then
	--- Build a situationStream from a LuaEvent source (addListener/removeListener).
	--- @param eventSource table
	--- @param mapEventToCandidate function
	--- @return table situationStream
	function Events.fromLuaEvent(eventSource, mapEventToCandidate)
		assertLuaEvent(eventSource)
		return {
			subscribe = function(_, onNext)
				local handler = function(...)
					if not onNext then
						return
					end
					local candidate = mapEventToCandidate(...)
					if candidate ~= nil then
						onNext(candidate)
					end
				end
				local unsubscribe = subscribeLuaEvent(eventSource, handler)
				if not unsubscribe then
					error("luaevent_subscribe_failed", 2)
				end
				return {
					unsubscribe = function()
						unsubscribe()
					end,
				}
			end,
		}
	end
end

return Events
