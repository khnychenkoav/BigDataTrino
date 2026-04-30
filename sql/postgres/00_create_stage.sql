CREATE SCHEMA IF NOT EXISTS stage;

DROP TABLE IF EXISTS stage.mock_data_raw CASCADE;

CREATE TABLE stage.mock_data_raw (
    raw_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_file text NOT NULL DEFAULT 'unknown',
    id text,
    customer_first_name text,
    customer_last_name text,
    customer_age text,
    customer_email text,
    customer_country text,
    customer_postal_code text,
    customer_pet_type text,
    customer_pet_name text,
    customer_pet_breed text,
    seller_first_name text,
    seller_last_name text,
    seller_email text,
    seller_country text,
    seller_postal_code text,
    product_name text,
    product_category text,
    product_price text,
    product_quantity text,
    sale_date text,
    sale_customer_id text,
    sale_seller_id text,
    sale_product_id text,
    sale_quantity text,
    sale_total_price text,
    store_name text,
    store_location text,
    store_city text,
    store_state text,
    store_country text,
    store_phone text,
    store_email text,
    pet_category text,
    product_weight text,
    product_color text,
    product_size text,
    product_brand text,
    product_material text,
    product_description text,
    product_rating text,
    product_reviews text,
    product_release_date text,
    product_expiry_date text,
    supplier_name text,
    supplier_contact text,
    supplier_email text,
    supplier_phone text,
    supplier_address text,
    supplier_city text,
    supplier_country text
);

DO $$
DECLARE
    file_name text;
    files text[] := ARRAY[
        'MOCK_DATA (5).csv',
        'MOCK_DATA (6).csv',
        'MOCK_DATA (7).csv',
        'MOCK_DATA (8).csv',
        'MOCK_DATA (9).csv'
    ];
BEGIN
    FOREACH file_name IN ARRAY files LOOP
        EXECUTE format('ALTER TABLE stage.mock_data_raw ALTER COLUMN source_file SET DEFAULT %L', file_name);
        EXECUTE format($copy$
            COPY stage.mock_data_raw (
                id, customer_first_name, customer_last_name, customer_age, customer_email, customer_country,
                customer_postal_code, customer_pet_type, customer_pet_name, customer_pet_breed,
                seller_first_name, seller_last_name, seller_email, seller_country, seller_postal_code,
                product_name, product_category, product_price, product_quantity, sale_date, sale_customer_id,
                sale_seller_id, sale_product_id, sale_quantity, sale_total_price, store_name, store_location,
                store_city, store_state, store_country, store_phone, store_email, pet_category, product_weight,
                product_color, product_size, product_brand, product_material, product_description,
                product_rating, product_reviews, product_release_date, product_expiry_date, supplier_name,
                supplier_contact, supplier_email, supplier_phone, supplier_address, supplier_city, supplier_country
            )
            FROM %L WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
        $copy$, '/data/' || file_name);
    END LOOP;
END $$;

ALTER TABLE stage.mock_data_raw ALTER COLUMN source_file SET DEFAULT 'unknown';

CREATE INDEX ix_mock_data_raw_source_file ON stage.mock_data_raw (source_file);
CREATE INDEX ix_mock_data_raw_source_ids ON stage.mock_data_raw (source_file, id, sale_customer_id, sale_seller_id, sale_product_id);

ANALYZE stage.mock_data_raw;
