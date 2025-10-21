{{
    config(
        materialized='table'
    )
}}

SELECT
    {{ dbt_utils.generate_surrogate_key(['lga_code']) }} as lga_key,
    lga_code,
    lga_name,
    census_lga_code,
    median_age_persons,
    median_mortgage_repay_monthly,
    average_household_size
FROM {{ ref('silver_lga') }}
WHERE lga_code IS NOT NULL