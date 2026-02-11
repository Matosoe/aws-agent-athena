# AWS Agent Athena - Análise de Incidentes com IA

> **Análise automatizada de incidentes AWS usando GitHub Copilot Agent + AWS Athena**

Este repositório fornece um framework completo para analisar incidentes de produção usando agentes de IA (GitHub Copilot) que consultam dados no AWS Athena em linguagem natural.

## 🎯 Objetivo

Permitir que você analise incidentes AWS **sem escrever SQL manualmente**. Basta descrever o problema em linguagem cotidiana, e o agente:

1. ✅ Monta queries SQL automaticamente
2. ✅ Executa no Athena via AWS CLI
3. ✅ Correlaciona logs, métricas e requisições
4. ✅ Identifica causa raiz
5. ✅ Apresenta análise estruturada com recomendações

## 📚 Estrutura do Repositório

```
aws-agent-athena/
├── README.md                    # Este arquivo
├── AGENT_INSTRUCTIONS.md        # Instruções detalhadas para o agente
├── INCIDENT_EXAMPLES.md         # 6 exemplos práticos de incidentes
└── COPILOT_PROMPT.md           # Templates de prompts prontos para usar
```

## 🚀 Quick Start

### Pré-requisitos

- **VS Code** com **GitHub Copilot** ativado
- **AWS CLI** configurado com credenciais de acesso ao Athena
- **Modo YOLO** ativado no Copilot (execução automática)

### Passos

1. **Clone este repositório:**
   ```bash
   git clone https://github.com/SEU_USUARIO/aws-agent-athena.git
   cd aws-agent-athena
   ```

2. **Configure o agente (uma vez):**
   - Abra VS Code neste diretório
   - Abra o chat do GitHub Copilot
   - Cole o prompt de configuração de [COPILOT_PROMPT.md](COPILOT_PROMPT.md)

3. **Analise um incidente:**
   - Copie um dos exemplos de [INCIDENT_EXAMPLES.md](INCIDENT_EXAMPLES.md)
   - Modifique com dados reais do seu incidente
   - Cole no Copilot
   - Aguarde a análise completa!

## 📖 Documentação

### Para Começar
- **[COPILOT_PROMPT.md](COPILOT_PROMPT.md)** - Templates prontos e quick start

### Para Entender Como Funciona
- **[AGENT_INSTRUCTIONS.md](AGENT_INSTRUCTIONS.md)** - Referência completa do agente
  - Estrutura das tabelas Athena
  - Como executar queries via AWS CLI
  - Fluxo de análise em 6 passos
  - Padrões comuns de incidentes

### Para Ver Exemplos Práticos
- **[INCIDENT_EXAMPLES.md](INCIDENT_EXAMPLES.md)** - 6 casos reais
  - Database Connection Timeout
  - Memory Leak
  - Cascading Failure
  - DDoS / Traffic Spike
  - Slow Query Introduzida
  - Breaking Change em Deploy

## 🎯 Casos de Uso

### 1. Análise Rápida de Spike de Erros
```markdown
Serviço: payment-service
Sintoma: Erros 5xx aumentaram 300% nas últimas 2 horas
```
→ Agente identifica causa raiz em minutos

### 2. Investigação de Latência Alta
```markdown
Serviço: checkout-service
Sintoma: Latência subiu de 200ms para 5s após deploy
```
→ Agente correlaciona deploy com queries lentas

### 3. Debug de Incidente Recorrente
```markdown
Padrão: Timeout toda terça-feira às 07:00 UTC
```
→ Agente busca padrão histórico e explica causa

### 4. Análise Pós-Deploy
```markdown
Deploy: v2.5.0 às 08:00 UTC
Sintoma: Taxa de erro aumentou 10%
```
→ Agente compara antes vs depois e recomenda ação

## 🔧 Configuração AWS

### Tabelas Esperadas no Athena

O projeto espera 3 tabelas no Athena:

1. **`logs`** - eventos de log das aplicações
2. **`metrics`** - métricas de sistema (CPU, memória, etc)
3. **`requests`** - requisições HTTP

Veja estrutura completa em [AGENT_INSTRUCTIONS.md](AGENT_INSTRUCTIONS.md).

### Credenciais AWS

Configure AWS CLI localmente:

```bash
# Opção 1: Credenciais diretas
aws configure

# Opção 2: Credenciais temporárias (STS)
aws sts assume-role \
  --role-arn arn:aws:iam::ACCOUNT:role/YourRole \
  --role-session-name incident-analysis
```

## 🎓 Como Funciona

### Fluxo de Análise (6 Passos)

```
1. Entender o Incidente
   └─> Serviço, timestamp, sintomas

2. Buscar Logs de Erro
   └─> SELECT * FROM logs WHERE service = '...'

3. Analisar Métricas
   └─> SELECT AVG(value) FROM metrics WHERE ...

4. Analisar Requisições
   └─> SELECT status_code, COUNT(*) FROM requests ...

5. Correlacionar Dados
   └─> Erros ocorrem quando métrica X > Y?

6. Causa Raiz + Recomendações
   └─> Análise estruturada com timeline e ações
```

### Exemplo de Análise Gerada

```markdown
Análise: O payment-service teve spike de erros 5xx causado por 
saturação do pool de conexões do banco de dados.

Timeline:
- Início: 2026-02-11 07:03:45 UTC
- Pico: 07:15 UTC (95% das requisições falhando)
- Duração: 35 minutos

Dados:
- Erros: 1,247 DATABASE_CONNECTION_TIMEOUT
- DB Pool: chegou a 98% (normal: 45%)
- Status 5xx: 1,532 (23% das requisições)

Correlação:
87% dos timeouts ocorreram quando db_pool_usage > 95%.

Causa Raiz:
Pool de conexões saturado. Nova feature abre 5 conexões por job,
jobs aumentaram de 2 para 8 simultâneos.

Recomendações:
☑ Imediato: Aumentar pool de 20 para 50 conexões
☐ Curto prazo: Otimizar jobs para reusar conexões
☐ Longo prazo: Alerting para pool > 80%
```

## 🆚 Comparação: Análise Manual vs Agent

| Aspecto | Manual | Com Agent |
|---------|--------|-----------|
| Escrever SQL | ✍️ Você escreve | ✅ Agente gera |
| Executar queries | ⌨️ Terminal manual | ✅ Automático |
| Correlacionar | 🧠 Mental | ✅ Agente faz |
| Tempo médio | 30-60 min | 3-5 min |
| Expertise SQL | Necessário | Opcional |

## 📊 Padrões de Incidentes Suportados

- ✅ Database Connection Timeout
- ✅ Memory Leak
- ✅ Cascading Failure
- ✅ DDoS / Traffic Spike
- ✅ Slow Query
- ✅ Deployment Breaking Change
- ✅ Circuit Breaker Open
- ✅ Rate Limiting Issues
- ✅ ... e outros (personalizável)

## 🛠️ Troubleshooting

### Queries demorando muito?
- Adicione `LIMIT` nas queries exploratórias
- Use agregação antes de retornar dados
- Verifique particionamento das tabelas

### Resultados não fazem sentido?
- Confirme timestamps corretos
- Verifique case-sensitive nos nomes de serviços
- Amplie janela de tempo

### Copilot não executa comandos?
- Verifique se modo YOLO está ativo
- Dê permissão explícita: "Execute as queries"
- Ou execute manualmente e cole resultados

Veja mais em [COPILOT_PROMPT.md](COPILOT_PROMPT.md#troubleshooting).

## 🎯 Roadmap

- [ ] Adicionar exemplos para Kubernetes logs
- [ ] Suporte para CloudWatch Logs Insights
- [ ] Template de postmortem automático
- [ ] Integração com PagerDuty/Slack
- [ ] Dashboard de métricas de incidentes
- [ ] Skills em Python (alternativa ao terminal)

## 🤝 Contribuindo

Contribuições são bem-vindas! Especialmente:

- ✨ Novos exemplos de incidentes
- 📝 Melhorias na documentação
- 🐛 Correções de bugs nos templates
- 💡 Novos padrões de análise

## 📄 Licença

MIT License - veja [LICENSE](LICENSE) para detalhes.

## 🙏 Agradecimentos

Inspirado por práticas de SRE da Google e análise de incidentes do mundo real.

---

**Última atualização:** Fevereiro 2026

**Autor:** Eduardo

**Repositório:** https://github.com/SEU_USUARIO/aws-agent-athena
