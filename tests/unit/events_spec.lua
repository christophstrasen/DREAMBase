package.path = table.concat({
	"Contents/mods/DREAMBase/42/media/lua/shared/?.lua",
	"Contents/mods/DREAMBase/42/media/lua/shared/?/init.lua",
	package.path,
}, ";")

_G.getDebug = function()
	return false
end

local function reload(moduleName)
	package.loaded[moduleName] = nil
	return require(moduleName)
end

describe("DREAMBase events", function()
	it("subscribes to PZ events via Add/Remove", function()
		local U = reload("DREAMBase/util")

		local event = { handlers = {} }
		function event.Add(fn)
			event.handlers[fn] = true
		end
		function event.Remove(fn)
			event.handlers[fn] = nil
		end
		function event.fire(payload)
			for fn in pairs(event.handlers) do
				fn(payload)
			end
		end

		local received = {}
		local unsubscribe = U.subscribeEvent(event, function(payload)
			table.insert(received, payload)
		end)

		assert.is_function(unsubscribe)

		event.fire("hello")
		assert.equals(1, #received)
		assert.equals("hello", received[1])

		unsubscribe()
		event.fire("again")
		assert.equals(1, #received)
	end)

	it("subscribes to LuaEvent via addListener/removeListener (token unsubscribe)", function()
		local U = reload("DREAMBase/util")

		local event = { listeners = {} }
		function event:addListener(fn)
			local token = {}
			self.listeners[token] = fn
			return token
		end
		function event:removeListener(token)
			if type(token) ~= "table" then
				error("token required")
			end
			self.listeners[token] = nil
		end
		function event:emit(payload)
			for _, fn in pairs(self.listeners) do
				fn(payload)
			end
		end

		local received = {}
		local unsubscribe = U.subscribeEvent(event, function(payload)
			table.insert(received, payload)
		end)

		assert.is_function(unsubscribe)

		event:emit("hello")
		assert.equals(1, #received)
		assert.equals("hello", received[1])

		unsubscribe()
		event:emit("again")
		assert.equals(1, #received)
	end)
end)

