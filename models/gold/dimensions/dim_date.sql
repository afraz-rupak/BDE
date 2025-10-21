{{
    config(
        materialized='table'
    )
}}

WITH date_spine AS (
    -- Generate dates from May 2020 to April 2021
    SELECT
        scraped_date as date_day
    FROM {{ ref('silver_listings') }}
    GROUP BY scraped_date
),

date_details AS (
    SELECT
        date_day,
        EXTRACT(YEAR FROM date_day) as year,
        EXTRACT(MONTH FROM date_day) as month,
        EXTRACT(DAY FROM date_day) as day,
        TO_CHAR(date_day, 'Month') as month_name,
        TO_CHAR(date_day, 'Mon') as month_name_short,
        EXTRACT(QUARTER FROM date_day) as quarter,
        TO_CHAR(date_day, 'YYYY-MM') as year_month,
        DATE_TRUNC('month', date_day) as month_start_date,
        (DATE_TRUNC('month', date_day) + INTERVAL '1 month - 1 day')::DATE as month_end_date
    FROM date_spine
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['date_day']) }} as date_key,
    date_day,
    year,
    month,
    day,
    month_name,
    month_name_short,
    quarter,
    year_month,
    month_start_date,
    month_end_date
FROM date_details