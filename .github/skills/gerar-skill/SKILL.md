---
name: gerar-skill
description: Gera novas skills de agente de forma estruturada. Use quando o usuário pedir para criar uma skill com escopo, instruções, arquivos de apoio e testes de sucesso/fora de escopo.
license: Proprietary. Uso interno deste repositório.
---

# Gerar Skill

## Objetivo
Criar uma skill nova de ponta a ponta, com coleta estruturada de requisitos, proposta de nome/descrição, geração de arquivos e validação por cenários.

## Quando aplicar esta skill
Use esta skill quando o usuário pedir para:
- criar uma nova skill em `.github/skills/`;
- estruturar `SKILL.md` com boas práticas;
- definir arquivos de apoio (templates, exemplos, scripts e testes);
- validar a skill com cenários de sucesso e fora de escopo.

## Fontes de boas práticas incorporadas
- Estrutura base de skill do GitHub Copilot: pasta da skill + `SKILL.md` obrigatório + arquivos de apoio opcionais.
- Boas práticas de skills do Claude Code: descrição acionável, gatilhos claros, limites de escopo, entradas obrigatórias, formato de saída, exemplos e uso de arquivos de apoio para manter o `SKILL.md` focado.

## Fluxo obrigatório (não pular etapas)

### Etapa 1 — Descoberta por perguntas (obrigatória)
Faça perguntas até obter todas as respostas mínimas. A ordem obrigatória é:
1. **Aplicações da skill** (em quais tipos de tarefa ela deve ser usada).
2. **O que a skill deve fazer** (ações e limites funcionais).
3. **Resultados esperados** (quais entregáveis concretos devem sair).
4. **Formato dos resultados esperados** (template, seções, estilo e nível de detalhe).

Se faltar qualquer item, continue perguntando de forma objetiva.

### Etapa 2 — Proposta de nome e descrição
Depois da coleta mínima, proponha:
- **Nome sugerido** no formato `lowercase-com-hifens`.
- **Descrição sugerida** contendo o que faz + quando usar.

Em seguida, peça escolha explícita:
- opção A: usar a proposta;
- opção B: usuário informar nome/descrição próprios.

Somente avance após essa decisão.

### Etapa 3 — Geração da skill
Crie a estrutura mínima:
- `SKILL.md` (obrigatório)

E, quando útil para clareza/manutenção, crie também:
- `templates/`
- `examples/`
- `tests/`
- `scripts/`

Siga este checklist de conteúdo no `SKILL.md` gerado:
1. Frontmatter YAML com `name` e `description`.
2. Objetivo da skill.
3. Quando aplicar / quando não aplicar.
4. Entradas obrigatórias e opcionais.
5. Procedimento passo a passo.
6. Formato de saída obrigatório.
7. Tratamento de erro e lacunas de contexto.
8. Critérios de qualidade.

### Etapa 4 — Testes obrigatórios da skill criada
Depois de criar a skill, execute testes baseados em cenários:
- **Cenários de sucesso**: entradas válidas e dentro do escopo; a skill deve responder no formato esperado.
- **Cenários fora de escopo**: pedidos incompatíveis; a skill deve responder claramente que não consegue atender por estar fora de escopo e, quando possível, sugerir próximo passo.

Use o roteiro em `tests/scenarios.md` e registre o resultado em `examples/test-report.md`.

## Regras de qualidade
- Faça perguntas curtas, sem jargão desnecessário.
- Não invente requisitos; confirme quando houver ambiguidade.
- Não criar funcionalidades além do que o usuário pediu.
- Preferir simplicidade (MVP) quando os requisitos não exigirem complexidade.
- Manter consistência entre descrição, escopo, exemplos e testes.
- Manter `SKILL.md` focado; mover material extenso para arquivos de apoio.

## Limites de escopo desta skill
Esta skill **não** deve:
- implementar sistemas completos não relacionados a skills;
- decidir sozinha políticas de negócio críticas sem confirmação;
- fingir validação quando não houver evidência de teste.

Nesses casos, responder objetivamente que está fora de escopo da skill e solicitar redirecionamento.

## Recursos de apoio
- Estrutura base para nova skill: `templates/SKILL.template.md`
- Roteiro de testes: `tests/scenarios.md`
- Relatório de execução de testes: `examples/test-report.md`
- Script de validação estrutural: `scripts/validate_generated_skill.sh`

## Comando de validação estrutural
```bash
bash .github/skills/gerar-skill/scripts/validate_generated_skill.sh .github/skills/<nome-da-skill>
```

## Saída esperada ao usar esta skill
Ao final de uma execução completa, entregar:
1. Caminhos dos arquivos criados/alterados.
2. Resumo curto do que foi implementado.
3. Resultado dos testes de sucesso e fora de escopo (passou/falhou + evidência curta).
