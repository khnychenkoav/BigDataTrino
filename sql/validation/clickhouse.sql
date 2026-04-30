SELECT
    object_name,
    rows_count
FROM (
    SELECT 'stage_clickhouse_raw' AS object_name, count() AS rows_count FROM reports.stage_mock_data_raw
    UNION ALL SELECT 'stage_unified_sales', count() FROM reports.stage_unified_sales
    UNION ALL SELECT 'dim_customer', count() FROM reports.dim_customer
    UNION ALL SELECT 'dim_seller', count() FROM reports.dim_seller
    UNION ALL SELECT 'dim_store', count() FROM reports.dim_store
    UNION ALL SELECT 'dim_supplier', count() FROM reports.dim_supplier
    UNION ALL SELECT 'dim_product', count() FROM reports.dim_product
    UNION ALL SELECT 'dim_pet', count() FROM reports.dim_pet
    UNION ALL SELECT 'fact_sales', count() FROM reports.fact_sales
    UNION ALL SELECT 'report_sales_by_product', count() FROM reports.report_sales_by_product
    UNION ALL SELECT 'report_sales_by_customer', count() FROM reports.report_sales_by_customer
    UNION ALL SELECT 'report_sales_by_time', count() FROM reports.report_sales_by_time
    UNION ALL SELECT 'report_sales_by_store', count() FROM reports.report_sales_by_store
    UNION ALL SELECT 'report_sales_by_supplier', count() FROM reports.report_sales_by_supplier
    UNION ALL SELECT 'report_product_quality', count() FROM reports.report_product_quality
)
ORDER BY object_name;

SELECT
    count() AS fact_rows,
    uniqExact(source_system) AS source_systems,
    uniqExact(source_file) AS source_files,
    sum(is_total_consistent) AS consistent_total_rows,
    count() - sum(is_total_consistent) AS inconsistent_total_rows,
    min(sale_total_price) AS min_source_total,
    max(sale_total_price) AS max_source_total,
    min(calculated_total_amount) AS min_calculated_total,
    max(calculated_total_amount) AS max_calculated_total
FROM reports.fact_sales;

SELECT
    source_system,
    source_file,
    count() AS rows_count
FROM reports.fact_sales
GROUP BY source_system, source_file
ORDER BY source_system, source_file;

SELECT
    'product_top_10' AS check_name,
    countIf(is_top_10_by_units = 1) AS marked_rows
FROM reports.report_sales_by_product
UNION ALL SELECT
    'customer_top_10',
    countIf(is_top_10_by_revenue = 1)
FROM reports.report_sales_by_customer
UNION ALL SELECT
    'store_top_5',
    countIf(is_top_5_by_revenue = 1)
FROM reports.report_sales_by_store
UNION ALL SELECT
    'supplier_top_5',
    countIf(is_top_5_by_revenue = 1)
FROM reports.report_sales_by_supplier
UNION ALL SELECT
    'quality_top_reviews',
    countIf(is_top_10_by_reviews = 1)
FROM reports.report_product_quality;
