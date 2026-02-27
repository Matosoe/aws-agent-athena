# Setup de Ambiente (GitHub + Athena)

Este arquivo reúne a configuração de acesso ao Athena e a publicação do repositório no GitHub.

Use este guia para preparar o ambiente. Para uso diário do agente, siga o [QUICKSTART.md](QUICKSTART.md).

## Escopo

- Configurar AWS CLI para consultas no Athena.
- Validar acesso ao banco `db_conceito_relacional`.
- Publicar o repositório no GitHub.

## 1) Pré-requisitos do AWS CLI

Garanta:
- AWS CLI instalado;
- credenciais configuradas (`aws configure` ou role/profile);
- permissões para Athena, Glue Data Catalog e bucket de resultados.

Comandos úteis:

```bash
aws configure
aws sts get-caller-identity
```

## 2) Validar acesso ao contexto relacional

No Athena, confirme acesso ao banco `db_conceito_relacional` e aos objetos esperados (ex.: `customers`, `orders`, `order_items`, `products`, `payments`, `vw_orders_customer_payment`).

Exemplo de validação:

```sql
SELECT *
FROM db_conceito_relacional.vw_orders_customer_payment
LIMIT 20;
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

- Atualize links e descrições no [README.md](README.md), se necessário.
- Adicione topics no GitHub se desejar (`aws`, `athena`, `copilot`, `analytics`).

## 5) Verificação rápida

- Repositório online acessível em `https://github.com/SEU_USUARIO/aws-agent-athena`.
- Acesso ao Athena funcionando com consultas no `db_conceito_relacional`.
