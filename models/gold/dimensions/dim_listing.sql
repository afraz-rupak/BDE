{{
    config(
        materialized='table'
    )
}}

SELECT
    {{ dbt_utils.generate_surrogate_key(['listing_id', 'dbt_valid_from']) }} as listing_key,
    listing_id,
    listing_neighbourhood,
    property_type,
    room_type,
    accommodates,
    dbt_valid_from,
    dbt_valid_to,
    CASE WHEN dbt_valid_to IS NULL THEN TRUE ELSE FALSE END as is_current
FROM {{ ref('snapshot_listing') }}