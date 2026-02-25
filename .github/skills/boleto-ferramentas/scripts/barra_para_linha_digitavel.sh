#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

barra="$(sanitize_digits "${1:-}")"
if [[ -z "$barra" ]]; then
  echo "Uso: $0 <codigo_de_barras_44>" >&2
  exit 1
fi
validar_tamanho "$barra" 44 "Código de barras"

barra_para_linha_fn "$barra"
