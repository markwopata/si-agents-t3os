{{
    config(
        materialized='table',
        cluster_by=['company_id', 'rental_status_name', 'rental_start_date'],
    )
}}

-- =====================================================================
-- FACT_ONRENT_METRICS: Denormalized on-rent rental metrics table
-- =====================================================================
-- Purpose: Single flat table for fast Looker dashboards
-- Replaces: stg_t3__on_rent (BUSINESS_INTELLIGENCE.TRIAGE)
-- Based on: Platform Gold dimensional model (fact_rental_metrics + dims)
-- Performance: Pre-joins all dimensions, filters to On-Rent only
-- =====================================================================


SELECT 
    -- ========================================
    -- PRIMARY KEYS & IDs (Natural Keys)
    -- ========================================
    frm.rental_key,
    dr.rental_id,
    da.asset_id,
    dc.company_id,
    dpo.purchase_order_id,
    dor.order_id,
    du.user_id,
    dl.location_id,
    dp.part_id,
    
    -- ========================================
    -- FACT METRICS (from fact_rental_metrics)
    -- ========================================
    frm.total_invoiced_amount,
    frm.total_invoiced_amount as to_date_rental,  -- Legacy alias
    frm.total_days_on_rent,
    frm.total_weekdays_on_rent,
    frm.price_per_day,
    frm.price_per_week,
    frm.price_per_month,
    frm.line_item_count,
    frm.billing_days_left,
    frm.current_cycle,
    
    -- Utilization metrics (last 7 days breakdown)
    frm.previous_day_utilization_utc,
    frm.previous_day_utilization_est,
    frm.previous_day_utilization_cst,
    frm.previous_day_utilization_mnt,
    frm.previous_day_utilization_wst,
    
    frm.two_days_ago_utilization_utc,
    frm.two_days_ago_utilization_est,
    frm.two_days_ago_utilization_cst,
    frm.two_days_ago_utilization_mnt,
    frm.two_days_ago_utilization_wst,
    
    frm.three_days_ago_utilization_utc,
    frm.three_days_ago_utilization_est,
    frm.three_days_ago_utilization_cst,
    frm.three_days_ago_utilization_mnt,
    frm.three_days_ago_utilization_wst,
    
    frm.four_days_ago_utilization_utc,
    frm.four_days_ago_utilization_est,
    frm.four_days_ago_utilization_cst,
    frm.four_days_ago_utilization_mnt,
    frm.four_days_ago_utilization_wst,
    
    frm.five_days_ago_utilization_utc,
    frm.five_days_ago_utilization_est,
    frm.five_days_ago_utilization_cst,
    frm.five_days_ago_utilization_mnt,
    frm.five_days_ago_utilization_wst,
    
    frm.six_days_ago_utilization_utc,
    frm.six_days_ago_utilization_est,
    frm.six_days_ago_utilization_cst,
    frm.six_days_ago_utilization_mnt,
    frm.six_days_ago_utilization_wst,
    
    frm.seven_days_ago_utilization_utc,
    frm.seven_days_ago_utilization_est,
    frm.seven_days_ago_utilization_cst,
    frm.seven_days_ago_utilization_mnt,
    frm.seven_days_ago_utilization_wst,
    
    -- Total rental period utilization (in seconds)
    frm.rental_period_utilization_utc,
    frm.rental_period_utilization_est,
    frm.rental_period_utilization_cst,
    frm.rental_period_utilization_mnt,
    frm.rental_period_utilization_wst,
    
    -- ========================================
    -- ASSET DIMENSIONS (pre-joined)
    -- ========================================
    da.asset_custom_name as custom_name,
    CONCAT(da.asset_equipment_make, ' ', da.asset_equipment_model_name) as make_and_model,
    da.asset_equipment_make,
    da.asset_equipment_model_name,
    da.asset_equipment_class_name as asset_class,
    da.asset_equipment_subcategory_name as subcategory,
    da.asset_equipment_category_name as category,
    da.asset_year,
    da.asset_serial_number,
    da.asset_tracker_id,
    CASE WHEN da.asset_tracker_id IS NOT NULL THEN TRUE ELSE FALSE END as asset_has_tracker,
    da.asset_last_address as current_asset_location,
    da.asset_last_location,
    da.asset_last_city,
    da.asset_last_street,
    NULL as asset_last_latitude,  -- Not available in dim_assets
    NULL as asset_last_longitude,  -- Not available in dim_assets
    NULL as lat_lon,  -- Derived from latitude/longitude which aren't available
    
    -- ========================================
    -- PART DIMENSIONS (for bulk items)
    -- ========================================
    dp.part_type_description,
    
    -- ========================================
    -- LOCATION DIMENSIONS (jobsite)
    -- ========================================
    dl.location_nickname as jobsite,
    dl.location_nickname as rental_location,  -- Legacy alias
    dl.location_street_1,
    dl.location_street_2,
    CONCAT(COALESCE(dl.location_street_1, ''), ' ', COALESCE(dl.location_street_2, '')) as location_address,
    dl.location_city,
    dl.location_state_key,
    NULL as location_state,  -- State name not directly available (need to join to dim_states)
    dl.location_zip_code,
    dl.location_latitude,
    dl.location_longitude,
    CONCAT(dl.location_latitude, ',', dl.location_longitude) as location_lat_lon,
    dl.location_city as jobsite_city_state,  -- Simplified (state not available without extra join)
    
    -- ========================================
    -- COMPANY DIMENSIONS (customer)
    -- ========================================
    dc.company_name as vendor,  -- Legacy alias from stg_t3__on_rent
    dc.company_name,
    dc.company_timezone,
    dc.company_has_fleet,
    dc.company_has_fleet_cam,
    
    -- ========================================
    -- SUB-RENTER DIMENSIONS
    -- ========================================
    dsr.sub_renter_company_name as sub_renting_company,
    dsr.sub_renter_ordered_by_name as sub_renting_contact,
    
    -- ========================================
    -- PURCHASE ORDER DIMENSIONS
    -- ========================================
    dpo.purchase_order_name,
    dpo.purchase_order_budget_amount,
    dpo.purchase_order_active,
    dpo.purchase_order_start_date,
    dpo.purchase_order_end_date,
    
    -- ========================================
    -- USER DIMENSIONS (ordered by)
    -- ========================================
    du.user_first_name,
    du.user_last_name,
    CONCAT(du.user_first_name, ' ', du.user_last_name) as ordered_by,
    du.user_full_name,
    du.user_username,
    du.user_timezone as user_timezone_pref,
    NULL as user_email,  -- Not available in dim_users
    NULL as user_phone_number,  -- Not available in dim_users
    
    -- ========================================
    -- RENTAL STATUS DIMENSIONS
    -- ========================================
    drs.rental_status_name,
    drs.rental_status_id,
    
    -- ========================================
    -- RENTAL DIMENSIONS
    -- ========================================
    dr.rental_source,
    dr.rental_type_name,
    dr.rental_type_id,
    dr.rental_delivery_city,
    dr.rental_delivery_state,
    dr.rental_delivery_state_abbreviation,
    dr.rental_delivery_latitude,
    dr.rental_delivery_longitude,
    CASE WHEN dr.rental_delivery_city IS NOT NULL THEN TRUE ELSE FALSE END as rental_delivery_required,
    dr.rental_purchase_option_name,
    
    -- ========================================
    -- MARKET DIMENSIONS
    -- ========================================
    NULL as market_name,  -- Market join removed - no FK relationship
    NULL as market_region_name,
    NULL as market_state,
    NULL as market_timezone,
    
    -- ========================================
    -- DATE DIMENSIONS (actual dates, not keys!)
    -- ========================================
    dd_start.dt_date as rental_start_date,
    NULL as rental_start_date_and_time,  -- dt_datetime not available
    NULL as rental_start_week,  -- dt_week not available
    dd_start.dt_month as rental_start_month,
    dd_start.dt_period as rental_start_quarter,  -- Using dt_period instead
    dd_start.dt_year as rental_start_year,
    dd_start.dt_day_of_week as rental_start_day_of_week,
    dd_start.dt_month_name as rental_start_month_name,
    
    dd_end.dt_date as scheduled_off_rent_date,
    NULL as scheduled_off_rent_date_and_time,  -- dt_datetime not available
    NULL as rental_end_week,  -- dt_week not available
    dd_end.dt_month as rental_end_month,
    dd_end.dt_period as rental_end_quarter,
    dd_end.dt_year as rental_end_year,
    
    dd_next.dt_date as next_cycle_date,
    
    -- Utilization date stamps (for last 7 days) - calculated from CURRENT_DATE
    DATEADD(day, -1, CURRENT_DATE()) as previous_day_date,
    DATEADD(day, -2, CURRENT_DATE()) as two_days_ago_date,
    DATEADD(day, -3, CURRENT_DATE()) as three_days_ago_date,
    DATEADD(day, -4, CURRENT_DATE()) as four_days_ago_date,
    DATEADD(day, -5, CURRENT_DATE()) as five_days_ago_date,
    DATEADD(day, -6, CURRENT_DATE()) as six_days_ago_date,
    DATEADD(day, -7, CURRENT_DATE()) as seven_days_ago_date,
    
    -- ========================================
    -- TRACKER HEALTH STATUS (placeholder for future join)
    -- ========================================
    NULL as public_health_status,
    NULL as utilization_status,
    NULL as filename,
    
    -- ========================================
    -- BENCHMARK METRICS (placeholder for future join)
    -- ========================================
    NULL::NUMBER as benchmarked_asset_count,
    NULL::NUMBER as utilization_30_day_class_benchmark,
    NULL as class_comparable_assets,
    NULL as class_utilization_comparison,
    
    NULL::NUMBER as benchmarked_category_asset_count,
    NULL::NUMBER as utilization_30_day_category_benchmark,
    NULL as category_comparable_assets,
    NULL as category_utilization_comparison,
    
    NULL::NUMBER as benchmarked_parent_category_asset_count,
    NULL::NUMBER as utilization_30_day_parent_category_benchmark,
    NULL as parent_category_comparable_assets,
    NULL as parent_category_utilization_comparison

FROM {{ ref('platform', 'fact_rental_metrics') }} frm

-- ========================================
-- CORE DIMENSION JOINS (all LEFT JOIN)
-- Cross-project references to platform using dbt mesh
-- ========================================
LEFT JOIN {{ ref('platform', 'dim_rentals') }} dr 
    ON frm.rental_key = dr.rental_key

LEFT JOIN {{ ref('platform', 'dim_rental_statuses') }} drs 
    ON frm.rental_status_key = drs.rental_status_key

LEFT JOIN {{ ref('platform', 'dim_companies') }} dc 
    ON frm.customer_company_key = dc.company_key

LEFT JOIN {{ ref('platform', 'dim_assets') }} da 
    ON frm.asset_key = da.asset_key

LEFT JOIN {{ ref('platform', 'dim_parts') }} dp 
    ON frm.part_key = dp.part_key

LEFT JOIN {{ ref('platform', 'dim_users') }} du 
    ON frm.user_key = du.user_key

LEFT JOIN {{ ref('platform', 'dim_sub_renters') }} dsr 
    ON frm.sub_renter_key = dsr.sub_renter_key

LEFT JOIN {{ ref('platform', 'dim_locations') }} dl 
    ON frm.location_key = dl.location_key

LEFT JOIN {{ ref('platform', 'dim_purchase_orders') }} dpo 
    ON frm.purchase_order_key = dpo.purchase_order_key

LEFT JOIN {{ ref('platform', 'dim_orders') }} dor 
    ON frm.order_key = dor.order_key

-- Note: dim_markets join removed - no direct relationship from companies to markets via foreign key

-- ========================================
-- DATE DIMENSION JOINS (8 date joins total)
-- Cross-project references to platform using dbt mesh
-- ========================================
LEFT JOIN {{ ref('platform', 'dim_dates') }} dd_start 
    ON frm.rental_start_date_key = dd_start.dt_key

LEFT JOIN {{ ref('platform', 'dim_dates') }} dd_end 
    ON frm.rental_end_date_key = dd_end.dt_key

LEFT JOIN {{ ref('platform', 'dim_dates') }} dd_next 
    ON frm.next_cycle_date_key = dd_next.dt_key

-- Note: Last 7 days date joins removed - these date keys don't exist in fact_rental_metrics
-- The utilization date stamps will be calculated from CURRENT_DATE instead

-- ========================================
-- FILTER TO ON-RENT ONLY
-- ========================================
WHERE drs.rental_status_id = 5  -- On-Rent status only

