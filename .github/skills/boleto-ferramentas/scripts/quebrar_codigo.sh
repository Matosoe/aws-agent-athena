#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

print_field() {
  local nome="$1"
  local valor="$2"
  local desc="$3"
  echo "- $nome: $valor"
  echo "  $desc"
}

entrada="${*:-}"
cod="$(sanitize_digits "$entrada")"

if [[ -z "$cod" ]]; then
  echo "Uso: $0 <texto com código de barras (44) ou linha digitável (47)>" >&2
  exit 1
fi

if [[ ${#cod} -eq 44 ]]; then
  ld="$(barra_para_linha_fn "$cod")"

  echo "Formato: Código de Barras (44 dígitos)"
  echo "Código de Barras: $cod"
  echo "Linha Digitável: $(formatar_linha_fn "$ld")"
  echo "Linha Digitável apenas números: $ld"
  echo

  print_field "Número código da ID destinatária no SILOC" "${cod:0:3}" "Identifica o banco/instituição."
  print_field "Código de Moeda" "${cod:3:1}" "9 = Real."
  print_field "Dígito Verificador (DV)" "${cod:4:1}" "Dígito de verificação do código de barras."

  fator="${cod:5:4}"
  print_field "Fator de vencimento" "$fator" "Data de vencimento calculada: $(fator_para_data_fn "$fator")"

  if [[ "${cod:5:1}" == "0" ]]; then
    ini_valor=6
  else
    ini_valor=9
  fi
  valor_cents="${cod:ini_valor:19-ini_valor}"
  print_field "Valor" "$valor_cents" "Valor nominal: $(formatar_moeda_br_cents "$valor_cents")"

  campo_livre="${cod:19:25}"
  print_field "Campo livre" "$campo_livre" "Informações específicas do banco/beneficiário."

  inicia_341=false
  if [[ "${cod:0:3}" == "341" ]]; then
    inicia_341=true
  fi
  carteira="${cod:19:3}"

  if [[ "$inicia_341" == true && "$carteira" != "198" ]]; then
    echo
    print_field "Carteira" "${cod:19:3}" "Código da carteira de cobrança."
    print_field "Nosso Número" "${cod:22:8}" "Número sequencial do documento."
    print_field "DAC NNUM" "${cod:30:1}" "Dígito verificador do Nosso Número."
    print_field "Agência" "${cod:31:4}" "Código da agência bancária."
    print_field "Conta" "${cod:35:5}" "Número da conta corrente."
    print_field "DAC Conta" "${cod:40:1}" "Dígito verificador da conta."
  elif [[ "$inicia_341" == true && "$carteira" == "198" ]]; then
    echo
    print_field "Carteira" "${cod:19:3}" "Código da carteira de cobrança."
  fi

elif [[ ${#cod} -eq 47 ]]; then
  barra="$(linha_para_barra_fn "$cod")"

  echo "Formato: Linha Digitável (47 dígitos)"
  echo "Código de Barras: $barra"
  echo "Linha Digitável: $(formatar_linha_fn "$cod")"
  echo "Linha Digitável apenas números: $cod"
  echo

  print_field "Campo 1" "${cod:0:9}" "Banco, moeda, parte do campo livre e DV do campo 1."
  print_field "Dígito verificador do Campo 1" "${cod:9:1}" "DV do campo 1."
  print_field "Campo 2" "${cod:10:10}" "Parte do campo livre."
  print_field "Dígito verificador do Campo 2" "${cod:20:1}" "DV do campo 2."
  print_field "Campo 3" "${cod:21:10}" "Parte do campo livre."
  print_field "Dígito verificador do Campo 3" "${cod:31:1}" "DV do campo 3."
  print_field "Dígito verificador geral (DV)" "${cod:32:1}" "DV geral do código de barras."

  fator="${cod:33:4}"
  print_field "Fator de vencimento" "$fator" "Data de vencimento calculada: $(fator_para_data_fn "$fator")"

  if [[ "${cod:33:1}" == "0" ]]; then
    ini_valor=33
  else
    ini_valor=37
  fi
  valor_cents="${cod:ini_valor:47-ini_valor}"
  print_field "Valor" "$valor_cents" "Valor nominal: $(formatar_moeda_br_cents "$valor_cents")"

  print_field "Campo livre" "${barra:19:25}" "Informações específicas do banco/beneficiário (do código de barras)."

  inicia_341=false
  if [[ "${barra:0:3}" == "341" ]]; then
    inicia_341=true
  fi
  carteira="${barra:19:3}"

  if [[ "$inicia_341" == true && "$carteira" != "198" ]]; then
    echo
    print_field "Carteira" "${barra:19:3}" "Código da carteira de cobrança."
    print_field "Nosso Número" "${barra:22:8}" "Número sequencial do documento."
    print_field "DAC NNUM" "${barra:30:1}" "Dígito verificador do Nosso Número."
    print_field "Agência" "${barra:31:4}" "Código da agência bancária."
    print_field "Conta" "${barra:35:5}" "Número da conta corrente."
    print_field "DAC Conta" "${barra:40:1}" "Dígito verificador da conta."
  elif [[ "$inicia_341" == true && "$carteira" == "198" ]]; then
    echo
    print_field "Carteira" "${barra:19:3}" "Código da carteira de cobrança."
  fi
else
  echo "O texto informado não contém 44 dígitos (código de barras) nem 47 dígitos (linha digitável) após a filtragem." >&2
  exit 1
fi
