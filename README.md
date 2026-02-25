# AWS Agent Athena - Análise de Incidentes de Boleto com IA

> **Análise automatizada de incidentes de boleto usando GitHub Copilot Agent + AWS Athena**

Este repositório fornece um framework completo para analisar incidentes de produção relacionados a **boletos** usando agentes de IA (GitHub Copilot) que consultam dados no AWS Athena em linguagem natural.

## 🎯 Objetivo

Permitir que você analise incidentes de boleto **sem escrever SQL manualmente**. Basta descrever o problema em linguagem cotidiana, e o agente:

1. ✅ Monta queries SQL automaticamente
2. ✅ Executa no Athena via AWS CLI
3. ✅ Correlaciona dados de cadastro de boleto, baixa, pagamento etc.
4. ✅ Interpreta resultados e identifica padrões
5. ✅ Apresenta análise estruturada com histórico e situação atual do boleto.

## 📚 Estrutura do Repositório

```
aws-agent-athena/
├── README.md                    # Este arquivo
├── AGENT_INSTRUCTIONS.md        # Instruções detalhadas para o agente
├── INCIDENT_EXAMPLES.md         # Exemplos práticos de incidentes
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

2. **Inicie a análise (copie e cole no Copilot Chat):**

```text
leia os arquivos copilot_prompt.md e agent_instructions.md e resolva meu problema abaixo:

Situacao:Cliente com CPF 67890123456 reporta que o boleto nao aparece na lista de pagamento.
```

3. **(Opcional) Veja exemplos práticos:**
   - Use [INCIDENT_EXAMPLES.md](INCIDENT_EXAMPLES.md) como referência

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
- **[INCIDENT_EXAMPLES.md](INCIDENT_EXAMPLES.md)** - exemplos de incidentes de boleto
   - Boleto não aparece na lista
   - Duplicidade de boleto
   - Pagou mas segue pendente
   - Baixado indevidamente

## 🎯 Casos de Uso

### 1. Boleto não aparece na lista
```markdown
Situacao: Cliente com CPF 67890123456 reporta que o boleto nao aparece na lista de pagamento.
```
→ Agente identifica se está pendente, pago ou baixado

### 2. Boleto aparece como pago, mas cliente diz não ter pago
```markdown
Situacao: Cliente com CPF 67890123456 reporta que o boleto consta como PAGO, mas ele nao reconhece o pagamento.
```
→ Agente valida registros e aponta inconsistências

### 3. Duplicidade de boleto
```markdown
Situacao: Cliente com CPF 67890123456 reporta dois boletos iguais para o mesmo vencimento.
```
→ Agente busca duplicidades por CPF/vencimento/valor

### 4. Baixa não refletiu
```markdown
Situacao: Cliente com CPF 67890123456 pagou, mas o boleto ainda aparece como PENDENTE.
```
→ Agente verifica situação atual e recomenda próximos passos

## 🔧 Configuração AWS

### Tabelas Esperadas no Athena

O projeto espera tabelas com dados de boleto no Athena. A tabela mínima esperada é:

1. **`cadastro_boletos`** - cadastro e situação atual do boleto (PENDENTE, PAGO, BAIXADO)

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
   └─> CPF, sintoma e janela de tempo

2. Consultar Boletos Pendentes
   └─> SELECT * FROM cadastro_boletos WHERE cpf_pagador = '...' AND situacao = 'PENDENTE'

3. Consultar Boletos Pagos
   └─> SELECT * FROM cadastro_boletos WHERE cpf_pagador = '...' AND situacao = 'PAGO'

4. Consultar Boletos Baixados
   └─> SELECT * FROM cadastro_boletos WHERE cpf_pagador = '...' AND situacao = 'BAIXADO'

5. Correlacionar Dados
   └─> O sintoma é explicado pela situação atual do boleto?

6. Causa Raiz + Recomendações
   └─> Análise estruturada com timeline e ações
```

### Exemplo de Análise Gerada

```markdown
Análise: Cliente com CPF 67890123456 reporta que o boleto não aparece na lista.

Timeline:
- Início: 2026-02-24 07:00:00 UTC
- Verificação: 07:02 UTC

Dados:
- Boletos PENDENTES: 0
- Boletos PAGOS: 1 (ex.: id 2, valor 200.50)

Correlação:
O boleto não aparece como pendente porque já consta como PAGO.

Causa Raiz:
O boleto já foi pago, por isso não aparece na lista de pendentes.

Recomendações:
☑ Imediato: Informar o cliente que o boleto já foi pago
☐ Curto prazo: Validar se há outros boletos em aberto para o CPF
☐ Longo prazo: Monitorar incidentes de duplicidade/baixa incorreta
```

## 🆚 Comparação: Análise Manual vs Agent

| Aspecto          | Manual            | Com Agent     |
| ---------------- | ----------------- | ------------- |
| Escrever SQL     | ✍️ Você escreve    | ✅ Agente gera |
| Executar queries | ⌨️ Terminal manual | ✅ Automático  |
| Correlacionar    | 🧠 Mental          | ✅ Agente faz  |
| Tempo médio      | 30-60 min         | 3-5 min       |
| Expertise SQL    | Necessário        | Opcional      |

## 📊 Padrões de Incidentes Suportados

- ✅ Boleto não aparece na lista
- ✅ Boleto pago mas exibido como pendente
- ✅ Boleto baixado indevidamente
- ✅ Duplicidade de boleto
- ✅ Divergência de situação (PENDENTE/PAGO/BAIXADO)
- ✅ ... e outros (personalizável)

## 🛠️ Troubleshooting

### Queries demorando muito?
- Adicione `LIMIT` nas queries exploratórias
- Use agregação antes de retornar dados
- Verifique particionamento das tabelas

### Resultados não fazem sentido?
- Confirme timestamps corretos
- Verifique CPF e filtros de situação (PENDENTE/PAGO/BAIXADO)
- Amplie janela de tempo

### Copilot não executa comandos?
- Verifique se modo YOLO está ativo
- Dê permissão explícita: "Execute as queries"
- Ou execute manualmente e cole resultados

Veja [COPILOT_PROMPT.md](COPILOT_PROMPT.md) e [AGENT_INSTRUCTIONS.md](AGENT_INSTRUCTIONS.md).

## 🎯 Roadmap

- [ ] Adicionar mais exemplos de incidentes de boleto
- [ ] Suporte a tabelas de pagamento/baixa (quando existirem)
- [ ] Template de postmortem automático
- [ ] Integração com PagerDuty/Slack
- [ ] Dashboard de métricas de incidentes de boleto
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
