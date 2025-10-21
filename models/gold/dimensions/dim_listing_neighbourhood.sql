{{
    config(
        materialized='table'
    )
}}

SELECT
    {{ dbt_utils.generate_surrogate_key(['listing_neighbourhood', 'dbt_valid_from']) }} as listing_neighbourhood_key,
    listing_neighbourhood,
    dbt_valid_from,
    dbt_valid_to,
    CASE WHEN dbt_valid_to IS NULL THEN TRUE ELSE FALSE END as is_current
FROM {{ ref('snapshot_listing_neighbourhood') }}