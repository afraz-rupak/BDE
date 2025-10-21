{% snapshot snapshot_host_neighbourhood %}

{{
    config(
      target_schema='silver',
      unique_key='host_neighbourhood',
      strategy='timestamp',
      updated_at='scraped_date',
    )
}}

SELECT DISTINCT
    host_neighbourhood,
    scraped_date
FROM {{ ref('silver_listings') }}
WHERE host_neighbourhood IS NOT NULL

{% endsnapshot %}