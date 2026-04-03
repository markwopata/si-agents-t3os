view: work_orders {
  sql_table_name: "ES_WAREHOUSE"."WORK_ORDERS"."WORK_ORDERS"
    ;;
  drill_fields: [work_order_id]

  dimension: work_order_id {
    primary_key: yes
    type: number
    value_format_name: id
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: _work_order_id {
    hidden: yes
    type: number
    sql: ${TABLE}."_WORK_ORDER_ID" ;;
  }

  dimension: _work_order_status_id {
    hidden: yes
    type: number
    sql: ${TABLE}."_WORK_ORDER_STATUS_ID" ;;
  }

  dimension_group: archived {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."ARCHIVED_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: billing_notes {
    type: string
    sql: ${TABLE}."BILLING_NOTES" ;;
  }

  dimension: billing_type_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."BILLING_TYPE_ID" ;;
  }

  dimension: branch_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: creator_user_id {
    type: number
    sql: ${TABLE}."CREATOR_USER_ID" ;;
  }

  dimension: customer_user_id {
    type: number
    sql: ${TABLE}."CUSTOMER_USER_ID" ;;
  }

  dimension_group: date_billed {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."DATE_BILLED" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_completed {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      month_name,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."DATE_COMPLETED" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_created {
    label: "Created"
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      month_name,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: days_to_bill {
    type: number
    sql: datediff(days, ${date_created_date}, ${date_billed_date}) ;;
  }

  measure: avg_days_to_bill {
    type: average
    value_format_name: decimal_0
    sql: ${days_to_bill} ;;
  }

  dimension: days_to_complete {
    type: number
    sql: datediff(days, ${date_created_date}, coalesce(${date_completed_date}, current_date())) ;;
  }

  measure: avg_days_to_complete {
    type: average
    value_format_name: decimal_1
    sql: ${days_to_complete};;
  }

  dimension_group: date_updated {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: reviewed {
    type: string
    sql:CASE WHEN (SUBSTRING(${description}, 1, 2) = 'HH') THEN TRUE
            WHEN  (SUBSTRING(${description}, 1, 2) = 'RA') THEN TRUE
            ELSE FALSE END;;
  }

  dimension_group: due {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."DUE_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: hours_at_service {
    type: number
    sql: ${TABLE}."HOURS_AT_SERVICE" ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }

  dimension: invoice_id {
    type: string
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: mileage_at_service {
    type: number
    sql: ${TABLE}."MILEAGE_AT_SERVICE" ;;
  }

  dimension: service_company_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."SERVICE_COMPANY_ID" ;;
  }

  dimension: severity_level_id {
    type: number
    sql: ${TABLE}."SEVERITY_LEVEL_ID" ;;
  }

  dimension: severity_level_name {
    type: string
    sql: ${TABLE}."SEVERITY_LEVEL_NAME" ;;
  }

  dimension: solution {
    type: string
    sql: ${TABLE}."SOLUTION" ;;
  }

  dimension: urgency_level_id {
    type: number
    sql: ${TABLE}."URGENCY_LEVEL_ID" ;;
  }

  # dimension: warranty_wo {
  #   type: yesno
  #   sql: ${billing_type_id} = 1  or ${work_order_company_tags.name} = '%warrant%';;
  # }

  dimension: work_order_status_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_STATUS_ID" ;;
  }

  dimension: work_order_status_name {
    type: string
    sql: ${TABLE}."WORK_ORDER_STATUS_NAME" ;;
  }

  dimension: work_order_type_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_TYPE_ID" ;;
  }

  dimension: work_order_type_name {
    type: string
    sql: ${TABLE}."WORK_ORDER_TYPE_NAME" ;;
  }

  dimension: work_order_type {
    type: string
    sql: case
          when ${work_order_type_id} = 1 then 'Work Order'
          when ${work_order_type_id} = 2 then 'Inspection'
          else null end
          ;;
  }

  measure: count {
    type: count
    label: "Count of Work Orders"
    drill_fields: [date_created_date
                  ,work_order_id_with_link_to_work_order
                  ,work_order_status_name
                  ,asset_id
                  ,market_region_xwalk.market_name
                  ,time_entries.total_hours
                  ,wo_parts_cost.total_cost
                  ]
  }
  measure: count_all_wos {
    type: count
    drill_fields: [detail*]
  }
  measure: work_order_count {
    type: count
    filters: [archived_date: "null",
      work_order_status_id: "3",
      work_order_type_id: "1"]
    drill_fields: [work_order_id_with_link_to_work_order, description, work_order_status_name, billing_types.name, work_orders_by_tag.count]
  }

  dimension: work_order_id_with_link_to_work_order {
    description: "Work Order ID with Link"
    label: "Work Order ID"
    type: string
    sql: ${work_order_id} ;;
    # html: <font color="blue "><u><a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="_blank">{{ work_order_id._value }}</a></font></u> ;;
    html: <a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="new" style="color: #0063f3; text-decoration: underline;">{{ work_order_id._value }}</a> ;;
  }

  dimension: work_order_url_text {
    label: "Work Order URL"
    type: string
    sql: CONCAT('https://app.estrack.com/#/service/work-orders/', ${work_order_id}) ;;
  }

  dimension: work_order_created_date_over_45_days {
    type: yesno
    sql: current_date - ${date_created_raw}::DATE > 45 ;;
  }

  measure: open_wos {
    type: yesno
    sql: ${total_open_wos} > 0 ;;
  }

  measure: work_order_over_45_days_total {
    type: count
    filters: [work_order_created_date_over_45_days: "yes"]
    drill_fields: [detail*]
  }

  measure: count_closed_work_orders {
    type: count
    drill_fields: [
      date_completed_date,
      work_order_id_with_link_to_work_order,
      work_order_status_name,
      billing_types.name,
      markets.name,
      assets.make,
      hours_at_service,
      time_entries.total_time_formatted,
      time_entries.estimated_labor,
      wo_parts_cost.est_parts_charge,
      assets.asset_id_wo_link,
      work_order_url_text]
  }

  measure: unbilled_customer_damage_wos {
    type: count_distinct
    filters: [
      billing_type_id: "2", # Customer
      work_order_status_id: "3", # Closed
      work_order_type_id: "1", # General
      ]
    sql: ${work_order_id} ;;
    drill_fields: [
      date_created_date,
      date_completed_date,
      work_order_id_with_link_to_work_order,
      work_order_url_text,
      markets.name,
      assets.asset_id_wo_link,
      assets.name,
      assets.make,
      time_entries.total_time_formatted,
      time_entries.estimated_labor,
      wo_parts_cost.est_parts_charge,
      wo_parts_cost.total_cost
    ]
  }

  measure: total_open_wos {
    type: count_distinct
    filters: [work_order_status_id: "1"]
    sql: ${work_order_id} ;;
    drill_fields: [detail*]
  }

  measure: total_open_wos_region_detail {
    type: count_distinct
    filters: [work_order_status_id: "1"]
    sql: ${work_order_id} ;;
    drill_fields: [
                  market_region_xwalk.market_id,
                  market_region_xwalk.market_name,
                  total_open_wos
                  ]
  }

  measure: transportation_open_wos {
    type: count_distinct
    sql: ${work_order_id} ;;
    drill_fields: [transportation_open_wo_detail*]
  }

  measure: transportation_unbilled_wos {
    type: count_distinct
    sql: ${work_order_id} ;;
    drill_fields: [transportation_unbilled_wo_detail*]
  }

  measure: closed_work_orders {
    type: count_distinct
    filters: [work_order_status_id: "3,4"]
    sql: ${work_order_id} ;;
  }

  measure: closed_work_orders_general {
    type: count_distinct
    filters: [work_order_status_id: "3,4", work_order_type_id: "1"]
    sql: ${work_order_id} ;;
  }

  measure: closed_work_orders_inspections {
    type: count_distinct
    filters: [work_order_status_id: "3,4", work_order_type_id: "2"]
    sql: ${work_order_id} ;;
  }

dimension: days_open {
  type: number
  sql: datediff('days',${date_created_date},coalesce(${date_completed_date},current_date())) ;;
}

measure: max_days_open {
  label: "Oldest WO days open"
  type: max
  sql: ${days_open} ;;
}

measure: 2_days_old {
  type: yesno
  sql: datediff('days',${date_created_date},current_date()) > 2 ;;
}

measure: open_sb_work_orders {
  type: count_distinct
  sql: ${work_order_id} ;;
  filters: [work_order_status_id: "1"]
  drill_fields: [service_bulletin_wo_detail*]
}

measure: closed_sb_work_orders {
  type: count_distinct
  sql: ${work_order_id} ;;
  filters: [work_order_status_id: "3,4"]
  drill_fields: [service_bulletin_wo_detail*]
}

measure: lasted_wo_completed {
  type: date
  sql: max(${date_completed_raw}) ;;
}

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      date_created_date,
      date_completed_date,
      work_order_id_with_link_to_work_order,
      work_order_url_text,
      description,
      work_order_status_name,
      days_open,
      billing_types.name,
      markets.name,
      assets.asset_id_wo_link,
      assets.name,
      assets.make,
      assets_aggregate.class,
      time_entries.total_time_formatted,
      time_entries.estimated_labor,
      wo_parts_cost.est_parts_charge,
      t3_purchase_order_details.po_number
    ]
  }

  set: transportation_open_wo_detail {
    fields: [
      asset_id,
      assets.year,
      assets.make,
      assets.model,
      company_purchase_order_line_items.license_plate,
      company_purchase_order_line_items.license_state_id,
      company_purchase_order_line_items.license_expiration_date,
      markets.name,
      work_order_id_with_link_to_work_order,
      date_created_date,
      users.created_by,
      2_days_old
    ]
  }

  set: transportation_unbilled_wo_detail {
    fields: [
      asset_id,
      assets.year,
      assets.make,
      assets.model,
      company_purchase_order_line_items.license_plate,
      company_purchase_order_line_items.license_state_id,
      company_purchase_order_line_items.license_expiration_date,
      markets.name,
      work_order_id_with_link_to_work_order,
      date_created_date,
      date_completed_date,
      users.created_by,
      2_days_old
    ]
  }

  set: service_bulletin_wo_detail {
    fields: [
      work_order_id_with_link_to_work_order,
      description,
      work_order_status_name,
      date_created_date,
      date_completed_date,
      date_billed_date,
      days_open,
      billing_types.name,
      v_markets.market_name,
      v_assets.asset_id,
      v_assets.asset_equipment_make,
      v_assets.asset_equipment_model_name,
      v_assets.asset_year,
      v_assets.asset_serial_number,
      time_entries.total_time_formatted,
      time_entries.estimated_labor,
      wo_parts_cost.est_parts_charge,
      work_order_files.count_images,
      warranty_team_billed_wo.is_warranty_team
    ]
  }
}

view: accumulated_depreciation_on_open_work_orders {
  derived_table: {
    sql:
-- Accumulated Depreciation on assets on currently open work orders
select wo.work_order_id
    , da.asset_id
    , (datediff(day, wo.date_created, current_date) * (.015 / (365 / 12))) * da.ASSET_CURRENT_OEC as accumulated_depreciation
from ${work_orders.SQL_TABLE_NAME} wo
join PLATFORM.GOLD.DIM_ASSETS da
    on da.asset_id = wo.asset_id
join ANALYTICS.PUBLIC.MARKET_REGION_XWALK m
    on m.market_id = wo.branch_id
where wo.work_order_status_name ilike 'open'
    and wo.archived_date is null ;;
  }

  dimension: work_order_id {
    type: number
    value_format_name: id
    primary_key: yes
    sql: ${TABLE}.work_order_id ;;
  }

  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.asset_id ;;
  }

  dimension: accumulated_depreciation {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.accumulated_depreciation ;;
  }

  measure: sum_accumulated_depreciation {
    type: sum
    value_format_name: usd_0
    sql: ${accumulated_depreciation} ;;
  }
}

view: expected_lost_revenue_on_open_hard_downs {
  derived_table: {
    sql:
with daily_rental_revenue as ( --daily revenue per asset at the district-class level
    select hu.dte as rev_date
        , m.market_district as district
        , da.asset_equipment_class_name as asset_class
        , count(distinct da.asset_id) as assets
        , sum(zeroifnull(hu.day_rate)) as rental_revenue
        , rental_revenue / assets as achieved_rental_rev_per_asset
    from analytics.public.historical_utilization hu
    join FLEET_OPTIMIZATION.GOLD.DIM_ASSETS_FLEET_OPT da
        on hu.asset_id = da.asset_id
    join FLEET_OPTIMIZATION.GOLD.DIM_MARKETS_FLEET_OPT m
        on m.market_id = hu.market_id
    where --dte >= dateadd(day,-400,current_date)
        hu.in_rental_fleet = true
    group by 1,2,3
)
select work_order_id
    , sum(zeroifnull(achieved_rental_rev_per_asset)) as district_class_expected_lost_revenue
    , row()
from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
join FLEET_OPTIMIZATION.GOLD.DIM_ASSETS_FLEET_OPT da
    on wo.asset_id = da.asset_id
join FLEET_OPTIMIZATION.GOLD.DIM_MARKETS_FLEET_OPT m
    on m.market_id = wo.branch_id
join daily_rental_revenue drr
    on drr.district = m.market_district
        and drr.asset_class = da.asset_equipment_class_name
        and drr.rev_date > wo.date_created::DATE
        and drr.rev_date <= current_date
where wo.archived_date is null
    and wo.work_order_status_name = 'Open'
    --and wo.severity_level_name = 'Hard Down'
group by 1;;
  }

  dimension: work_order_id {
    type: number
    value_format_name: id
    primary_key: yes
    sql: ${TABLE}.work_order_id ;;
  }

  dimension: district_class_expected_lost_revenue {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.district_class_expected_lost_revenue ;;
  }
  dimension: row_number {
    type: number
    value_format_name: id
    sql: ${TABLE}.row ;;
  }
}

view: time_between_failures {
  derived_table: {
    sql:
select wo.work_order_id
    , wo.asset_id
    , lag(wo.work_order_id) over (partition by wo.asset_id order by wo.date_completed asc) as prev_work_order_id
    , lag(wo.date_completed) over (partition by wo.asset_id order by wo.date_completed asc) as prev_work_order_completed
    , wo.date_created as new_work_order_created
    , datediff(day, prev_work_order_completed, wo.date_created) days_between_failures
    , iff(iea.asset_id is not null, true, false) second_wo_on_rent
    , r.rental_id
    , dc.company_id as rental_company_id
    , dc.company_name as rental_company_name
from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDER_ORIGINATORS woo
    on woo.work_order_id = wo.work_order_id
LEFT JOIN (
        SELECT DISTINCT work_order_id -- this is telematics and customer error/damage
        FROM ES_WAREHOUSE.WORK_ORDERS.WORK_ORDER_COMPANY_TAGS
        WHERE COMPANY_TAG_ID IN (23, 41, 7624, 54, 985, 980, 888, 393, 486, 400, 401, 1396, 1209)) wott
    ON wo.WORK_ORDER_ID = wott.WORK_ORDER_ID
left join ANALYTICS.ASSETS.INT_EQUIPMENT_ASSIGNMENTS iea
    on iea.asset_id = wo.asset_id
        and iea.date_start <= wo.date_created
        and iea.date_end >= wo.date_created
left join ES_WAREHOUSE.PUBLIC.RENTALS r
    on r.rental_id = iea.rental_id
left join ES_WAREHOUSE.PUBLIC.ORDERS o
    on o.order_id = r.order_id
left join FLEET_OPTIMIZATION.GOLD.DIM_COMPANIES_FLEET_OPT dc
    on dc.company_id = o.company_id
join FLEET_OPTIMIZATION.GOLD.DIM_MARKETS_FLEET_OPT dm
    on dm.market_id = wo.branch_id
        and dm.reporting_market
where wo.asset_id is not null
    and wo.work_order_type_name ilike 'General'
    and woo.originator_type_id <> 3
    and wo.archived_date is null
    and wott.work_order_id is null
qualify prev_work_order_completed is not null
    and days_between_failures >= 0 --Avoiding weird old work orders where they were left open for years
;;
  }

  dimension: work_order_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.work_order_id ;;
    html: <a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="new" style="color: #0063f3; text-decoration: underline;">{{ work_order_id._value }}</a> ;;
  }
  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.asset_id ;;
    html: <a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id._value }}" target="new" style="color: #0063f3; text-decoration: underline;">{{ asset_id._value }}</a> ;;
  }
  dimension: prev_work_order_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.prev_work_order_id ;;
    html: <a href="https://app.estrack.com/#/service/work-orders/{{ prev_work_order_id._value }}" target="new" style="color: #0063f3; text-decoration: underline;">{{ prev_work_order_id._value }}</a> ;;
  }
  dimension_group: prev_work_order_completed {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.prev_work_order_completed ;;
  }
  dimension_group: new_work_order_created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.new_work_order_created ;;
  }
  dimension: days_between_failures {
    type: number
    sql: ${TABLE}.days_between_failures ;;
  }
  measure: avg_days_between_failures {
    type: average
    value_format_name: decimal_0
    sql: ${days_between_failures} ;;
    drill_fields: [
      asset_id
      , prev_work_order_id
      , prev_work_order_completed_date
      , rental_id
      , rental_company_name
      , work_order_id
      , new_work_order_created_date
      , days_between_failures
    ]
  }
  dimension: second_wo_on_rent {
    type: yesno
    sql: ${TABLE}.second_wo_on_rent ;;
  }
  dimension: rental_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.rental_id ;;
    html: <a href="https://app.estrack.com/#/assets/all/rentals/{{ rental_id._value }}" target="new" style="color: #0063f3; text-decoration: underline;">{{ rental_id._value }}</a> ;;
  }
  dimension: rental_company_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.rental_company_id ;;
  }
  dimension: rental_company_name {
    type: string
    sql: ${TABLE}.rental_company_name ;;
  }
  measure: count {
    type: count
    drill_fields: [
      asset_id
      , prev_work_order_id
      , prev_work_order_completed_date
      , rental_id
      , rental_company_name
      , work_order_id
      , new_work_order_created_date
      , days_between_failures
      ]
  }
  dimension: time_between_failure_distribution_buckets {
    type: string
    sql:
    case
      when ${days_between_failures} <= 7 then '7 Day Failure'
      when ${days_between_failures} >= 8 and ${days_between_failures} <= 14 then '8 - 14 Day Failure'
      when ${days_between_failures} >= 15 and ${days_between_failures} <= 31 then '15 - 31 Day Failure'
      when ${days_between_failures} >= 32 and ${days_between_failures} <= 62 then '2 Month Failure'
      when ${days_between_failures} >= 63 and ${days_between_failures} <= 94 then '3 Month Failure'
      when ${days_between_failures} >= 95 and ${days_between_failures} <= 126 then '4 Month Failure'
      when ${days_between_failures} >= 127 and ${days_between_failures} <= 158 then '5 Month Failure'
      when ${days_between_failures} >= 159 and ${days_between_failures} <= 190 then '6 Month Failure'
      when ${days_between_failures} >= 191 and ${days_between_failures} <= 222 then '7 Month Failure'
      when ${days_between_failures} >= 223 and ${days_between_failures} <= 254 then '8 Month Failure'
      else '9+ Month Failure' end;;
  }
}
