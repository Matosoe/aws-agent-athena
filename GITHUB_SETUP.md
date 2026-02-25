# Instruções para criar tabela e inserir dados de exemplo no Athena

```sql
CREATE EXTERNAL TABLE IF NOT EXISTS db_conceito_athena.cadastro_boletos (
   id STRING,
   data_vencimento DATE,
   valor DECIMAL(10,2),
   situacao STRING,
   codigo_barra STRING,
   cpf_pagador STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe'
WITH SERDEPROPERTIES (
   'serialization.format' = ',',
   'field.delim' = ','
)
LOCATION 's3://seu_bucket/athena/dados/boletos/'
TBLPROPERTIES ('has_encrypted_data'='false');

-- Inserção de 10 linhas de exemplo
INSERT INTO cadastro_boletos VALUES
('1', DATE '2026-03-10', 150.00, 'PENDENTE', '23793381286000000012345678901234567890123456', '12345678901'),
('2', DATE '2026-03-15', 200.50, 'PAGO', '23793381286000000022345678901234567890123456', '23456789012'),
('3', DATE '2026-03-20', 99.99, 'CANCELADO', '23793381286000000032345678901234567890123456', '34567890123'),
('4', DATE '2026-03-25', 350.75, 'PENDENTE', '23793381286000000042345678901234567890123456', '45678901234'),
('5', DATE '2026-03-30', 500.00, 'VENCIDO', '23793381286000000052345678901234567890123456', '56789012345'),
('6', DATE '2026-04-05', 120.00, 'PAGO', '23793381286000000062345678901234567890123456', '67890123456'),
('7', DATE '2026-04-10', 75.25, 'PENDENTE', '23793381286000000072345678901234567890123456', '78901234567'),
('8', DATE '2026-04-15', 180.00, 'CANCELADO', '23793381286000000082345678901234567890123456', '89012345678'),
('9', DATE '2026-04-20', 210.10, 'VENCIDO', '23793381286000000092345678901234567890123456', '90123456789'),
('10', DATE '2026-04-25', 300.00, 'PENDENTE', '23793381286000000102345678901234567890123456', '01234567890');
```
# Instruções para Publicar no GitHub

O repositório local foi criado com sucesso em `C:/Projetos/aws-agent-athena/`.

## ✅ Concluído
- ✅ Diretório do projeto criado
- ✅ 6 arquivos criados:
  - README.md
  - AGENT_INSTRUCTIONS.md
  - INCIDENT_EXAMPLES.md
  - COPILOT_PROMPT.md
  - .gitignore
  - LICENSE (MIT)
- ✅ Git inicializado
- ✅ Commit inicial realizado

## 🚀 Próximos Passos: Publicar no GitHub

### Opção 1: Usando GitHub CLI (Recomendado)

1. **Instale o GitHub CLI:**
   - Windows: `winget install --id GitHub.cli`
   - Ou baixe de: https://cli.github.com/

2. **Autentique:**
   ```bash
   gh auth login
   ```

3. **Crie o repositório e faça push:**
   ```bash
   cd C:/Projetos/aws-agent-athena
   gh repo create aws-agent-athena --public --source=. --remote=origin --push
   ```

### Opção 2: Manual via Web + Git

1. **Crie o repositório no GitHub:**
   - Acesse: https://github.com/new
   - Nome: `aws-agent-athena`
   - Descrição: "Análise automatizada de incidentes AWS usando GitHub Copilot Agent + Athena"
   - Público ou Privado: sua escolha
   - **NÃO** marque "Initialize with README"
   - Clique em "Create repository"

2. **Faça push do repositório local:**
   ```bash
   cd C:/Projetos/aws-agent-athena
   git remote add origin https://github.com/SEU_USUARIO/aws-agent-athena.git
   git branch -M main
   git push -u origin main
   ```

   **Substitua `SEU_USUARIO` pelo seu username do GitHub**

### Opção 3: Usando Git + Token de Acesso Pessoal

Se não quiser instalar GitHub CLI:

1. Crie um Personal Access Token:
   - Acesse: https://github.com/settings/tokens
   - "Generate new token (classic)"
   - Marque: `repo` (full control)
   - Copie o token gerado

2. Crie o repositório via API:
   ```bash
   curl -u SEU_USUARIO:SEU_TOKEN https://api.github.com/user/repos -d '{"name":"aws-agent-athena","description":"Análise automatizada de incidentes AWS usando GitHub Copilot Agent + Athena","private":false}'
   ```

3. Faça push:
   ```bash
   cd C:/Projetos/aws-agent-athena
   git remote add origin https://github.com/SEU_USUARIO/aws-agent-athena.git
   git branch -M main
   git push -u origin main
   ```

## 📝 Após Publicar

1. **Atualize o README.md:**
   - Substitua `SEU_USUARIO` pela sua conta real do GitHub no final do README.md

2. **Adicione topics no GitHub:**
   - Acesse Settings > Manage topics
   - Adicione: `aws`, `athena`, `incident-analysis`, `copilot`, `agent`, `sre`

3. **Configure GitHub Pages (opcional):**
   - Settings > Pages
   - Source: Deploy from branch `main` / root

## ✅ Verificar Publicação

Acesse: `https://github.com/SEU_USUARIO/aws-agent-athena`

Você deve ver:
- ✅ README.md renderizado
- ✅ 6 arquivos
- ✅ Licença MIT
- ✅ .gitignore

---

**Repositório Local:** `C:/Projetos/aws-agent-athena/`

**Próximo comando:** Escolha uma das opções acima e execute.
