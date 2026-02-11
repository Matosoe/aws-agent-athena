@echo off
REM Script para publicar o repositório aws-agent-athena no GitHub
REM Uso: publish.bat SEU_USUARIO_GITHUB

echo =========================================
echo   Publicando aws-agent-athena no GitHub
echo =========================================
echo.

if "%1"=="" (
    echo ERRO: Forneça seu username do GitHub!
    echo Uso: publish.bat SEU_USUARIO
    echo Exemplo: publish.bat eduardosilva
    pause
    exit /b 1
)

set GITHUB_USER=%1
set REPO_NAME=aws-agent-athena

echo Usuario GitHub: %GITHUB_USER%
echo Repositorio: %REPO_NAME%
echo.

echo [1/3] Verificando se gh CLI esta instalado...
gh --version >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo ! GitHub CLI nao encontrado
    echo.
    echo Por favor, instale o GitHub CLI:
    echo   Windows: winget install --id GitHub.cli
    echo   Ou acesse: https://cli.github.com/
    echo.
    echo Apos instalar, execute:
    echo   gh auth login
    echo   publish.bat %GITHUB_USER%
    echo.
    pause
    exit /b 1
)

echo OK - GitHub CLI instalado
echo.

echo [2/3] Verificando autenticacao...
gh auth status >nul 2>&1
if %errorlevel% neq 0 (
    echo ! Voce nao esta autenticado
    echo.
    echo Execute:
    echo   gh auth login
    echo.
    echo E depois execute novamente este script.
    pause
    exit /b 1
)

echo OK - Autenticado
echo.

echo [3/3] Criando repositorio e fazendo push...
gh repo create %REPO_NAME% --public --source=. --remote=origin --push

if %errorlevel% eq 0 (
    echo.
    echo ============================================
    echo   SUCESSO!
    echo ============================================
    echo.
    echo Repositorio criado e publicado:
    echo   https://github.com/%GITHUB_USER%/%REPO_NAME%
    echo.
    echo Proximos passos:
    echo   1. Acesse o repositorio
    echo   2. Adicione topics: aws, athena, incident-analysis, copilot, agent, sre
    echo   3. Atualize o README.md substituindo SEU_USUARIO por %GITHUB_USER%
    echo.
) else (
    echo.
    echo ! ERRO ao criar repositorio
    echo.
    echo Pode ser que o repositorio ja exista.
    echo Tente manualmente:
    echo.
    echo   git remote add origin https://github.com/%GITHUB_USER%/%REPO_NAME%.git
    echo   git branch -M main
    echo   git push -u origin main
    echo.
)

pause
