INSERT INTO clickhouse.reports.report_sales_by_product
WITH base AS (
    SELECT
        p.product_key,
        p.product_name,
        p.product_category,
        p.product_brand,
        count(*) AS sales_count,
        sum(f.sale_quantity) AS total_units_sold,
        sum(f.sale_total_price) AS source_revenue,
        sum(f.calculated_total_amount) AS calculated_revenue,
        avg(CAST(f.calculated_total_amount AS double) / f.sale_quantity) AS avg_unit_price,
        min(p.product_rating) AS product_rating,
        min(p.product_reviews) AS product_reviews
    FROM clickhouse.reports.fact_sales f
    JOIN clickhouse.reports.dim_product p ON f.product_key = p.product_key
    GROUP BY p.product_key, p.product_name, p.product_category, p.product_brand
),
ranked AS (
    SELECT
        base.*,
        sum(source_revenue) OVER (PARTITION BY product_category) AS category_source_revenue,
        row_number() OVER (ORDER BY total_units_sold DESC, product_name, product_key) AS product_units_rank
    FROM base
)
SELECT
    row_number() OVER (ORDER BY product_name, product_key),
    product_key,
    product_name,
    product_category,
    product_brand,
    sales_count,
    total_units_sold,
    source_revenue,
    calculated_revenue,
    source_revenue - calculated_revenue,
    avg_unit_price,
    product_rating,
    product_reviews,
    category_source_revenue,
    product_units_rank,
    CASE WHEN product_units_rank <= 10 THEN 1 ELSE 0 END
FROM ranked;

INSERT INTO clickhouse.reports.report_sales_by_customer
WITH base AS (
    SELECT
        c.customer_key,
        c.email AS customer_email,
        concat(c.first_name, ' ', c.last_name) AS customer_name,
        c.country AS customer_country,
        count(*) AS sales_count,
        sum(f.sale_quantity) AS total_units_bought,
        sum(f.sale_total_price) AS source_revenue,
        sum(f.calculated_total_amount) AS calculated_revenue,
        avg(CAST(f.sale_total_price AS double)) AS avg_check
    FROM clickhouse.reports.fact_sales f
    JOIN clickhouse.reports.dim_customer c ON f.customer_key = c.customer_key
    GROUP BY c.customer_key, c.email, c.first_name, c.last_name, c.country
),
ranked AS (
    SELECT
        base.*,
        row_number() OVER (ORDER BY source_revenue DESC, customer_email, customer_key) AS customer_revenue_rank,
        count(*) OVER (PARTITION BY customer_country) AS country_customer_count
    FROM base
)
SELECT
    row_number() OVER (ORDER BY customer_email, customer_key),
    customer_key,
    customer_email,
    customer_name,
    customer_country,
    sales_count,
    total_units_bought,
    source_revenue,
    calculated_revenue,
    avg_check,
    customer_revenue_rank,
    CASE WHEN customer_revenue_rank <= 10 THEN 1 ELSE 0 END,
    country_customer_count
FROM ranked;

INSERT INTO clickhouse.reports.report_sales_by_time
WITH base AS (
    SELECT
        year(d.full_date) AS sales_year,
        month(d.full_date) AS sales_month,
        date_trunc('month', d.full_date) AS period_start,
        count(*) AS sales_count,
        sum(f.sale_quantity) AS total_units_sold,
        sum(f.sale_total_price) AS source_revenue,
        sum(f.calculated_total_amount) AS calculated_revenue,
        avg(CAST(f.sale_total_price AS double)) AS avg_order_amount
    FROM clickhouse.reports.fact_sales f
    JOIN clickhouse.reports.dim_date d ON f.sale_date_key = d.date_key
    GROUP BY year(d.full_date), month(d.full_date), date_trunc('month', d.full_date)
),
ranked AS (
    SELECT
        base.*,
        lag(source_revenue, 1, CAST(0 AS decimal(18, 2))) OVER (ORDER BY period_start) AS prev_month_source_revenue
    FROM base
)
SELECT
    row_number() OVER (ORDER BY period_start),
    sales_year,
    sales_month,
    period_start,
    sales_count,
    total_units_sold,
    source_revenue,
    calculated_revenue,
    avg_order_amount,
    prev_month_source_revenue,
    source_revenue - prev_month_source_revenue
FROM ranked;

INSERT INTO clickhouse.reports.report_sales_by_store
WITH base AS (
    SELECT
        s.store_key,
        s.store_name,
        s.city AS store_city,
        s.country AS store_country,
        count(*) AS sales_count,
        sum(f.sale_quantity) AS total_units_sold,
        sum(f.sale_total_price) AS source_revenue,
        sum(f.calculated_total_amount) AS calculated_revenue,
        avg(CAST(f.sale_total_price AS double)) AS avg_check
    FROM clickhouse.reports.fact_sales f
    JOIN clickhouse.reports.dim_store s ON f.store_key = s.store_key
    GROUP BY s.store_key, s.store_name, s.city, s.country
),
ranked AS (
    SELECT
        base.*,
        row_number() OVER (ORDER BY source_revenue DESC, store_name, store_key) AS store_revenue_rank,
        sum(source_revenue) OVER (PARTITION BY store_city) AS city_source_revenue,
        sum(source_revenue) OVER (PARTITION BY store_country) AS country_source_revenue
    FROM base
)
SELECT
    row_number() OVER (ORDER BY store_name, store_key),
    store_key,
    store_name,
    store_city,
    store_country,
    sales_count,
    total_units_sold,
    source_revenue,
    calculated_revenue,
    avg_check,
    store_revenue_rank,
    CASE WHEN store_revenue_rank <= 5 THEN 1 ELSE 0 END,
    city_source_revenue,
    country_source_revenue
FROM ranked;

INSERT INTO clickhouse.reports.report_sales_by_supplier
WITH base AS (
    SELECT
        sup.supplier_key,
        sup.supplier_name,
        sup.city AS supplier_city,
        sup.country AS supplier_country,
        count(*) AS sales_count,
        sum(f.sale_quantity) AS total_units_sold,
        sum(f.sale_total_price) AS source_revenue,
        sum(f.calculated_total_amount) AS calculated_revenue,
        avg(CAST(f.calculated_total_amount AS double) / f.sale_quantity) AS avg_product_unit_price
    FROM clickhouse.reports.fact_sales f
    JOIN clickhouse.reports.dim_supplier sup ON f.supplier_key = sup.supplier_key
    JOIN clickhouse.reports.dim_product p ON f.product_key = p.product_key
    GROUP BY sup.supplier_key, sup.supplier_name, sup.city, sup.country
),
ranked AS (
    SELECT
        base.*,
        row_number() OVER (ORDER BY source_revenue DESC, supplier_name, supplier_key) AS supplier_revenue_rank,
        sum(source_revenue) OVER (PARTITION BY supplier_country) AS country_source_revenue
    FROM base
)
SELECT
    row_number() OVER (ORDER BY supplier_name, supplier_key),
    supplier_key,
    supplier_name,
    supplier_city,
    supplier_country,
    sales_count,
    total_units_sold,
    source_revenue,
    calculated_revenue,
    avg_product_unit_price,
    supplier_revenue_rank,
    CASE WHEN supplier_revenue_rank <= 5 THEN 1 ELSE 0 END,
    country_source_revenue
FROM ranked;

INSERT INTO clickhouse.reports.report_product_quality
WITH base AS (
    SELECT
        p.product_key,
        p.product_name,
        p.product_category,
        min(p.product_rating) AS product_rating,
        min(p.product_reviews) AS product_reviews,
        sum(f.sale_quantity) AS total_units_sold,
        sum(f.sale_total_price) AS source_revenue
    FROM clickhouse.reports.fact_sales f
    JOIN clickhouse.reports.dim_product p ON f.product_key = p.product_key
    GROUP BY p.product_key, p.product_name, p.product_category
),
ranked AS (
    SELECT
        base.*,
        corr(product_rating, CAST(total_units_sold AS double)) OVER () AS rating_sales_correlation,
        row_number() OVER (ORDER BY product_rating DESC, product_reviews DESC, product_name, product_key) AS best_rating_rank,
        row_number() OVER (ORDER BY product_rating ASC, product_reviews DESC, product_name, product_key) AS worst_rating_rank,
        row_number() OVER (ORDER BY product_reviews DESC, product_rating DESC, product_name, product_key) AS reviews_rank
    FROM base
)
SELECT
    row_number() OVER (ORDER BY product_name, product_key),
    product_key,
    product_name,
    product_category,
    product_rating,
    product_reviews,
    total_units_sold,
    source_revenue,
    rating_sales_correlation,
    best_rating_rank,
    worst_rating_rank,
    reviews_rank,
    CASE WHEN reviews_rank <= 10 THEN 1 ELSE 0 END,
    CASE WHEN best_rating_rank <= 10 THEN 1 ELSE 0 END,
    CASE WHEN worst_rating_rank <= 10 THEN 1 ELSE 0 END
FROM ranked;
