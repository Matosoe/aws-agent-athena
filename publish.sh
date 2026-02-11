#!/bin/bash
# Script para publicar o repositório aws-agent-athena no GitHub
# Uso: ./publish.sh SEU_USUARIO_GITHUB

set -e

echo "========================================="
echo "  Publicando aws-agent-athena no GitHub"
echo "========================================="
echo ""

if [ -z "$1" ]; then
    echo "ERRO: Forneça seu username do GitHub!"
    echo "Uso: ./publish.sh SEU_USUARIO"
    echo "Exemplo: ./publish.sh eduardosilva"
    exit 1
fi

GITHUB_USER=$1
REPO_NAME="aws-agent-athena"

echo "Usuario GitHub: $GITHUB_USER"
echo "Repositorio: $REPO_NAME"
echo ""

echo "[1/3] Verificando se gh CLI esta instalado..."
if ! command -v gh &> /dev/null; then
    echo ""
    echo "! GitHub CLI nao encontrado"
    echo ""
    echo "Por favor, instale o GitHub CLI:"
    echo "  Mac: brew install gh"
    echo "  Linux: sudo apt install gh  (ou veja https://cli.github.com/)"
    echo ""
    echo "Apos instalar, execute:"
    echo "  gh auth login"
    echo "  ./publish.sh $GITHUB_USER"
    echo ""
    exit 1
fi

echo "OK - GitHub CLI instalado"
echo ""

echo "[2/3] Verificando autenticacao..."
if ! gh auth status &> /dev/null; then
    echo "! Voce nao esta autenticado"
    echo ""
    echo "Execute:"
    echo "  gh auth login"
    echo ""
    echo "E depois execute novamente este script."
    exit 1
fi

echo "OK - Autenticado"
echo ""

echo "[3/3] Criando repositorio e fazendo push..."
gh repo create "$REPO_NAME" --public --source=. --remote=origin --push

echo ""
echo "============================================"
echo "  SUCESSO!"
echo "============================================"
echo ""
echo "Repositorio criado e publicado:"
echo "  https://github.com/$GITHUB_USER/$REPO_NAME"
echo ""
echo "Proximos passos:"
echo "  1. Acesse o repositorio"
echo "  2. Adicione topics: aws, athena, incident-analysis, copilot, agent, sre"
echo "  3. Atualize o README.md substituindo SEU_USUARIO por $GITHUB_USER"
echo ""
