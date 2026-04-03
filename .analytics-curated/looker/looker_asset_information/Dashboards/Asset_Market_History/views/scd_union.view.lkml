view: scd_union {
  derived_table: {
    sql:
select
asset_id,
service_branch_id as market_id,
date_start,
date_end,
user_id,
current_flag,
'Service Branch' as market_type
from es_warehouse.scd.scd_asset_msp

UNION

select
asset_id,
rental_branch_id as market_id,
date_start,
date_end,
user_id,
current_flag,
'Rental Branch' as market_type
from es_warehouse.scd.scd_asset_rsp

UNION

select
asset_id,
inventory_branch_id as market_id,
date_start,
date_end,
user_id,
current_flag,
'Inventory Branch' as market_type
from es_warehouse.scd.scd_asset_inventory
;;
  }

  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."ASSET_ID" ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id }}/status" target="_blank">{{rendered_value}}</a></font></u> ;;
  }

  dimension: market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension_group: start {
    type: time
    timeframes: [
      time,
      date,
      raw
    ]
    sql: ${TABLE}."DATE_START" ;;
  }

  dimension_group: end {
    type: time
    timeframes: [
      time,
      date,
      raw
    ]
    sql: ${TABLE}."DATE_END" ;;
  }

  dimension: user_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: current {
    type: yesno
    sql: ${TABLE}."CURRENT_FLAG" ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }



}
