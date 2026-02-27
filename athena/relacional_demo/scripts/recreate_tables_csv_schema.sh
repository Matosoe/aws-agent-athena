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

run_query "DROP VIEW IF EXISTS ${DATABASE}.vw_orders_customer_payment"

run_query "DROP TABLE IF EXISTS ${DATABASE}.customers"
run_query "CREATE EXTERNAL TABLE IF NOT EXISTS ${DATABASE}.customers (customer_id INT, cpf STRING, full_name STRING, email STRING, city STRING, state STRING, created_at STRING) ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde' WITH SERDEPROPERTIES ('separatorChar'=',','quoteChar'='\"','escapeChar'='\\\\') STORED AS TEXTFILE LOCATION 's3://teste-conceito-trabalho/athena/relacional_demo/data/customers/' TBLPROPERTIES ('skip.header.line.count'='1')"

run_query "DROP TABLE IF EXISTS ${DATABASE}.orders"
run_query "CREATE EXTERNAL TABLE IF NOT EXISTS ${DATABASE}.orders (order_id INT, customer_id INT, order_date STRING, status STRING, total_amount DECIMAL(10,2)) ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde' WITH SERDEPROPERTIES ('separatorChar'=',','quoteChar'='\"','escapeChar'='\\\\') STORED AS TEXTFILE LOCATION 's3://teste-conceito-trabalho/athena/relacional_demo/data/orders/' TBLPROPERTIES ('skip.header.line.count'='1')"

run_query "DROP TABLE IF EXISTS ${DATABASE}.payments"
run_query "CREATE EXTERNAL TABLE IF NOT EXISTS ${DATABASE}.payments (payment_id INT, order_id INT, customer_id INT, payment_method STRING, payment_date STRING, amount DECIMAL(10,2), payment_status STRING, transaction_ref STRING, boleto_barcode STRING) ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde' WITH SERDEPROPERTIES ('separatorChar'=',','quoteChar'='\"','escapeChar'='\\\\') STORED AS TEXTFILE LOCATION 's3://teste-conceito-trabalho/athena/relacional_demo/data/payments/' TBLPROPERTIES ('skip.header.line.count'='1')"

run_query "CREATE OR REPLACE VIEW ${DATABASE}.vw_orders_customer_payment AS SELECT o.order_id, o.order_date, o.status AS order_status, o.total_amount, c.customer_id, c.full_name, c.cpf, p.payment_id, p.payment_method, p.boleto_barcode, p.payment_status, p.amount AS payment_amount FROM ${DATABASE}.orders o JOIN ${DATABASE}.customers c ON o.customer_id = c.customer_id LEFT JOIN ${DATABASE}.payments p ON o.order_id = p.order_id"

echo "Recriação concluída com schema compatível para CSV."