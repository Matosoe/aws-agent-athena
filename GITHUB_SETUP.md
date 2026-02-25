# Setup GitHub + Athena

Este arquivo é a referência única para:
- criar a tabela de exemplo no Athena;
- publicar o repositório no GitHub.

Use este guia para preparar o ambiente. Para uso diário do agente, siga o [QUICKSTART.md](QUICKSTART.md).

## Estrutura atual do repositório

- README.md
- QUICKSTART.md
- GITHUB_SETUP.md
- .github/skills/boleto-incidente-resposta/SKILL.md

## 1) Preparar Athena (tabela de exemplo)

A skill do projeto consulta a tabela `cadastro_boletos` e considera os status:
- `PENDENTE`
- `PAGO`
- `BAIXADO`

### 1.1 Criar tabela

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
```

### 1.2 Inserir dados de exemplo

```sql
INSERT INTO db_conceito_athena.cadastro_boletos VALUES
('1', DATE '2026-03-10', 150.00, 'PENDENTE', '23793381286000000012345678901234567890123456', '12345678901'),
('2', DATE '2026-03-15', 200.50, 'PAGO',     '23793381286000000022345678901234567890123456', '23456789012'),
('3', DATE '2026-03-20', 99.99,  'BAIXADO',  '23793381286000000032345678901234567890123456', '34567890123'),
('4', DATE '2026-03-25', 350.75, 'PENDENTE', '23793381286000000042345678901234567890123456', '45678901234'),
('5', DATE '2026-03-30', 500.00, 'PAGO',     '23793381286000000052345678901234567890123456', '56789012345'),
('6', DATE '2026-04-05', 120.00, 'PAGO',     '23793381286000000062345678901234567890123456', '67890123456'),
('7', DATE '2026-04-10', 75.25,  'PENDENTE', '23793381286000000072345678901234567890123456', '78901234567'),
('8', DATE '2026-04-15', 180.00, 'BAIXADO',  '23793381286000000082345678901234567890123456', '89012345678'),
('9', DATE '2026-04-20', 210.10, 'PENDENTE', '23793381286000000092345678901234567890123456', '90123456789'),
('10', DATE '2026-04-25', 300.00, 'BAIXADO', '23793381286000000102345678901234567890123456', '01234567890');
```

## 2) Pré-requisitos AWS CLI (Athena)

A skill usa Athena via AWS CLI. Garanta:
- AWS CLI instalado;
- credenciais configuradas (`aws configure` ou role/profile);
- permissões para Athena e bucket de resultado.

Comandos úteis:

```bash
aws configure
aws sts get-caller-identity
```

## 3) Publicar no GitHub

### Opção 1 (recomendada): GitHub CLI

```bash
winget install --id GitHub.cli
gh auth login
cd C:/Projetos/aws-agent-athena
gh repo create aws-agent-athena --public --source=. --remote=origin --push
```

### Opção 2: manual via web + Git

1. Crie o repositório em https://github.com/new
   - Nome: `aws-agent-athena`
   - Não inicialize com README.

2. Faça push:

```bash
cd C:/Projetos/aws-agent-athena
git remote add origin https://github.com/SEU_USUARIO/aws-agent-athena.git
git branch -M main
git push -u origin main
```

## 4) Pós-publicação

- Atualize a URL final no [README.md](README.md) com seu usuário real.
- Adicione topics no GitHub se desejar (`aws`, `athena`, `copilot`, `incident-analysis`).

## 5) Verificação rápida

- Repositório online acessível em `https://github.com/SEU_USUARIO/aws-agent-athena`.
- Skill presente em [.github/skills/boleto-incidente-resposta/SKILL.md](.github/skills/boleto-incidente-resposta/SKILL.md).
- Tabela `db_conceito_athena.cadastro_boletos` criada e consultável.
