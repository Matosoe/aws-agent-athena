# GitHub Copilot - Templates de Prompts para Análise de Incidentes

Este documento contém **templates prontos** para usar com GitHub Copilot ao analisar incidentes AWS com Athena.

---

## 🎯 Setup Inicial (Cole Isto 1x)

### Prompt de Configuração

```markdown
# Configuração do Agente de Análise de Incidentes

Você é um especialista em análise de incidentes AWS. Seu trabalho é:
1. Investigar problemas de produção usando AWS Athena
2. Executar queries SQL via AWS CLI
3. Correlacionar logs, métricas e requisições HTTP
4. Identificar causa raiz
5. Apresentar análise estruturada com recomendações acionáveis

## Instruções
- Leia e siga as diretrizes em `AGENT_INSTRUCTIONS.md`
- Use exemplos de `INCIDENT_EXAMPLES.md` como referência
- Execute comandos AWS CLI diretamente (modo YOLO está ativo)
- Seja metódico: siga os 6 passos de análise
- Sempre correlacione logs com métricas
- Quantifique impacto (números, percentuais)
- Apresente análise no formato padrão

## Contexto AWS
- Database: production_logs
- Output Location: s3://athena-results/
- Credenciais: AWS CLI configurado localmente (sessão temporária ativa)

## Tabelas Disponíveis
- `logs` - eventos de log das aplicações
- `metrics` - métricas de sistema e aplicação
- `requests` - requisições HTTP

Confirme que entendeu lendo os arquivos de instruções e esteja pronto 
para receber dados de incidentes.
```

**O que esperar:**
- ✅ Copilot confirma que leu os arquivos
- ✅ Mostra resumo do que pode fazer
- ✅ Aguarda dados do próximo incidente

---

## 📋 Template Padrão para Incidentes

Use este template para **qualquer novo incidente**:

```markdown
# INCIDENTE: [Nome/Descrição Curta]

## Dados do Incidente
- **Serviço:** [nome-do-servico]
- **Início:** [YYYY-MM-DD HH:MM:SS UTC]
- **Status:** [Em andamento / Resolvido / Crítico]
- **Sintomas:**
  - [Sintoma 1: ex: "Spike de erros 5xx"]
  - [Sintoma 2: ex: "Latência aumentou 300%"]
  - [Sintoma 3: ex: "Usuários reportam timeout"]
- **Contexto Adicional:** [Mudanças recentes, deploys, eventos]

## Tarefa
Analise este incidente seguindo o fluxo de 6 passos:
1. Buscar logs de erro na janela de tempo relevante
2. Analisar métricas de sistema (CPU, memória, DB pool, etc)
3. Analisar requisições HTTP (status codes, latência)
4. Correlacionar logs com métricas
5. Identificar padrão temporal e histórico
6. Determinar causa raiz e apresentar análise completa

Execute as queries necessárias no Athena e apresente a análise estruturada 
com timeline, dados quantificados, correlações, causa raiz e recomendações.
```

---

## 🚀 Exemplos de Prompts Prontos

### 1. Análise Rápida de Spike de Erros

```markdown
# ANÁLISE RÁPIDA: Spike de Erros

Serviço: payment-service
Período: últimas 2 horas
Sintoma: Aumento súbito de erros 5xx

Tarefa:
1. Contar erros por minuto nas últimas 2h
2. Top 5 mensagens de erro mais frequentes
3. Verificar métricas críticas (CPU, memória, DB pool)
4. Identificar se houve mudança recente (deploy, etc)
5. Resumir possíveis causas
```

### 2. Investigação de Latência Alta

```markdown
# INVESTIGAÇÃO: Latência Alta

Serviço: checkout-service
Sintomas:
- Latência p95 subiu de 200ms para 5s
- Usuários reportando página lenta
- Início: 2026-02-11 10:30:00 UTC

Tarefa:
1. Comparar latência atual vs 24h atrás (baseline)
2. Identificar endpoints mais lentos
3. Correlacionar com métricas de DB (query time, connection pool)
4. Verificar se há queries lentas nos logs
5. Determinar se é problema de DB, código ou infraestrutura
6. Análise completa com causa raiz
```

### 3. Análise Pós-Deploy

```markdown
# ANÁLISE PÓS-DEPLOY

Serviço: user-api
Deploy: v2.5.0 em 2026-02-11 08:00:00 UTC
Sintomas (após deploy):
- Alguns usuários reportando erros intermitentes
- Taxa de erro aumentou 10%

Tarefa:
1. Comparar métricas 1h antes vs 1h depois do deploy
2. Identificar novos tipos de erro (que não existiam antes)
3. Verificar latência antes vs depois
4. Analisar se erro está relacionado a código novo (stack traces)
5. Recomendar: keep, rollback ou fix forward?
```

### 4. Investigação de Incident Recorrente

```markdown
# INVESTIGAÇÃO: Incident Recorrente

Serviço: notification-service
Padrão: Erro de timeout toda terça-feira entre 07:00-08:00 UTC
Última ocorrência: 2026-02-11 07:15:00 UTC

Tarefa:
1. Analisar dados da última ocorrência (hoje)
2. Buscar padrão histórico (últimas 4 semanas, terças-feiras 07:00-08:00)
3. Identificar o que há de comum nesses horários (jobs batch? maior carga?)
4. Correlacionar com outras métricas ou eventos
5. Explicar por que acontece nesse horário específico
6. Recomendar solução definitiva
```

---

## 🔄 Fluxo de Trabalho Completo

### Passo a Passo

1. **Abrir VS Code**
   - Certifique-se de que AWS CLI está configurado
   - Verifique credenciais: `aws sts get-caller-identity`

2. **Ativar Copilot Agent Mode + YOLO**
   - Abra o chat do Copilot
   - Ative modo YOLO para execução automática

3. **Configuração Inicial (primeira vez apenas)**
   ```
   Cole o "Prompt de Configuração" do início deste documento
   ```

4. **Para cada incidente:**
   - Copie o "Template Padrão" ou um dos "Exemplos Prontos"
   - Preencha com dados reais do incidente
   - Cole no chat do Copilot
   - Aguarde análise completa

5. **Revisar Análise**
   - Leia a análise gerada
   - Peça refinamentos se necessário: "Detalhe mais a correlação de métricas"
   - Peça queries específicas: "Mostre a query exata que usou para contar erros"

6. **Ações Pós-Análise**
   - Use recomendações para resolver o incidente
   - Documente causa raiz no seu sistema de tickets
   - Compartilhe análise com o time

---

## 🎛️ Comandos de Controle Durante Análise

### Comandos Úteis

```markdown
# Pausar e pedir explicação
"Explique melhor como chegou a essa conclusão"

# Pedir query específica
"Mostre a query SQL exata que usou para essa análise"

# Pedir mais detalhes
"Detalhe mais a análise da correlação entre erros e CPU"

# Mudar foco
"Ignore a análise de CPU, foque em métricas de rede"

# Pedir formato diferente
"Resuma isso em 3 bullets points"

# Exportar dados
"Salve os dados dessa query em incident_data.json"

# Verificar hipótese específica
"Teste se os erros aumentam quando DB pool > 90%"
```

---

## 🛠️ Troubleshooting

### Problema: "AWS CLI não encontrado"
**Solução:**
```bash
# Verifique se AWS CLI está instalado
aws --version

# Se não estiver, instale:
# Windows: https://aws.amazon.com/cli/
# Mac: brew install awscli
# Linux: apt install awscli
```

### Problema: "Credenciais expiradas"
**Solução:**
```bash
# Verifique credenciais atuais
aws sts get-caller-identity

# Se expiradas, renove (depende do seu método de acesso)
# Ex: assume role
aws sts assume-role --role-arn arn:aws:iam::ACCOUNT:role/YourRole --role-session-name incident-analysis
```

### Problema: "Query timeout no Athena"
**Solução:**
```markdown
Cole no Copilot:
"A query está demorando muito. Adicione LIMIT 1000 e faça agregação 
antes de retornar os dados. Use date_trunc para agrupar por minuto."
```

### Problema: "Resultados não fazem sentido"
**Solução:**
```markdown
"Revise a query. Verifique se:
1. Timestamps estão corretos (use timestamp 'YYYY-MM-DD HH:MM:SS')
2. Nome do serviço está correto (case-sensitive)
3. A janela de tempo inclui o período do incidente"
```

### Problema: "Copilot não está executando comandos"
**Solução:**
1. Verifique se modo YOLO está ativo
2. Tente dar permissão explícita: "Execute as queries necessárias"
3. Ou execute manualmente e cole resultados:
```markdown
"Executei esta query: [QUERY]
Resultado: [JSON]
Analise esses dados."
```

---

## 📊 Formatos de Saída Alternativos

### Pedir Dados Estruturados

```markdown
"Apresente a análise em formato de tabela markdown"

"Export os dados em JSON para eu importar no sistema de tickets"

"Crie um diagrama de timeline do incidente"

"Gere um relatório executivo de 3 parágrafos para management"
```

### Exemplo de Output Customizado

```markdown
# Para Relatório Executivo
"Resuma este incidente em:
1. Um parágrafo explicando o problema (para não-técnicos)
2. Impacto em números (quantos usuários, quanto tempo)
3. Ação tomada e status atual"

# Para Postmortem
"Gere template de postmortem com:
- Título e timestamp
- Impacto mensurado
- Causa raiz técnica detalhada
- Timeline dos eventos
- Ações corretivas (curto e longo prazo)
- Lições aprendidas"
```

---

## 🎓 Dicas Avançadas

### Análise Multi-Serviço

```markdown
# Quando múltiplos serviços estão afetados
"Analise estes 3 serviços em paralelo:
- payment-service
- checkout-service
- notification-service

Identifique:
1. Qual falhou primeiro (ordem temporal)
2. Dependências entre eles
3. Se a causa é comum ou propagação de erro"
```

### Análise Comparativa

```markdown
# Comparar dois incidentes similares
"Compare o incidente de hoje (2026-02-11 07:00) com o incidente 
similar de 2026-02-04 07:00. Identifique:
1. Semelhanças
2. Diferenças
3. Por que estão recorrendo?"
```

### Análise Preditiva

```markdown
# Prever problemas antes de ocorrerem
"Analise métricas das últimas 24h do payment-service.
Identifique tendências preocupantes que podem virar incidente:
- Memória crescendo continuamente?
- DB pool se aproximando do limite?
- Taxa de erro aumentando gradualmente?"
```

### Automação de Análise

```markdown
# Criar script de análise reutilizável
"Crie um script Bash que:
1. Aceita parâmetros: serviço, timestamp início, timestamp fim
2. Executa as 6 queries principais do fluxo de análise
3. Salva resultados em JSON
4. Gera relatório markdown

Quero poder rodar: ./analyze_incident.sh payment-service '2026-02-11 07:00:00' '2026-02-11 09:00:00'"
```

---

## ✅ Checklist de Qualidade da Análise

Antes de considerar a análise completa, verifique:

- [ ] **Timeline clara:** Início, duração, pico, resolução
- [ ] **Dados quantificados:** Números concretos (não "muitos erros", mas "1.247 erros")
- [ ] **Correlação demonstrada:** Relação causa-efeito comprovada com dados
- [ ] **Causa raiz identificada:** Imediata + subjacente + contexto
- [ ] **Impacto mensurado:** % de requisições afetadas, número de usuários, etc
- [ ] **Recomendações acionáveis:** Passos concretos, não genéricos
- [ ] **Priorização:** Imediato, curto prazo, longo prazo
- [ ] **Padrão histórico:** Já ocorreu antes? Quando?

Se algum item faltar, peça ao Copilot:
```markdown
"A análise está incompleta. Falta [ITEM]. Por favor, investigue e adicione."
```

---

## 📚 Recursos Adicionais

### Documentos de Referência
- [AGENT_INSTRUCTIONS.md](AGENT_INSTRUCTIONS.md) - Instruções detalhadas do agente
- [INCIDENT_EXAMPLES.md](INCIDENT_EXAMPLES.md) - 6 exemplos práticos completos

### Documentação AWS
- [AWS Athena SQL Reference](https://docs.aws.amazon.com/athena/latest/ug/ddl-sql-reference.html)
- [AWS CLI Athena Commands](https://docs.aws.amazon.com/cli/latest/reference/athena/)
- [Presto Functions](https://prestodb.io/docs/current/functions.html) (Athena usa Presto)

### Patterns de Análise
- SRE Handbook: https://sre.google/sre-book/table-of-contents/
- Incident Response: https://response.pagerduty.com/

---

## 🎬 Começar Agora

### Quick Start em 3 Passos

1. **Cole no Copilot:**
   ```
   Leia os arquivos AGENT_INSTRUCTIONS.md, INCIDENT_EXAMPLES.md e 
   COPILOT_PROMPT.md. Confirme que está pronto para analisar incidentes.
   ```

2. **Copie um exemplo de [INCIDENT_EXAMPLES.md](INCIDENT_EXAMPLES.md) ou use o Template Padrão acima**

3. **Modifique com dados reais do seu incidente e cole no chat**

**Pronto!** O agente executará as análises e retornará o resultado completo.

---

**Última atualização:** Fevereiro 2026
