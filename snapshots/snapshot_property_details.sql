{% snapshot snapshot_property_details %}

{{
    config(
      target_schema='silver',
      unique_key='property_detail_key',
      strategy='timestamp',
      updated_at='scraped_date',
    )
}}

WITH property_combinations AS (
    SELECT DISTINCT
        {{ dbt_utils.generate_surrogate_key(['property_type', 'room_type', 'accommodates']) }} as property_detail_key,
        property_type,
        room_type,
        accommodates,
        scraped_date
    FROM {{ ref('silver_listings') }}
    WHERE property_type IS NOT NULL 
      AND room_type IS NOT NULL
      AND accommodates IS NOT NULL
)

SELECT * FROM property_combinations

{% endsnapshot %}