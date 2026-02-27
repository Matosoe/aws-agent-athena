# AWS Agent Athena - Contexto Relacional no Athena

Este repositório reúne um ambiente relacional de demonstração no Athena, usando o banco `db_conceito_relacional` e consultas via AWS CLI.

## Objetivo

Facilitar análises com dados relacionais de exemplo:
- clientes;
- pedidos e itens de pedido;
- pagamentos;
- consultas com `JOIN` e view consolidada.

## Estrutura atual

```
aws-agent-athena/
├── README.md
├── QUICKSTART.md
├── GITHUB_SETUP.md
└── athena/
   └── relacional_demo/
      ├── README.md
      ├── data/
      ├── sql/
      └── scripts/
```

## Onde está cada informação

- **Uso rápido do agente:** [QUICKSTART.md](QUICKSTART.md)
- **Configuração de ambiente e GitHub:** [GITHUB_SETUP.md](GITHUB_SETUP.md)
- **Guia do ambiente relacional:** [athena/relacional_demo/README.md](athena/relacional_demo/README.md)

## Exemplo de prompt

```text
Analise o contexto db_conceito_relacional no Athena via AWS CLI.
Liste um resumo de clientes, pedidos e pagamentos e depois rode uma consulta com JOIN usando a view vw_orders_customer_payment.
```

## Licença

MIT License - veja [LICENSE](LICENSE).
