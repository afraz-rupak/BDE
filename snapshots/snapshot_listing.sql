{% snapshot snapshot_listing %}

{{
    config(
      target_schema='silver',
      unique_key='listing_id',
      strategy='timestamp',
      updated_at='scraped_date',
    )
}}

SELECT DISTINCT
    listing_id,
    listing_neighbourhood,
    property_type,
    room_type,
    accommodates,
    scraped_date
FROM {{ ref('silver_listings') }}
WHERE listing_id IS NOT NULL

{% endsnapshot %}