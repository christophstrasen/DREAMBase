# DREAMBase — Development

DREAMBase is part of the DREAM mod family (Build 42):
- DREAM (multi-repo convenience): https://github.com/christophstrasen/DREAM

Prereqs (for the `dev/` scripts): `rsync`, `inotifywait` (`inotify-tools`), `inkscape`.

## Sync

Deploy to your local Workshop wrapper folder (default):

```bash
./dev/sync-workshop.sh
```

Optional: deploy to `~/Zomboid/mods` instead:

```bash
./dev/sync-mods.sh
```

## Watch

Watch + deploy (default: Workshop wrapper under `~/Zomboid/Workshop`):

```bash
./dev/watch.sh
```

Optional: deploy to `~/Zomboid/mods` instead:

```bash
TARGET=mods ./dev/watch.sh
```

## Tests

Headless unit tests:

```bash
busted --helper=tests/helper.lua tests/unit
```

## Lint

```bash
luacheck Contents/mods/DREAMBase/42/media/lua/shared/DREAMBase Contents/mods/DREAMBase/42/media/lua/shared/DREAMBase.lua
```

## Pre-commit hooks

This repo ships a `.pre-commit-config.yaml` mirroring CI (`luacheck` + `busted`).

Enable hooks:

```bash
pre-commit install
```

Run on demand:

```bash
pre-commit run --all-files
```

## Smoke (loader)

`./dev/smoke.sh` expects the full suite to be deployed to `~/Zomboid/mods`. From `DREAM`, run:

```bash
TARGET=mods ./dev/sync-all.sh
```

Then from `DREAMBase`:

```bash
./dev/smoke.sh
```
