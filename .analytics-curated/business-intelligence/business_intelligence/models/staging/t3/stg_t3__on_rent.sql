{{ config(
    materialized='table'
    , cluster_by=['company_id']
) }}

-- On Rent Report
with asset_list_rental as (
    SELECT
      coalesce(ea.asset_id, r.asset_id) as asset_id, -- Bulk orders do not have an asset_id
      coalesce(ea.rental_id, r.rental_id) as rental_id,
      u.company_id,
      r.rental_type_id,
      rt.name as rental_type_name,
      coalesce(ea.start_date, r.start_date) as start_date,
      coalesce(ea.end_date, r.end_date, '2099-01-01'::timestamp_tz) as end_date
    FROM {{ ref('platform', 'es_warehouse__public__orders') }} o
    join {{ ref('platform', 'es_warehouse__public__users') }} u on u.user_id = o.user_id -- perf: pull in viewing user ID at join level for some sec_levels?
    join {{ ref('platform', 'es_warehouse__public__rentals') }} r on r.order_id = o.order_id
    left join {{ ref('platform', 'es_warehouse__public__equipment_assignments') }} ea on ea.rental_id = r.rental_id and ea.end_date is null
    join {{ ref('platform', 'es_warehouse__public__rental_types') }} rt on rt.rental_type_id = r.rental_type_id
    WHERE r.rental_status_id = 5
)    
, orders_salesperson_breakdown AS (
SELECT DISTINCT
    order_id,
    MAX(CASE WHEN salesperson_type_id = 1 THEN user_id END) AS primary_salesperson_id,
    NULLIF(
        LISTAGG(CASE WHEN salesperson_type_id = 2 THEN user_id END, ',') ,
        ''
    ) AS secondary_salesperson_ids,
    SUM(CASE WHEN salesperson_type_id = 2 THEN 1 ELSE 0 END) as total_secondary_salespersons,
    NULLIF(SPLIT_PART(secondary_salesperson_ids, ',', 1),'') AS secondary_salesperson_1,
    NULLIF(SPLIT_PART(secondary_salesperson_ids, ',', 2),'') AS secondary_salesperson_2,
    NULLIF(SPLIT_PART(secondary_salesperson_ids, ',', 3),'') AS secondary_salesperson_3
FROM es_warehouse.public.order_salespersons
GROUP BY order_id
) 
, rental_on_time as (
     select 
      bdu.asset_id
      , sum(coalesce(on_time_utc,0) + coalesce(in_progress_on_time_utc,0)) as rental_on_time_utc
      , sum(coalesce(on_time_est,0) + coalesce(in_progress_on_time_est,0)) as rental_on_time_est
      , sum(coalesce(on_time_cst,0) + coalesce(in_progress_on_time_cst,0)) as rental_on_time_cst
      , sum(coalesce(on_time_mnt,0) + coalesce(in_progress_on_time_mnt,0)) as rental_on_time_mnt
      , sum(coalesce(on_time_wst,0) + coalesce(in_progress_on_time_wst,0)) as rental_on_time_wst
      from 
      {{ ref('stg_t3__by_day_utilization') }} bdu 
      left join es_warehouse.public.rentals r on r.asset_id = bdu.asset_id
      and bdu.date >= start_date and bdu.date <= end_date
      where 
      r.rental_status_id = 5
      group by bdu.asset_id
      having 
      rental_on_time_utc > 0 
      OR rental_on_time_est > 0
      OR rental_on_time_cst > 0 
      OR rental_on_time_mnt > 0 
      OR rental_on_time_wst > 0 
)
, rental_used_days AS (
    SELECT
        alr.asset_id,
        alr.rental_id,

        COUNT(DISTINCT CASE
            WHEN (COALESCE(bdu.on_time_cst,0) + COALESCE(bdu.in_progress_on_time_cst,0)) > 0
             AND bdu.date::date BETWEEN alr.start_date::date AND LEAST(alr.end_date::date, CURRENT_DATE())
            THEN bdu.date::date
        END) AS total_days_used_on_rent,

        COUNT(DISTINCT CASE
            WHEN (COALESCE(bdu.on_time_cst,0) + COALESCE(bdu.in_progress_on_time_cst,0)) > 0
             AND bdu.date::date BETWEEN alr.start_date::date AND LEAST(alr.end_date::date, CURRENT_DATE())
             AND DAYOFWEEK(bdu.date::date) BETWEEN 2 AND 6
            THEN bdu.date::date
        END) AS total_weekdays_used_on_rent,
        MAX(CASE
            WHEN (COALESCE(bdu.on_time_cst,0) + COALESCE(bdu.in_progress_on_time_cst,0)) > 0
             AND bdu.date::date BETWEEN alr.start_date::date AND LEAST(alr.end_date::date, CURRENT_DATE())
            THEN bdu.date::date
        END) AS last_use_date

    FROM asset_list_rental alr
    LEFT JOIN BUSINESS_INTELLIGENCE.triage.stg_t3__by_day_utilization bdu
      ON bdu.asset_id = alr.asset_id
     AND bdu.date::date BETWEEN alr.start_date::date AND LEAST(alr.end_date::date, CURRENT_DATE())
    GROUP BY 1,2
)
, current_tracker_status as (
      select 
      distinct 
      asset_id
      , public_health_status 
      from
      BUSINESS_INTELLIGENCE.TRIAGE.stg_t3__telematics_health
)
, kakfa_engine_hours_check as (

select distinct 
a.asset_id
, TRUE as in_engine_hours_stream_flag
FROM confluent.manifold__silver.v_metadata_last_value_timestamp k
INNER JOIN PLATFORM.GOLD.DIM_TRACKERS t
                ON k.DEVICE_SERIAL = t.TRACKER_DEVICE_SERIAL
            INNER JOIN PLATFORM.GOLD.INT_ASSETS_TRACKERS_MAPPING atm
                ON t.TRACKER_ID_ESDB = atm.TRACKER_ID
            INNER JOIN PLATFORM.GOLD.DIM_ASSETS a
                ON atm.ASSET_ID = a.ASSET_ID
    WHERE TOTAL_ENGINE_HOURS > '0001-01-01 00:00:00.000'
)
      SELECT distinct
          cm.name as vendor,
          r.rental_id::text as rental_id,
          o.order_id::text as order_id,
          pcr.parent_company_id,
          pc.name as parent_company_name,
          coalesce(a.custom_name, TO_VARCHAR(ea.asset_id), 'Asset to be assigned') as custom_name,
          alr.company_id,
          c.name as company_name, 
          coalesce(concat(a.make,' ',a.model),concat('Bulk Item - ',p.part_id)) as make_and_model,
          coalesce(l.nickname,' ') as jobsite,
          coalesce(po.name,' ') as purchase_order_name,
          ai.equipment_class_id,
          coalesce(a.asset_class,pt.description,' ') as asset_class,
          ai.category,
          ai.parent_category,
          concat(u.first_name,' ',u.last_name) as ordered_by,
          r.start_date::date as rental_start_date,
          r.end_date::date as scheduled_off_rent_date,
          ac.last_cycle_inv_date::timestamp as last_cycle_date,
          ac.next_cycle_inv_date::timestamp as next_cycle_date,
          case
            when r.start_date::date >= current_date::date then 1
            else ac.total_days_on_rent
          end as total_days_on_rent,
          CASE 
            WHEN ac.start_date::timestamp >= current_date THEN 0
            ELSE (
                -- Total days from start to yesterday
                DATEDIFF(DAY, ac.start_date::timestamp, current_date - 1) + 1
                -- Subtract 2 weekend days for each full week
                - (FLOOR((DATEDIFF(DAY, ac.start_date::timestamp, current_date - 1) + 1) / 7) * 2)
                -- Adjust for remaining partial week weekend days
                - CASE 
                    WHEN MOD(DATEDIFF(DAY, ac.start_date::timestamp, current_date - 1) + 1, 7) = 0 THEN 0
                    ELSE 
                    CASE 
                        WHEN DATE_PART(DOW, ac.start_date::timestamp) = 6 THEN
                        CASE 
                            WHEN MOD(DATEDIFF(DAY, ac.start_date::timestamp, current_date - 1) + 1, 7) >= 1 THEN 1 ELSE 0
                        END
                        WHEN DATE_PART(DOW, ac.start_date::timestamp) = 0 THEN
                        CASE 
                            WHEN MOD(DATEDIFF(DAY, ac.start_date::timestamp, current_date - 1) + 1, 7) >= 1 THEN 1 ELSE 0
                        END
                        WHEN DATE_PART(DOW, ac.start_date::timestamp) <= 5 AND DATE_PART(DOW, ac.start_date::timestamp) + MOD(DATEDIFF(DAY, ac.start_date::timestamp, current_date - 1), 7) >= 6 THEN
                        2
                        ELSE 0
                    END
                END
            )
          END AS total_weekdays_on_rent,
          ac.days_left as billing_days_left,
          coalesce(ll.address,age.geofences,ll.location,' ') as current_asset_location,
          coalesce(r.quantity,1) as quantity,
          coalesce(r.price_per_day,0) as price_per_day,
          coalesce(r.price_per_month,0) as price_per_month,
          coalesce(r.price_per_week,0) as price_per_week,
          coalesce(ac.current_cycle,null) as current_cycle,
          round(coalesce(amt.amount,0),2) as to_date_rental,
            dateadd('day',-1,bdu.data_refresh_timestamp)::date as previous_day_date,
              round(case when bdu.date::date = previous_day_date then (coalesce(bdu.on_time_utc, 0) + coalesce(bdu.in_progress_on_time_utc, 0)) / 3600 else 0 end, 2) as previous_day_utilization_utc,
              round(case when bdu.date::date = previous_day_date then (coalesce(bdu.on_time_est, 0) + coalesce(bdu.in_progress_on_time_est, 0)) / 3600 else 0 end, 2) as previous_day_utilization_est,
              round(case when bdu.date::date = previous_day_date then (coalesce(bdu.on_time_cst, 0) + coalesce(bdu.in_progress_on_time_cst, 0)) / 3600 else 0 end, 2) as previous_day_utilization_cst,
              round(case when bdu.date::date = previous_day_date then (coalesce(bdu.on_time_mnt, 0) + coalesce(bdu.in_progress_on_time_mnt, 0)) / 3600 else 0 end, 2) as previous_day_utilization_mnt,
              round(case when bdu.date::date = previous_day_date then (coalesce(bdu.on_time_wst, 0) + coalesce(bdu.in_progress_on_time_wst, 0)) / 3600 else 0 end, 2) as previous_day_utilization_wst,
          dateadd('day',-2,bdu.data_refresh_timestamp)::date as two_days_ago_date,
              round(case when bdu2.date::date = two_days_ago_date then (coalesce(bdu2.on_time_utc, 0) +  coalesce(bdu.in_progress_on_time_utc, 0)) / 3600 else 0 end, 2) as two_days_utilization_utc,
              round(case when bdu2.date::date = two_days_ago_date then (coalesce(bdu2.on_time_est, 0) +  coalesce(bdu.in_progress_on_time_est, 0)) / 3600 else 0 end, 2) as two_days_utilization_est,
              round(case when bdu2.date::date = two_days_ago_date then (coalesce(bdu2.on_time_cst, 0) +  coalesce(bdu.in_progress_on_time_cst, 0)) / 3600 else 0 end, 2) as two_days_utilization_cst,
              round(case when bdu2.date::date = two_days_ago_date then (coalesce(bdu2.on_time_mnt, 0) +  coalesce(bdu.in_progress_on_time_mnt, 0)) / 3600 else 0 end, 2) as two_days_utilization_mnt,
              round(case when bdu2.date::date = two_days_ago_date then (coalesce(bdu2.on_time_wst, 0) +  coalesce(bdu.in_progress_on_time_wst, 0)) / 3600 else 0 end, 2) as two_days_utilization_wst,
          dateadd('day',-3,bdu.data_refresh_timestamp)::date as three_days_ago_date,
              round(case when bdu3.date::date = three_days_ago_date then (coalesce(bdu3.on_time_utc, 0) +  coalesce(bdu.in_progress_on_time_utc, 0)) / 3600 else 0 end, 2) as three_days_utilization_utc,
              round(case when bdu3.date::date = three_days_ago_date then (coalesce(bdu3.on_time_est, 0) +  coalesce(bdu.in_progress_on_time_est, 0)) / 3600 else 0 end, 2) as three_days_utilization_est,
              round(case when bdu3.date::date = three_days_ago_date then (coalesce(bdu3.on_time_cst, 0) +  coalesce(bdu.in_progress_on_time_cst, 0)) / 3600 else 0 end, 2) as three_days_utilization_cst,
              round(case when bdu3.date::date = three_days_ago_date then (coalesce(bdu3.on_time_mnt, 0) +  coalesce(bdu.in_progress_on_time_mnt, 0)) / 3600 else 0 end, 2) as three_days_utilization_mnt,
              round(case when bdu3.date::date = three_days_ago_date then (coalesce(bdu3.on_time_wst, 0) +  coalesce(bdu.in_progress_on_time_wst, 0)) / 3600 else 0 end, 2) as three_days_utilization_wst,
          dateadd('day',-4,bdu.data_refresh_timestamp)::date as four_days_ago_date,
              round(case when bdu4.date::date = four_days_ago_date then (coalesce(bdu4.on_time_utc, 0) +  coalesce(bdu.in_progress_on_time_utc, 0)) / 3600 else 0 end, 2) as four_days_utilization_utc,
              round(case when bdu4.date::date = four_days_ago_date then (coalesce(bdu4.on_time_est, 0) +  coalesce(bdu.in_progress_on_time_est, 0)) / 3600 else 0 end, 2) as four_days_utilization_est,
              round(case when bdu4.date::date = four_days_ago_date then (coalesce(bdu4.on_time_cst, 0) +  coalesce(bdu.in_progress_on_time_cst, 0)) / 3600 else 0 end, 2) as four_days_utilization_cst,
              round(case when bdu4.date::date = four_days_ago_date then (coalesce(bdu4.on_time_mnt, 0) +  coalesce(bdu.in_progress_on_time_mnt, 0)) / 3600 else 0 end, 2) as four_days_utilization_mnt,
              round(case when bdu4.date::date = four_days_ago_date then (coalesce(bdu4.on_time_wst, 0) +  coalesce(bdu.in_progress_on_time_wst, 0)) / 3600 else 0 end, 2) as four_days_utilization_wst,
          dateadd('day',-5,bdu.data_refresh_timestamp)::date as five_days_ago_date,
              round(case when bdu5.date::date = five_days_ago_date then (coalesce(bdu5.on_time_utc, 0) +  coalesce(bdu.in_progress_on_time_utc, 0)) / 3600 else 0 end, 2) as five_days_utilization_utc,
              round(case when bdu5.date::date = five_days_ago_date then (coalesce(bdu5.on_time_est, 0) +  coalesce(bdu.in_progress_on_time_est, 0)) / 3600 else 0 end, 2) as five_days_utilization_est,
              round(case when bdu5.date::date = five_days_ago_date then (coalesce(bdu5.on_time_cst, 0) +  coalesce(bdu.in_progress_on_time_cst, 0)) / 3600 else 0 end, 2) as five_days_utilization_cst,
              round(case when bdu5.date::date = five_days_ago_date then (coalesce(bdu5.on_time_mnt, 0) +  coalesce(bdu.in_progress_on_time_mnt, 0)) / 3600 else 0 end, 2) as five_days_utilization_mnt,
              round(case when bdu5.date::date = five_days_ago_date then (coalesce(bdu5.on_time_wst, 0) +  coalesce(bdu.in_progress_on_time_wst, 0)) / 3600 else 0 end, 2) as five_days_utilization_wst,
          dateadd('day',-6,bdu.data_refresh_timestamp)::date as six_days_ago_date,
              round(case when bdu6.date::date = six_days_ago_date then (coalesce(bdu6.on_time_utc, 0) +  coalesce(bdu.in_progress_on_time_utc, 0)) / 3600 else 0 end, 2) as six_days_utilization_utc,
              round(case when bdu6.date::date = six_days_ago_date then (coalesce(bdu6.on_time_est, 0) +  coalesce(bdu.in_progress_on_time_est, 0)) / 3600 else 0 end, 2) as six_days_utilization_est,
              round(case when bdu6.date::date = six_days_ago_date then (coalesce(bdu6.on_time_cst, 0) +  coalesce(bdu.in_progress_on_time_cst, 0)) / 3600 else 0 end, 2) as six_days_utilization_cst,
              round(case when bdu6.date::date = six_days_ago_date then (coalesce(bdu6.on_time_mnt, 0) +  coalesce(bdu.in_progress_on_time_mnt, 0)) / 3600 else 0 end, 2) as six_days_utilization_mnt,
              round(case when bdu6.date::date = six_days_ago_date then (coalesce(bdu6.on_time_wst, 0) +  coalesce(bdu.in_progress_on_time_wst, 0)) / 3600 else 0 end, 2) as six_days_utilization_wst,
          dateadd('day',-7,bdu.data_refresh_timestamp)::date as seven_days_ago_date,
              round(case when bdu7.date::date = seven_days_ago_date then (coalesce(bdu7.on_time_utc, 0) +  coalesce(bdu.in_progress_on_time_utc, 0)) / 3600 else 0 end, 2) as seven_days_utilization_utc,
              round(case when bdu7.date::date = seven_days_ago_date then (coalesce(bdu7.on_time_est, 0) +  coalesce(bdu.in_progress_on_time_est, 0)) / 3600 else 0 end, 2) as seven_days_utilization_est,
              round(case when bdu7.date::date = seven_days_ago_date then (coalesce(bdu7.on_time_cst, 0) +  coalesce(bdu.in_progress_on_time_cst, 0)) / 3600 else 0 end, 2) as seven_days_utilization_cst,
              round(case when bdu7.date::date = seven_days_ago_date then (coalesce(bdu7.on_time_mnt, 0) +  coalesce(bdu.in_progress_on_time_mnt, 0)) / 3600 else 0 end, 2) as seven_days_utilization_mnt,
              round(case when bdu7.date::date = seven_days_ago_date then (coalesce(bdu7.on_time_wst, 0) +  coalesce(bdu.in_progress_on_time_wst, 0)) / 3600 else 0 end, 2) as seven_days_utilization_wst,
              
              --total rental period on_time removed /3600 to keep seconds
              coalesce(rot.rental_on_time_utc, 0) as rental_period_utilization_utc,
              coalesce(rot.rental_on_time_est, 0) as rental_period_utilization_est,
              coalesce(rot.rental_on_time_cst, 0) as rental_period_utilization_cst,
              coalesce(rot.rental_on_time_mnt, 0) as rental_period_utilization_mnt,
              coalesce(rot.rental_on_time_wst, 0) as rental_period_utilization_wst,

          ea.asset_id,
          photo.filename,
          o.purchase_order_id,
          m.name as rental_location,
          case
            when a.tracker_id is null then 'No tracker installed'
            when datediff(hours,lc.last_location_timestamp,current_timestamp) >= 120 then 'No utilization due to last location check in over 120 hours'
            when tm.tracker_grouping NOT IN ('Data and Location Only','AEMP') then concat('No utilization due to ',case 
            when tm.tracker_grouping is null then 'asset having no tracker' else concat('tracker having ', lower(tm.tracker_grouping), ' ability') end )
            else 'show utilization' end as utilization_status,
          ll.location as lat_lon,
          r.start_date as rental_start_date_and_time,
          r.end_date as scheduled_off_rent_date_and_time,
          concat(coalesce(city,''),', ',coalesce(s.abbreviation,'')) as jobsite_city_state,
          div0(div0(rental_period_utilization_cst , 3600) , (total_days_on_rent * 8)) as rental_period_percent, 
          div0(div0(rental_period_utilization_cst , 3600) , (total_days_on_rent * 16)) as rental_period_percent_double_shift, 
          div0(div0(rental_period_utilization_cst , 3600) , (total_days_on_rent * 24)) as rental_period_percent_triple_shift,
          case
            when r.shift_type_id = 3 then rental_period_percent_triple_shift >= 0.8
            when r.shift_type_id = 2 then rental_period_percent_double_shift >= 0.8
            else rental_period_percent >= 0.8
          end as overage_risk,
          -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
           bcu.distinct_asset_count as benchmarked_asset_count,
           bcu.utilization_30_day_class_benchmark,

        case
        when benchmarked_asset_count is null then 'Class Does Not Report Utilization'
        when benchmarked_asset_count >= 1000 then '1,000+'
        when benchmarked_asset_count >= 500 then '500 - 1,000'
        when benchmarked_asset_count >= 100 then '100 - 500'
        when benchmarked_asset_count >= 50 then '50 - 100'
        when benchmarked_asset_count > 5 then 'Less than 50'
        else 'Not Enough Comparable Assets' end as class_comparable_assets
       ,

           case 
           when rental_period_percent = 0 then 'No Utilization Reported'
           when rental_period_percent - utilization_30_day_class_benchmark  >= .25 then 'Higher Utilization'
           when rental_period_percent - utilization_30_day_class_benchmark < .25
            and  rental_period_percent - utilization_30_day_class_benchmark > -.25 then 'Average Utilization'
        when rental_period_percent - utilization_30_day_class_benchmark <= -.25 then 'Lower Utilization'
        else 'Class Does Not Report Utilization' end as class_utilization_comparison,
        ------------ double shift ------------
         bcu.utilization_30_day_class_benchmark_double_shift,

           case 
           when rental_period_percent_double_shift = 0 then 'No Utilization Reported'
           when rental_period_percent_double_shift - utilization_30_day_class_benchmark  >= .25 then 'Higher Utilization'
           when rental_period_percent_double_shift - utilization_30_day_class_benchmark < .25
            and  rental_period_percent_double_shift - utilization_30_day_class_benchmark > -.25 then 'Average Utilization'
        when rental_period_percent_double_shift - utilization_30_day_class_benchmark <= -.25 then 'Lower Utilization'
        else 'Class Does Not Report Utilization' end as class_utilization_comparison_double_shift,
        ------------ triple shift ------------
        bcu.utilization_30_day_class_benchmark_triple_shift,

           case 
           when rental_period_percent_triple_shift = 0 then 'No Utilization Reported'
           when rental_period_percent_triple_shift - utilization_30_day_class_benchmark  >= .25 then 'Higher Utilization'
           when rental_period_percent_triple_shift - utilization_30_day_class_benchmark < .25
            and  rental_period_percent_triple_shift - utilization_30_day_class_benchmark > -.25 then 'Average Utilization'
        when rental_period_percent_triple_shift - utilization_30_day_class_benchmark <= -.25 then 'Lower Utilization'
        else 'Class Does Not Report Utilization' end as class_utilization_comparison_triple_shift,
           -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- ---- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
           bcat.distinct_asset_count as benchmarked_category_asset_count,
           bcat.utilization_30_day_cateogry_benchmark as utilization_30_day_category_benchmark,
             case
        when benchmarked_category_asset_count is null then 'Category Does Not Report Utilization'
        when benchmarked_category_asset_count >= 1000 then '1,000+'
        when benchmarked_category_asset_count >= 500 then '500 - 1,000'
        when benchmarked_category_asset_count >= 100 then '100 - 500'
        when benchmarked_category_asset_count >= 50 then '50 - 100'
        when benchmarked_category_asset_count > 5 then 'Less than 50'
        else 'Not Enough Comparable Assets' end as category_comparable_assets
       ,

           case 
           when rental_period_percent = 0 then 'No Utilization Reported'
           when rental_period_percent - utilization_30_day_cateogry_benchmark  >= .25 then 'Higher Utilization'
           when rental_period_percent - utilization_30_day_cateogry_benchmark < .25
            and  rental_period_percent - utilization_30_day_cateogry_benchmark > -.25 then 'Average Utilization'
        when rental_period_percent - utilization_30_day_cateogry_benchmark <= -.25 then 'Lower Utilization'
        else 'Class Does Not Report Utilization' end as category_utilization_comparison,
           --
           pcat.RENTAL_DATE_COUNT as benchmarked_parent_category_asset_count,
           pcat.UTILIZATION_30_DAY_PARENT_CATEGORY_BENCHMARK,
             case
             when benchmarked_parent_category_asset_count is null then 'Parent Category Does Not Report Utilization'
        when benchmarked_parent_category_asset_count >= 1000 then '1,000+'
        when benchmarked_parent_category_asset_count >= 500 then '500 - 1,000'
        when benchmarked_parent_category_asset_count >= 100 then '100 - 500'
        when benchmarked_parent_category_asset_count >= 50 then '50 - 100'
        when benchmarked_parent_category_asset_count > 5 then 'Less than 50'
        else 'Not Enough Comparable Assets' end as parent_category_comparable_assets
       ,
           case 
           when rental_period_percent = 0 then 'No Utilization Reported'
           when rental_period_percent - UTILIZATION_30_DAY_PARENT_CATEGORY_BENCHMARK  >= .25 then 'Higher Utilization'
           when rental_period_percent - UTILIZATION_30_DAY_PARENT_CATEGORY_BENCHMARK < .25
            and  rental_period_percent - UTILIZATION_30_DAY_PARENT_CATEGORY_BENCHMARK > -.25 then 'Average Utilization'
        when rental_period_percent - UTILIZATION_30_DAY_PARENT_CATEGORY_BENCHMARK <= -.25 then 'Lower Utilization'
        else 'Class Does Not Report Utilization' end as parent_category_utilization_comparison,
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- ---- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

           public_health_status,
           cv.SUB_RENTER_ID, 
           cv.SUB_RENTER_COMPANY_ID, 
           cv.SUB_RENTING_COMPANY, 
           cv.SUB_RENTING_CONTACT,
           r.shift_type_id,
           osb.primary_salesperson_id,
           concat(ps.first_name,' ', ps.last_name) as primary_salesperson_name,
           osb.total_secondary_salespersons,
           osb.secondary_salesperson_1,
           concat(ss.first_name,' ', ss.last_name) as secondary_salesperson_name,
           coalesce(ehc.in_engine_hours_stream_flag, FALSE) as t3_map_flag,
           CURRENT_TIMESTAMP()::timestamp_ntz AS data_refresh_timestamp,
           COALESCE(rud.total_days_used_on_rent, 0) AS total_days_used_on_rent,
           GREATEST(0, COALESCE(ac.total_days_on_rent, 0) - COALESCE(rud.total_days_used_on_rent, 0)) AS total_days_not_used_on_rent,
           COALESCE(rud.total_weekdays_used_on_rent, 0) AS total_weekdays_used_on_rent,
           GREATEST(0, COALESCE(total_weekdays_on_rent, 0) - COALESCE(rud.total_weekdays_used_on_rent, 0)) AS total_weekdays_not_used_on_rent,
           rud.last_use_date AS last_use_date,
           DATEDIFF(DAY, rud.last_use_date, CURRENT_DATE()) AS days_since_last_use
      from
          asset_list_rental alr
          join {{ ref('platform', 'es_warehouse__public__rentals') }} r on alr.rental_id = r.rental_id
          left join {{ ref('platform', 'es_warehouse__public__equipment_assignments') }} ea on ea.asset_id = alr.asset_id and ea.rental_id = alr.rental_id and alr.start_date::date >= ea.start_date::date and alr.end_date::date <= coalesce(ea.end_date::date,'2999-12-31')
          left join {{ ref('platform', 'es_warehouse__public__assets') }} a on alr.asset_id = a.asset_id
          left join {{ ref('platform', 'es_warehouse__public__rental_part_assignments') }} rpa on rpa.rental_id = r.rental_id
          left join {{ ref('platform', 'es_warehouse__inventory__parts') }}  p on p.part_id = rpa.part_id
          left join {{ ref('platform', 'es_warehouse__inventory__part_types') }}  pt on pt.part_type_id = p.part_type_id
          left join {{ ref('platform', 'es_warehouse__public__rental_location_assignments') }} rla on rla.rental_id = alr.rental_id and (rla.end_date >= current_timestamp OR rla.end_date is null)
          left join {{ ref('platform', 'es_warehouse__public__locations') }} l on l.location_id = rla.location_id
          left join {{ ref('platform', 'es_warehouse__public__states') }}  s on s.state_id = l.state_id
          left join {{ ref('platform', 'es_warehouse__public__admin_cycle') }}  ac on r.rental_id = ac.rental_id and ac.asset_id = ea.asset_id
          left join {{ ref('platform', 'es_warehouse__public__orders') }}  o on r.order_id = o.order_id
          left join {{ ref('platform', 'es_warehouse__public__markets') }}  m on m.market_id = o.market_id
          left join {{ ref('platform', 'es_warehouse__public__companies') }}  cm on cm.company_id = m.company_id
          left join {{ ref('platform', 'es_warehouse__public__purchase_orders') }}  po on po.purchase_order_id = o.purchase_order_id
          left join {{ ref('platform', 'es_warehouse__public__users') }}  u on u.user_id = o.user_id
          join {{ ref('platform', 'es_warehouse__public__companies') }}  c on c.company_id = u.company_id
          left join {{ ref('platform', 'es_warehouse__public__photos') }}  photo on a.photo_id = photo.photo_id
          left join {{ ref('platform', 'es_warehouse__public__trackers_mapping') }}  tm on tm.asset_id = a.asset_id
          left join 
          (
            SELECT ASSET_ID, SUB_RENTER_ID, SUB_RENTER_COMPANY_ID, SUB_RENTING_COMPANY, SUB_RENTING_CONTACT 
            FROM business_intelligence.triage.stg_t3__company_values
            QUALIFY ROW_NUMBER() OVER(PARTITION BY ASSET_ID ORDER BY START_DATE desc) = 1 --most recent 
          ) cv on alr.asset_id = cv.asset_id
         
          left join
          (
          select
              r.rental_id,
              sum(coalesce(li.total, 0)) as amount
          from
              {{ ref('platform', 'es_warehouse__public__orders') }} o
              join {{ ref('platform', 'es_warehouse__public__rentals') }} r on o.order_id = r.order_id
              join {{ ref('platform', 'es_warehouse__public__global_line_items') }}  li on r.rental_id = li.rental_id
              join {{ ref('platform', 'es_warehouse__public__users') }}  u on u.user_id = o.user_id
          where (li.line_item_type_id = 8 and domain_id = 0)
          or (li.line_item_type_id = 1 and domain_id = 1)
          group by
              r.rental_id
          ) amt on amt.rental_id = r.rental_id
          left join {{ ref('stg_t3__by_day_utilization') }} bdu on bdu.asset_id = a.asset_id 
          and bdu.date = dateadd('day',-1,bdu.data_refresh_timestamp)::date
          and (bdu.rental_company_id = c.company_id or bdu.owner_company_id = c.company_id
            or (bdu.owner_company_id IS NULL AND bdu.rental_company_id IS NULL)
            )
          left join BUSINESS_INTELLIGENCE.triage.stg_t3__by_day_utilization bdu2 on bdu2.asset_id = a.asset_id and bdu2.date = two_days_ago_date
          and bdu2.date = dateadd('day',-2,bdu.data_refresh_timestamp)::date
          and (bdu2.rental_company_id = c.company_id or bdu2.owner_company_id = c.company_id
            or (bdu2.owner_company_id IS NULL AND bdu2.rental_company_id IS NULL)
            )
          left join BUSINESS_INTELLIGENCE.triage.stg_t3__by_day_utilization bdu3 on bdu3.asset_id = a.asset_id and bdu3.date = three_days_ago_date
          and bdu3.date = dateadd('day',-3,bdu.data_refresh_timestamp)::date
          and (bdu3.rental_company_id = c.company_id or bdu3.owner_company_id = c.company_id
            or (bdu3.owner_company_id IS NULL AND bdu3.rental_company_id IS NULL)
            )
          left join BUSINESS_INTELLIGENCE.triage.stg_t3__by_day_utilization bdu4 on bdu4.asset_id = a.asset_id and bdu4.date = four_days_ago_date
          and bdu4.date = dateadd('day',-4,bdu.data_refresh_timestamp)::date
          and (bdu4.rental_company_id = c.company_id or bdu4.owner_company_id = c.company_id
            or (bdu4.owner_company_id IS NULL AND bdu4.rental_company_id IS NULL)
            )
          left join BUSINESS_INTELLIGENCE.triage.stg_t3__by_day_utilization bdu5 on bdu5.asset_id = a.asset_id and bdu5.date = five_days_ago_date
          and bdu5.date = dateadd('day',-5,bdu.data_refresh_timestamp)::date
          and (bdu5.rental_company_id = c.company_id or bdu5.owner_company_id = c.company_id
            or (bdu5.owner_company_id IS NULL AND bdu5.rental_company_id IS NULL)
            )
          left join BUSINESS_INTELLIGENCE.triage.stg_t3__by_day_utilization bdu6 on bdu6.asset_id = a.asset_id and bdu6.date = six_days_ago_date
          and bdu6.date = dateadd('day',-6,bdu.data_refresh_timestamp)::date
          and (bdu6.rental_company_id = c.company_id or bdu6.owner_company_id = c.company_id
            or (bdu6.owner_company_id IS NULL AND bdu6.rental_company_id IS NULL)
            )
          left join BUSINESS_INTELLIGENCE.triage.stg_t3__by_day_utilization bdu7 on bdu7.asset_id = a.asset_id and bdu7.date = seven_days_ago_date
          and bdu7.date = dateadd('day',-7,bdu.data_refresh_timestamp)::date
          and (bdu7.rental_company_id = c.company_id or bdu7.owner_company_id = c.company_id
            or (bdu7.owner_company_id IS NULL AND bdu7.rental_company_id IS NULL)
            )
          left join rental_on_time rot on a.asset_id = rot.asset_id
          left join {{ ref('platform', 'es_warehouse__public__asset_last_location') }} ll on ll.asset_id = a.asset_id
          left join (
            select
                asset_id, rental_id, company_id,
                listagg(name, ' /// ') within group(order by name) geofences
            from (
                    select distinct asset_id, g.name, age.rental_id, g.company_id
                    from
                        {{ ref('platform', 'es_warehouse__public__asset_geofence_encounters') }} age
                    join
                        {{ ref('platform', 'es_warehouse__public__geofences') }} g on g.geofence_id = age.geofence_id
                    where
                        encounter_end_timestamp is null
                        and g.geofence_type_id is null
                    )
                group by asset_id, rental_id, company_id
                
          ) age on age.rental_id = alr.rental_id
          left join (select asset_id, value as last_location_timestamp from {{ ref('platform', 'es_warehouse__public__asset_status_key_values') }} where name = 'last_location_timestamp') lc on lc.asset_id = a.asset_id
      left join BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__ASSET_INFO ai on ai.asset_id = alr.asset_id
      left join BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__BENCHMARKS_CLASS_UTILIZATION bcu on ai.equipment_class_id = bcu.equipment_class_id
      left join BUSINESS_INTELLIGENCE.TRIAGE.stg_t3_benchmark_category bcat on ai.category = bcat.category
      left join BUSINESS_INTELLIGENCE.TRIAGE.stg_t3__benchmark_parent_category pcat on ai.parent_category = pcat.parent_category
      left join BUSINESS_INTELLIGENCE.TRIAGE.stg_t3__national_account_assignments pcr on pcr.company_id = o.company_id
      left join es_warehouse.public.companies pc on pc.company_id = pcr.parent_company_id
      left join rental_used_days rud on rud.rental_id = r.rental_id and rud.asset_id  = a.asset_id
      left join current_tracker_status cts on alr.asset_id = cts.asset_id
      left join orders_salesperson_breakdown osb on osb.order_id = o.order_id
      left join {{ref('platform','es_warehouse__public__users')}} ps on ps.user_id = osb.primary_salesperson_id
      left join {{ref('platform','es_warehouse__public__users')}} ss on ss.user_id = osb.secondary_salesperson_1
      left join kakfa_engine_hours_check ehc on ai.asset_id = ehc.asset_id
      where r.rental_status_id = 5

