
# Exemplos de Incidentes de Boleto

Este documento traz exemplos práticos de incidentes de boleto e como investigá-los usando Athena, conforme o [AGENT_INSTRUCTIONS.md](AGENT_INSTRUCTIONS.md).

---

## Exemplo: Boleto não aparece na lista

### Dados do Incidente
- Cliente CPF: 67890123456
- Data: 2026-02-24 07:00:00 UTC
- Sintoma: boleto não aparece na lista de pagamento

### Consultas Realizadas
- Buscar boletos pendentes:
  ```sql
  SELECT * FROM cadastro_boletos WHERE cpf_pagador = '67890123456' AND situacao = 'PENDENTE';
  ```
  Resultado: nenhum boleto pendente encontrado.

- Buscar boletos pagos:
  ```sql
  SELECT * FROM cadastro_boletos WHERE cpf_pagador = '67890123456' AND situacao = 'PAGO';
  ```
  Resultado:
  | id | data_vencimento | valor  | situacao | codigo_barra                                 | cpf_pagador |
  |----|-----------------|--------|----------|----------------------------------------------|-------------|
| 2  | 2026-03-15      | 200.50 | PAGO     | 23793381286000000022345678901234567890123456 | 67890123456 |

### Diagnóstico
- O boleto não aparece na lista porque já foi pago.

### Recomendações
- [x] Informar ao cliente que o boleto já foi pago.
- [ ] Validar se há outros boletos em aberto.
- [ ] Monitorar casos de duplicidade ou erro de cadastro.

---

**Adapte este exemplo para outros incidentes de boleto, alterando CPF, datas, sintomas e resultados conforme necessário.**