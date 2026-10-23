#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v verilator >/dev/null 2>&1; then
  echo "ERROR: verilator not found. Install it or add it to PATH." >&2
  exit 127
fi

verilator --version
verilator --binary --timing --Wall -Wno-fatal \
  --Mdir obj_dir_random \
  --top-module mac_random_tb \
  rtl/mac_unit.sv tb/random/mac_random_tb.sv

./obj_dir_random/Vmac_random_tb
