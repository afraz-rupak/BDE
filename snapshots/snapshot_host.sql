{% snapshot snapshot_host %}

{{
    config(
      target_schema='silver',
      unique_key='host_id',
      strategy='timestamp',
      updated_at='scraped_date',
    )
}}

SELECT DISTINCT
    host_id,
    host_name,
    host_since,
    host_is_superhost,
    host_neighbourhood,
    scraped_date
FROM {{ ref('silver_listings') }}
WHERE host_id IS NOT NULL

{% endsnapshot %}