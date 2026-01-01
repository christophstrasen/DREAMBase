# DREAMBase — Development

DREAMBase is part of the DREAM mod family (Build 42):
- DREAM-Workspace (multi-repo convenience): https://github.com/christophstrasen/DREAM-Workspace

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

## Smoke (loader)

`./dev/smoke.sh` expects the full suite to be deployed to `~/Zomboid/mods`. From `DREAM-Workspace`, run:

```bash
TARGET=mods ./dev/sync-all.sh
```

Then from `DREAMBase`:

```bash
./dev/smoke.sh
```

