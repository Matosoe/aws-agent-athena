#!/usr/bin/env bash

sanitize_digits() {
  tr -cd '0-9' <<<"${1:-}"
}

modulo10_fn() {
  local num="$1"
  local soma=0
  local peso=2
  local i
  local digit
  local mult

  for ((i=${#num}-1; i>=0; i--)); do
    digit="${num:i:1}"
    mult=$((10#$digit * peso))
    if ((mult > 9)); then
      mult=$((mult - 9))
    fi
    soma=$((soma + mult))
    if ((peso == 2)); then
      peso=1
    else
      peso=2
    fi
  done

  echo $(((10 - (soma % 10)) % 10))
}

barra_para_linha_fn() {
  local barra="$1"
  local campo1="${barra:0:4}${barra:19:5}"
  local dv1
  dv1="$(modulo10_fn "$campo1")"

  local campo2="${barra:24:10}"
  local dv2
  dv2="$(modulo10_fn "$campo2")"

  local campo3="${barra:34:10}"
  local dv3
  dv3="$(modulo10_fn "$campo3")"

  local campo4="${barra:4:1}"
  local campo5="${barra:5:14}"

  echo "${campo1}${dv1}${campo2}${dv2}${campo3}${dv3}${campo4}${campo5}"
}

linha_para_barra_fn() {
  local ld="$1"
  local campo1="${ld:0:9}"
  local campo2="${ld:10:10}"
  local campo3="${ld:21:10}"
  local dv_geral="${ld:32:1}"
  local fator_venc="${ld:33:4}"
  local valor="${ld:37:10}"

  local barra=""
  barra+="${campo1:0:4}"
  barra+="${dv_geral}"
  barra+="${fator_venc}"
  barra+="${valor}"
  barra+="${campo1:4:5}"
  barra+="${campo2}"
  barra+="${campo3}"
  echo "$barra"
}

formatar_linha_fn() {
  local ld="$1"
  echo "${ld:0:5}.${ld:5:5} ${ld:10:5}.${ld:15:5} ${ld:20:5}.${ld:25:6} ${ld:31:1} ${ld:32}"
}

formatar_moeda_br_cents() {
  local cents_raw="$1"
  local cents
  cents=$((10#$cents_raw))
  local reais=$((cents / 100))
  local centavos=$((cents % 100))
  local reais_str="$reais"
  local reais_fmt=""
  local chunk

  while (( ${#reais_str} > 3 )); do
    chunk="${reais_str: -3}"
    if [[ -z "$reais_fmt" ]]; then
      reais_fmt="$chunk"
    else
      reais_fmt="$chunk.$reais_fmt"
    fi
    reais_str="${reais_str:0:${#reais_str}-3}"
  done

  if [[ -z "$reais_fmt" ]]; then
    reais_fmt="$reais_str"
  else
    reais_fmt="$reais_str.$reais_fmt"
  fi

  printf "R$ %s,%02d" "$reais_fmt" "$centavos"
}

fator_para_data_fn() {
  local fator="$1"

  if [[ "${fator:0:1}" == "0" ]]; then
    echo "sem data, esta começando com \"0\""
    return 0
  fi

  local fator_num=$((10#$fator))
  local base
  local offset
  local hoje

  hoje="$(date +%F)"
  if [[ "$hoje" < "2025-02-22" ]]; then
    base="1997-10-07"
    offset="$fator_num"
  else
    base="2025-02-22"
    offset=$((fator_num - 1000))
  fi

  date -d "$base +$offset days" +"%d/%m/%Y"
}

validar_tamanho() {
  local valor="$1"
  local esperado="$2"
  local nome="$3"
  if [[ ${#valor} -ne $esperado ]]; then
    echo "Erro: $nome deve ter $esperado dígitos após sanitização." >&2
    return 1
  fi
}
