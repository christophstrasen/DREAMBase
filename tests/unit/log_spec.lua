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

describe("DREAMBase log", function()
	it("provides a compatible fallback logger when LQR is unavailable", function()
		package.preload["LQR/util/log"] = nil
		local Log = reload("DREAMBase/log")

		assert.is_table(Log)
		assert.is_function(Log.withTag)
		assert.is_function(Log.setLevel)
		assert.is_function(Log.getLevel)

		local tagged = Log.withTag("TEST")
		assert.is_table(tagged)
		assert.is_function(tagged.info)
		assert.is_function(tagged.warn)
	end)

	it("delegates to LQR util log when available", function()
		local saved = package.preload["LQR/util/log"]
		package.preload["LQR/util/log"] = function()
			return {
				withTag = function(tag)
					return { tag = tag }
				end,
			}
		end

		local Log = reload("DREAMBase/log")
		local tagged = Log.withTag("ABC")
		assert.equals("ABC", tagged.tag)

		package.preload["LQR/util/log"] = saved
		package.loaded["DREAMBase/log"] = nil
	end)
end)

