CREATE DATABASE IF NOT EXISTS db_conceito_relacional;

CREATE EXTERNAL TABLE IF NOT EXISTS db_conceito_relacional.customers (
  customer_id INT,
  cpf STRING,
  full_name STRING,
  email STRING,
  city STRING,
  state STRING,
  created_at STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  'separatorChar' = ',',
  'quoteChar' = '"',
  'escapeChar' = '\\'
)
STORED AS TEXTFILE
LOCATION 's3://teste-conceito-trabalho/athena/relacional_demo/data/customers/'
TBLPROPERTIES ('skip.header.line.count'='1');

CREATE EXTERNAL TABLE IF NOT EXISTS db_conceito_relacional.products (
  product_id INT,
  product_name STRING,
  category STRING,
  unit_price DECIMAL(10,2)
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  'separatorChar' = ',',
  'quoteChar' = '"',
  'escapeChar' = '\\'
)
STORED AS TEXTFILE
LOCATION 's3://teste-conceito-trabalho/athena/relacional_demo/data/products/'
TBLPROPERTIES ('skip.header.line.count'='1');

CREATE EXTERNAL TABLE IF NOT EXISTS db_conceito_relacional.orders (
  order_id INT,
  customer_id INT,
  order_date STRING,
  status STRING,
  total_amount DECIMAL(10,2)
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  'separatorChar' = ',',
  'quoteChar' = '"',
  'escapeChar' = '\\'
)
STORED AS TEXTFILE
LOCATION 's3://teste-conceito-trabalho/athena/relacional_demo/data/orders/'
TBLPROPERTIES ('skip.header.line.count'='1');

CREATE EXTERNAL TABLE IF NOT EXISTS db_conceito_relacional.order_items (
  order_item_id INT,
  order_id INT,
  product_id INT,
  quantity INT,
  unit_price DECIMAL(10,2),
  line_total DECIMAL(10,2)
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  'separatorChar' = ',',
  'quoteChar' = '"',
  'escapeChar' = '\\'
)
STORED AS TEXTFILE
LOCATION 's3://teste-conceito-trabalho/athena/relacional_demo/data/order_items/'
TBLPROPERTIES ('skip.header.line.count'='1');

CREATE EXTERNAL TABLE IF NOT EXISTS db_conceito_relacional.payments (
  payment_id INT,
  order_id INT,
  customer_id INT,
  payment_method STRING,
  payment_date STRING,
  amount DECIMAL(10,2),
  payment_status STRING,
  transaction_ref STRING,
  boleto_barcode STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  'separatorChar' = ',',
  'quoteChar' = '"',
  'escapeChar' = '\\'
)
STORED AS TEXTFILE
LOCATION 's3://teste-conceito-trabalho/athena/relacional_demo/data/payments/'
TBLPROPERTIES ('skip.header.line.count'='1');

CREATE OR REPLACE VIEW db_conceito_relacional.vw_orders_customer_payment AS
SELECT
  o.order_id,
  o.order_date,
  o.status AS order_status,
  o.total_amount,
  c.customer_id,
  c.full_name,
  c.cpf,
  p.payment_id,
  p.payment_method,
  p.boleto_barcode,
  p.payment_status,
  p.amount AS payment_amount
FROM db_conceito_relacional.orders o
JOIN db_conceito_relacional.customers c ON o.customer_id = c.customer_id
LEFT JOIN db_conceito_relacional.payments p ON o.order_id = p.order_id;