#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v verilator >/dev/null 2>&1; then
  echo "ERROR: verilator not found. Install it or add it to PATH." >&2
  exit 127
fi

verilator --version
verilator --lint-only --Wall -Wno-fatal \
  --top-module accelerator_top \
  rtl/mac_unit.sv rtl/accelerator_top.sv

echo "RTL lint command completed. Review warnings above before considering the RTL clean."
