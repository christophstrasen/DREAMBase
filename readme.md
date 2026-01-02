## DREAMBase

*A small “base library” mod for the [DREAM](https://github.com/christophstrasen/DREAM) family of mods (Build 42).*

[![CI](https://github.com/christophstrasen/DREAMBase/actions/workflows/ci.yml/badge.svg)](https://github.com/christophstrasen/DREAMBase/actions/workflows/ci.yml)

---

[Steam Workshop → [42SP] DREAMBase](https://steamcommunity.com/sharedfiles/filedetails/?id=3637543051)

---

## Scope

It aims to provide shared utilities that work both:
- in **Project Zomboid B42** (Lua 5.1 / Kahlua), and
- in **headless vanilla Lua 5.1** (busted/tests, CLI scripts).

### Module overview

- `require("DREAMBase/log")`
  - Tagged, leveled logger.
  - Delegates to `require("LQR/util/log")` when available; otherwise uses a compatible fallback logger.

- `require("DREAMBase/util")`
  - Small pure helpers (assert/log helpers, deterministic key/hash helpers, simple cache, selection helpers).
  - Includes `subscribeEvent(...)` for adapting PZ `Events.*` and Starlit `LuaEvent` sources.

- `require("DREAMBase/time_ms")`
  - Best-effort `gameMillis()` and `cpuMillis()` clock helpers (ms).

- `require("DREAMBase/events")`
  - Event interop helpers (currently a thin wrapper around `DREAMBase/util.subscribeEvent`).

- `require("DREAMBase/pz/java_list")`
  - Defensive helpers for Java-backed lists/arrays in Kahlua (`size`, `get`).

- `require("DREAMBase/pz/safe_call")`
  - Safe engine method invocation helper (`safeCall(obj, methodName, ...)`).

- `require("DREAMBase/bootstrap")`
  - Headless-only loader convenience (best-effort `package.path` extension); should be a no-op in PZ.

### In-game usage

Add `\\DREAMBase` to your `mod.info` `require=` list, then:

```lua
local U = require("DREAMBase/util")
local Log = require("DREAMBase/log").withTag("MY.MOD")
```

### Headless usage

In tests/scripts, make sure `package.path` can find DREAMBase, then optionally:

```lua
require("DREAMBase/bootstrap")
```

### Development

See `development.md`.
