{{
    config(
        materialized='table'
    )
}}

WITH lga_with_census AS (
    SELECT
        lc.lga_code,
        lc.lga_name,
        g01.lga_code as census_lga_code,
        g02.median_age_persons,
        g02.median_mortgage_repay_monthly,
        g02.average_household_size
    FROM {{ source('bronze', 'raw_lga_code') }} lc
    LEFT JOIN {{ ref('silver_census_g01') }} g01
        ON CAST(lc.lga_code AS VARCHAR) = g01.lga_code
    LEFT JOIN {{ ref('silver_census_g02') }} g02
        ON g01.lga_code = g02.lga_code
)

SELECT 
    lga_code,
    TRIM(lga_name) as lga_name,
    census_lga_code,
    median_age_persons,
    median_mortgage_repay_monthly,
    average_household_size
FROM lga_with_census