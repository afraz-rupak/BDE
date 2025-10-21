{{
    config(
        materialized='table'
    )
}}

WITH source_data AS (
    SELECT
        listing_id,
        scrape_id,
        scraped_date,
        host_id,
        host_name,
        host_since,
        host_is_superhost,
        host_neighbourhood,
        listing_neighbourhood,
        property_type,
        room_type,
        accommodates,
        price,
        has_availability,
        availability_30,
        number_of_reviews,
        review_scores_rating,
        review_scores_accuracy,
        review_scores_cleanliness,
        review_scores_checkin,
        review_scores_communication,
        review_scores_value
    FROM {{ source('bronze', 'raw_listings') }}
),

cleaned_data AS (
    SELECT
        -- IDs
        listing_id,
        scrape_id,
        scraped_date,
        host_id,
        
        -- Host attributes
        TRIM(host_name) as host_name,
        host_since,
        CASE 
            WHEN LOWER(host_is_superhost) = 't' THEN TRUE
            WHEN LOWER(host_is_superhost) = 'f' THEN FALSE
            ELSE FALSE
        END as host_is_superhost,
        TRIM(host_neighbourhood) as host_neighbourhood,
        
        -- Listing attributes
        TRIM(listing_neighbourhood) as listing_neighbourhood,
        TRIM(property_type) as property_type,
        TRIM(room_type) as room_type,
        accommodates,
        
        -- Price - already numeric
        price,
        
        -- Availability
        CASE 
            WHEN LOWER(has_availability) = 't' THEN TRUE
            WHEN LOWER(has_availability) = 'f' THEN FALSE
            ELSE FALSE
        END as has_availability,
        availability_30,
        
        -- Reviews
        number_of_reviews,
        review_scores_rating,
        review_scores_accuracy,
        review_scores_cleanliness,
        review_scores_checkin,
        review_scores_communication,
        review_scores_value,
        
        -- Calculated fields
        CASE 
            WHEN LOWER(has_availability) = 't' AND availability_30 IS NOT NULL
            THEN (30 - availability_30)
            ELSE 0
        END as number_of_stays,
        
        CASE 
            WHEN LOWER(has_availability) = 't' AND availability_30 IS NOT NULL AND price IS NOT NULL
            THEN (30 - availability_30) * price
            ELSE 0
        END as estimated_revenue
        
    FROM source_data
    WHERE listing_id IS NOT NULL
)

SELECT * FROM cleaned_data