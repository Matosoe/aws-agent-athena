#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

ld="$(sanitize_digits "${1:-}")"
if [[ -z "$ld" ]]; then
  echo "Uso: $0 <linha_digitavel_47>" >&2
  exit 1
fi
validar_tamanho "$ld" 47 "Linha digitável"

formatar_linha_fn "$ld"
