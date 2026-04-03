view: asset_util_eff_rate_rolling180 {
derived_table: {
  sql:
        WITH day_series AS (
        select distinct date_trunc('day', series)::date as day_date
        from table(es_warehouse.public.generate_series(
                                dateadd(day, -179, convert_timezone('UTC', '{{ _user_attributes['user_timezone'] }}', current_timestamp))::timestamp_tz,
                                convert_timezone('UTC', '{{ _user_attributes['user_timezone'] }}', current_timestamp + interval '1 day')::timestamp_tz,
                                'day'))
        )
        , all_assets_in_inventory_with_rental_status as (
        -- Assets in inventory at the start of the time period
            select distinct
              ds.day_date,
              sai.asset_id, initcap(aa.asset_type) as asset_type, sai.date_start, sai.date_end,
              coalesce(ec.name, 'No Asset Class') as asset_class,
              m.market_id as branch_id,
              m.name as branch,
              coalesce(aph.oec,a.purchase_price,0) as oec,
              aor.asset_start, aor.asset_end,
              case when day_date between aor.asset_start and aor.asset_end
                   then 1 else 0 end as on_rent_status,
              aor.rental_id
              /* REPLACING TO INCLUDE DELETED ASSETS USING RSP HISTORY LOGS; JOIN ON ASSET PURCHASE HISTORY FOR OEC FOR DELETED ASSETS */
      from ES_WAREHOUSE.SCD.scd_asset_rsp sai
        LEFT JOIN ES_WAREHOUSE.PUBLIC.asset_purchase_history aph on sai.asset_id = aph.asset_id
        left join es_warehouse.public.assets_aggregate aa on aa.asset_id = sai.asset_id
        left join ES_WAREHOUSE.PUBLIC.assets a on sai.asset_id = a.asset_id
        left join ES_WAREHOUSE.PUBLIC.equipment_classes ec on a.equipment_class_id = ec.equipment_class_id
        join ES_WAREHOUSE.PUBLIC.markets m on sai.rental_branch_id = m.market_id
        join ES_WAREHOUSE.PUBLIC.companies c on aa.company_id = c.company_id
--           from es_warehouse.public.assets_aggregate aa
--                  join ES_WAREHOUSE.SCD.scd_asset_inventory sai on aa.asset_id = sai.asset_id
--                  join ES_WAREHOUSE.PUBLIC.assets a on sai.asset_id = a.asset_id--
--                  left join ES_WAREHOUSE.PUBLIC.equipment_classes ec on a.equipment_class_id = ec.equipment_class_id
--                  join ES_WAREHOUSE.PUBLIC.markets m on coalesce(a.rental_branch_id, a.inventory_branch_id) = m.market_id
--                  join ES_WAREHOUSE.PUBLIC.companies c on a.company_id = c.company_id
                  join day_series ds
                              on ds.day_date >= (convert_timezone( '{{ _user_attributes['user_timezone'] }}', sai.date_start))
                                     AND ds.day_date <= coalesce((convert_timezone( '{{ _user_attributes['user_timezone'] }}', sai.date_end)), '2099-12-31')
              -- using view vs SCD for rental status due to SCD inaccuracies
                  left join ${asset_on_rent_statuses_2021.SQL_TABLE_NAME} aor on aa.asset_id = aor.asset_id
                                  AND ds.day_date::date between aor.asset_start and aor.asset_end
            where m.company_id = {{ _user_attributes['company_id'] }}
              -- removed deleted assets prior to the time period based on the SDC asset inventory table
              and ES_WAREHOUSE.PUBLIC.overlaps(sai.date_start, sai.date_end,
                                               convert_timezone('UTC', '{{ _user_attributes['user_timezone'] }}', current_timestamp)::date - interval '180 days',
                                               convert_timezone('UTC',  '{{ _user_attributes['user_timezone'] }}', current_timestamp)::date + interval '59 mins' + interval '59 seconds')
        )
          select inv.*,
            coalesce(effective_daily_rate,0) as effective_daily_rate
          from all_assets_in_inventory_with_rental_status inv
            left join ${effective_day_rate_by_asset_id.SQL_TABLE_NAME}
                on
                    inv.asset_id = effective_day_rate_by_asset_id.asset_id
                    and inv.rental_id = effective_day_rate_by_asset_id.rental_id
        ;;
}

dimension: compound_primary_key {
  primary_key: yes
  type: string
  sql: concat(${day_date}, ${asset_id}) ;;
}

dimension_group: day {
  label: "Date"
  type: time
  timeframes: [date, week]
  sql: ${TABLE}."DAY_DATE" ;;
}

dimension: asset_id {
  type: number
  sql: ${TABLE}."ASSET_ID" ;;
  value_format_name: id
}

dimension: branch_id {
  type: number
  sql: ${TABLE}."BRANCH_ID" ;;
  value_format_name: id
}

dimension: asset_type {
  type: string
  sql: ${TABLE}."ASSET_TYPE" ;;
}

dimension: asset_class {
  type: string
  sql: ${TABLE}."ASSET_CLASS" ;;
}

dimension: branch {
  type: string
  sql: ${TABLE}."BRANCH" ;;
}

dimension: on_rent_status {
  type: number
  sql: ${TABLE}."ON_RENT_STATUS" ;;
}

dimension: oec {
  type: number
  sql: ${TABLE}."OEC" ;;
  value_format_name: usd_0
}

  dimension: asset_start {
    label: "Rental Start"
    type: date
    sql: ${TABLE}."ASSET_START" ;;
  }

  dimension: asset_end {
    label: "Rental End"
    type: date
    sql: ${TABLE}."ASSET_END" ;;
  }

  dimension: date_end {
    label: "Fleet End Date"
    type: date
    sql:  CASE WHEN ${TABLE}."DATE_END" <= CURRENT_DATE THEN ${TABLE}."DATE_END" ELSE NULL END;;
  }

  dimension: asset_status {
    description: "Only show asset status for active assets; not deleted assets since they can be in another company's fleet"
    type: string
    sql:  CASE WHEN ${TABLE}."DATE_END" >= CURRENT_DATE THEN ${asset_status_key_values.value} ELSE NULL END;;
  }

  dimension: active_asset_owner {
    description: "Only show asset owner for active assets; not deleted assets since they can be in another company's fleet"
    type: string
    sql:  CASE WHEN ${TABLE}."DATE_END" >= CURRENT_DATE THEN ${asset_class_customer_branch.asset_owner} ELSE NULL END;;
  }

  dimension: effective_daily_rate {
    type: number
    sql: ${TABLE}."EFFECTIVE_DAILY_RATE" ;;
  }

  ## OEC TOTALS FOR ON RENT AND ALL ASSETS

  measure: on_rent_oec {
    label: "On Rent OEC"
    type: sum
    sql: ${oec};;
    filters: [on_rent_status: "1"]
    value_format: "$0.0,,\" M\""
    drill_fields: [asset_class, oec, branch, asset_id]
  }

  measure: on_rent_oec_today {
    label: "On Rent OEC (Today)"
    type: sum
    sql: ${oec};;
    filters: [on_rent_status: "1", day_date: "Today"]
    value_format: "$0.0,,\" M\""
    drill_fields: [asset_class_customer_branch.asset_category, asset_class, oec, branch, asset_id]
  }

  measure: tot_asset_oec {
    label: "OEC"
    type: sum
    sql: ${oec};;
     value_format: "$0.0,,\" M\""
    drill_fields: [asset_class, oec, branch, asset_id]
  }

  measure: tot_asset_oec_today {
    label: "OEC (Current)"
    type: sum_distinct
    sql: ${oec};;
    filters: [day_date: "Today", date_end: "NULL"]
    value_format_name: usd_0
    drill_fields: [asset_class, oec, branch, asset_id]
  }

  measure: oec_count_percent_today {
    label: "OEC % (Current)"
    type: percent_of_total
    sql: ${tot_asset_oec_today} ;;
  }

  ## ON RENT ASSET COUNT FOR ALL TIME PERIODS

  measure: assets_considered_on_rent {
    type: sum_distinct
    sql: ${on_rent_status} ;;
    drill_fields: [asset_class, on_rent_status, asset_start, asset_end, branch, asset_id]
  }

  measure: assets_considered_on_rent_180d {
    label: "Days Asset On Rent (Last 180 Days)"
    type: sum_distinct
    sql: ${on_rent_status} ;;
    filters: [day_date: "Last 180 Days"]
  }

  measure: assets_considered_on_rent_30d {
    label: "Days Asset On Rent (Last 30 Days)"
    type: sum_distinct
    sql: ${on_rent_status} ;;
    filters: [day_date: "Last 30 Days"]
  }

  measure: assets_considered_on_rent_7d {
    label: "Days Asset On Rent (Last 7 Days)"
    type: sum_distinct
    sql: ${on_rent_status} ;;
    filters: [day_date: "Last 7 Days"]
  }

  measure: assets_considered_on_rent_today {
    label: "Assets On Rent (Current)"
    type: sum_distinct
    sql: ${on_rent_status} ;;
    filters: [day_date: "Today"]
    drill_fields: [asset_class, on_rent_status, oec, asset_start, asset_end, branch, asset_id]
  }

  ## OTHER METRICS

  measure: unavailable_OEC_percentage {
    label: "Unavailable OEC"
    type: number
    sql: (${tot_asset_oec} - ${on_rent_oec}) / case when ${tot_asset_oec} = 0 then NULL else ${tot_asset_oec} end ;;
    value_format_name: percent_1
    drill_fields: [day_date, asset_class, on_rent_status, total_asset_count, branch, asset_id]
  }

  ## TOTAL ASSET COUNT FOR ALL TIME PERIODS

  measure: total_asset_count {
    description: "Distinct asset count"
    type: count_distinct
    sql: ${asset_id} ;;
    filters: [date_end: "NULL"]
    drill_fields: [asset_class, oec, branch, asset_id]
  }

  measure: total_assets_over_time_period {
    type: count
  }

  measure: total_assets_180d {
    type: count
    filters: [day_date: "Last 180 Days"]
  }

  measure: total_assets_30d {
    type: count
    filters: [day_date: "Last 30 Days"]
  }

  measure: total_assets_7d {
    type: count
    filters: [day_date: "Last 7 Days"]
  }

  measure: total_assets_today {
    type: count
    filters: [day_date: "Today"]
    drill_fields: [asset_id]
  }

  ## DISTINCT ASSET COUNT FOR ALL TIME PERIODS

  measure: total_distinct_assets_360d {
    type: count_distinct
    sql: ${asset_id} ;;
    filters: [day_date: "Last 360 Days"]
  }

  measure: total_distinct_assets_180d {
    type: count_distinct
    sql: ${asset_id} ;;
    filters: [day_date: "Last 180 Days"]
  }

  measure: total_distinct_assets_90d {
    type: count_distinct
    sql: ${asset_id} ;;
    filters: [day_date: "Last 90 Days"]
  }

  measure: total_distinct_assets_30d {
    type: count_distinct
    sql: ${asset_id} ;;
    filters: [day_date: "Last 30 Days"]
  }

  measure: total_distinct_assets_7d {
    type: count_distinct
    sql: ${asset_id} ;;
    filters: [day_date: "Last 7 Days"]
  }

  measure: total_distinct_assets_today {
    type: count_distinct
    sql: ${asset_id};;
    filters: [day_date: "Today",
              date_end: "NULL"]
  }



  ## TOTAL EFFECTIVE DAILY RENTAL FOR ASSETS WITH OEC DATA FOR ALL TIME PERIODS

  measure: tot_est_rental_rev_for_oec_assets {
    label: "Est. Daily Rental Revenue"
    description: "Use to calculate in explore when using date filters"
    type: sum
    sql: CASE WHEN ${oec} = 0 then NULL ELSE ${effective_daily_rate} END ;;
    value_format_name: usd_0
  }

  measure: tot_est_rental_rev_for_oec_assets_180d {
    label: "Total Effective Daily Rate (180 Days)"
    type: sum
    sql: CASE WHEN ${oec} = 0 then NULL ELSE ${effective_daily_rate} END ;;
    filters: [day_date: "Last 180 Days"]
    value_format_name: usd_0
  }

  measure: tot_est_rental_rev_for_oec_assets_30d {
    label: "Total Effective Daily Rate (30 Days)"
    type: sum
    sql: CASE WHEN ${oec} = 0 then NULL ELSE NULLIF(${effective_daily_rate},0) END ;;
    filters: [day_date: "Last 30 Days"]
    value_format_name: usd_0
  }

  measure: tot_est_rental_rev_for_oec_assets_7d {
    label: "Total Effective Daily Rate (7 Days)"
    type: sum
    sql: CASE WHEN ${oec} = 0 then NULL ELSE ${effective_daily_rate} END ;;
    filters: [day_date: "Last 7 Days"]
    value_format_name: usd_0
  }

  measure: tot_est_rental_rev_for_oec_assets_today {
    label: "Total Effective Daily Rate (Today)"
    type: sum
    sql: CASE WHEN ${oec} = 0 then NULL ELSE ${effective_daily_rate} END ;;
    filters: [day_date: "Today"]
    value_format_name: usd_0
  }

  ## TOTAL EFFECTIVE DAILY RENTAL FOR ALL ASSETS FOR ALL TIME PERIODS (USED FOR AVG RENTAL REVENUE)

  measure: tot_est_rental_rev_360d {
    label: "Total Effective Daily Rate (360 Days)"
    type: sum
    sql: NULLIF(${effective_daily_rate},0) ;;
    filters: [day_date: "Last 360 Days"]
    value_format_name: usd_0
  }

  measure: tot_est_rental_rev_180d {
    label: "Total Effective Daily Rate (180 Days)"
    type: sum
     sql: NULLIF(${effective_daily_rate},0) ;;
    filters: [day_date: "Last 180 Days"]
    value_format_name: usd_0
  }

  measure: tot_est_rental_rev_90d {
    label: "Total Effective Daily Rate (90 Days)"
    type: sum
    sql: NULLIF(${effective_daily_rate},0) ;;
    filters: [day_date: "Last 90 Days"]
    value_format_name: usd_0
  }

  measure: tot_est_rental_rev_30d {
    label: "Total Effective Daily Rate (30 Days)"
    type: sum
     sql: NULLIF(${effective_daily_rate},0) ;;
    filters: [day_date: "Last 30 Days"]
    value_format_name: usd_0
  }


  ## ANNUALIZED TOTAL EFFECTIVE DAILY RENTAL FOR ASSETS WITH OEC FOR ALL PERIODS (USED FOR FINANCIAL UTILIZATION)

  measure: est_yearly_rental_rev_for_oec_assets_180d {
    label: "Annualized Rental Revenue (180 Days)"
    type: number
    sql: ${tot_est_rental_rev_for_oec_assets_180d} * 365 / 180 ;;
    value_format_name: usd_0
  }

  measure: est_yearly_rental_rev_for_oec_assets_30d {
    label: "Annualized Rental Revenue (30 Days)"
    type: number
    sql: ${tot_est_rental_rev_for_oec_assets_30d} * 365 / 30 ;;
    value_format_name: usd_0
  }

  measure: est_yearly_rental_rev_for_oec_assets_7d {
    label: "Annualized Rental Revenue (7 Days)"
    type: number
    sql: ${tot_est_rental_rev_for_oec_assets_7d} * 365 / 7 ;;
    value_format_name: usd_0
  }

  measure: est_yearly_rental_rev_for_oec_assets_today {
    label: "Annualized Rental Revenue (Today)"
    type: number
    sql: ${tot_est_rental_rev_for_oec_assets_today} * 365 ;;
    value_format_name: usd_0
  }

  ## FINANCIAL UTILIZATION FOR ALL TIME PERIODS

  measure: financial_utilization {
    type: number
    sql:  ${tot_est_rental_rev_for_oec_assets} * 365 / CASE WHEN ${tot_asset_oec} = 0 THEN NULL ELSE ${tot_asset_oec} END ;;
    value_format_name: percent_1
    drill_fields: [day_date,
      asset_class,
      asset_class_customer_branch.make,
      asset_class_customer_branch.model,
      on_rent_status,
      tot_est_rental_rev_for_oec_assets,
      oec,
      financial_utilization,
      branch,
      asset_id]
  }

  measure: financial_utilization_180d {
    label: "180D Financial Util"
    type: number
    sql:  ${tot_est_rental_rev_for_oec_assets_180d} * 365/ 180 / NULLIF(${tot_asset_oec_today},0);;
    value_format_name: percent_1
    drill_fields: [asset_class,
                  oec,
                  unit_utilization_today,
                  financial_utilization_today,
                  unit_utilization_7days,
                  financial_utilization_7d,
                  unit_utilization_30days,
                  financial_utilization_30d,
                  unit_utilization_180days,
                  financial_utilization_180d,
                  asset_id,
                  date_end,
                  asset_status,
                  active_asset_owner,
                  branch]
  }

  measure: financial_utilization_30d {
    label: "30D Financial Util"
    type: number
    sql:  ${tot_est_rental_rev_for_oec_assets_30d} * 365/ 30 / NULLIF(${tot_asset_oec_today},0) ;;
    value_format_name: percent_1
    drill_fields: [asset_class,
                  oec,
                  unit_utilization_today,
                  financial_utilization_today,
                  unit_utilization_7days,
                  financial_utilization_7d,
                  unit_utilization_30days,
                  financial_utilization_30d,
                  unit_utilization_180days,
                  financial_utilization_180d,
                  asset_id,
                  date_end,
                  asset_status,
                  branch]
  }

  measure: financial_utilization_7d {
    label: "7D Financial Util"
    type: number
    sql:  ${tot_est_rental_rev_for_oec_assets_7d} * 365/ 7 / NULLIF(${tot_asset_oec_today},0);;
    value_format_name: percent_1
    drill_fields: [asset_class,
                  oec,
                  unit_utilization_today,
                  financial_utilization_today,
                  unit_utilization_7days,
                  financial_utilization_7d,
                  unit_utilization_30days,
                  financial_utilization_30d,
                  unit_utilization_180days,
                  financial_utilization_180d,
                  asset_id,
                  date_end,
                  asset_status,
                  active_asset_owner,
                  branch]
  }

  measure: financial_utilization_today {
    label: "1D Financial Util"
    type: number
    sql:  ${tot_est_rental_rev_for_oec_assets_today} * 365/ NULLIF(${tot_asset_oec_today},0);;
    value_format_name: percent_1
    drill_fields: [asset_class,
                  oec,
                  unit_utilization_today,
                  financial_utilization_today,
                  unit_utilization_7days,
                  financial_utilization_7d,
                  unit_utilization_30days,
                  financial_utilization_30d,
                  unit_utilization_180days,
                  financial_utilization_180d,
                  asset_id,
                  date_end,
                  asset_status,
                  active_asset_owner,
                  branch]
  }

## UNIT UTILIZATION FOR EACH TIME PERIOD AND TO USE FOR DAILY CALCULATED FOR ROLLING 180

  measure: count_utilization {
    label: "Unit Utilization"
    description: "Calculates based on daily rolling basis"
    type: number
    sql: ${assets_considered_on_rent} / NULLIF( ${total_asset_count},0) ;;
    value_format_name: percent_1
    drill_fields: [day_date, asset_class, on_rent_status, total_asset_count, branch, asset_id]
  }

  measure: count_utilization_over_time_period {
    label: "Unit Utilization"
    description: "Calculates based on rolling when date filter in explore is used"
    type: number
    sql: ${assets_considered_on_rent} / NULLIF(${total_assets_over_time_period},0) ;;
    value_format_name: percent_1
  }

  measure: unit_utilization_180days {
    label: "180D Unit Util"
    type: number
    sql:  ${assets_considered_on_rent_180d} / NULLIF(${total_assets_180d},0);;
    value_format_name: percent_1
    drill_fields: [asset_class,
                  oec,
                  unit_utilization_today,
                  financial_utilization_today,
                  unit_utilization_7days,
                  financial_utilization_7d,
                  unit_utilization_30days,
                  financial_utilization_30d,
                  unit_utilization_180days,
                  financial_utilization_180d,
                  asset_id,
                  date_end,
                  asset_status,
                  active_asset_owner,
                  branch]
  }

  measure: unit_utilization_30days {
    label: "30D Unit Util"
    type: number
    sql: ${assets_considered_on_rent_30d} / NULLIF(${total_assets_30d},0);;
    value_format_name: percent_1
    drill_fields: [asset_class,
                oec,
                unit_utilization_today,
                financial_utilization_today,
                unit_utilization_7days,
                financial_utilization_7d,
                unit_utilization_30days,
                financial_utilization_30d,
                unit_utilization_180days,
                financial_utilization_180d,
                asset_id,
                date_end,
                asset_status,
                active_asset_owner,
                branch]
  }

  measure: unit_utilization_7days {
    label: "7D Unit Utilization"
    type: number
    sql:  ${assets_considered_on_rent_7d} / NULLIF(${total_assets_7d},0);;
    value_format_name: percent_1
    drill_fields: [asset_class,
                  oec,
                  unit_utilization_today,
                  financial_utilization_today,
                  unit_utilization_7days,
                  financial_utilization_7d,
                  unit_utilization_30days,
                  financial_utilization_30d,
                  unit_utilization_180days,
                  financial_utilization_180d,
                  asset_id,
                  date_end,
                  asset_status,
                  active_asset_owner,
                  branch]
  }

  measure: unit_utilization_today {
    label: "1D Unit Util"
    type: number
    sql:  ${assets_considered_on_rent_today} / NULLIF(${total_distinct_assets_today},0);;
    value_format_name: percent_1
    drill_fields: [asset_class,
                  oec,
                  unit_utilization_today,
                  financial_utilization_today,
                  unit_utilization_7days,
                  financial_utilization_7d,
                  unit_utilization_30days,
                  financial_utilization_30d,
                  unit_utilization_180days,
                  financial_utilization_180d,
                  asset_id,
                  date_end,
                  asset_status,
                  active_asset_owner,
                  branch]
  }

  ## AVERAGE REVENUE FOR ALL TIME PERIODS

  measure: avg_rental_rev_360d {
    label: "360D Avg Monthly Rev"
    type: number
    sql: ((case when ${tot_est_rental_rev_360d} is null then 0 else ${tot_est_rental_rev_360d} end / 360) * 30) / case when ${total_distinct_assets_360d} is null then 0 else ${total_distinct_assets_360d} end ;;
    value_format_name: usd_0
    drill_fields: [asset_class,
                  avg_rental_rev_30d,
                  avg_rental_rev_90d,
                  avg_rental_rev_180d,
                  avg_rental_rev_360d,
                  asset_id,
                  branch]
  }

  measure: avg_rental_rev_180d {
    label: "180D Avg Monthly Rev"
    type: number
    sql: ((case when ${tot_est_rental_rev_180d} is null then 0 else ${tot_est_rental_rev_180d} end / 180) * 30) / case when ${total_distinct_assets_180d} is null then 0 else ${total_distinct_assets_180d} end ;;
    value_format_name: usd_0
    drill_fields: [asset_class,
                  avg_rental_rev_30d,
                  avg_rental_rev_90d,
                  avg_rental_rev_180d,
                  avg_rental_rev_360d,
                  asset_id,
                  branch]
  }

  measure: avg_rental_rev_90d {
    label: "90D Avg Monthly Rev"
    type: number
    sql: ((case when ${tot_est_rental_rev_90d} is null then 0 else ${tot_est_rental_rev_90d} end / 90) * 30) / case when ${total_distinct_assets_90d} is null then 0 else ${total_distinct_assets_90d} end ;;
    value_format_name: usd_0
    drill_fields: [asset_class,
                  avg_rental_rev_30d,
                  avg_rental_rev_90d,
                  avg_rental_rev_180d,
                  avg_rental_rev_360d,
                  asset_id,
                  branch]
  }

  measure: avg_rental_rev_30d {
    label: "30D Avg Monthly Rev"
    type: number
    sql: ((case when ${tot_est_rental_rev_30d} is null then 0 else ${tot_est_rental_rev_30d} end / 30) * 30) / case when ${total_distinct_assets_30d} is null then 0 else ${total_distinct_assets_30d} end ;;
    value_format_name: usd_0
    drill_fields: [asset_class,
                  avg_rental_rev_30d,
                  avg_rental_rev_90d,
                  avg_rental_rev_180d,
                  avg_rental_rev_360d,
                  asset_id,
                  branch]
  }

  }
