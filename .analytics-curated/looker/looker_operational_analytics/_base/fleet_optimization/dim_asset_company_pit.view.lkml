view: dim_asset_company_pit {
  sql_table_name: "FLEET_OPTIMIZATION"."GOLD"."DIM_ASSET_COMPANY_PIT" ;;

  dimension: asset_abs_during_window {
    type: yesno
    sql: ${TABLE}."ASSET_ABS_DURING_WINDOW" ;;
  }
  dimension: asset_has_changed_ownership {
    type: yesno
    sql: ${TABLE}."ASSET_HAS_CHANGED_OWNERSHIP" ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    value_format_name: id
  }
  dimension: asset_own_during_window {
    type: yesno
    sql: ${TABLE}."ASSET_OWN_DURING_WINDOW" ;;
  }
  dimension: company_ownership_duration {
    type: number
    sql: ${TABLE}."COMPANY_OWNERSHIP_DURATION" ;;
  }
  dimension_group: company_ownership_end {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."COMPANY_OWNERSHIP_END_DATE" ;;
  }
  dimension_group: company_ownership_start {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."COMPANY_OWNERSHIP_START_DATE" ;;
  }
  dimension: company_pit_key {
    type: string
    sql: ${TABLE}."COMPANY_PIT_KEY" ;;
  }
  dimension: current_company_id {
    type: number
    sql: ${TABLE}."CURRENT_COMPANY_ID" ;;
    value_format_name: id
  }
  dimension: is_current_company_assignment {
    type: yesno
    sql: ${TABLE}."IS_CURRENT_COMPANY_ASSIGNMENT" ;;
  }
  dimension: previous_company_id {
    type: number
    sql: ${TABLE}."PREVIOUS_COMPANY_ID" ;;
    value_format_name: id
  }
  measure: count {
    type: count
  }
}
