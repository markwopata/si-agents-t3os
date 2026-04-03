view: inventory_balances_snapshot {
  sql_table_name: "PUBLIC"."INVENTORY_BALANCES_SNAPSHOT" ;;

  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
  }
  dimension: cost {
    type: number
    sql: ${TABLE}."COST" ;;
  }
  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }
  dimension: max {
    type: number
    sql: ${TABLE}."MAX" ;;
  }
  dimension: min {
    type: number
    sql: ${TABLE}."MIN" ;;
  }
  dimension: parent_id {
    type: number
    sql: ${TABLE}."PARENT_ID" ;;
  }
  dimension: part_id {
    type: number
    sql: ${TABLE}."PART_ID" ;;
  }
  dimension: part_number {
    type: string
    sql: ${TABLE}."PART_NUMBER" ;;
  }
  dimension: provider_name {
    type: string
    sql: ${TABLE}."PROVIDER_NAME" ;;
  }
  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }
  dimension: store_id {
    type: number
    sql: ${TABLE}."STORE_ID" ;;
  }
  dimension: store_name {
    type: string
    sql: ${TABLE}."STORE_NAME" ;;
  }
  dimension: store_part_id {
    type: number
    sql: ${TABLE}."STORE_PART_ID" ;;
  }
  dimension_group: timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP";;
  }
  dimension: total {
    type: number
    sql: ${TABLE}."TOTAL" ;;
  }
  dimension: total_value {
    type: string
    sql: ${TABLE}."TOTAL_VALUE" ;;
  }
}
