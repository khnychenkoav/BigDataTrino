CREATE DATABASE IF NOT EXISTS reports;

DROP TABLE IF EXISTS reports.report_product_quality;
DROP TABLE IF EXISTS reports.report_sales_by_supplier;
DROP TABLE IF EXISTS reports.report_sales_by_store;
DROP TABLE IF EXISTS reports.report_sales_by_time;
DROP TABLE IF EXISTS reports.report_sales_by_customer;
DROP TABLE IF EXISTS reports.report_sales_by_product;
DROP TABLE IF EXISTS reports.fact_sales;
DROP TABLE IF EXISTS reports.dim_date;
DROP TABLE IF EXISTS reports.dim_pet;
DROP TABLE IF EXISTS reports.dim_product;
DROP TABLE IF EXISTS reports.dim_supplier;
DROP TABLE IF EXISTS reports.dim_store;
DROP TABLE IF EXISTS reports.dim_seller;
DROP TABLE IF EXISTS reports.dim_customer;
DROP TABLE IF EXISTS reports.stage_unified_sales;
DROP TABLE IF EXISTS reports.stage_mock_data_raw;

CREATE TABLE reports.stage_mock_data_raw (
    source_file String DEFAULT 'unknown',
    id String,
    customer_first_name String,
    customer_last_name String,
    customer_age String,
    customer_email String,
    customer_country String,
    customer_postal_code String,
    customer_pet_type String,
    customer_pet_name String,
    customer_pet_breed String,
    seller_first_name String,
    seller_last_name String,
    seller_email String,
    seller_country String,
    seller_postal_code String,
    product_name String,
    product_category String,
    product_price String,
    product_quantity String,
    sale_date String,
    sale_customer_id String,
    sale_seller_id String,
    sale_product_id String,
    sale_quantity String,
    sale_total_price String,
    store_name String,
    store_location String,
    store_city String,
    store_state String,
    store_country String,
    store_phone String,
    store_email String,
    pet_category String,
    product_weight String,
    product_color String,
    product_size String,
    product_brand String,
    product_material String,
    product_description String,
    product_rating String,
    product_reviews String,
    product_release_date String,
    product_expiry_date String,
    supplier_name String,
    supplier_contact String,
    supplier_email String,
    supplier_phone String,
    supplier_address String,
    supplier_city String,
    supplier_country String
) ENGINE = MergeTree
ORDER BY (source_file, id);

CREATE TABLE reports.stage_unified_sales (
    source_system String,
    source_file String,
    sale_event_key String,
    source_id Int32,
    customer_key String,
    source_customer_id Int32,
    customer_first_name String,
    customer_last_name String,
    customer_age Int32,
    customer_email String,
    customer_country String,
    customer_postal_code String,
    pet_key String,
    customer_pet_type String,
    customer_pet_name String,
    customer_pet_breed String,
    pet_category String,
    seller_key String,
    source_seller_id Int32,
    seller_first_name String,
    seller_last_name String,
    seller_email String,
    seller_country String,
    seller_postal_code String,
    product_key String,
    source_product_id Int32,
    product_name String,
    product_category String,
    product_price Decimal(14, 2),
    product_quantity Int32,
    product_weight Decimal(12, 2),
    product_color String,
    product_size String,
    product_brand String,
    product_material String,
    product_description String,
    product_rating Float64,
    product_reviews Int32,
    product_release_date Date,
    product_expiry_date Date,
    sale_date Date,
    sale_quantity Int32,
    sale_total_price Decimal(14, 2),
    calculated_total_amount Decimal(14, 2),
    is_total_consistent Int32,
    store_key String,
    store_name String,
    store_location String,
    store_city String,
    store_state String,
    store_country String,
    store_phone String,
    store_email String,
    supplier_key String,
    supplier_name String,
    supplier_contact String,
    supplier_email String,
    supplier_phone String,
    supplier_address String,
    supplier_city String,
    supplier_country String
) ENGINE = MergeTree
ORDER BY (source_system, source_file, source_id);

CREATE TABLE reports.dim_customer (
    customer_key String,
    source_customer_id Int32,
    first_name String,
    last_name String,
    age Int32,
    email String,
    country String,
    postal_code String
) ENGINE = MergeTree
ORDER BY customer_key;

CREATE TABLE reports.dim_seller (
    seller_key String,
    source_seller_id Int32,
    first_name String,
    last_name String,
    email String,
    country String,
    postal_code String
) ENGINE = MergeTree
ORDER BY seller_key;

CREATE TABLE reports.dim_store (
    store_key String,
    store_name String,
    store_location String,
    city String,
    state String,
    country String,
    phone String,
    email String
) ENGINE = MergeTree
ORDER BY store_key;

CREATE TABLE reports.dim_supplier (
    supplier_key String,
    supplier_name String,
    contact_name String,
    email String,
    phone String,
    address String,
    city String,
    country String
) ENGINE = MergeTree
ORDER BY supplier_key;

CREATE TABLE reports.dim_product (
    product_key String,
    source_product_id Int32,
    product_name String,
    product_category String,
    product_brand String,
    product_material String,
    product_color String,
    product_size String,
    product_weight Decimal(12, 2),
    product_description String,
    product_rating Float64,
    product_reviews Int32,
    release_date_key Int32,
    expiry_date_key Int32
) ENGINE = MergeTree
ORDER BY product_key;

CREATE TABLE reports.dim_pet (
    pet_key String,
    pet_name String,
    pet_type String,
    pet_breed String,
    pet_category String
) ENGINE = MergeTree
ORDER BY pet_key;

CREATE TABLE reports.dim_date (
    date_key Int32,
    full_date Date,
    year Int32,
    quarter Int32,
    month Int32,
    day_of_month Int32,
    day_of_week Int32
) ENGINE = MergeTree
ORDER BY date_key;

CREATE TABLE reports.fact_sales (
    sale_event_key String,
    source_system String,
    source_file String,
    source_id Int32,
    customer_key String,
    seller_key String,
    product_key String,
    pet_key String,
    store_key String,
    supplier_key String,
    sale_date_key Int32,
    sale_quantity Int32,
    sale_total_price Decimal(14, 2),
    calculated_total_amount Decimal(14, 2),
    is_total_consistent Int32
) ENGINE = MergeTree
ORDER BY sale_event_key;

CREATE TABLE reports.report_sales_by_product (
    report_row_id Int64,
    product_key String,
    product_name String,
    product_category String,
    product_brand String,
    sales_count Int64,
    total_units_sold Int64,
    source_revenue Decimal(18, 2),
    calculated_revenue Decimal(18, 2),
    revenue_delta Decimal(18, 2),
    avg_unit_price Float64,
    product_rating Float64,
    product_reviews Int32,
    category_source_revenue Decimal(18, 2),
    product_units_rank Int64,
    is_top_10_by_units Int32
) ENGINE = MergeTree
ORDER BY report_row_id;

CREATE TABLE reports.report_sales_by_customer (
    report_row_id Int64,
    customer_key String,
    customer_email String,
    customer_name String,
    customer_country String,
    sales_count Int64,
    total_units_bought Int64,
    source_revenue Decimal(18, 2),
    calculated_revenue Decimal(18, 2),
    avg_check Float64,
    customer_revenue_rank Int64,
    is_top_10_by_revenue Int32,
    country_customer_count Int64
) ENGINE = MergeTree
ORDER BY report_row_id;

CREATE TABLE reports.report_sales_by_time (
    report_row_id Int64,
    sales_year Int32,
    sales_month Int32,
    period_start Date,
    sales_count Int64,
    total_units_sold Int64,
    source_revenue Decimal(18, 2),
    calculated_revenue Decimal(18, 2),
    avg_order_amount Float64,
    prev_month_source_revenue Decimal(18, 2),
    source_revenue_delta Decimal(18, 2)
) ENGINE = MergeTree
ORDER BY report_row_id;

CREATE TABLE reports.report_sales_by_store (
    report_row_id Int64,
    store_key String,
    store_name String,
    store_city String,
    store_country String,
    sales_count Int64,
    total_units_sold Int64,
    source_revenue Decimal(18, 2),
    calculated_revenue Decimal(18, 2),
    avg_check Float64,
    store_revenue_rank Int64,
    is_top_5_by_revenue Int32,
    city_source_revenue Decimal(18, 2),
    country_source_revenue Decimal(18, 2)
) ENGINE = MergeTree
ORDER BY report_row_id;

CREATE TABLE reports.report_sales_by_supplier (
    report_row_id Int64,
    supplier_key String,
    supplier_name String,
    supplier_city String,
    supplier_country String,
    sales_count Int64,
    total_units_sold Int64,
    source_revenue Decimal(18, 2),
    calculated_revenue Decimal(18, 2),
    avg_product_unit_price Float64,
    supplier_revenue_rank Int64,
    is_top_5_by_revenue Int32,
    country_source_revenue Decimal(18, 2)
) ENGINE = MergeTree
ORDER BY report_row_id;

CREATE TABLE reports.report_product_quality (
    report_row_id Int64,
    product_key String,
    product_name String,
    product_category String,
    product_rating Float64,
    product_reviews Int32,
    total_units_sold Int64,
    source_revenue Decimal(18, 2),
    rating_sales_correlation Float64,
    best_rating_rank Int64,
    worst_rating_rank Int64,
    reviews_rank Int64,
    is_top_10_by_reviews Int32,
    is_top_10_by_rating Int32,
    is_bottom_10_by_rating Int32
) ENGINE = MergeTree
ORDER BY report_row_id;
