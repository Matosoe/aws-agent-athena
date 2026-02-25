#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
codigo="34191101213456788005871234570001616670000012345"

if [[ "${1:-}" == "--raw" ]]; then
  echo "$codigo"
  exit 0
fi

"$SCRIPT_DIR/quebrar_codigo.sh" "$codigo"
