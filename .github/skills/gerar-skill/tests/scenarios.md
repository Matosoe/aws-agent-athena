# Cenários de teste da skill gerada

Use este roteiro após criar a nova skill. Cada cenário deve registrar:
- Entrada de teste
- Resultado observado
- Resultado esperado
- Status (PASS/FAIL)

## 1) Cenários de sucesso

### Sucesso 1 — Solicitação direta e completa
- Entrada: pedido dentro do escopo com dados completos.
- Esperado: resposta no formato definido pela skill, sem faltar seções obrigatórias.

### Sucesso 2 — Solicitação com lacunas recuperáveis
- Entrada: pedido dentro do escopo, mas faltando alguns dados.
- Esperado: skill faz perguntas objetivas até completar os dados e depois entrega resultado final.

## 2) Cenários fora de escopo

### Fora de escopo 1 — Pedido não relacionado à finalidade da skill
- Entrada: tarefa que não pertence ao domínio da skill.
- Esperado: resposta explícita informando que não consegue atender por fora de escopo.

### Fora de escopo 2 — Pedido que exige decisão não autorizada
- Entrada: tarefa que exige política/decisão que não foi delegada.
- Esperado: recusa por fora de escopo + sugestão de próximo passo seguro.

## Critério mínimo de aprovação
- Todos os cenários de sucesso: PASS
- Todos os cenários fora de escopo: PASS (com recusa correta e objetiva)
