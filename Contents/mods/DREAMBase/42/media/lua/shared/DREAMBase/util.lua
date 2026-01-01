-- DREAMBase/util.lua

local moduleName = ...

---@class DREAMBase.Util
local U = {}
if type(moduleName) == "string" then
	---@diagnostic disable-next-line: undefined-field
	local loaded = package.loaded[moduleName]
	if type(loaded) == "table" then
		U = loaded
	else
		---@diagnostic disable-next-line: undefined-field
		package.loaded[moduleName] = U
	end
end

local function debugEnabled()
	if type(_G) ~= "table" then
		return false
	end
	local f = rawget(_G, "getDebug")
	if type(f) ~= "function" then
		return false
	end
	local ok, value = pcall(f)
	return ok and value == true
end

if U.makeLogger == nil then
	--- Build a debug-gated log function for the given tag.
	--- @param tag string
	--- @return fun(msg:any)
	function U.makeLogger(tag)
		return function(msg)
			if debugEnabled() then
				U.log(tag, msg)
			end
		end
	end
end

if U.asStringList == nil then
	--- Normalize a single string or list into a deduped string list.
	--- @param value any
	--- @param default_list table|nil
	--- @return table|nil
	function U.asStringList(value, default_list)
		local out, seen = {}, {}

		local function addOne(s)
			if type(s) ~= "string" then
				return
			end
			s = s:match("^%s*(.-)%s*$")
			if s ~= "" and not seen[s] then
				seen[s] = true
				out[#out + 1] = s
			end
		end

		if type(value) == "string" then
			addOne(value)
		elseif type(value) == "table" then
			for i = 1, #value do
				addOne(value[i])
			end
		end

		if #out > 0 then
			return out
		end

		if type(default_list) == "table" and #default_list > 0 then
			for i = 1, #default_list do
				addOne(default_list[i])
			end
			return (#out > 0) and out or nil
		end

		return nil
	end
end

if U.clampInt == nil then
	--- Clamp a value to an integer >= minv.
	--- @param n any
	--- @param minv number|nil
	--- @return integer
	function U.clampInt(n, minv)
		local x = math.floor(tonumber(n) or 0)
		if x < (minv or 0) then
			x = (minv or 0)
		end
		return x
	end
end

if U.cheby == nil then
	--- Chebyshev distance (L∞) in 2D.
	--- @return number
	function U.cheby(x1, y1, x2, y2)
		local dx = math.abs((x1 or 0) - (x2 or 0))
		local dy = math.abs((y1 or 0) - (y2 or 0))
		return (dx > dy) and dx or dy
	end
end

if U.shallowCopy == nil then
	--- Shallow copy a map-like table.
	--- @param t table|nil
	--- @return table
	function U.shallowCopy(t)
		if type(t) ~= "table" then
			return {}
		end
		local c = {}
		for k, v in pairs(t) do
			c[k] = v
		end
		return c
	end
end

if U.logCtx == nil then
	--- Debug-gated structured log helper (key=value suffix).
	--- @param tag string
	--- @param msg string
	--- @param ctx table|nil
	function U.logCtx(tag, msg, ctx)
		if not debugEnabled() then
			return
		end
		local parts = {}
		for k, v in pairs(ctx or {}) do
			parts[#parts + 1] = tostring(k) .. "=" .. tostring(v)
		end
		local suffix = (#parts > 0) and (" " .. table.concat(parts, " ")) or ""
		U.log(tag, tostring(msg or "") .. suffix)
	end
end

	if U.log == nil then
		--- Minimal tag+message log helper.
		--- Uses DREAMBase/log (which delegates to LQR when available).
		--- @param tag string|nil
		--- @param msg any
		function U.log(tag, msg)
			local Log = require("DREAMBase/log")
			Log.tagged("info", tostring(tag or "DB"), "%s", tostring(msg or ""))
		end
	end

if U.assertf == nil then
	--- Assert with a formatted-ish message (string).
	--- @param cond any
	--- @param msg any
	--- @return any cond
	function U.assertf(cond, msg)
		if not cond then
			error(tostring(msg or "assert failed"), 2)
		end
		return cond
	end
end

if U.simpleCache == nil then
	--- Simple cache keyed by tostring(key); returns {get, put, clear}.
	function U.simpleCache()
		local store = {}
		local M = {}
		function M.get(key)
			return store[tostring(key)]
		end
		function M.put(key, val)
			store[tostring(key)] = val
		end
		function M.clear()
			store = {}
		end
		return M
	end
end

if U.shortlistFromPool == nil then
	--- Neutral selector with optional shuffling.
	--- deterministic ~= false => take first `take`, no RNG, no mutation.
	--- deterministic == false => Fisher–Yates shuffle then take (mutates pool).
	--- @param pool table
	--- @param take number|nil
	--- @param deterministic boolean|nil
	--- @return table|nil
	function U.shortlistFromPool(pool, take, deterministic)
		if not pool or #pool == 0 then
			return nil
		end
		local n = #pool
		local k = math.min(n, math.max(1, math.floor(take or 1)))

		if deterministic ~= false then
			local out = {}
			for i = 1, k do
				out[i] = pool[i]
			end
			return out
		end

		local rand = (type(_G) == "table") and rawget(_G, "ZombRand") or nil
		if type(rand) ~= "function" then
			rand = function(maxExclusive)
				return math.random(0, (maxExclusive or 1) - 1)
			end
		end

		for i = n, 2, -1 do
			local j = rand(i) + 1
			pool[i], pool[j] = pool[j], pool[i]
		end
		local out = {}
		for i = 1, k do
			out[i] = pool[i]
		end
		return out
	end
end

if U.hash32 == nil then
	--- Deterministic 32-bit hash (djb2) that works in Lua 5.1.
	--- @param s string
	--- @return integer
	function U.hash32(s)
		local h = 5381
		for i = 1, #s do
			h = (h * 32 + h + s:byte(i)) % 0x100000000
		end
		if h < 0 then
			h = -h
		end
		return h
	end
end

if U.murmur32 == nil then
	--- Deterministic 32-bit MurmurHash3 (x86_32) for better avalanche on similar keys.
	--- @param s string
	--- @param seed number|nil
	--- @return integer
	function U.murmur32(s, seed)
		s = tostring(s or "")
		local n = #s
		local h = seed or 0
		local MOD = 0x100000000

		local function normalize32(x)
			x = x % MOD
			if x < 0 then
				x = x + MOD
			end
			return x
		end

		local band, bxor, lshift, rshift, rol
		do
			local b = rawget(_G, "bit32")
			if type(b) == "table" then
				band = b.band
				bxor = b.bxor
				lshift = b.lshift
				rshift = b.rshift
				rol = b.lrotate
			else
				b = rawget(_G, "bit")
				if type(b) == "table" then
					band = b.band
					bxor = b.bxor
					lshift = b.lshift
					rshift = b.rshift
					rol = b.rol or function(x, k)
						return normalize32(lshift(x, k) + rshift(x, 32 - k))
					end
				end
			end
		end

		if not band then
			local function bitOp(a, b, op)
				local res = 0
				local bit = 1
				a = normalize32(a)
				b = normalize32(b)
				for _ = 1, 32 do
					local aa = a % 2
					local bb = b % 2
					if op(aa, bb) then
						res = res + bit
					end
					a = (a - aa) / 2
					b = (b - bb) / 2
					bit = bit * 2
				end
				return res
			end

			band = function(a, b)
				return bitOp(a, b, function(aa, bb)
					return aa == 1 and bb == 1
				end)
			end
			bxor = function(a, b)
				return bitOp(a, b, function(aa, bb)
					return aa ~= bb
				end)
			end
			lshift = function(a, k)
				return normalize32((normalize32(a) * (2 ^ k)) % MOD)
			end
			rshift = function(a, k)
				return math.floor(normalize32(a) / (2 ^ k))
			end
			rol = function(a, k)
				return normalize32(lshift(a, k) + rshift(a, 32 - k))
			end
		end

		local function mul32(a, b)
			local a_lo = band(a, 0xffff)
			local a_hi = rshift(a, 16)
			local b_lo = band(b, 0xffff)
			local b_hi = rshift(b, 16)
			local lo = a_lo * b_lo
			local mid = a_hi * b_lo + a_lo * b_hi
			return band(lo + lshift(band(mid, 0xffff), 16), 0xffffffff)
		end

		h = normalize32(h)
		local c1 = 0xcc9e2d51
		local c2 = 0x1b873593

		local i = 1
		local limit = n - (n % 4)
		while i <= limit do
			local b1, b2, b3, b4 = s:byte(i, i + 3)
			local k = b1 + b2 * 256 + b3 * 65536 + b4 * 16777216
			k = mul32(k, c1)
			k = rol(k, 15)
			k = mul32(k, c2)
			h = bxor(h, k)
			h = rol(h, 13)
			h = normalize32(mul32(h, 5) + 0xe6546b64)
			i = i + 4
		end

		local rem = n % 4
		if rem > 0 then
			local k1 = 0
			local b1 = s:byte(limit + 1) or 0
			local b2 = s:byte(limit + 2) or 0
			local b3 = s:byte(limit + 3) or 0
			if rem == 3 then
				k1 = b1 + b2 * 256 + b3 * 65536
			elseif rem == 2 then
				k1 = b1 + b2 * 256
			else
				k1 = b1
			end
			k1 = mul32(k1, c1)
			k1 = rol(k1, 15)
			k1 = mul32(k1, c2)
			h = bxor(h, k1)
		end

		h = bxor(h, n)
		h = bxor(h, rshift(h, 16))
		h = mul32(h, 0x85ebca6b)
		h = bxor(h, rshift(h, 13))
		h = mul32(h, 0xc2b2ae35)
		h = bxor(h, rshift(h, 16))

		return normalize32(h)
	end
end

if U.buildKey == nil then
	--- Build a compact nil-safe stable key from varargs.
	--- @param ... any
	--- @return string
	function U.buildKey(...)
		local n = select("#", ...)
		local t = {}
		for i = 1, n do
			local v = select(i, ...)
			if v == nil then
				t[i] = "∅"
			else
				t[i] = tostring(v)
			end
		end
		return table.concat(t, "|")
	end
end

if U.pickIdxHash == nil then
	--- 1..k pick index using stable hash (k<=1 -> 1).
	--- @param key string
	--- @param k number|nil
	--- @return integer
	function U.pickIdxHash(key, k)
		if not k or k <= 1 then
			return 1
		end
		local h = U.hash32(key)
		return (h % k) + 1
	end
end

if U.subscribeEvent == nil then
	--- Subscribe to a PZ/Starlit event source (Add/Remove or addListener/removeListener).
	--- @param eventSource table
	--- @param handler function
	--- @return function|nil unsubscribe
	function U.subscribeEvent(eventSource, handler)
		if type(eventSource) ~= "table" or type(handler) ~= "function" then
			return nil
		end

		if type(eventSource.Add) == "function" and type(eventSource.Remove) == "function" then
			local ok, result = pcall(eventSource.Add, handler)
			if ok then
				local token = result
				return function()
					local removeArg = token ~= nil and token or handler
					pcall(eventSource.Remove, removeArg)
				end
			end
			ok, result = pcall(eventSource.Add, eventSource, handler)
			if ok then
				local token = result
				return function()
					local removeArg = token ~= nil and token or handler
					pcall(eventSource.Remove, eventSource, removeArg)
				end
			end
			return nil
		end

		if type(eventSource.addListener) == "function" and type(eventSource.removeListener) == "function" then
			local ok, result = pcall(eventSource.addListener, eventSource, handler)
			if ok then
				local token = result
				return function()
					local removeArg = token ~= nil and token or handler
					pcall(eventSource.removeListener, eventSource, removeArg)
				end
			end
			ok, result = pcall(eventSource.addListener, handler)
			if ok then
				local token = result
				return function()
					local removeArg = token ~= nil and token or handler
					pcall(eventSource.removeListener, removeArg)
				end
			end
			return nil
		end

		return nil
	end
end

return U
