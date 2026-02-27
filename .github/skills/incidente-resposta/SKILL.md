---
name: incidente-resposta
description: Analisa e resolve incidentes operacionais de pagamento com foco em boleto no Athena usando o modelo relacional `db_conceito_relacional` (customers, orders, payments e view consolidada), com evidências de consulta via AWS CLI e diagnóstico de causa raiz.
license: Proprietary. Uso interno deste repositório.
compatibility: Requer acesso às consultas SQL/Athena usadas no ambiente do incidente.
---

# Incident Response

## Objetivo
Gerar diagnóstico objetivo para incidentes de boleto (não aparece, divergência de status, duplicidade, erro de pagamento) com base em CPF, sintoma e data/hora do incidente.

## Regra de acesso ao Athena (obrigatória)
- Para esta skill, o acesso ao Athena deve ser feito explicitamente via **AWS CLI**.
- Não assumir resultado sem executar consulta quando o contexto exigir evidência operacional.
- Sempre registrar no diagnóstico final quais comandos AWS CLI foram usados.

Pré-requisitos mínimos de execução:
- AWS CLI configurado e autenticado (`aws configure` ou credenciais já provisionadas).
- Permissão para Athena (`athena:StartQueryExecution`, `athena:GetQueryExecution`, `athena:GetQueryResults`) e acesso ao bucket de output.
- Definição de `database`, `workgroup` e `result output location` (S3).

## Quando aplicar esta skill
Aplique esta skill quando houver solicitação de:
- boleto não aparece na lista;
- validação de status de pagamento (`PENDING`, `PAID`, `FAILED`, `REFUNDED`, `CHARGEBACK`);
- investigação por CPF;
- confirmação de duplicidade de pagamento/transação;
- explicação de causa raiz e recomendação operacional.

## Dados mínimos esperados
1. CPF do cliente.
2. Sintoma reportado.
3. Data/hora do incidente (quando disponível).

Se algum dado faltar, siga com o que existe e deixe explícito no diagnóstico quais lacunas reduziram a precisão.

## Contexto de dados (`db_conceito_relacional`)
Tabelas e campos de referência para incidente:

`customers`
- `customer_id` (int)
- `cpf` (string)
- `full_name` (string)

`orders`
- `order_id` (int)
- `customer_id` (int)
- `status` (string): status do pedido
- `order_date` (string)
- `total_amount` (decimal)

`payments`
- `payment_id` (int)
- `order_id` (int)
- `customer_id` (int)
- `payment_method` (string): método de pagamento (inclui boleto)
- `payment_status` (string): status do pagamento
- `payment_date` (string)
- `amount` (decimal)
- `transaction_ref` (string)
- `boleto_barcode` (string)

View de apoio:

`vw_orders_customer_payment`
- join consolidado de `orders` + `customers` + `payments`
- simplifica investigação por CPF e status em uma única consulta.

## Procedimento padrão de investigação
Siga esta ordem, sem pular etapas:

1. **Entender o incidente**
   - Registrar: CPF, sintoma, data/hora do incidente.
   - Traduzir o sintoma para hipótese operacional (ex.: “não aparece” pode indicar ausência em status de aberto ou pagamento já finalizado).

2. **Executar consultas de evidência no Athena**
   - Usar sempre o fluxo padrão AWS CLI:
```bash
# 1) iniciar execução
aws athena start-query-execution \
  --query-string "<SQL>" \
  --query-execution-context Database=db_conceito_relacional \
  --work-group <WORKGROUP> \
  --result-configuration OutputLocation=s3://<BUCKET>/<PREFIX>/

# 2) consultar status até SUCCEEDED
aws athena get-query-execution --query-execution-id <QUERY_EXECUTION_ID>

# 3) obter resultados
aws athena get-query-results --query-execution-id <QUERY_EXECUTION_ID>
```

   - **Consulta 1: baseline do cliente e pedidos com pagamento**
```sql
SELECT
  customer_id,
  full_name,
  cpf,
  order_id,
  order_date,
  order_status,
  total_amount,
  payment_id,
  payment_method,
  boleto_barcode,
  payment_status,
  payment_amount
FROM db_conceito_relacional.vw_orders_customer_payment
WHERE cpf = '{CPF}'
ORDER BY order_date DESC;
```

   - **Consulta 2: pagamentos por método boleto e status**
```sql
SELECT
  p.payment_id,
  p.order_id,
  p.customer_id,
  p.payment_method,
  p.payment_status,
  p.payment_date,
  p.amount,
  p.transaction_ref,
  p.boleto_barcode
FROM db_conceito_relacional.payments p
JOIN db_conceito_relacional.customers c
  ON p.customer_id = c.customer_id
WHERE c.cpf = '{CPF}'
  AND lower(p.payment_method) LIKE '%boleto%'
ORDER BY p.payment_date DESC;
```

   - **Consulta 3: checagem de duplicidade por referência/transação**
```sql
SELECT
  p.transaction_ref,
  p.boleto_barcode,
  COUNT(*) AS qtd,
  MIN(p.payment_date) AS primeiro_pagamento,
  MAX(p.payment_date) AS ultimo_pagamento,
  SUM(p.amount) AS valor_total
FROM db_conceito_relacional.payments p
JOIN db_conceito_relacional.customers c
  ON p.customer_id = c.customer_id
WHERE c.cpf = '{CPF}'
  AND lower(p.payment_method) LIKE '%boleto%'
GROUP BY p.transaction_ref, p.boleto_barcode
HAVING COUNT(*) > 1
ORDER BY qtd DESC, ultimo_pagamento DESC;
```

3. **Interpretar resultado**
   - Se não houver registro de boleto para o CPF, considerar falha de cadastro, filtro incorreto (CPF divergente) ou atraso de integração.
   - Se houver `payment_status` finalizado (ex.: `PAID`) e ausência em listas de aberto, classificar como comportamento esperado.
   - Se houver múltiplas linhas para mesma `transaction_ref`/`boleto_barcode`, indicar suspeita de duplicidade.
   - Cruzar `orders.status` com `payments.payment_status` para detectar inconsistência de estado.

4. **Fechar diagnóstico com ação**
   - Definir causa raiz provável baseada em evidência.
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
- Consulta na `vw_orders_customer_payment` mostra pagamento em boleto com `payment_status = 'PAID'`.
- Não há pagamento em status aberto para o mesmo pedido.
- Conclusão: item não aparece na lista de pendentes porque o pagamento já foi finalizado.

## Critérios de qualidade
- Ser específico ao CPF e ao sintoma informado.
- Separar fato observado de hipótese.
- Não omitir query executada.
- Manter resposta acionável para operação/atendimento.
