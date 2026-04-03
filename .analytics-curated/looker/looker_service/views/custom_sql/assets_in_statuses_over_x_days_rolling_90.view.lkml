view: assets_in_statuses_over_x_days_rolling_90 {
  derived_table: {
    # datagroup_trigger: Every_Two_Hours_Update
#     indexes: ["MARKET_ID"]
    sql: with get_past_days as
    (
    select
    dateadd(
    day,
    '-' || row_number() over (order by null),
    dateadd(day, '+1', current_date())
    ) as generated_date
    from table (generator(rowcount => 130))
    )
    ,status_in_days as (
    select
    pd.generated_date::date as generated_date,
    case when dayofweek(pd.generated_date) = 0 or dayofweek(pd.generated_date) = 6 then 1 else 0 end as weekendbinary,
    m.market_id,
    sais.asset_id,
    sais.asset_inventory_status,
    sais.date_start,
    coalesce(convert_timezone('America/Chicago',date_end)::date,convert_timezone('America/Chicago','UTC',current_date)) as date_end,
    case when asset_inventory_status IN ('Needs Inspection','Make Ready') AND (pd.generated_date::date - convert_timezone('America/Chicago',sais.date_start)::date) >= 3 then 1 end as ready_inspection_flag,
    case when asset_inventory_status IN ('Hard Down') AND (pd.generated_date::date - convert_timezone('America/Chicago',sais.date_start)::date) >= 30 then 1 end as hard_down_flag
    --(pd.generated_date::date - convert_timezone('America/Chicago',sais.date_start)::date) as days_in_status
    from
    ES_WAREHOUSE.SCD.scd_asset_inventory_status sais
    join get_past_days pd on pd.generated_date::date between convert_timezone('America/Chicago',sais.date_start)::date and coalesce(convert_timezone('America/Chicago',date_end)::date,convert_timezone('America/Chicago','UTC',current_date))
    inner join ES_WAREHOUSE.PUBLIC.assets a on a.asset_id = sais.asset_id
    inner join ES_WAREHOUSE.PUBLIC.markets m on m.market_id = a.rental_branch_id
    where
    m.company_id = 1854
    and a.asset_type_id = 1
    --and ((SUBSTR(TRIM(a.serial_number), 1, 3) != 'RR-' and SUBSTR(TRIM(a.serial_number), 1, 2) != 'RR') or a.serial_number is null)
    -- new re-rent logic based on how Fleet is handling these now. -Jack G 6/27/22
    and (LEFT(a.serial_number, 2) <> 'RR' or LEFT(a.custom_name, 2) <> 'RR' or a.company_id <> 11606)
    --AND sais.asset_id in (111145)
    --AND sais.asset_id in (17623)
    )
    ,removing_weekend_dates as (
    select
        generated_date,
        case when dayofweek(generated_date) = 0 or dayofweek(generated_date) = 6 then 1 else 0 end as weekendbinary
    from
        get_past_days
    where
        weekendbinary = 0
    order by
        generated_date desc
    limit 90
     )
     ,days_to_count_towards_status as (
     select
        wd.generated_date,
        sd.market_id,
        sd.asset_id,
        sd.asset_inventory_status,
        sd.date_start,
        sd.date_end,
        sd.ready_inspection_flag,
        sd.hard_down_flag
     from
        removing_weekend_dates wd
        left join status_in_days sd on wd.generated_date = sd.generated_date AND (sd.ready_inspection_flag = 1 OR sd.hard_down_flag = 1)
     )
     select
        generated_date,
        market_id,
        sum(case when asset_inventory_status = 'Needs Inspection' and ready_inspection_flag >= 1 then 1 end) as needs_inspection_count,
        sum(case when asset_inventory_status = 'Make Ready' and ready_inspection_flag >= 1 then 1 end) as make_ready_count,
        sum(case when asset_inventory_status = 'Hard Down' and hard_down_flag >= 1 then 1 end) as hard_down_count
     from
        days_to_count_towards_status
     where
        asset_inventory_status in ('Needs Inspection','Make Ready','Hard Down')
        --AND market_id = 9
     group by
        generated_date,
        market_id
     order by
        generated_date desc
    ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: generated_date {
    type: date
    sql: ${TABLE}.GENERATED_DATE ;;
  }

  dimension_group: generated_group {
    type: time
    timeframes: [raw, time, date, week, month]
    sql: ${TABLE}.GENERATED_DATE ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: needs_inspection_count {
    type: number
    sql: ${TABLE}."NEEDS_INSPECTION_COUNT" ;;
  }

  dimension: make_ready_count {
    type: number
    sql: ${TABLE}."MAKE_READY_COUNT" ;;
  }

  dimension: hard_down_count {
    type: number
    sql: ${TABLE}."HARD_DOWN_COUNT" ;;
  }

  measure: total_needs_inspection_count {
    type: sum
    sql: ${needs_inspection_count} ;;
  }

  measure: total_make_ready_count {
    type: sum
    sql: ${make_ready_count} ;;
  }

  measure: total_hard_down_count {
    type: sum
    sql: ${hard_down_count} ;;
  }

  measure: average_assets_in_needs_inspection {
    type: number
    sql: ${total_needs_inspection_count}/90 ;;
    value_format_name: decimal_1
    drill_fields: [detail_needs_inspection*]
  }

  measure: average_assets_in_make_ready {
    type: number
    sql: ${total_make_ready_count}/90 ;;
    value_format_name: decimal_1
    drill_fields: [detail_make_ready*]
  }

  measure: average_assets_in_hard_down {
    type: number
    sql: ${total_hard_down_count}/90 ;;
    value_format_name: decimal_1
    drill_fields: [detail_hard_down*]
  }

  set: detail {
    fields: [generated_date, market_id, needs_inspection_count, make_ready_count, hard_down_count]
  }

  set: detail_needs_inspection {
    fields: [generated_date, market_region_xwalk.region_name, market_region_xwalk.market_name, total_needs_inspection_count]
  }

  set: detail_make_ready {
    fields: [generated_date, market_region_xwalk.region_name, market_region_xwalk.market_name, total_make_ready_count]
  }

  set: detail_hard_down {
    fields: [generated_date, market_region_xwalk.region_name, market_region_xwalk.market_name, total_hard_down_count]
  }
}
