{{
    config(
        materialized='table'
    )
}}

SELECT
    lga_code_2016 as lga_code,
    -- Total population
    tot_p_p as total_population,
    tot_p_m as total_male,
    tot_p_f as total_female,
    
    -- Age groups (persons)
    age_0_4_yr_p as age_0_4,
    age_5_14_yr_p as age_5_14,
    age_15_19_yr_p as age_15_19,
    age_20_24_yr_p as age_20_24,
    age_25_34_yr_p as age_25_34,
    age_35_44_yr_p as age_35_44,
    age_45_54_yr_p as age_45_54,
    age_55_64_yr_p as age_55_64,
    age_65_74_yr_p as age_65_74,
    age_75_84_yr_p as age_75_84,
    age_85ov_p as age_85_over,
    
    -- Indigenous population
    indigenous_p_tot_p as total_indigenous,
    
    -- Birthplace
    birthplace_australia_p as birthplace_australia,
    birthplace_elsewhere_p as birthplace_elsewhere,
    
    -- Language
    lang_spoken_home_eng_only_p as language_english_only,
    lang_spoken_home_oth_lang_p as language_other,
    
    -- Citizenship
    australian_citizen_p as australian_citizens,
    
    -- Education attendance by age
    age_psns_att_educ_inst_0_4_p as education_attendance_0_4,
    age_psns_att_educ_inst_5_14_p as education_attendance_5_14,
    age_psns_att_edu_inst_15_19_p as education_attendance_15_19,
    age_psns_att_edu_inst_20_24_p as education_attendance_20_24,
    age_psns_att_edu_inst_25_ov_p as education_attendance_25_over,
    
    -- Highest year of school completed
    high_yr_schl_comp_yr_12_eq_p as highest_school_year_12,
    high_yr_schl_comp_yr_11_eq_p as highest_school_year_11,
    high_yr_schl_comp_yr_10_eq_p as highest_school_year_10,
    high_yr_schl_comp_yr_9_eq_p as highest_school_year_9,
    high_yr_schl_comp_yr_8_belw_p as highest_school_year_8_below,
    
    -- Dwelling counts
    count_psns_occ_priv_dwgs_p as persons_in_private_dwellings,
    count_persons_other_dwgs_p as persons_in_other_dwellings

FROM {{ source('bronze', 'raw_census_g01') }}
WHERE lga_code_2016 IS NOT NULL