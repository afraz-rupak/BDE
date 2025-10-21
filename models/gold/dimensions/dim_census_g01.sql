{{
    config(
        materialized='table'
    )
}}

SELECT
    {{ dbt_utils.generate_surrogate_key(['lga_code']) }} as census_g01_key,
    *
FROM {{ ref('silver_census_g01') }}