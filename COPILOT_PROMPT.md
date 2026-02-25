# Prompt de Incidente - Boleto nao aparece na lista

## Inicio rapido (copie e cole no Copilot Chat)

```text
leia os arquivos copilot_prompt.md e agent_instructions.md e resolva meu problema abaixo:

Situacao:Cliente com CPF 67890123456 reporta que o boleto nao aparece na lista de pagamento.
```

## Regra obrigatoria de resposta
- Sempre devolver resposta final completa com base nos dados informados.
- Nao finalizar com pergunta de confirmacao (ex: "Deseja que eu analise?").
- Informar consultas executadas, resultados (inclusive quando nao houver registros) e conclusao objetiva no mesmo fluxo.

## Situacao
Cliente com CPF 67890123456 reporta que o boleto nao aparece na lista de pagamento.

## Dados do incidente
- Abertura: 2026-02-24 07:00:00 UTC
- Sintomas: boleto nao aparece na lista

## Consultas e resultados

### Boleto pendente
```sql
SELECT *
FROM db_conceito_athena.cadastro_boletos
WHERE cpf_pagador = '67890123456'
  AND situacao = 'PENDENTE';
```
Resultado: nenhum boleto pendente encontrado.

### Boleto pago
```sql
SELECT *
FROM db_conceito_athena.cadastro_boletos
WHERE cpf_pagador = '67890123456'
  AND situacao = 'PAGO';
```
Resultado:
| id | data_vencimento | valor  | situacao | codigo_barra                                 | cpf_pagador |
|----|-----------------|--------|----------|----------------------------------------------|-------------|
| 2  | 2026-03-15      | 200.50 | PAGO     | 23793381286000000022345678901234567890123456 | 67890123456 |

## Conclusao
Nao ha boleto pendente para este cliente. O boleto ja foi pago, por isso nao aparece na lista de pendentes.
