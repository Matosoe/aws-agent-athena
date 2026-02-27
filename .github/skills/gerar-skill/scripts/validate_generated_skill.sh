#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${1:-}"

if [[ -z "${TARGET_DIR}" ]]; then
  echo "Uso: $0 .github/skills/<nome-da-skill>"
  exit 2
fi

if [[ ! -d "${TARGET_DIR}" ]]; then
  echo "ERRO: diretório não encontrado: ${TARGET_DIR}"
  exit 1
fi

SKILL_FILE="${TARGET_DIR}/SKILL.md"
if [[ ! -f "${SKILL_FILE}" ]]; then
  echo "ERRO: arquivo obrigatório ausente: ${SKILL_FILE}"
  exit 1
fi

if ! grep -q '^---$' "${SKILL_FILE}"; then
  echo "ERRO: frontmatter YAML não encontrado em ${SKILL_FILE}"
  exit 1
fi

if ! grep -q '^name:' "${SKILL_FILE}"; then
  echo "ERRO: campo 'name' ausente no frontmatter"
  exit 1
fi

if ! grep -q '^description:' "${SKILL_FILE}"; then
  echo "ERRO: campo 'description' ausente no frontmatter"
  exit 1
fi

echo "OK: estrutura mínima válida para skill em ${TARGET_DIR}"
