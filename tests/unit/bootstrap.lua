package.path = table.concat({
	"Contents/mods/DREAMBase/42/media/lua/shared/?.lua",
	"Contents/mods/DREAMBase/42/media/lua/shared/?/init.lua",
	package.path,
}, ";")

local Bootstrap = require("DREAMBase/test/bootstrap")
assert(
	type(Bootstrap) == "table" and type(Bootstrap.apply) == "function",
	"DREAMBase/test/bootstrap must export apply()"
)
Bootstrap.apply({
	luaRoots = {
		"Contents/mods/DREAMBase/42/media/lua/shared",
	},
})
