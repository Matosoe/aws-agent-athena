#!/usr/bin/env bash
set -euo pipefail

WORKGROUP="${WORKGROUP:-primary}"
DATABASE="${DATABASE:-db_conceito_relacional}"
RESULT_S3="${RESULT_S3:-s3://teste-conceito-trabalho/athena/query-results/}"

run_query() {
  local query="$1"
  local qid

  qid=$(AWS_PAGER="" aws athena start-query-execution \
    --query-string "$query" \
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
      echo "SUCCEEDED: $qid"
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
}

run_query "ALTER TABLE ${DATABASE}.customers REPLACE COLUMNS (customer_id INT, cpf STRING, full_name STRING, email STRING, city STRING, state STRING, created_at STRING)"
run_query "ALTER TABLE ${DATABASE}.orders REPLACE COLUMNS (order_id INT, customer_id INT, order_date STRING, status STRING, total_amount DECIMAL(10,2))"
run_query "ALTER TABLE ${DATABASE}.payments REPLACE COLUMNS (payment_id INT, order_id INT, customer_id INT, payment_method STRING, payment_date STRING, amount DECIMAL(10,2), payment_status STRING, transaction_ref STRING)"

echo "Schema corrigido: colunas de data/hora em CSV ajustadas para STRING."