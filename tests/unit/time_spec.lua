dofile("tests/unit/bootstrap.lua")

local function reload(moduleName)
	package.loaded[moduleName] = nil
	return require(moduleName)
end

describe("DREAMBase time_ms", function()
	it("uses getGameTime calendar millis when available", function()
		local saved = _G.getGameTime
		_G.getGameTime = function()
			local t = {}
			function t:getTimeCalendar()
				local c = {}
				function c:getTimeInMillis()
					return 123
				end
				return c
			end
			return t
		end

		local Time = reload("DREAMBase/time_ms")
		assert.equals(123, Time.gameMillis())

		_G.getGameTime = saved
		package.loaded["DREAMBase/time_ms"] = nil
	end)
end)
