{{
    config(
        materialized='table'
    )
}}

SELECT
    lga_code_2016 as lga_code,
    median_age_persons,
    median_mortgage_repay_monthly,
    median_tot_prsnl_inc_weekly as median_personal_income_weekly,
    median_rent_weekly,
    median_tot_fam_inc_weekly as median_family_income_weekly,
    average_num_psns_per_bedroom as avg_persons_per_bedroom,
    median_tot_hhd_inc_weekly as median_household_income_weekly,
    average_household_size
FROM {{ source('bronze', 'raw_census_g02') }}
WHERE lga_code_2016 IS NOT NULL