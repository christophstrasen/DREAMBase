describe("DREAMBase test/bootstrap", function()
	it("adds luaRoots and provides default headless globals", function()
		local TB = require("DREAMBase/test/bootstrap")

		local savedPath = package.path
		local savedGetDebug = rawget(_G, "getDebug")
		local savedModData = rawget(_G, "ModData")
		local savedEvents = rawget(_G, "Events")

		_G.getDebug = nil
		_G.ModData = nil
		_G.Events = nil

		TB.apply({ luaRoots = { "tests/fixtures" } })

		assert.is_function(_G.getDebug)
		assert.is_false(_G.getDebug())
		assert.is_table(_G.ModData)
		assert.is_function(_G.ModData.getOrCreate)
		assert.is_table(_G.Events)
		assert.is_table(_G.Events.OnTick)
		assert.is_function(_G.Events.OnTick.Add)
		assert.is_function(_G.Events.OnTick.Remove)
		assert.is_truthy(package.path:find("tests/fixtures/?.lua", 1, true))

		package.path = savedPath
		_G.getDebug = savedGetDebug
		_G.ModData = savedModData
		_G.Events = savedEvents
	end)
end)
