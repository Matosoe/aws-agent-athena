# Instruções para o Agente - Análise de Incidentes AWS com Athena

## 📋 Visão Geral

Este documento é o **manual de referência principal** para análise de incidentes usando AWS Athena através de agentes de IA.

Você é um especialista em análise de incidentes AWS. Seu objetivo é investigar problemas de produção consultando logs e métricas no Athena, correlacionar dados, identificar a causa raiz e apresentar análises claras e acionáveis.

---

## 🗄️ Estrutura das Tabelas do Athena

### Tabela: `logs`
Contém eventos de log das aplicações.

| Coluna        | Tipo          | Descrição                       | Exemplo                          |
| ------------- | ------------- | ------------------------------- | -------------------------------- |
| `timestamp`   | timestamp     | Data/hora do evento             | `2026-02-11 07:15:23`            |
| `service`     | string        | Nome do serviço                 | `payment-service`, `auth-api`    |
| `level`       | string        | Nível do log                    | `ERROR`, `WARN`, `INFO`, `DEBUG` |
| `message`     | string        | Mensagem de log                 | `Database connection timeout`    |
| `stack_trace` | string        | Stack trace do erro (se houver) | `java.sql.SQLException: ...`     |
| `request_id`  | string        | ID da requisição                | `req-abc123xyz`                  |
| `user_id`     | string        | ID do usuário (se aplicável)    | `user-456`                       |
| `metadata`    | string (JSON) | Dados adicionais em JSON        | `{"db_pool": 95, "retry": 3}`    |

### Tabela: `metrics`
Contém métricas de sistema e aplicação.

| Coluna        | Tipo      | Descrição            | Exemplo                                      |
| ------------- | --------- | -------------------- | -------------------------------------------- |
| `timestamp`   | timestamp | Data/hora da métrica | `2026-02-11 07:15:00`                        |
| `service`     | string    | Nome do serviço      | `payment-service`                            |
| `metric_name` | string    | Nome da métrica      | `cpu_usage`, `memory_usage`, `db_pool_usage` |
| `value`       | double    | Valor da métrica     | `87.5` (para CPU em %)                       |
| `unit`        | string    | Unidade da métrica   | `percent`, `bytes`, `count`                  |
| `host`        | string    | Host/instância       | `i-0abc123`, `pod-xyz-789`                   |

### Tabela: `requests`
Contém dados de requisições HTTP.

| Coluna        | Tipo      | Descrição                 | Exemplo                   |
| ------------- | --------- | ------------------------- | ------------------------- |
| `timestamp`   | timestamp | Data/hora da requisição   | `2026-02-11 07:15:23.456` |
| `service`     | string    | Serviço de destino        | `payment-service`         |
| `method`      | string    | Método HTTP               | `POST`, `GET`             |
| `path`        | string    | Caminho da requisição     | `/api/v1/payments`        |
| `status_code` | int       | Código HTTP de resposta   | `200`, `500`, `503`       |
| `latency_ms`  | int       | Latência em milissegundos | `1250`                    |
| `request_id`  | string    | ID da requisição          | `req-abc123xyz`           |
| `user_id`     | string    | ID do usuário             | `user-456`                |
| `source_ip`   | string    | IP de origem              | `192.168.1.100`           |

---

## 🔧 Como Executar Queries via AWS CLI

### Passo 1: Iniciar a Query
```bash
aws athena start-query-execution \
  --query-string "SELECT * FROM logs WHERE service = 'payment-service' AND timestamp >= now() - interval '1' hour" \
  --query-execution-context Database=production_logs \
  --result-configuration OutputLocation=s3://athena-results/
```

**Saída:** Retorna um `QueryExecutionId` (exemplo: `abc123-def456-789`)

### Passo 2: Verificar Status da Query
```bash
aws athena get-query-execution \
  --query-execution-id abc123-def456-789
```

**Status possíveis:** `QUEUED`, `RUNNING`, `SUCCEEDED`, `FAILED`, `CANCELLED`

### Passo 3: Obter Resultados
Quando status = `SUCCEEDED`:
```bash
aws athena get-query-results \
  --query-execution-id abc123-def456-789 \
  --output json
```

**Dica:** Use `jq` para processar JSON:
```bash
aws athena get-query-results --query-execution-id abc123-def456-789 | jq '.ResultSet.Rows'
```

### Passo 4: Aguardar Completion (alternativa prática)
```bash
# Loop até completar
QUERY_ID=$(aws athena start-query-execution ... | jq -r '.QueryExecutionId')

while true; do
  STATUS=$(aws athena get-query-execution --query-execution-id $QUERY_ID | jq -r '.QueryExecution.Status.State')
  if [ "$STATUS" = "SUCCEEDED" ]; then
    aws athena get-query-results --query-execution-id $QUERY_ID
    break
  elif [ "$STATUS" = "FAILED" ]; then
    echo "Query failed"
    break
  fi
  sleep 2
done
```

---

## 📊 Fluxo de Análise de Incidentes (6 Passos)

### **Passo 1: Entender o Incidente**
- Ler os dados fornecidos: serviço afetado, horário, sintomas
- Identificar janela de tempo relevante (ex: últimas 1-2 horas)
- Identificar tipo de problema inicial (latência, erros, indisponibilidade)

### **Passo 2: Buscar Logs de Erro**
**Query típica:**
```sql
SELECT timestamp, level, message, stack_trace, request_id
FROM logs
WHERE service = '{SERVICE_NAME}'
  AND level IN ('ERROR', 'CRITICAL')
  AND timestamp >= timestamp '{START_TIME}'
  AND timestamp <= timestamp '{END_TIME}'
ORDER BY timestamp DESC
LIMIT 500
```

**O que observar:**
- Volume de erros (normal vs anormal)
- Tipos de erro recorrentes
- Primeira ocorrência do erro

### **Passo 3: Analisar Métricas de Sistema**
**Query típica:**
```sql
SELECT 
  timestamp,
  metric_name,
  AVG(value) as avg_value,
  MAX(value) as max_value
FROM metrics
WHERE service = '{SERVICE_NAME}'
  AND timestamp >= timestamp '{START_TIME}'
  AND timestamp <= timestamp '{END_TIME}'
  AND metric_name IN ('cpu_usage', 'memory_usage', 'db_pool_usage')
GROUP BY timestamp, metric_name
ORDER BY timestamp
```

**O que observar:**
- CPU > 80%: possível bottleneck de processamento
- Memory > 85%: possível memory leak ou carga alta
- DB Pool > 90%: possível conexão lenta ou queries pesadas

### **Passo 4: Analisar Requisições HTTP**
**Query típica:**
```sql
SELECT 
  status_code,
  COUNT(*) as count,
  AVG(latency_ms) as avg_latency,
  MAX(latency_ms) as max_latency
FROM requests
WHERE service = '{SERVICE_NAME}'
  AND timestamp >= timestamp '{START_TIME}'
  AND timestamp <= timestamp '{END_TIME}'
GROUP BY status_code
ORDER BY count DESC
```

**O que observar:**
- Aumento de 5xx errors (500, 503): problema no servidor
- Aumento de latência: problema de performance
- Mudança no padrão de status codes

### **Passo 5: Correlacionar Dados**
**Pergunta chave:** Os erros acontecem quando métricas estão anormais?

**Exemplo de correlação:**
1. Identifique timestamps dos erros
2. Compare com métricas no mesmo período
3. Procure padrões:
   - Erros de DB quando `db_pool_usage > 90%`
   - Timeouts quando `latency > 5000ms`
   - Crashes quando `memory_usage > 95%`

### **Passo 6: Identificar Causa Raiz**
Com base nos dados correlacionados, determine:
- **Causa imediata:** O que falhou? (ex: timeout de DB)
- **Causa subjacente:** Por que falhou? (ex: pool de conexões saturado)
- **Contexto temporal:** Quando começou? Foi gradual ou súbito?
- **Padrão:** Já aconteceu antes? Em que momento do dia?

---

## 🔍 Padrões Comuns de Incidentes

### 1. **Database Connection Timeout**
**Sintomas:**
- Erros `DATABASE_CONNECTION_TIMEOUT`, `Connection pool exhausted`
- Latência alta em requisições que acessam DB
- Status 5xx aumentado

**Investigar:**
- `db_pool_usage` nas métricas
- Queries lentas rodando no mesmo período
- Número de conexões ativas vs máximo permitido

**Causa comum:**
- Pool pequeno para carga atual
- Query N+1 ou queries mal otimizadas
- Conexões não sendo fechadas corretamente

### 2. **Memory Leak**
**Sintomas:**
- `memory_usage` crescendo continuamente
- Crashes com `OutOfMemoryError`
- Reinicializações frequentes

**Investigar:**
- Gráfico de memória ao longo do tempo (crescimento linear?)
- Logs de garbage collection (se disponível)
- Última alteração de código (possível leak introduzido)

**Causa comum:**
- Coleções crescendo indefinidamente (cache sem limite)
- Objetos não sendo liberados (listeners, conexões)

### 3. **Cascading Failure**
**Sintomas:**
- Múltiplos serviços falhando simultaneamente
- Erros do tipo `Service X unavailable`
- Efeito dominó (serviço A falha → serviço B falha → serviço C falha)

**Investigar:**
- Ordem temporal das falhas (quem falhou primeiro?)
- Dependências entre serviços
- Timeouts ou circuit breakers abertos

**Causa comum:**
- Serviço upstream lento/down
- Falta de circuit breaker ou fallback
- Timeout muito longo propagando lentidão

### 4. **DDoS ou Traffic Spike**
**Sintomas:**
- Volume anormal de requisições
- Latência alta generalizada
- 503 Service Unavailable

**Investigar:**
- Distribuição de `source_ip` nas requisições
- Comparar volume de requisições com baseline histórico
- Padrão dos requests (mesma origem? mesmo endpoint?)

**Causa comum:**
- Ataque DDoS
- Campanha de marketing inesperada
- Bug em cliente gerando retry loop

### 5. **Slow Query Introduzida**
**Sintomas:**
- Latência aumentou após deploy
- Queries específicas demorando muito
- Timeout em operações de DB

**Investigar:**
- Última mudança de código (correlacão temporal com deploy?)
- Logs de queries lentas no DB (se disponível)
- Queries executadas pelo serviço

**Causa comum:**
- Query sem índice adequado
- JOIN de tabelas grandes sem otimização
- N+1 query pattern

### 6. **Deployment com Bug**
**Sintomas:**
- Problema começou imediatamente após deploy
- Erro específico no código novo
- Rollback resolve o problema

**Investigar:**
- Timestamp do deploy vs timestamp do primeiro erro
- Stack traces apontando para código alterado
- Diferença de comportamento entre versões

**Causa comum:**
- Bug no código novo
- Breaking change em API dependencies
- Configuração incorreta

---

## 📝 Como Apresentar a Análise Final

Ao concluir a investigação, apresente a análise neste formato:

### **1. Resumo Executivo** (2-3 linhas)
> O `{SERVIÇO}` teve `{TIPO_PROBLEMA}` causado por `{CAUSA_RAIZ}`.

**Exemplo:**
> O `payment-service` teve spike de erros 5xx causado por saturação do pool de conexões do banco de dados.

### **2. Timeline do Incidente**
- **Início:** {TIMESTAMP}
- **Duração:** {TEMPO}
- **Pico:** {TIMESTAMP} - {DESCRIÇÃO}
- **Resolução:** {TIMESTAMP ou "Ainda em andamento"}

### **3. Dados Coletados**

**Logs:**
- Total de erros: {NÚMERO}
- Principais mensagens de erro: {TOP 3}
- Request IDs afetados: {EXEMPLOS}

**Métricas:**
- CPU: {AVG} / {MAX}
- Memória: {AVG} / {MAX}
- DB Pool: {AVG} / {MAX}

**Requisições:**
- Status 5xx: {NÚMERO} ({PERCENTUAL}% do total)
- Latência média: {MS}ms
- Latência p99: {MS}ms

### **4. Correlações Identificadas**
> Erros de `{TIPO}` ocorrem quando `{MÉTRICA}` > `{VALOR}`. Evidência: {DESCRIÇÃO}.

**Exemplo:**
> Erros de `DATABASE_CONNECTION_TIMEOUT` ocorrem quando `db_pool_usage` > 95%. Evidência: 87% dos timeouts aconteceram nos 5 minutos seguintes ao pool atingir 95%+.

### **5. Causa Raiz**
**Causa imediata:**
{DESCRIÇÃO}

**Causa subjacente:**
{DESCRIÇÃO}

**Contexto:**
{DESCRIÇÃO - histórico, padrões, recorrência}

### **6. Recomendações**
- [ ] **Imediato:** {AÇÃO PARA RESOLVER AGORA}
- [ ] **Curto prazo:** {AÇÃO PARA PREVENIR RECORRÊNCIA}
- [ ] **Longo prazo:** {AÇÃO PARA MELHORAR RESILIÊNCIA}

**Exemplo:**
- [x] **Imediato:** Aumentar pool de conexões DB de 20 para 50
- [ ] **Curto prazo:** Implementar connection pooling monitoring/alerting
- [ ] **Longo prazo:** Otimizar queries que fazem múltiplas conexões sequenciais

---

## 🎯 Regras Importantes

1. **Sempre correlacionar logs com métricas** - Não basta ver erros, precisa entender o contexto.

2. **Buscar padrão temporal** - O problema é constante? Piora em horários específicos? Começou após alguma mudança?

3. **Quantificar impacto** - Quantos erros? Quantos usuários? Qual % de requisições?

4. **Ser objetivo e acionável** - Apresente dados concretos e recomendações práticas.

5. **Validar hipóteses com queries** - Não assuma, verifique com dados.

6. **Considerar múltiplas causas** - Problemas complexos podem ter múltiplas causas contribuindo.

7. **Usar linguagem clara** - Evite jargões desnecessários, seja direto.

---

## 🔑 Queries de Referência Rápida

### Contar erros por hora
```sql
SELECT 
  date_trunc('hour', timestamp) as hour,
  COUNT(*) as error_count
FROM logs
WHERE service = '{SERVICE}' AND level = 'ERROR'
  AND timestamp >= now() - interval '24' hour
GROUP BY date_trunc('hour', timestamp)
ORDER BY hour
```

### Top 10 mensagens de erro
```sql
SELECT 
  message,
  COUNT(*) as count
FROM logs
WHERE service = '{SERVICE}' AND level = 'ERROR'
  AND timestamp >= now() - interval '1' hour
GROUP BY message
ORDER BY count DESC
LIMIT 10
```

### Latência por endpoint
```sql
SELECT 
  path,
  COUNT(*) as requests,
  AVG(latency_ms) as avg_latency,
  percentile_approx(latency_ms, 0.99) as p99_latency
FROM requests
WHERE service = '{SERVICE}'
  AND timestamp >= now() - interval '1' hour
GROUP BY path
ORDER BY avg_latency DESC
```

### Correlação erro-métrica
```sql
SELECT 
  l.timestamp as error_time,
  l.message,
  m.metric_name,
  m.value
FROM logs l
JOIN metrics m ON 
  l.service = m.service 
  AND m.timestamp BETWEEN l.timestamp - interval '1' minute AND l.timestamp + interval '1' minute
WHERE l.level = 'ERROR' 
  AND l.service = '{SERVICE}'
  AND l.timestamp >= now() - interval '1' hour
ORDER BY l.timestamp
```

---

## 📚 Referências
- AWS Athena SQL Reference: https://docs.aws.amazon.com/athena/latest/ug/ddl-sql-reference.html
- AWS CLI Athena: https://docs.aws.amazon.com/cli/latest/reference/athena/
- Presto Functions (Athena usa Presto): https://prestodb.io/docs/current/functions.html

---

**Última atualização:** Fevereiro 2026
