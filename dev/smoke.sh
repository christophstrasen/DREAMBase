#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

PZ_MODS_DIR="${PZ_MODS_DIR:-$HOME/Zomboid/mods}"

required=(
  "$PZ_MODS_DIR/DREAMBase/42/media/lua/shared"
  "$PZ_MODS_DIR/PromiseKeeper/42/media/lua/shared"
  "$PZ_MODS_DIR/SceneBuilder/42/media/lua/shared"
  "$PZ_MODS_DIR/WorldObserver/42/media/lua/shared"
  "$PZ_MODS_DIR/LQR/42/media/lua/shared"
  "$PZ_MODS_DIR/reactivex/42/media/lua/shared"
)

missing=()
for p in "${required[@]}"; do
  if [ ! -d "$p" ]; then
    missing+=("$p")
  fi
done

if [ "${#missing[@]}" -gt 0 ]; then
  echo "[error] missing deployed dependency folders under PZ_MODS_DIR:"
  printf '  - %s\n' "${missing[@]}"
  echo "Run DREAM-Workspace/dev/sync-all.sh with TARGET=mods first (or set PZ_MODS_DIR)."
  exit 2
fi

if ! command -v lua >/dev/null; then
  echo "[error] lua not found in PATH"
  exit 1
fi

PZ_LUA_PATH="$(printf "%s/?.lua;%s/?/init.lua;%s/?.lua;%s/?/init.lua;%s/?.lua;%s/?/init.lua;%s/?.lua;%s/?/init.lua;%s/?.lua;%s/?/init.lua;%s/?.lua;%s/?/init.lua;;" \
  "$PZ_MODS_DIR/DREAMBase/42/media/lua/shared" "$PZ_MODS_DIR/DREAMBase/42/media/lua/shared" \
  "$PZ_MODS_DIR/PromiseKeeper/42/media/lua/shared" "$PZ_MODS_DIR/PromiseKeeper/42/media/lua/shared" \
  "$PZ_MODS_DIR/SceneBuilder/42/media/lua/shared" "$PZ_MODS_DIR/SceneBuilder/42/media/lua/shared" \
  "$PZ_MODS_DIR/WorldObserver/42/media/lua/shared" "$PZ_MODS_DIR/WorldObserver/42/media/lua/shared" \
  "$PZ_MODS_DIR/LQR/42/media/lua/shared" "$PZ_MODS_DIR/LQR/42/media/lua/shared" \
  "$PZ_MODS_DIR/reactivex/42/media/lua/shared" "$PZ_MODS_DIR/reactivex/42/media/lua/shared")" \
  lua "$REPO_ROOT/pz_smoke.lua" DREAMBase PromiseKeeper SceneBuilder WorldObserver LQR reactivex

