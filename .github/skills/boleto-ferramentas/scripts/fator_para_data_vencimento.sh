#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

fator="$(sanitize_digits "${1:-}")"
if [[ -z "$fator" ]]; then
  echo "Uso: $0 <fator_4_digitos>" >&2
  exit 1
fi
validar_tamanho "$fator" 4 "Fator de vencimento"

fator_para_data_fn "$fator"
