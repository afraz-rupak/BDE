{{
    config(
        materialized='view'
    )
}}

WITH monthly_base AS (
    SELECT
        dhn.host_neighbourhood_lga_name,
        dd.year_month,
        dd.month_start_date,
        
        COUNT(DISTINCT f.host_key) as distinct_hosts,
        
        COUNT(CASE WHEN f.has_availability THEN 1 END) as active_listings,
        
        SUM(CASE WHEN f.has_availability THEN f.estimated_revenue ELSE 0 END) as total_estimated_revenue
        
    FROM {{ ref('fact_listings') }} f
    INNER JOIN {{ ref('dim_host_neighbourhood') }} dhn
        ON f.host_neighbourhood_key = dhn.host_neighbourhood_key
    INNER JOIN {{ ref('dim_date') }} dd
        ON f.date_key = dd.date_key
    
    WHERE dhn.host_neighbourhood_lga_name IS NOT NULL
    
    GROUP BY dhn.host_neighbourhood_lga_name, dd.year_month, dd.month_start_date
)

SELECT
    host_neighbourhood_lga_name as host_neighbourhood_lga,
    year_month,
    distinct_hosts,
    
    CASE 
        WHEN active_listings > 0 
        THEN ROUND(total_estimated_revenue / active_listings, 2)
        ELSE 0
    END as estimated_revenue_per_active_listing,
    
    CASE 
        WHEN distinct_hosts > 0 
        THEN ROUND(total_estimated_revenue / distinct_hosts, 2)
        ELSE 0
    END as estimated_revenue_per_host

FROM monthly_base
ORDER BY host_neighbourhood_lga, year_month