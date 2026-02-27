#!/usr/bin/env bash
set -euo pipefail

WORKGROUP="${WORKGROUP:-primary}"
DATABASE="${DATABASE:-db_conceito_relacional}"
RESULT_S3="${RESULT_S3:-s3://teste-conceito-trabalho/athena/query-results/}"

exec_and_show() {
  local query="$1"
  local qid

  qid=$(AWS_PAGER="" aws athena start-query-execution \
    --query-string "$query" \
    --query-execution-context Database="$DATABASE" \
    --work-group "$WORKGROUP" \
    --result-configuration OutputLocation="$RESULT_S3" \
    --query 'QueryExecutionId' \
    --output text)

  while true; do
    local state
    state=$(AWS_PAGER="" aws athena get-query-execution \
      --query-execution-id "$qid" \
      --query 'QueryExecution.Status.State' \
      --output text)

    if [[ "$state" == "SUCCEEDED" ]]; then
      break
    elif [[ "$state" == "FAILED" || "$state" == "CANCELLED" ]]; then
      echo "FAILED: $qid"
      AWS_PAGER="" aws athena get-query-execution \
        --query-execution-id "$qid" \
        --query 'QueryExecution.Status.StateChangeReason' \
        --output text
      exit 1
    fi

    sleep 2
  done

  echo "--- QUERY_ID: $qid ---"
  AWS_PAGER="" aws athena get-query-results --query-execution-id "$qid" --output text
}

exec_and_show "SELECT 'customers' AS tabela, count(*) AS qtd FROM customers UNION ALL SELECT 'products' AS tabela, count(*) AS qtd FROM products UNION ALL SELECT 'orders' AS tabela, count(*) AS qtd FROM orders UNION ALL SELECT 'order_items' AS tabela, count(*) AS qtd FROM order_items UNION ALL SELECT 'payments' AS tabela, count(*) AS qtd FROM payments"

exec_and_show "SELECT o.order_id, c.full_name, o.total_amount, coalesce(sum(p.amount), 0) AS paid_amount FROM orders o JOIN customers c ON c.customer_id = o.customer_id LEFT JOIN payments p ON p.order_id = o.order_id GROUP BY o.order_id, c.full_name, o.total_amount ORDER BY o.order_id"

exec_and_show "SELECT oi.order_id, sum(oi.line_total) AS itens_total, o.total_amount, CASE WHEN sum(oi.line_total) = o.total_amount THEN 'OK' ELSE 'DIVERGENTE' END AS status_conferencia FROM order_items oi JOIN orders o ON o.order_id = oi.order_id GROUP BY oi.order_id, o.total_amount ORDER BY oi.order_id"