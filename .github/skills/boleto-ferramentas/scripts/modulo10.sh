#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

entrada="$(sanitize_digits "${1:-}")"
if [[ -z "$entrada" ]]; then
  echo "Uso: $0 <numero>" >&2
  exit 1
fi

modulo10_fn "$entrada"
