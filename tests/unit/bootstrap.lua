package.path = table.concat({
	"Contents/mods/DREAMBase/42/media/lua/shared/?.lua",
	"Contents/mods/DREAMBase/42/media/lua/shared/?/init.lua",
	package.path,
}, ";")

local ok, Bootstrap = pcall(require, "DREAMBase/test/bootstrap")
if ok and type(Bootstrap) == "table" and type(Bootstrap.apply) == "function" then
	Bootstrap.apply({
		luaRoots = {
			"Contents/mods/DREAMBase/42/media/lua/shared",
		},
	})
end

