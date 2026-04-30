# Решение лабораторной работы №4

## Что сделано

В работе собран воспроизводимый ETL-контур на PostgreSQL, ClickHouse и Trino. Первые пять CSV-файлов загружаются в ClickHouse, следующие пять CSV-файлов загружаются в PostgreSQL, после чего Trino объединяет оба источника и перекладывает данные в аналитическую модель звезда в ClickHouse

Финальная модель и все отчетные таблицы находятся в ClickHouse. Trino используется как единая SQL-точка обработки: он читает PostgreSQL и ClickHouse через каталоги, типизирует сырые строки, строит ключи измерений, факт продаж и шесть витрин для анализа

## Запуск

Полный запуск выполняется командой .\scripts\run_all.ps1

Скрипт поднимает PostgreSQL, ClickHouse и Trino, загружает 5000 строк в PostgreSQL, загружает 5000 строк в ClickHouse, выполняет Trino SQL для построения модели и создает все отчеты

Если нужно пересоздать окружение полностью, можно выполнить:

docker compose down -v
.\scripts\run_all.ps1

Проверка результата выполняется командой .\scripts\validate.ps1

## Подключения

PostgreSQL:

- Host localhost
- Port 5435
- Database trino_lab
- User lab
- Password lab

ClickHouse:

- HTTP port 8125
- Native port 9002
- Database reports
- User lab
- Password lab

Trino:

- Web UI http://localhost:8082
- Catalog postgresql для PostgreSQL
- Catalog clickhouse для ClickHouse

## Как устроен ETL

PostgreSQL при старте контейнера создает схему stage и таблицу stage.mock_data_raw, после чего загружает файлы MOCK_DATA (5).csv, MOCK_DATA (6).csv, MOCK_DATA (7).csv, MOCK_DATA (8).csv и MOCK_DATA (9).csv

ClickHouse создается скриптом sql/clickhouse/00_create_all.sql. Он подготавливает сырую таблицу, промежуточную типизированную таблицу, измерения, факт и шесть отчетных таблиц. Загрузка ClickHouse-части выполняется сервисом clickhouse-loader, который импортирует MOCK_DATA.csv и файлы MOCK_DATA (1).csv - MOCK_DATA (4).csv

Trino выполняет три SQL-скрипта. Сначала sql/trino/01_load_unified_stage.sql объединяет PostgreSQL и ClickHouse, приводит типы, нормализует email, даты и числовые поля, рассчитывает ключи и контрольную сумму продажи. Затем sql/trino/02_build_star.sql строит измерения и факт. После этого sql/trino/03_build_reports.sql создает шесть витрин

## Модель данных

Зерно факта выбрано как одна строка исходного CSV, то есть одна продажа. Поля id, sale_customer_id, sale_seller_id и sale_product_id не используются как глобальные ключи, потому что повторяются в разных файлах. Для факта используется ключ из source_system, source_file и id, а для измерений используются устойчивые натуральные ключи или хеши от бизнес-атрибутов

В ClickHouse создаются измерения клиентов, продавцов, магазинов, поставщиков, продуктов и питомцев. Факт reports.fact_sales хранит ссылки на эти измерения, дату продажи, исходную сумму продажи, рассчитанную сумму product_price * sale_quantity и флаг качества is_total_consistent.

## Отчеты

В решении создаются шесть отдельных таблиц:

- reports.report_sales_by_product для анализа продаж по продуктам, категориям, рейтингу и топ-10 по количеству проданных единиц
- reports.report_sales_by_customer для анализа клиентов, стран, среднего чека и топ-10 покупателей по сумме покупок
- reports.report_sales_by_time для месячных и годовых трендов, среднего заказа и сравнения выручки с предыдущим месяцем
- reports.report_sales_by_store для анализа магазинов, городов, стран и топ-5 магазинов по выручке
- reports.report_sales_by_supplier для анализа поставщиков, стран, средней цены товаров и топ-5 поставщиков по выручке
- reports.report_product_quality для анализа рейтингов, отзывов, объема продаж и корреляции рейтинга с продажами

## Проверка

Ожидаемый результат после .\scripts\validate.ps1:

- ClickHouse stage содержит 5000 строк из первых пяти CSV-файлов
- PostgreSQL stage содержит 5000 строк из следующих пяти CSV-файлов
- reports.stage_unified_sales содержит 10000 строк из двух источников
- reports.fact_sales содержит 10000 строк
- каждый из 10 CSV-файлов дает по 1000 строк факта
- все шесть отчетных таблиц заполнены
- для sale_total_price сохраняется отдельная проверка качества, потому что исходная сумма не совпадает с product_price * sale_quantity
