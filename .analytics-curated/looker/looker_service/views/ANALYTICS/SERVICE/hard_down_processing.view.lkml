view: hard_down_processing {
  sql_table_name: "ANALYTICS"."SERVICE"."HARD_DOWN_PROCESSING" ;;

  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."CREATED_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: is_current {
    type: yesno
    sql: ${TABLE}."IS_CURRENT" ;;
  }
  dimension: note_added {
    type: string
    sql: ${TABLE}."NOTE_ADDED" ;;
  }
  dimension: repair_state {
    type: string
    sql: ${TABLE}."REPAIR_STATE" ;;
  }
  dimension: review_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."REVIEW_ID" ;;
    primary_key: yes
  }
  dimension: update_type {
    type: string
    sql: ${TABLE}."UPDATE_TYPE" ;;
  }
  dimension: user_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."USER_ID" ;;
  }
  dimension: work_order_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."WORK_ORDER_ID" ;;
    html: <a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="new" style="color: #0063f3; text-decoration: underline;">{{ work_order_id._value }}</a> ;;
  }
  measure: count {
    type: count
    drill_fields: [
      users.full_name
      , created_date
      , work_order_id
      , dim_assets_fleet_opt.asset_equipment_make_and_model
      , update_type
      , repair_state
      , work_orders.avg_days_to_bill
      , note_added
    ]
  }
}
