{{
    config(
        materialized='table'
    )
}}

SELECT
    {{ dbt_utils.generate_surrogate_key(['property_detail_key', 'dbt_valid_from']) }} as property_key,
    property_detail_key,
    property_type,
    room_type,
    accommodates,
    dbt_valid_from,
    dbt_valid_to,
    CASE WHEN dbt_valid_to IS NULL THEN TRUE ELSE FALSE END as is_current
FROM {{ ref('snapshot_property_details') }}