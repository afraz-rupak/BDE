{% snapshot snapshot_listing_neighbourhood %}

{{
    config(
      target_schema='silver',
      unique_key='listing_neighbourhood',
      strategy='timestamp',
      updated_at='scraped_date',
    )
}}

SELECT DISTINCT
    listing_neighbourhood,
    scraped_date
FROM {{ ref('silver_listings') }}
WHERE listing_neighbourhood IS NOT NULL

{% endsnapshot %}