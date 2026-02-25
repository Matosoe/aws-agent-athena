---
name: boleto-incidente-resposta
description: Analisa e resolve incidentes de boleto (boleto não aparece, duplicidade, erro de pagamento, divergência de situação) usando consultas em Athena e dados fornecidos no chamado. Use esta skill sempre que o usuário mencionar incidente de boleto, CPF de cliente, status PENDENTE/PAGO/BAIXADO, diagnóstico de causa raiz, ou solicitar análise operacional com evidências de query.
license: Proprietary. Uso interno deste repositório.
compatibility: Requer acesso às consultas SQL/Athena usadas no ambiente do incidente.
---

# Boleto Incident Response

## Objetivo
Gerar um diagnóstico objetivo para incidentes de boleto (cadastro, pagamento, baixa, consulta), com base em CPF, sintoma e data/hora do incidente.

## Regra de acesso ao Athena (obrigatória)
- Para esta skill, o acesso ao Athena deve ser feito explicitamente via **AWS CLI**.
- Não assumir resultados sem executar consulta no Athena quando o contexto exigir evidência operacional.
- Sempre registrar no diagnóstico final quais comandos AWS CLI foram usados.

Pré-requisitos mínimos de execução:
- AWS CLI configurado e autenticado (`aws configure` ou credenciais já provisionadas).
- Permissão para Athena (`athena:StartQueryExecution`, `athena:GetQueryExecution`, `athena:GetQueryResults`) e acesso ao bucket de output de query.
- Definição de `database`, `workgroup` e `result output location` (S3).

## Quando aplicar esta skill
Aplique esta skill quando houver qualquer solicitação de:
- boleto não aparece na lista;
- validação de status (`PENDENTE`, `PAGO`, `BAIXADO`);
- investigação por CPF;
- confirmação de duplicidade ou inconsistência de cadastro;
- explicação de causa raiz e recomendação de ação.

## Dados mínimos esperados
1. CPF do cliente.
2. Sintoma reportado.
3. Data/hora do incidente (quando disponível).

Se algum dado faltar, siga com o que existe e deixe explícito no diagnóstico quais lacunas reduziram a precisão.

## Contexto de dados
Tabela base de referência:

`cadastro_boletos`
- `id` (int): identificador do boleto
- `data_vencimento` (date): vencimento
- `valor` (double): valor do boleto
- `situacao` (string): `PENDENTE`, `PAGO`, `BAIXADO`
- `codigo_barra` (string): código de barras
- `cpf_pagador` (string): CPF do pagador

## Procedimento padrão de investigação
Siga esta ordem, sem pular etapas:

1. **Entender o incidente**
   - Registre: CPF, sintoma, data/hora do incidente.
   - Traduza o sintoma para hipótese operacional (ex.: “não aparece na lista” geralmente implica ausência em `PENDENTE`).

2. **Executar consultas por situação**
   - Execute as consultas no Athena via AWS CLI, usando este fluxo padrão:
```bash
# 1) iniciar execução
aws athena start-query-execution \
  --query-string "<SQL>" \
  --query-execution-context Database=<DATABASE> \
  --work-group <WORKGROUP> \
  --result-configuration OutputLocation=s3://<BUCKET>/<PREFIX>/

# 2) consultar status até SUCCEEDED
aws athena get-query-execution --query-execution-id <QUERY_EXECUTION_ID>

# 3) obter resultados
aws athena get-query-results --query-execution-id <QUERY_EXECUTION_ID>
```
   - Consultar `PENDENTE`:
```sql
SELECT *
FROM cadastro_boletos
WHERE cpf_pagador = '{CPF}'
  AND situacao = 'PENDENTE';
```
   - Consultar `PAGO`:
```sql
SELECT *
FROM cadastro_boletos
WHERE cpf_pagador = '{CPF}'
  AND situacao = 'PAGO';
```
   - Consultar `BAIXADO`:
```sql
SELECT *
FROM cadastro_boletos
WHERE cpf_pagador = '{CPF}'
  AND situacao = 'BAIXADO';
```

3. **Interpretar resultado**
   - Se não houver `PENDENTE`, verificar se existe `PAGO` ou `BAIXADO` (causa provável do “não aparece”).
   - Se houver múltiplos boletos na mesma situação, analisar possível duplicidade por `id`, `data_vencimento`, `valor` e `codigo_barra`.
   - Se não houver registros em nenhuma situação, indicar possível falha de cadastro, chave de busca incorreta ou latência de integração.

4. **Fechar diagnóstico com ação**
   - Definir causa raiz provável.
   - Indicar ações imediatas e preventivas.

## Regra obrigatória de resposta
- Sempre devolver resposta final completa no mesmo fluxo.
- Nunca encerrar com pergunta de confirmação do tipo “Deseja que eu analise?”.
- Mesmo sem registros, sempre reportar:
   - comandos AWS CLI executados para consultar o Athena;
  - consultas executadas;
  - resultados encontrados (inclusive “nenhum registro”);
  - conclusão clara do motivo provável.

## Formato de saída obrigatório
Use sempre este template:

```markdown
## Resumo Executivo
[diagnóstico em 1-3 frases]

## Dados do Incidente
- CPF: ...
- Sintoma: ...
- Data/hora: ...

## Consultas Executadas
0. [comandos AWS CLI utilizados: start-query-execution / get-query-execution / get-query-results]
1. [query 1 + resultado]
2. [query 2 + resultado]
3. [query 3 + resultado]

## Causa Raiz Provável
[explicação objetiva]

## Recomendações
- [ação imediata]
- [ação de validação]
- [ação preventiva]
```

## Exemplo de referência
Incidente: cliente `CPF 67890123456` reporta “boleto não aparece na lista”.

Resultado esperado de diagnóstico:
- `PENDENTE`: nenhum registro.
- `PAGO`: 1 registro (`id=2`, `valor=200.50`, `vencimento=2026-03-15`).
- Conclusão: boleto não aparece na lista de pendentes porque já foi pago.

## Critérios de qualidade
- Ser específico ao CPF e ao sintoma informado.
- Separar fatos observados de hipótese.
- Não omitir query executada.
- Manter resposta acionável para operação/atendimento.
