{{
    config(
        materialized='table'
    )
}}

SELECT
    {{ dbt_utils.generate_surrogate_key(['host_id', 'dbt_valid_from']) }} as host_key,
    host_id,
    host_name,
    host_since,
    host_is_superhost,
    host_neighbourhood,
    dbt_valid_from,
    dbt_valid_to,
    -- Helper columns for SCD2 joins
    CASE WHEN dbt_valid_to IS NULL THEN TRUE ELSE FALSE END as is_current
FROM {{ ref('snapshot_host') }}