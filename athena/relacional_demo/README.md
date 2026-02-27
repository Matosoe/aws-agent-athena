# Ambiente Relacional no Athena (Clientes, Pedidos e Pagamentos)

Este diretório contém um ambiente relacional de exemplo para Athena, com múltiplas tabelas e relacionamentos lógicos.

## Referência de modelo (internet)

O desenho foi inspirado no modelo público **Sakila** (normalizado, com foco em joins e relacionamento entre entidades), especialmente nos conceitos de `customer`, `rental/order` e `payment`.

- Repositório: https://github.com/jOOQ/sakila

## Estrutura criada

- `customers` (dimensão de cliente)
- `products` (catálogo de produtos)
- `orders` (pedido por cliente)
- `order_items` (itens do pedido)
- `payments` (pagamentos por pedido/cliente)
- `vw_orders_customer_payment` (view com join de pedidos + cliente + pagamento)

## Bucket e prefixos usados

- Bucket: `s3://teste-conceito-trabalho`
- Prefixo base de dados: `s3://teste-conceito-trabalho/athena/relacional_demo/data/`
- Saída das consultas: `s3://teste-conceito-trabalho/athena/query-results/`

## Como usar

1. Enviar os CSVs para o S3:

```bash
aws s3 cp athena/relacional_demo/data/customers.csv s3://teste-conceito-trabalho/athena/relacional_demo/data/customers/customers.csv
aws s3 cp athena/relacional_demo/data/products.csv s3://teste-conceito-trabalho/athena/relacional_demo/data/products/products.csv
aws s3 cp athena/relacional_demo/data/orders.csv s3://teste-conceito-trabalho/athena/relacional_demo/data/orders/orders.csv
aws s3 cp athena/relacional_demo/data/order_items.csv s3://teste-conceito-trabalho/athena/relacional_demo/data/order_items/order_items.csv
aws s3 cp athena/relacional_demo/data/payments.csv s3://teste-conceito-trabalho/athena/relacional_demo/data/payments/payments.csv
```

2. Validar no Athena:

```sql
SELECT * FROM db_conceito_relacional.vw_orders_customer_payment LIMIT 20;
```

## Layout de `payments`

- Colunas: `payment_id, order_id, customer_id, payment_method, payment_date, amount, payment_status, transaction_ref`
- O método de pagamento é representado na coluna `payment_method`.

## Observação importante

Athena (via Glue Data Catalog) **não impõe foreign keys fisicamente** em tabelas externas CSV. Os relacionamentos aqui são lógicos e validados por consultas `JOIN`.