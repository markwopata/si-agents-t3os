view: warranty_terms {
  sql_table_name: "ANALYTICS"."WARRANTIES"."WARRANTY_TERMS" ;;

  dimension_group: _fivetran_synced {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }
  dimension: mapped_vendor_name {
    type: string
    sql: ${TABLE}."MAPPED_VENDOR_NAME" ;;
  }
  dimension: warranty_hours {
    type: number
    sql: ${TABLE}."WARRANTY_HOURS" ;;
  }
  dimension: warranty_unlimited_hours {
    type: yesno
    sql: ${TABLE}."WARRANTY_UNLIMITED_HOURS" ;;
  }
  dimension: warranty_year {
    type: number
    sql: ${TABLE}."WARRANTY_YEAR" ;;
  }
  measure: count {
    type: count
    drill_fields: [mapped_vendor_name]
  }
}

view: vendor_warranty_terms_score {
  derived_table: {
    sql:
with cte as (
    select tvm.vendorid
        , wt.mapped_vendor_name
        , tvm.vendor_type
        , wt.warranty_year as vendor_warranty_years
        , wt.warranty_hours as vendor_warranty_hours
        , wt.warranty_unlimited_hours as vendor_unlimited_hours
    from ANALYTICS.WARRANTIES.WARRANTY_TERMS wt
    join ANALYTICS.PARTS_INVENTORY.TOP_VENDOR_MAPPING tvm
        on wt.mapped_vendor_name = tvm.mapped_vendor_name
            and tvm.primary_vendor ilike 'yes'
)

select a.vendorid
    , a.vendor_warranty_years
    , a.vendor_warranty_hours
    , a.vendor_unlimited_hours
    , avg(pa.vendor_warranty_years) as peer_avg_warranty_years
    , greatest(coalesce(peer_avg_warranty_years, 0), 3) as warranty_years_target
    , iff((a.vendor_warranty_years / warranty_years_target) * (1/14) > (1/14), (1/14), (a.vendor_warranty_years / warranty_years_target) * (1/14)) as vendor_warranty_years_score
    , iff((a.vendor_warranty_years / warranty_years_target) * 10 > 10, 10, (a.vendor_warranty_years / warranty_years_target) * 10) as vendor_warranty_years_score10

    , 3000 as ES_hours_goal
    , avg(iff(pa.vendor_unlimited_hours = true, ES_hours_goal, pa.vendor_warranty_hours)) as peer_avg_warranty_hours
    , greatest(coalesce(peer_avg_warranty_hours, 0), ES_hours_goal) as warranty_hours_target
    , iff(a.vendor_unlimited_hours = false, iff((a.vendor_warranty_hours / warranty_hours_target) * (1/14) > (1/14), (1/14), (a.vendor_warranty_hours / warranty_hours_target) * (1/14)), (1/14)) as vendor_warranty_hours_score
    , iff(a.vendor_unlimited_hours = false, iff((a.vendor_warranty_hours / warranty_hours_target) * 10 > 10, 10, (a.vendor_warranty_hours / warranty_hours_target) * 10), 10) as vendor_warranty_hours_score10
from cte a
left join cte pa
    on pa.vendorid <> a.vendorid
        and pa.vendor_type = a.vendor_type
group by 1,2,2,3,4,ES_hours_goal;;
  }
  dimension: vendorid {
    type: string
    sql: ${TABLE}.vendorid ;;
  }
  dimension: vendor_warranty_years {
    type: number
    sql: ${TABLE}.vendor_warranty_years ;;
  }
  dimension: vendor_warranty_hours {
    type: number
    sql: ${TABLE}.vendor_warranty_hours ;;
  }
  dimension: vendor_unlimited_hours {
    type: yesno
    sql: ${TABLE}.vendor_unlimited_hours ;;
  }
  dimension: peer_avg_warranty_years {
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}.peer_avg_warranty_years ;;
  }
  dimension: graded_target_years {
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}.warranty_years_target ;;
  }
  dimension: vendor_warranty_years_score {
    type: number
    value_format_name: decimal_2
    sql: coalesce(${TABLE}.vendor_warranty_years_score, 0) ;;
  }
  dimension: vendor_warranty_years_score10 {
    type: number
    value_format_name: decimal_1
    sql: coalesce(${TABLE}.vendor_warranty_years_score10, 0) ;;
  }
  dimension: peer_avg_warranty_hours {
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}.peer_avg_warranty_hours ;;
  }
  dimension: graded_target_hours {
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}.warranty_hours_target;;
  }
  dimension: vendor_warranty_hours_score {
    type: number
    value_format_name: decimal_2
    sql: coalesce(${TABLE}.vendor_warranty_hours_score, 0) ;;
  }
  dimension: vendor_warranty_hours_score10 {
    type: number
    value_format_name: decimal_1
    sql: coalesce(${TABLE}.vendor_warranty_hours_score10, 0) ;;
  }
}
