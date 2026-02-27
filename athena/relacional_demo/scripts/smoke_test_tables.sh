#!/usr/bin/env bash
set -euo pipefail

WORKGROUP="${WORKGROUP:-primary}"
DATABASE="${DATABASE:-db_conceito_relacional}"
RESULT_S3="${RESULT_S3:-s3://teste-conceito-trabalho/athena/query-results/}"

run_test() {
  local table_name="$1"
  local query="SELECT * FROM ${DATABASE}.${table_name} LIMIT 5"

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
      echo "[OK] ${table_name} (QueryExecutionId=${qid})"
      AWS_PAGER="" aws athena get-query-results --query-execution-id "$qid" --max-items 10 --output text >/dev/null
      break
    elif [[ "$state" == "FAILED" || "$state" == "CANCELLED" ]]; then
      local reason
      reason=$(AWS_PAGER="" aws athena get-query-execution \
        --query-execution-id "$qid" \
        --query 'QueryExecution.Status.StateChangeReason' \
        --output text)
      echo "[ERROR] ${table_name} (QueryExecutionId=${qid})"
      echo "        ${reason}"
      return 1
    fi

    sleep 2
  done
}

failed=0
for t in customers products orders order_items payments; do
  if ! run_test "$t"; then
    failed=1
  fi
done

if [[ "$failed" -eq 1 ]]; then
  echo "Smoke test finalizado com erros."
  exit 1
fi

echo "Smoke test finalizado sem erros."