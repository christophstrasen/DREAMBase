-- DREAMBase/time_ms.lua -- shared time helpers (game ms, cpu ms) with minimal guarding.

local moduleName = ...
local Time = {}
if type(moduleName) == "string" then
	---@diagnostic disable-next-line: undefined-field
	local loaded = package.loaded[moduleName]
	if type(loaded) == "table" then
		Time = loaded
	else
		---@diagnostic disable-next-line: undefined-field
		package.loaded[moduleName] = Time
	end
end

if Time.gameMillis == nil then
	--- @return number|nil
	function Time.gameMillis()
		local getGameTime = (type(_G) == "table") and rawget(_G, "getGameTime") or nil
		if getGameTime then
			local t = getGameTime()
			if t and t.getTimeCalendar then
				local c = t:getTimeCalendar()
				if c and c.getTimeInMillis then
					return c:getTimeInMillis()
				end
			end
		end
		if os and os.time then
			return os.time() * 1000
		end
		return nil
	end
end

if Time.cpuMillis == nil then
	--- @return number|nil
	function Time.cpuMillis()
		if os and os.clock then
			return os.clock() * 1000
		end
		return nil
	end
end

return Time

