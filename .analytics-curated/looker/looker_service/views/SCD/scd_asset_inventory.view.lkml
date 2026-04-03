view: scd_asset_inventory {
  sql_table_name: "ES_WAREHOUSE"."SCD"."SCD_ASSET_INVENTORY" ;;
  drill_fields: [scd_asset_inventory_id]

  dimension: scd_asset_inventory_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."SCD_ASSET_INVENTORY_ID" ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: current_flag {
    type: yesno
    sql: ${TABLE}."CURRENT_FLAG" ;;
  }
  dimension_group: date_end {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_END" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_start {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_START" AS TIMESTAMP_NTZ) ;;
  }
  dimension: inventory_branch_id {
    type: number
    sql: ${TABLE}."INVENTORY_BRANCH_ID" ;;
  }
  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }
  measure: count {
    type: count
    drill_fields: [scd_asset_inventory_id]
  }
}

view: prev_and_current_asset_inventory {
  derived_table: {
    sql: with prep as (
    select asset_id
        , lag(inventory_branch_id) over (partition by asset_id order by date_start asc) as prev_inventory_branch_id
        , lag(date_end) over (partition by asset_id order by date_start asc) prev_inventory_branch_end_date
        , inventory_branch_id current_inventory_branch_id
        , current_flag
    from ${scd_asset_inventory.SQL_TABLE_NAME} scd
)

select asset_id
    , prev_inventory_branch_id
    , pm.name as prev_inventory_branch_name
    , prev_inventory_branch_end_date
    , current_inventory_branch_id
    , cm.name as current_inventory_branch_name
from prep p
left join ES_WAREHOUSE.PUBLIC.MARKETS pm
    on pm.market_id = p.prev_inventory_branch_id
left join ES_WAREHOUSE.PUBLIC.MARKETS cm
    on cm.market_id = p.current_inventory_branch_id
where current_flag = TRUE ;;
  }

  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.asset_id ;;
  }

  dimension: prev_inventory_branch_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.prev_inventory_branch_id ;;
  }

  dimension: prev_inventory_branch_name {
    type: string
    sql: ${TABLE}.prev_inventory_branch_name ;;
  }

  dimension_group: prev_inventory_branch_end {
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
    sql: ${TABLE}.prev_inventory_branch_end_date ;;
  }

  dimension: current_inventory_branch_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.current_inventory_branch_id  ;;
  }

  dimension: current_inventory_branch_name {
    type: string
    sql: ${TABLE}.current_inventory_branch_name ;;
  }
}
