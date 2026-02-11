# Exemplos de Incidentes - Análise com Athena

Este documento contém **6 exemplos práticos** de incidentes reais e como investigá-los usando as instruções do [AGENT_INSTRUCTIONS.md](AGENT_INSTRUCTIONS.md).

---

## 📖 Como Usar Este Documento

1. **Copie um exemplo** completo abaixo
2. **Cole no GitHub Copilot** (modo Agent + YOLO ativado)
3. **Deixe o agente trabalhar** - ele executará as queries, correlacionará dados e apresentará a análise
4. **Adapte para seus incidentes reais** - modifique serviços, timestamps, sintomas conforme necessário

---

## Exemplo 1: Database Connection Timeout

### 📋 Dados do Incidente
```
INCIDENTE: Database Connection Timeout no Payment Service
Serviço: payment-service
Início: 2026-02-11 07:00:00 UTC
Status: Em andamento
Sintomas:
  - Spike de erros 5xx (aumento de 300%)
  - Latência aumentou de 200ms para 5000ms
  - Usuários reportam "Payment failed" errors
  - Mensagem comum nos logs: "DATABASE_CONNECTION_TIMEOUT"
```

### 🔍 O Que Investigar

**Passo 1:** Buscar logs de erro na janela de tempo (06:00 - 08:00)
- Procurar por `DATABASE_CONNECTION_TIMEOUT`, `Connection pool exhausted`
- Contar frequência de erros por minuto
- Identificar quando começou exatamente

**Passo 2:** Analisar métricas de DB pool
- `db_pool_usage` no mesmo período
- Comparar com baseline normal (ex: 40-50%)
- Identificar quando passou de 90%

**Passo 3:** Verificar requisições HTTP
- Status codes: quantos 500, 503, 504?
- Latência: p50, p95, p99
- Volume de requisições (possível spike?)

**Passo 4:** Correlacionar
- Os timeouts acontecem quando pool > X%?
- Há um evento específico que disparou o problema?

**Passo 5:** Verificar histórico
- Esse problema já ocorreu antes?
- Mesma hora do dia? Mesmo dia da semana?

### ✅ Resultado Esperado
```
Análise: O payment-service teve spike de erros 5xx (300% acima do normal)
causado por saturação do pool de conexões do banco de dados.

Timeline:
- Início: 2026-02-11 07:03:45 UTC
- Pico: 07:15 UTC (95% das requisições falhando)
- Duração: 35 minutos (ainda em andamento)

Dados:
- Erros: 1,247 DATABASE_CONNECTION_TIMEOUT
- DB Pool: chegou a 98% (normal: 45%)
- Status 5xx: 1,532 (23% das requisições)
- Latência p99: 8,500ms (normal: 300ms)

Correlação:
87% dos timeouts ocorreram quando db_pool_usage > 95%.
Primeiro pool saturation às 07:03:30, primeiro erro às 07:03:45.

Causa Raiz:
Imediata: Pool de conexões saturado (20 conexões, todas em uso)
Subjacente: Nova feature de "batch payment processing" introduzida 
ontem abre 5 conexões por job, jobs aumentaram de 2 para 8 simultâneos.
Contexto: Problema recorrente - ocorreu 2x no último mês sempre entre 
07:00-08:00 UTC (horário de processamento batch noturno).

Recomendações:
☑ Imediato: Aumentar pool de 20 para 50 conexões
☐ Curto prazo: Otimizar batch jobs para usar 2 conexões por job (reuse)
☐ Longo prazo: Implementar alerting para db_pool_usage > 80%
```

---

## Exemplo 2: Memory Leak

### 📋 Dados do Incidente
```
INCIDENTE: Memory Leak no Auth API
Serviço: auth-api
Início: 2026-02-10 14:00:00 UTC (detectado agora)
Status: Crítico - service reiniciando a cada 2 horas
Sintomas:
  - Memory usage crescendo continuamente
  - OutOfMemoryError nos logs
  - Reinicializações automáticas frequentes (6x nas últimas 12h)
  - Latência aumentando gradualmente antes de cada crash
```

### 🔍 O Que Investigar

**Passo 1:** Analisar histórico de memória (últimas 24h)
- Gráfico de `memory_usage` ao longo do tempo
- É crescimento linear? Exponencial?
- Há momentos de queda (garbage collection ou restart?)

**Passo 2:** Correlacionar crashes com uso de memória
- Timestamps dos crashes vs `memory_usage` antes do crash
- Todos os crashes acontecem em ~95% memory?

**Passo 3:** Buscar logs de GC (se disponível)
- Frequência de garbage collection aumentando?
- GC conseguindo liberar memória ou não?

**Passo 4:** Verificar mudanças recentes
- Último deploy foi quando?
- Houve mudança em volume de tráfego?

**Passo 5:** Procurar padrões nos logs antes do crash
- Há operações específicas sendo executadas?
- Algum endpoint/feature sendo usado mais?

### ✅ Resultado Esperado
```
Análise: O auth-api está com memory leak causado por cache interno 
crescendo indefinidamente sem política de eviction.

Timeline:
- Problema iniciou: 2026-02-10 14:23:00 UTC (após deploy)
- Padrão: memory cresce 8% por hora, crash em ~2h30min
- Crashes: 6 ocorrências nas últimas 12h

Dados:
- Memory usage: cresce de 45% → 95% em 2h30min (linear)
- Crashes: todos com OutOfMemoryError quando memory > 93%
- GC: tentativas de GC aumentam 400% antes do crash, sem sucesso
- Tráfego: estável (não é causado por aumento de carga)

Correlação:
Deploy da versão 2.3.5 em 2026-02-10 14:00:00 introduziu feature 
"session caching" que armazena sessões em HashMap sem limite.
Cada login adiciona entry no cache, nenhuma é removida.

Causa Raiz:
Imediata: OutOfMemoryError por heap saturation
Subjacente: Cache de sessões implementado sem LRU ou TTL
Contexto: Bug introduzido no commit abc123f "Add session caching 
for performance" - cache in-memory sem bounded size

Recomendações:
☑ Imediato: Rollback para versão 2.3.4 (estável)
☑ Curto prazo: Implementar LRU cache com max 10k entries ou TTL 1h
☐ Longo prazo: Migrar cache para Redis (distribuído + eviction)
☐ Adicionar memory alerting + heap dump automation
```

---

## Exemplo 3: Cascading Failure

### 📋 Dados do Incidente
```
INCIDENTE: Cascading Failure - Múltiplos Serviços Down
Início: 2026-02-11 09:15:00 UTC
Status: Crítico - impacto generalizado
Serviços Afetados:
  - checkout-service (primeiro a falhar)
  - payment-service (falhou 2min depois)
  - notification-service (falhou 5min depois)
  - user-profile-service (falhou 8min depois)
Sintomas:
  - Todos com alta taxa de erros 5xx
  - Mensagens de "Service X unavailable"
  - Timeouts em chamadas entre serviços
```

### 🔍 O Que Investigar

**Passo 1:** Estabelecer ordem temporal das falhas
- Que serviço falhou primeiro?
- Quais falharam em sequência?
- Intervalo entre cada falha?

**Passo 2:** Mapear dependências
- Que serviços dependem de checkout-service?
- Diagrama de chamadas (quem chama quem?)

**Passo 3:** Analisar logs de cada serviço
- Tipo de erro em cada um
- Há menção a outros serviços nos erros?

**Passo 4:** Verificar timeouts
- Latência das chamadas inter-service
- Há circuit breakers abrindo?

**Passo 5:** Identificar causa raiz no serviço inicial
- Por que checkout-service falhou?
- Problema interno ou dependência externa?

### ✅ Resultado Esperado
```
Análise: Cascading failure iniciou no checkout-service por problema 
no banco de dados, propagou para serviços dependentes devido à 
falta de circuit breakers e timeouts longos (30s).

Timeline:
- 09:15:00: checkout-service começa a falhar (DB down)
- 09:17:15: payment-service saturado (retry loop chamando checkout)
- 09:20:30: notification-service timeout (depende de payment)
- 09:23:45: user-profile-service degradado (depende de checkout)

Dados:
- checkout-service: 3,421 erros "Database unreachable"
- payment-service: 2,187 timeouts chamando checkout (30s timeout)
- notification-service: thread pool esgotado aguardando payment
- user-profile-service: 847 erros por lentidão em checkout calls

Correlação:
Banco do checkout-service teve falha de rede às 09:14:45.
Serviços downstream continuaram tentando chamar checkout com 
retry automático e timeout de 30s, criando efeito dominó.

Causa Raiz:
Imediata: Database network failure no checkout-service
Subjacente: Falta de circuit breakers + timeout muito longo
Contexto: Arquitetura sem resiliência - uma falha propagou para 
4 serviços. Não há fallback ou fail-fast mechanism.

Recomendações:
☑ Imediato: Restaurar conectividade do DB (time de infra atuando)
☑ Curto prazo: Implementar circuit breakers (Hystrix/Resilience4j)
☐ Reduzir timeouts de 30s para 3-5s com retry exponencial
☐ Longo prazo: Implementar health checks e graceful degradation
☐ Adicionar fallback responses para chamadas não-críticas
```

---

## Exemplo 4: DDoS / Traffic Spike

### 📋 Dados do Incidente
```
INCIDENTE: Traffic Spike Anormal no User API
Serviço: user-api
Início: 2026-02-11 16:30:00 UTC
Status: Em andamento
Sintomas:
  - Volume de requisições 50x acima do normal
  - Latência alta generalizada (5-10s)
  - 503 Service Unavailable para usuários legítimos
  - CPU em 98% em todos os pods
  - Auto-scaling não acompanhando demanda
```

### 🔍 O Que Investigar

**Passo 1:** Comparar volume atual com baseline
- Requisições/min: atual vs média histórica
- Quando começou o spike?

**Passo 2:** Analisar origem das requisições
- Distribuição de `source_ip`
- Há IPs específicos responsáveis por alto volume?
- Padrão de User-Agent

**Passo 3:** Verificar endpoints atacados
- Que paths estão sendo chamados?
- Distribuição de requisições por endpoint
- Há um endpoint específico ou todos?

**Passo 4:** Analisar padrão das requisições
- Todas do mesmo IP? Múltiplos IPs?
- Requisições legítimas ou maliciosas?
- Há padrão temporal (constante? em ondas?)

**Passo 5:** Avaliar impacto em usuários reais
- Quantos % de requisições são do "attack"?
- Usuários legítimos conseguindo acessar?

### ✅ Resultado Esperado
```
Análise: O user-api sofreu DDoS de 23 IPs gerando 150k req/min 
(normal: 3k req/min) no endpoint /api/v1/users/search, causando 
indisponibilidade parcial para usuários legítimos.

Timeline:
- 16:30:00: Início do ataque
- 16:32:00: Latência sobe de 100ms para 8s
- 16:35:00: Auto-scaling tenta ajustar (20 → 50 pods)
- 16:40:00: 503 errors começam (pods saturados)

Dados:
- Volume: 150k req/min (50x acima do normal de 3k/min)
- IPs maliciosos: 23 IPs responsáveis por 92% do tráfego
- Endpoint atacado: /api/v1/users/search (query complexa sem cache)
- Impacto: 35% das requisições legítimas retornando 503
- CPU: 98% em todos os 50 pods

Distribuição por IP:
- Top 3 IPs: 45.123.67.89 (28k req/min), 52.198.34.12 (22k req/min)
- User-Agent: todos com "Mozilla/5.0" genérico (mesma string)
- Padrão: bursts de 100 requisições/segundo por IP

Correlação:
Requisições maliciosas todas para /users/search com queries que 
fazem full table scan (sem usar índice), consumindo 500ms+ cada.
Latência legítima aumentou porque thread pool esgotado.

Causa Raiz:
Imediata: DDoS em endpoint sem rate limiting
Subjacente: Endpoint vulnerável (query pesada sem cache/limite)
Contexto: Endpoint /users/search não tem cache, permite queries 
amplas, não tem rate limiting por IP.

Recomendações:
☑ Imediato: Bloquear 23 IPs maliciosos no WAF/Load Balancer
☑ Implementar rate limiting urgente: 100 req/min por IP
☐ Curto prazo: Adicionar cache no endpoint /users/search
☐ Otimizar query com índices ou limitar escopo (paginação obrigatória)
☐ Longo prazo: Implementar AWS WAF com regras anti-DDoS
```

---

## Exemplo 5: Slow Query Introduzida

### 📋 Dados do Incidente
```
INCIDENTE: Slow Query Após Deploy
Serviço: order-service
Início: 2026-02-11 11:05:00 UTC (imediatamente após deploy)
Status: Degradado
Sintomas:
  - Latência aumentou de 150ms para 3s (p95)
  - Queries específicas demorando 5-10s
  - Timeout em operações de listagem de pedidos
  - Usuários reportam "página não carrega"
Deploy: v3.2.0 (nova feature "Order History with Filters")
```

### 🔍 O Que Investigar

**Passo 1:** Correlação temporal com deploy
- Timestamp do deploy: 11:05:00
- Timestamp do primeiro erro/lentidão: ?
- Há coincidência?

**Passo 2:** Comparar latência antes vs depois
- Latência média: 1 hora antes do deploy vs 1 hora depois
- Endpoints afetados: todos ou específicos?

**Passo 3:** Analisar logs de queries lentas
- Mensagens de "slow query" no log
- Que queries estão demorando?
- Há stack trace apontando para código novo?

**Passo 4:** Verificar mudanças no código
- Diff do deploy v3.1.9 → v3.2.0
- Que queries foram adicionadas/modificadas?
- Há JOINs novos? Queries sem WHERE?

**Passo 5:** Testar rollback
- Se houver teste A/B ou canary: rollback resolve?

### ✅ Resultado Esperado
```
Análise: Deploy da v3.2.0 introduziu query N+1 no endpoint de 
listagem de pedidos, causando aumento de latência de 150ms para 3s.

Timeline:
- 11:05:00: Deploy v3.2.0 concluído
- 11:05:34: Primeira requisição com latência alta (2.8s)
- 11:07:00: 80% das requisições com latência > 2s
- 11:15:00: Time identificou problema e iniciou investigação

Dados:
- Latência p50: 150ms → 1.2s (aumento de 700%)
- Latência p95: 300ms → 3.5s (aumento de 1,066%)
- Endpoint afetado: GET /api/v1/orders (com filtros)
- Queries executadas: 1 SELECT + 1 SELECT por item (N+1 pattern)

Correlação:
100% das requisições lentas são para o endpoint novo /orders?filters=X.
Stack traces apontam para OrderService.getOrdersWithFilters() linha 87.
Antes do deploy: 1 query SQL por requisição.
Depois do deploy: 1 query + N queries (N = número de pedidos).

Exemplo: Listar 50 pedidos = 1 query + 50 queries = 51 queries totais.

Causa Raiz:
Imediata: Query N+1 introduzida na feature "Order History Filters"
Subjacente: ORM configurado sem eager loading para relacionamentos
Contexto: Código novo em OrderService.getOrdersWithFilters() 
carrega items com lazy loading. Cada acesso a order.items dispara 
query ao DB. PR #1234 não teve revisão de performance.

Recomendações:
☑ Imediato: Rollback para v3.1.9 (latência volta ao normal)
☑ Curto prazo: Fix N+1 com eager loading (JOIN FETCH)
☐ Adicionar teste de performance no CI/CD (query count < 5)
☐ Longo prazo: Code review checklist incluir "ORM query patterns"
```

---

## Exemplo 6: Deployment com Breaking Change

### 📋 Dados do Incidente
```
INCIDENTE: API Breaking Change Após Deploy
Serviço: notification-service v2.0.0
Início: 2026-02-11 13:00:00 UTC
Status: Crítico - múltiplos clientes falhando
Sintomas:
  - Erros 400 Bad Request generalizados
  - Clientes reportando "Invalid request format"
  - Logs mostram "Missing required field: channel"
  - Deploy foi migration v1.x → v2.0.0 (breaking changes esperados)
Contexto: Migration planejada mas clientes não atualizaram ainda
```

### 🔍 O Que Investigar

**Passo 1:** Identificar mudanças na API
- Diff do schema v1 vs v2
- Que campos foram adicionados/removidos/renomeados?

**Passo 2:** Analisar erros 400
- Mensagens de erro específicas
- Que campos estão faltando?
- Exemplos de payload rejeitado

**Passo 3:** Identificar clientes afetados
- Que serviços/apps estão chamando a API?
- Quais atualizaram? Quais não?

**Passo 4:** Verificar compatibilidade retroativa
- API v2 deveria suportar v1?
- Há versionamento de endpoint (/v1/notify vs /v2/notify)?

**Passo 5:** Avaliar opções de mitigação
- Rollback? Re-deploy com backward compatibility? 
- Forçar clientes a atualizar?

### ✅ Resultado Esperado
```
Análise: Deploy da v2.0.0 do notification-service introduziu breaking 
change (campo "channel" obrigatório) sem manter backward compatibility, 
causando falha em 8 serviços clientes que não atualizaram.

Timeline:
- 13:00:00: Deploy v2.0.0 concluído
- 13:00:15: Primeiros erros 400 de clientes v1
- 13:05:00: 8 serviços afetados identificados
- 13:20:00: Decisão de rollback + fix

Dados:
- Erros 400: 4,721 requisições rejeitadas (42% do tráfego)
- Mensagem comum: "Missing required field: channel"
- Clientes afetados: 8 serviços ainda usando API v1 schema
- Clientes OK: 2 serviços já migraram para v2

Mudança breaking:
v1 Schema:
{
  "user_id": "123",
  "message": "Hello",
  "type": "email"  ← campo "type" 
}

v2 Schema:
{
  "user_id": "123",
  "message": "Hello",
  "channel": "email"  ← campo renomeado + obrigatório
}

Correlação:
Todos os erros 400 vêm de payloads sem campo "channel".
Documentação v2 menciona breaking change mas não foi comunicado 
com antecedência suficiente. Migration guide existe mas clientes 
não tiveram tempo de implementar.

Causa Raiz:
Imediata: Breaking change não backward compatible
Subjacente: Deploy forçado antes de todos os clientes migrarem
Contexto: Processo de migration falhou - não houve período de 
deprecated + suporte dual (v1 e v2 simultâneos). Não há versionamento 
de endpoint (/v1/notify e /v2/notify separados).

Recomendações:
☑ Imediato: Rollback para v1.9.5 OU fix rápido para aceitar "type"/"channel"
☑ Curto prazo: Re-deploy v2.0.1 com backward compatibility:
  - Aceitar "type" OU "channel" (alias)
  - Deprecation warning para "type"
☐ Longo prazo: Implementar API versioning (/v1/notify, /v2/notify)
☐ Processo de migration: 
  1. Anunciar breaking change 30d antes
  2. Deploy com suporte dual (v1+v2) por 60d
  3. Deprecate v1 após 100% dos clientes migrarem
```

---

## 💡 Dicas de Debug

### Se as queries não retornam resultados
- Verifique se os timestamps estão no formato correto: `timestamp '2026-02-11 07:00:00'`
- Verifique se o serviço está escrito corretamente (case-sensitive)
- Amplie a janela de tempo (ex: últimas 24h em vez de 1h)

### Se houver timeout nas queries
- Adicione `LIMIT 1000` nas queries exploratórias
- Use `date_trunc('minute', timestamp)` para agregar antes de contar
- Verifique se as tabelas têm partições por data (use `WHERE date = '2026-02-11'`)

### Se não houver correlação clara
- Expanda a análise para dados não estruturados (`metadata` JSON)
- Considere causas externas (ex: problema em cloud provider, DDoS)
- Verifique múltiplas janelas de tempo (talvez o problema começou antes)

### Se o agente não está encontrando o problema
- Forneça mais contexto: últimas mudanças, deploys recentes
- Peça para analisar padrões históricos (últimos 7 dias)
- Sugira hipóteses: "será que é memory leak?" → agente foca nisso

---

## 🚀 Como Usar com GitHub Copilot

### Setup (uma vez)
1. Abra VS Code
2. Ative GitHub Copilot Agent Mode
3. Ative modo YOLO (execução automática sem confirmação)
4. No chat, cole:
```
Leia os arquivos AGENT_INSTRUCTIONS.md e INCIDENT_EXAMPLES.md para 
configurar seu contexto de análise de incidentes AWS com Athena.
```

### Para cada novo incidente
1. Copie o template de um dos exemplos acima
2. Modifique com dados reais do seu incidente
3. Cole no chat do Copilot
4. Aguarde a análise completa

### Esperado
O agente vai:
- ✅ Executar queries no Athena via AWS CLI
- ✅ Processar resultados JSON
- ✅ Correlacionar logs com métricas
- ✅ Identificar padrões
- ✅ Apresentar análise estruturada com causa raiz e recomendações

---

**Última atualização:** Fevereiro 2026
