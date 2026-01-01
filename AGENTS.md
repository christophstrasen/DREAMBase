# DREAMBase — Agent Guide

Quick rules for working with this repo.

## Priority and scope

- **Priority:** system > developer > `AGENTS.md` > `.aicontext/*` > task instructions > file-local comments.
- **Scope:** this file applies to the DREAMBase repo only.

## Expectations

- Keep changes minimal and behavior-preserving unless explicitly requested.
- Target runtime is Project Zomboid Build 42 (Lua 5.1 / Kahlua); keep code compatible with vanilla Lua 5.1 where feasible.

## Verification

After Lua code changes, run:
- `luacheck Contents/mods/DREAMBase/42/media/lua/shared/DREAMBase Contents/mods/DREAMBase/42/media/lua/shared/DREAMBase.lua`
- `busted --helper=tests/helper.lua tests/unit`

Prefer using `pre-commit run --all-files` where available (mirrors CI).

