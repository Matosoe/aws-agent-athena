#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
codigo="34196166700000123451101234567880057123457000"

if [[ "${1:-}" == "--raw" ]]; then
  echo "$codigo"
  exit 0
fi

"$SCRIPT_DIR/quebrar_codigo.sh" "$codigo"
