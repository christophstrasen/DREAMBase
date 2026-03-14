#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

PZ_MODS_DIR="${PZ_MODS_DIR:-$HOME/Zomboid/mods}"
PZ_WORKSHOP_DIR="${PZ_WORKSHOP_DIR:-$HOME/Zomboid/Workshop}"
SOURCE="${SOURCE:-workshop}" # workshop|mods

case "$SOURCE" in
  workshop)
    base_dir="$PZ_WORKSHOP_DIR"
    path_fmt='%s/%s/Contents/mods/%s/42/media/lua/shared'
    ;;
  mods)
    # Backward-compatible for direct script invocations, not used by workspace wrappers.
    base_dir="$PZ_MODS_DIR"
    path_fmt='%s/%s/42/media/lua/shared'
    ;;
  *)
    echo "[error] unknown SOURCE='$SOURCE' (expected 'workshop' or 'mods')"
    exit 1
    ;;
esac

required=(
  "$(printf "$path_fmt" "$base_dir" "DREAMBase" "DREAMBase")"
  "$(printf "$path_fmt" "$base_dir" "PromiseKeeper" "PromiseKeeper")"
  "$(printf "$path_fmt" "$base_dir" "SceneBuilder" "SceneBuilder")"
  "$(printf "$path_fmt" "$base_dir" "WorldObserver" "WorldObserver")"
  "$(printf "$path_fmt" "$base_dir" "LQR" "LQR")"
  "$(printf "$path_fmt" "$base_dir" "reactivex" "reactivex")"
)

missing=()
for p in "${required[@]}"; do
  if [ ! -d "$p" ]; then
    missing+=("$p")
  fi
done

if [ "${#missing[@]}" -gt 0 ]; then
  echo "[error] missing deployed dependency folders for SOURCE=$SOURCE:"
  printf '  - %s\n' "${missing[@]}"
  echo "Run DREAM/dev/sync-all.sh first (or set PZ_WORKSHOP_DIR/PZ_MODS_DIR)."
  exit 2
fi

if ! command -v lua >/dev/null; then
  echo "[error] lua not found in PATH"
  exit 1
fi

PZ_LUA_PATH="$(printf "%s/?.lua;%s/?/init.lua;%s/?.lua;%s/?/init.lua;%s/?.lua;%s/?/init.lua;%s/?.lua;%s/?/init.lua;%s/?.lua;%s/?/init.lua;%s/?.lua;%s/?/init.lua;;" \
  "${required[0]}" "${required[0]}" \
  "${required[1]}" "${required[1]}" \
  "${required[2]}" "${required[2]}" \
  "${required[3]}" "${required[3]}" \
  "${required[4]}" "${required[4]}" \
  "${required[5]}" "${required[5]}")" \
  lua "$REPO_ROOT/pz_smoke.lua" DREAMBase PromiseKeeper SceneBuilder WorldObserver LQR reactivex
