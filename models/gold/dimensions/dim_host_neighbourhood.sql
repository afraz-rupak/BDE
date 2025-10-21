{{
    config(
        materialized='table'
    )
}}

WITH host_neighbourhood_snapshot AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['host_neighbourhood', 'dbt_valid_from']) }} as host_neighbourhood_key,
        host_neighbourhood,
        dbt_valid_from,
        dbt_valid_to,
        CASE WHEN dbt_valid_to IS NULL THEN TRUE ELSE FALSE END as is_current
    FROM {{ ref('snapshot_host_neighbourhood') }}
),

-- Join with LGA mapping
with_lga AS (
    SELECT
        hn.*,
        ls.lga_name,
        lc.lga_code
    FROM host_neighbourhood_snapshot hn
    LEFT JOIN {{ source('bronze', 'raw_lga_suburb') }} ls
        ON LOWER(TRIM(hn.host_neighbourhood)) = LOWER(TRIM(ls.suburb_name))
    LEFT JOIN {{ source('bronze', 'raw_lga_code') }} lc
        ON LOWER(TRIM(ls.lga_name)) = LOWER(TRIM(lc.lga_name))
)

SELECT
    host_neighbourhood_key,
    host_neighbourhood,
    lga_name as host_neighbourhood_lga_name,
    lga_code as host_neighbourhood_lga_code,
    dbt_valid_from,
    dbt_valid_to,
    is_current
FROM with_lga