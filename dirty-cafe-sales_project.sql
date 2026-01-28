-- 1. overview the dataset.

SELECT *
FROM `cafe_project.raw_cafe_sales`;
LIMIT 50

SELECT *
FROM `cafe_project.menu`;

-- 2. look for missing/duplicate value
SELECT COUNT(DISTINCT transaction_id) AS count_id
FROM `cafe_project.raw_cafe_sales` -- no missing/duplicate value on transaction_id (10001)

SELECT DISTINCT item AS unique_item
FROM `cafe_project.raw_cafe_sales` -- there are missing value in item and some value that are not on the menu (ERROR, UNKNOWN, and Item)

SELECT DISTINCT quantity AS unique_q
FROM `cafe_project.raw_cafe_sales` -- there are missing value in quantity and some value that are not a number (ERROR, UNKNOWN, and Quantity)

SELECT DISTINCT price_per_unit AS unique_price
FROM `cafe_project.raw_cafe_sales` -- there are missing value in price_per_unit and some value that are not a number (ERROR, UNKNOWN, and Price Per Unit)

SELECT DISTINCT total_spent AS unique_total
FROM `cafe_project.raw_cafe_sales` -- there are missing value in total_spent and some value that are not a number (ERROR, UNKNOWN, and Total Spent)

SELECT DISTINCT payment_method AS unique_payment
FROM `cafe_project.raw_cafe_sales` -- there are missing value in payment_method and some value that are not Cash, Credit Card, and Digital Wallet (ERROR, UNKNOWN, and Payment Method)

SELECT DISTINCT location AS unique_location
FROM `cafe_project.raw_cafe_sales` -- there are missing value in price_per_unit and some value that are not In-store and Takeaway (ERROR, UNKNOWN, and Price Per Unit)

SELECT DISTINCT(transaction_date) AS count_date
FROM `cafe_project.raw_cafe_sales` -- there are missing value in transaction_date and some value that are not a date (ERROR, UNKNOWN, and Transaction Date)

-- 3. fix the data type and delete rows that missing some value (by create new table)
CREATE OR REPLACE TABLE cafe_project.raw_cafe_sales2 AS
SELECT
  UPPER(TRIM(transaction_id)) AS transaction_id2, -- transaction_id
  CASE -- item
    WHEN item IS NULL OR UPPER(TRIM(item)) IN ('ERROR', 'UNKNOWN', 'ITEM', '') THEN 'Unknown'
    WHEN UPPER(TRIM(item)) = 'SMOOTHIE' THEN 'Sandwich'
    WHEN UPPER(TRIM(item)) = 'JUICE' THEN 'Cake'
    ELSE INITCAP(TRIM(item))
  END AS item2,
  CASE -- quantity
    WHEN UPPER(TRIM(quantity)) IN ('ERROR', 'UNKNOWN', 'QUANTITY', '') THEN NULL
    ELSE SAFE_CAST(quantity AS INT64)
  END AS quantity2,
  CASE -- price_per_unit
    WHEN UPPER(TRIM(price_per_unit)) IN ('ERROR', 'UNKNOWN', 'PRICE PER UNIT', '') THEN NULL
    ELSE SAFE_CAST(price_per_unit AS FLOAT64)
  END AS price_per_unit2,
  CASE -- total_spent
    WHEN UPPER(TRIM(total_spent)) IN ('ERROR', 'UNKNOWN', 'TOTAL SPENT', '') THEN NULL
    ELSE SAFE_CAST(total_spent AS FLOAT64)
  END AS total_spent2,
  CASE -- payment_method
    WHEN payment_method IS NULL OR UPPER(TRIM(payment_method)) IN ('ERROR', 'UNKNOWN', 'PAYMENT METHOD', '') THEN 'Unknown'
    ELSE INITCAP(TRIM(payment_method))
  END AS payment_method2,
  CASE -- location
    WHEN location IS NULL OR UPPER(TRIM(location)) IN ('ERROR', 'UNKNOWN', 'LOCATION', '') THEN 'Unknown'
    ELSE INITCAP(TRIM(location))
  END AS location2,
  CASE -- transaction_date
    WHEN UPPER(TRIM(transaction_date)) IN ('ERROR', 'UNKNOWN', 'TRANSACTION DATE', '') THEN NULL
    ELSE SAFE_CAST(transaction_date AS DATE)
  END AS transaction_date2
FROM `cafe_project.raw_cafe_sales`
WHERE UPPER(TRIM(transaction_date)) NOT IN ('ERROR', 'UNKNOWN', 'TRANSACTION DATE', '');

-- 4. overview the new table (raw_cafe_sales2)
SELECT *
FROM `cafe_project.raw_cafe_sales2`;

-- 5. fix the Unknown and null values and create a new table with the cleaned query
CREATE OR REPLACE TABLE `cafe_project.cafe_sales` AS
WITH clean_cafe1 AS ( -- first filter (item)
  SELECT *,
    COALESCE(
      m1.item,
      m2.item,
      item2
    ) cleaned_item -- item cleaned
  FROM `cafe_project.raw_cafe_sales2` r2
  LEFT JOIN `cafe_project.menu` m1 ON r2.price_per_unit2 = m1.price
  LEFT JOIN `cafe_project.menu` m2 ON SAFE_DIVIDE(r2.total_spent2, r2.quantity2) = m2.price
),

clean_cafe2 AS ( -- second filter (quantity)
  SELECT *,
    COALESCE(
      CAST(SAFE_DIVIDE(total_spent2, price_per_unit2) AS INT64),
      quantity2
    ) cleaned_quantity -- first quantity filter
  FROM clean_cafe1
),

clean_cafe3 AS ( -- third filter (price)
  SELECT *,
    COALESCE(
      m1.price,
      m2.price,
      price_per_unit2
    ) cleaned_price -- price cleaned
  FROM clean_cafe2 c2 
  LEFT JOIN `cafe_project.menu` m1 ON c2.cleaned_item = m1.item
  LEFT JOIN `cafe_project.menu` m2 ON SAFE_DIVIDE(c2.total_spent2, c2.cleaned_quantity) = m2.price
),

clean_cafe4 AS ( -- fourth filter (total)
  SELECT *,
    COALESCE(
      SAFE_MULTIPLY(cleaned_price, cleaned_quantity),
      total_spent2
    ) cleaned_total -- cleaned total
  FROM clean_cafe3
),

clean_cafe5 AS ( -- fifth filter (quantity)
  SELECT *,
    COALESCE(
      CAST(SAFE_DIVIDE(cleaned_total, cleaned_price) AS INT64),
      cleaned_quantity
    ) cleaned_quantity2 -- quantity cleaned
  FROM clean_cafe4
)
 
SELECT 
  transaction_id2 transaction_id,
  cleaned_item item,
  cleaned_quantity2 quantity,
  cleaned_price price,
  cleaned_total total,
  payment_method2 payment_method,
  location2 location,
  transaction_date2 transaction_date,
  CASE
    WHEN EXTRACT(MONTH FROM transaction_date2) = 1 THEN 'January'
    WHEN EXTRACT(MONTH FROM transaction_date2) = 2 THEN 'February'
    WHEN EXTRACT(MONTH FROM transaction_date2) = 3 THEN 'March'
    WHEN EXTRACT(MONTH FROM transaction_date2) = 4 THEN 'April'
    WHEN EXTRACT(MONTH FROM transaction_date2) = 5 THEN 'May'
    WHEN EXTRACT(MONTH FROM transaction_date2) = 6 THEN 'June'
    WHEN EXTRACT(MONTH FROM transaction_date2) = 7 THEN 'July'
    WHEN EXTRACT(MONTH FROM transaction_date2) = 8 THEN 'August'
    WHEN EXTRACT(MONTH FROM transaction_date2) = 9 THEN 'September'
    WHEN EXTRACT(MONTH FROM transaction_date2) = 10 THEN 'October'
    WHEN EXTRACT(MONTH FROM transaction_date2) = 11 THEN 'November'
    WHEN EXTRACT(MONTH FROM transaction_date2) = 12 THEN 'December'
  END AS month_name
FROM clean_cafe5
WHERE (cleaned_quantity2 IS NOT NULL AND cleaned_price IS NOT NULL) 
  OR (cleaned_quantity2 IS NOT NULL AND cleaned_total IS NOT NULL) 
  OR (cleaned_total IS NOT NULL AND cleaned_price IS NOT NULL);

-- 6. overview the cleaned cafe sales table
SELECT *
FROM `cafe_project.cafe_sales`;

-- 7. data validation process

SELECT * -- a. check null values on critical column
FROM `cafe_project.cafe_sales`
WHERE transaction_id IS NULL
   OR item IS NULL
   OR quantity IS NULL
   OR price IS NULL
   OR total IS NULL; -- 0 data

SELECT * -- b. check negative or zero values on critical column
FROM `cafe_project.cafe_sales`
WHERE quantity <= 0
   OR price <= 0
   OR total <= 0; -- 0 data

SELECT * -- c. check if total = quantity * price
FROM `cafe_project.cafe_sales`
WHERE ABS(total - (quantity * price)) > 0.01; -- 0 data

SELECT * -- d. check only the valid item on menu exist
FROM `cafe_project.cafe_sales`
WHERE item NOT IN ('Coffee', 'Tea', 'Cake', 'Cookie', 'Sandwich', 'Salad'); -- 0 data

SELECT * -- e. check only the valid payment method exist
FROM `cafe_project.cafe_sales`
WHERE payment_method NOT IN ('Cash', 'Credit Card', 'Digital Wallet', 'Unknown'); -- 0 data

SELECT * -- f. check if there are no future dates
FROM `cafe_project.cafe_sales`
WHERE transaction_date > CURRENT_DATE(); -- 0 data

SELECT transaction_id, COUNT(*) AS check_duplicates -- g. check duplicates transaction_id
FROM `cafe_project.cafe_sales`
GROUP BY transaction_id
HAVING COUNT(*) > 1; -- 0 data






