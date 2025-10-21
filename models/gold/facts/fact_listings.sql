{{
    config(
        materialized='table'
    )
}}

WITH listings_with_keys AS (
    SELECT
        sl.listing_id,
        sl.scrape_id,
        sl.scraped_date,
        sl.host_id,
        dd.date_key,
        dh.host_key,
        dl.listing_key,
        dpd.property_key,
        dln.listing_neighbourhood_key,
        dhn.host_neighbourhood_key,
        
        sl.price,
        sl.has_availability,
        sl.availability_30,
        sl.number_of_reviews,
        sl.review_scores_rating,
        sl.review_scores_accuracy,
        sl.review_scores_cleanliness,
        sl.review_scores_checkin,
        sl.review_scores_communication,
        sl.review_scores_value,
        sl.number_of_stays,
        sl.estimated_revenue
        
    FROM {{ ref('silver_listings') }} sl
    
    LEFT JOIN {{ ref('dim_date') }} dd
        ON sl.scraped_date = dd.date_day
    
    LEFT JOIN {{ ref('dim_host') }} dh
        ON sl.host_id = dh.host_id
        AND sl.scraped_date >= dh.dbt_valid_from
        AND (sl.scraped_date < dh.dbt_valid_to OR dh.dbt_valid_to IS NULL)
    
    LEFT JOIN {{ ref('dim_listing') }} dl
        ON sl.listing_id = dl.listing_id
        AND sl.scraped_date >= dl.dbt_valid_from
        AND (sl.scraped_date < dl.dbt_valid_to OR dl.dbt_valid_to IS NULL)
    
    LEFT JOIN {{ ref('dim_property_details') }} dpd
        ON sl.property_type = dpd.property_type
        AND sl.room_type = dpd.room_type
        AND sl.accommodates = dpd.accommodates
        AND sl.scraped_date >= dpd.dbt_valid_from
        AND (sl.scraped_date < dpd.dbt_valid_to OR dpd.dbt_valid_to IS NULL)
    
    LEFT JOIN {{ ref('dim_listing_neighbourhood') }} dln
        ON sl.listing_neighbourhood = dln.listing_neighbourhood
        AND sl.scraped_date >= dln.dbt_valid_from
        AND (sl.scraped_date < dln.dbt_valid_to OR dln.dbt_valid_to IS NULL)
    
    LEFT JOIN {{ ref('dim_host_neighbourhood') }} dhn
        ON sl.host_neighbourhood = dhn.host_neighbourhood
        AND sl.scraped_date >= dhn.dbt_valid_from
        AND (sl.scraped_date < dhn.dbt_valid_to OR dhn.dbt_valid_to IS NULL)
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['listing_id', 'scraped_date']) }} as fact_key,
    *
FROM listings_with_keys