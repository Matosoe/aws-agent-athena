# AWS Agent Athena - Incidentes de Boleto com Copilot + Athena

Análise operacional de incidentes de boleto com GitHub Copilot, usando consultas no Athena via AWS CLI.

## Objetivo

Resolver incidentes como:
- boleto não aparece na lista;
- divergência de status (`PENDENTE`, `PAGO`, `BAIXADO`);
- duplicidade ou inconsistência por CPF.

## Estrutura atual

```
aws-agent-athena/
├── README.md
├── QUICKSTART.md
├── GITHUB_SETUP.md
└── .github/
   └── skills/
      ├── boleto-incidente-resposta/
      │  └── SKILL.md
      └── boleto-ferramentas/
         ├── SKILL.md
         └── scripts/
```

## Onde está cada informação

- **Uso rápido do agente:** [QUICKSTART.md](QUICKSTART.md)
- **Setup de ambiente (Athena + AWS CLI + publicação GitHub):** [GITHUB_SETUP.md](GITHUB_SETUP.md)
- **Skill de incidente (Athena):** [.github/skills/boleto-incidente-resposta/SKILL.md](.github/skills/boleto-incidente-resposta/SKILL.md)
- **Skill de ferramentas de boleto (Bash):** [.github/skills/boleto-ferramentas/SKILL.md](.github/skills/boleto-ferramentas/SKILL.md)

## Prompt curto (exemplo)

```text
Use a skill /boleto-incidente-resposta para analisar o incidente abaixo usando Athena via AWS CLI, executando as consultas e retornando diagnóstico final completo.

Situação: Cliente com CPF 67890123456 reporta que o boleto não aparece na lista de pagamento.
```

## Prompt curto (ferramentas de boleto)

```text
Use a skill /boleto-ferramentas para converter e explicar o boleto abaixo.

Entrada: 34196166700000123451101234567880057123457000
Tarefa: converter para linha digitável, formatar e quebrar os campos.
```

## Licença

MIT License - veja [LICENSE](LICENSE).
