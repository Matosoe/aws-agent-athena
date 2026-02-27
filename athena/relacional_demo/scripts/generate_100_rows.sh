#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DATA_DIR="$BASE_DIR/data"

mkdir -p "$DATA_DIR"

echo "customer_id,cpf,full_name,email,city,state,created_at" > "$DATA_DIR/customers.csv"
for i in $(seq 1 100); do
  cpf=$(printf "%011d" $((10000000000 + i)))
  city="Cidade$(( (i - 1) % 20 + 1 ))"
  state=$(printf "S%01d" $(( (i - 1) % 9 + 1 )))
  day=$(printf "%02d" $(( (i - 1) % 28 + 1 )))
  hour=$(printf "%02d" $(( (i - 1) % 24 )))
  min=$(printf "%02d" $(( (i * 3) % 60 )))
  printf "%d,%s,Cliente %03d,cliente%03d@email.com,%s,%s,2025-01-%s %s:%s:00\n" \
    "$i" "$cpf" "$i" "$i" "$city" "$state" "$day" "$hour" "$min" >> "$DATA_DIR/customers.csv"
done

echo "product_id,product_name,category,unit_price" > "$DATA_DIR/products.csv"
for i in $(seq 1 100); do
  product_id=$((1000 + i))
  category="Categoria$(( (i - 1) % 10 + 1 ))"
  unit_price=$((50 + (i * 7)))
  printf "%d,Produto %03d,%s,%d.00\n" "$product_id" "$i" "$category" "$unit_price" >> "$DATA_DIR/products.csv"
done

echo "order_id,customer_id,order_date,status,total_amount" > "$DATA_DIR/orders.csv"
for i in $(seq 1 100); do
  order_id=$((1000 + i))
  customer_id=$i
  day=$(printf "%02d" $(( (i - 1) % 28 + 1 )))
  hour=$(printf "%02d" $(( (8 + i) % 24 )))
  status_idx=$((i % 4))
  if [[ $status_idx -eq 0 ]]; then
    status="PAID"
  elif [[ $status_idx -eq 1 ]]; then
    status="PENDING"
  elif [[ $status_idx -eq 2 ]]; then
    status="PARTIALLY_PAID"
  else
    status="FAILED"
  fi

  q1=$(( (i % 3) + 1 ))
  u1=$((50 + (i * 7)))
  total=$((q1 * u1))

  printf "%d,%d,2025-04-%s %s:00:00,%s,%d.00\n" "$order_id" "$customer_id" "$day" "$hour" "$status" "$total" >> "$DATA_DIR/orders.csv"
done

echo "order_item_id,order_id,product_id,quantity,unit_price,line_total" > "$DATA_DIR/order_items.csv"
item_id=1
for i in $(seq 1 100); do
  order_id=$((1000 + i))

  p1=$((1000 + i))
  q1=$(( (i % 3) + 1 ))
  u1=$((50 + (i * 7)))
  l1=$((q1 * u1))
  printf "%d,%d,%d,%d,%d.00,%d.00\n" "$item_id" "$order_id" "$p1" "$q1" "$u1" "$l1" >> "$DATA_DIR/order_items.csv"
  item_id=$((item_id + 1))
done

echo "payment_id,order_id,customer_id,payment_method,payment_date,amount,payment_status,transaction_ref,boleto_barcode" > "$DATA_DIR/payments.csv"
for i in $(seq 1 100); do
  payment_id=$((9000 + i))
  order_id=$((1000 + i))
  customer_id=$i
  day=$(printf "%02d" $(( (i - 1) % 28 + 1 )))
  hour=$(printf "%02d" $(( (10 + i) % 24 )))
  min=$(printf "%02d" $(( (i * 2) % 60 )))

  q1=$(( (i % 3) + 1 ))
  u1=$((50 + (i * 7)))
  total=$((q1 * u1))

  method="BOLETO"

  banco="341"
  moeda="9"
  dv_geral="1"
  fator_vencimento=$(printf "%04d" $((1000 + i)))
  valor_centavos=$(printf "%010d" $((total * 100)))
  campo_livre=$(printf "%025d" "$order_id$payment_id")
  boleto_barcode="${banco}${moeda}${dv_geral}${fator_vencimento}${valor_centavos}${campo_livre}"

  status_idx=$((i % 4))
  if [[ $status_idx -eq 0 ]]; then
    pay_status="CONFIRMED"
    amount="$total.00"
  elif [[ $status_idx -eq 1 ]]; then
    pay_status="PENDING"
    amount="0.00"
  elif [[ $status_idx -eq 2 ]]; then
    pay_status="PARTIAL"
    partial=$(( total / 2 ))
    amount="$partial.00"
  else
    pay_status="FAILED"
    amount="0.00"
  fi

  printf "%d,%d,%d,%s,2025-04-%s %s:%s:00,%s,%s,TXN-%d,%s\n" \
    "$payment_id" "$order_id" "$customer_id" "$method" "$day" "$hour" "$min" "$amount" "$pay_status" "$order_id" "$boleto_barcode" >> "$DATA_DIR/payments.csv"
done

echo "Arquivos gerados em: $DATA_DIR"