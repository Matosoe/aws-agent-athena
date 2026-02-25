
# Instruções para o Agente - Análise de Incidentes de Boleto

## Visão Geral
Este manual orienta a investigação de incidentes relacionados a boletos (cadastro, pagamento, baixa, consulta) usando AWS Athena.

Seu objetivo é analisar o histórico e situação atual de boletos, identificar causas de problemas (ex: boleto não aparece, duplicidade, erro de pagamento) e apresentar um diagnóstico objetivo.

---

## Estrutura das Tabelas

### Tabela: `cadastro_boletos`
| Coluna         | Tipo      | Descrição                |
|--------------- |---------- |------------------------- |
| id             | int       | Identificador do boleto  |
| data_vencimento| date      | Data de vencimento       |
| valor          | double    | Valor do boleto          |
| situacao       | string    | PENDENTE, PAGO, BAIXADO  |
| codigo_barra   | string    | Código de barras         |
| cpf_pagador    | string    | CPF do pagador           |

---

## Fluxo de Análise de Incidentes

1. **Entender o Incidente**
   - Sintoma reportado (ex: boleto não aparece)
   - CPF do cliente
   - Data/hora do incidente

2. **Consultar Boletos**
   - Buscar boletos pendentes:
     ```sql
     SELECT * FROM cadastro_boletos WHERE cpf_pagador = '{CPF}' AND situacao = 'PENDENTE';
     ```
   - Buscar boletos pagos:
     ```sql
     SELECT * FROM cadastro_boletos WHERE cpf_pagador = '{CPF}' AND situacao = 'PAGO';
     ```
   - Buscar boletos baixados:
     ```sql
     SELECT * FROM cadastro_boletos WHERE cpf_pagador = '{CPF}' AND situacao = 'BAIXADO';
     ```

3. **Analisar Resultado**
   - Se não há boleto pendente, verificar se está pago ou baixado.
   - Se há boleto duplicado, identificar IDs e datas.
   - Se boleto não aparece, verificar histórico de cadastro e situação.

4. **Apresentar Diagnóstico**
   - Resumo executivo: situação do boleto e causa provável.
   - Dados coletados: resultado das queries.
   - Recomendações: ações para resolver ou prevenir.

---

## Regra Obrigatória de Resposta do Agente

- O agente deve **sempre** devolver uma resposta final completa com base nos dados informados no incidente (CPF, sintoma e data/hora).
- O agente **não deve** encerrar com pergunta de confirmação do tipo: "Deseja que eu analise?".
- Mesmo quando não houver registros para o CPF consultado, o agente deve retornar diagnóstico objetivo informando:
  - consultas executadas;
  - resultados encontrados (inclusive "nenhum registro");
  - conclusão clara sobre o motivo do sintoma.
- A resposta final deve ser entregue no mesmo fluxo, sem depender de nova interação do usuário para concluir a análise.

---

## Exemplo de Análise Final

### Resumo Executivo
> O boleto do cliente CPF 67890123456 não aparece na lista de pendentes porque já foi pago.

### Dados Coletados
- Nenhum boleto pendente encontrado.
- 1 boleto pago encontrado (id: 2, valor: 200.50, vencimento: 2026-03-15).

### Causa Raiz
- O boleto foi pago, por isso não aparece na lista de pendentes.

### Recomendações
- [x] Informar ao cliente que o boleto já foi pago.
- [ ] Validar se há outros boletos em aberto.
- [ ] Monitorar casos de duplicidade ou erro de cadastro.

---

## Queries de Referência

- Buscar boletos pendentes:
  ```sql
  SELECT * FROM cadastro_boletos WHERE cpf_pagador = '{CPF}' AND situacao = 'PENDENTE';
  ```
- Buscar boletos pagos:
  ```sql
  SELECT * FROM cadastro_boletos WHERE cpf_pagador = '{CPF}' AND situacao = 'PAGO';
  ```
- Buscar boletos baixados:
  ```sql
  SELECT * FROM cadastro_boletos WHERE cpf_pagador = '{CPF}' AND situacao = 'BAIXADO';
  ```

---

**Última atualização:** 2026-02-24
