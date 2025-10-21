{{
    config(
        materialized='view'
    )
}}

WITH monthly_base AS (
    SELECT
        dpd.property_type,
        dpd.room_type,
        dpd.accommodates,
        dd.year_month,
        dd.month_start_date,
        
        COUNT(f.listing_id) as total_listings,
        COUNT(CASE WHEN f.has_availability THEN 1 END) as active_listings,
        COUNT(DISTINCT f.host_key) as distinct_hosts,
        COUNT(DISTINCT CASE WHEN dh.host_is_superhost THEN f.host_key END) as superhost_count,
        
        MIN(CASE WHEN f.has_availability THEN f.price END) as min_price,
        MAX(CASE WHEN f.has_availability THEN f.price END) as max_price,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY CASE WHEN f.has_availability THEN f.price END) as median_price,
        AVG(CASE WHEN f.has_availability THEN f.price END) as avg_price,
        
        AVG(CASE WHEN f.has_availability THEN f.review_scores_rating END) as avg_review_score,
        
        SUM(CASE WHEN f.has_availability THEN f.number_of_stays ELSE 0 END) as total_stays,
        SUM(CASE WHEN f.has_availability THEN f.estimated_revenue ELSE 0 END) as total_estimated_revenue
        
    FROM {{ ref('fact_listings') }} f
    INNER JOIN {{ ref('dim_property_details') }} dpd
        ON f.property_key = dpd.property_key
    INNER JOIN {{ ref('dim_date') }} dd
        ON f.date_key = dd.date_key
    LEFT JOIN {{ ref('dim_host') }} dh
        ON f.host_key = dh.host_key
    
    GROUP BY dpd.property_type, dpd.room_type, dpd.accommodates, dd.year_month, dd.month_start_date
),

with_calculations AS (
    SELECT
        property_type,
        room_type,
        accommodates,
        year_month,
        month_start_date,
        
        CASE 
            WHEN total_listings > 0 
            THEN ROUND((active_listings::NUMERIC / total_listings) * 100, 2)
            ELSE 0
        END as active_listing_rate,
        
        min_price,
        max_price,
        ROUND(median_price, 2) as median_price,
        ROUND(avg_price, 2) as avg_price,
        
        distinct_hosts,
        CASE 
            WHEN distinct_hosts > 0 
            THEN ROUND((superhost_count::NUMERIC / distinct_hosts) * 100, 2)
            ELSE 0
        END as superhost_rate,
        
        ROUND(avg_review_score, 2) as avg_review_score,
        
        total_stays,
        CASE 
            WHEN active_listings > 0 
            THEN ROUND(total_estimated_revenue / active_listings, 2)
            ELSE 0
        END as avg_estimated_revenue_per_active_listing,
        
        active_listings,
        total_listings - active_listings as inactive_listings
        
    FROM monthly_base
),

with_lag AS (
    SELECT
        *,
        LAG(active_listings) OVER (
            PARTITION BY property_type, room_type, accommodates
            ORDER BY month_start_date
        ) as prev_active_listings,
        LAG(inactive_listings) OVER (
            PARTITION BY property_type, room_type, accommodates
            ORDER BY month_start_date
        ) as prev_inactive_listings
    FROM with_calculations
)

SELECT
    property_type,
    room_type,
    accommodates,
    year_month,
    active_listing_rate,
    min_price,
    max_price,
    median_price,
    avg_price,
    distinct_hosts,
    superhost_rate,
    avg_review_score,
    
    CASE 
        WHEN prev_active_listings > 0 AND prev_active_listings IS NOT NULL
        THEN ROUND(((active_listings - prev_active_listings)::NUMERIC / prev_active_listings) * 100, 2)
        ELSE NULL
    END as pct_change_active_listings,
    
    CASE 
        WHEN prev_inactive_listings > 0 AND prev_inactive_listings IS NOT NULL
        THEN ROUND(((inactive_listings - prev_inactive_listings)::NUMERIC / prev_inactive_listings) * 100, 2)
        ELSE NULL
    END as pct_change_inactive_listings,
    
    total_stays,
    avg_estimated_revenue_per_active_listing

FROM with_lag
ORDER BY property_type, room_type, accommodates, year_month