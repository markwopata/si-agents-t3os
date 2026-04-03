view: employee_rewards_card {
  sql_table_name: "ANALYTICS"."EMPLOYEE_REWARDS"."REWARDS_ISSUED" ;;

  dimension_group: _fivetran_synced {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
    primary_key: yes
  }
  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
    value_format_name: usd
  }
  dimension: employee_id {
    type: string
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }
  dimension: employee_snapshot {
    type: string
    sql: ${TABLE}."EMPLOYEE_SNAPSHOT" ;;
  }
  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }
  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }
  dimension_group: reward {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."REWARD_DATE" ;;
  }
  dimension: reward_status {
    type: string
    sql: ${TABLE}."REWARD_STATUS" ;;
  }
  dimension: reward_type {
    type: string
    sql: ${TABLE}."REWARD_TYPE" ;;
  }
  measure: count {
    type: count
    drill_fields: [first_name, last_name]
  }
  measure: amount_total {
    type: sum
    sql: ${TABLE}."AMOUNT" ;;
    value_format_name: usd
  }
}
