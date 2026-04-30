INSERT INTO clickhouse.reports.dim_customer
SELECT
    customer_key,
    min(source_customer_id),
    min(customer_first_name),
    min(customer_last_name),
    min(customer_age),
    min(customer_email),
    min(customer_country),
    min(customer_postal_code)
FROM clickhouse.reports.stage_unified_sales
GROUP BY customer_key;

INSERT INTO clickhouse.reports.dim_seller
SELECT
    seller_key,
    min(source_seller_id),
    min(seller_first_name),
    min(seller_last_name),
    min(seller_email),
    min(seller_country),
    min(seller_postal_code)
FROM clickhouse.reports.stage_unified_sales
GROUP BY seller_key;

INSERT INTO clickhouse.reports.dim_store
SELECT
    store_key,
    min(store_name),
    min(store_location),
    min(store_city),
    min(store_state),
    min(store_country),
    min(store_phone),
    min(store_email)
FROM clickhouse.reports.stage_unified_sales
GROUP BY store_key;

INSERT INTO clickhouse.reports.dim_supplier
SELECT
    supplier_key,
    min(supplier_name),
    min(supplier_contact),
    min(supplier_email),
    min(supplier_phone),
    min(supplier_address),
    min(supplier_city),
    min(supplier_country)
FROM clickhouse.reports.stage_unified_sales
GROUP BY supplier_key;

INSERT INTO clickhouse.reports.dim_pet
SELECT
    pet_key,
    min(customer_pet_name),
    min(customer_pet_type),
    min(customer_pet_breed),
    min(pet_category)
FROM clickhouse.reports.stage_unified_sales
GROUP BY pet_key;

INSERT INTO clickhouse.reports.dim_date
WITH all_dates AS (
    SELECT sale_date AS full_date FROM clickhouse.reports.stage_unified_sales
    UNION ALL
    SELECT product_release_date AS full_date FROM clickhouse.reports.stage_unified_sales
    UNION ALL
    SELECT product_expiry_date AS full_date FROM clickhouse.reports.stage_unified_sales
)
SELECT
    year(full_date) * 10000 + month(full_date) * 100 + day_of_month(full_date),
    full_date,
    year(full_date),
    quarter(full_date),
    month(full_date),
    day_of_month(full_date),
    day_of_week(full_date)
FROM (
    SELECT DISTINCT full_date
    FROM all_dates
    WHERE full_date IS NOT NULL
);

INSERT INTO clickhouse.reports.dim_product
SELECT
    product_key,
    min(source_product_id),
    min(product_name),
    min(product_category),
    min(product_brand),
    min(product_material),
    min(product_color),
    min(product_size),
    min(product_weight),
    min(product_description),
    min(product_rating),
    min(product_reviews),
    min(year(product_release_date) * 10000 + month(product_release_date) * 100 + day_of_month(product_release_date)),
    min(year(product_expiry_date) * 10000 + month(product_expiry_date) * 100 + day_of_month(product_expiry_date))
FROM clickhouse.reports.stage_unified_sales
GROUP BY product_key;

INSERT INTO clickhouse.reports.fact_sales
SELECT
    sale_event_key,
    source_system,
    source_file,
    source_id,
    customer_key,
    seller_key,
    product_key,
    pet_key,
    store_key,
    supplier_key,
    year(sale_date) * 10000 + month(sale_date) * 100 + day_of_month(sale_date),
    sale_quantity,
    sale_total_price,
    calculated_total_amount,
    is_total_consistent
FROM clickhouse.reports.stage_unified_sales;
