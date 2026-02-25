# 🚀 Quick Start - 2 Minutos

## Para Publicar no GitHub AGORA

### Opção 1 - Automático (Recomendado) ⚡

```bash
# Instale GitHub CLI (se ainda não tiver)
winget install --id GitHub.cli

# Autentique
gh auth login

# Publique (substitua SEU_USUARIO)
cd C:/Projetos/aws-agent-athena
publish.bat SEU_USUARIO
```

### Opção 2 - Manual 📝

1. Crie repositório no GitHub: https://github.com/new
   - Nome: `aws-agent-athena`
   - Público
   - **NÃO** inicialize com README

2. Execute:
```bash
cd C:/Projetos/aws-agent-athena
git remote add origin https://github.com/SEU_USUARIO/aws-agent-athena.git
git branch -M main
git push -u origin main
```

---

## Para Usar o Agente

1. **Abra VS Code** neste diretório
2. **Abra Copilot Chat**
3. **Cole isto (início rápido):**

```text
leia os arquivos copilot_prompt.md e agent_instructions.md e resolva meu problema abaixo:

Situacao:Cliente com CPF 67890123456 reporta que o boleto nao aparece na lista de pagamento.
```

5. **Aguarde a análise automática!** ✨

---

**Ver mais:** [README.md](README.md) | [COPILOT_PROMPT.md](COPILOT_PROMPT.md)
