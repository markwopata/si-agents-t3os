view: part_inventory_transactions {
  sql_table_name: "PUBLIC"."PART_INVENTORY_TRANSACTIONS" ;;

#UNDER CONSTRUCTION STILL

  dimension: key_field {
    primary_key: yes
    type: string
    sql: concat(cast(${TABLE}."TRANSACTION_ITEM_ID" as string),' ',${TABLE}."SRC")  ;;
  }

  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }

  dimension: consumption_transaction {
    type: yesno
    sql: ${TABLE}."TRANSACTION_TYPE_ID" in (3,7,13) ;;
  }

  dimension: possible_receiving_transaction { #under construction
    type: yesno
    sql: ${TABLE}."TRANSACTION_TYPE_ID" in (6,14,17,21,23) ;;
  }

  dimension: cost {
    type: number
    sql: ${TABLE}."COST" ;;
  }

  dimension: cost_per_item {
    type: number
    sql: ${TABLE}."COST_PER_ITEM" ;;
  }

  dimension: po_cost_per_line{ #under construction
    type: number
    sql: ${TABLE}."COST_PER_ITEM" * ${TABLE}."QUANTITY" ;;
  }

  dimension: created_by {
    type: string
    sql: ${TABLE}."CREATED_BY" ;;
  }

  dimension_group: date_completed {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year]
    sql: ${TABLE}."DATE_COMPLETED" ;;
  }

  dimension_group: snap_match {
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
    sql: iff(last_day(${TABLE}."DATE_COMPLETED", month) = last_day(current_date(), month), dateadd(day, -1, date_trunc(month, ${TABLE}."DATE_COMPLETED")), last_day(${TABLE}."DATE_COMPLETED", month)) ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: from_id {
    type: number
    sql: ${TABLE}."FROM_ID" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension_group: month_ {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year]
    sql: ${TABLE}."MONTH_" ;;
  }

  dimension: parent_store_id {
    type: number
    sql: ${TABLE}."PARENT_STORE_ID" ;;
  }

  dimension: part_id {
    type: number
    sql: ${TABLE}."PART_ID" ;;
  }

  dimension: part_number {
    type: string
    sql: ${TABLE}."PART_NUMBER" ;;
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }

  dimension: src {
    type: string
    sql: ${TABLE}."SRC" ;;
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

  dimension: to_id {
    type: number
    sql: ${TABLE}."TO_ID" ;;
  }

  dimension: transaction_age_days {
    type: number
    sql: datediff(day,${TABLE}."DATE_COMPLETED",current_date()) ;;
  }

  dimension: transaction_age_months {
    type: number
    sql: datediff(month,${TABLE}."DATE_COMPLETED",current_date()) ;;
  }

  dimension: transaction_id {
    type: number
    sql: ${TABLE}."TRANSACTION_ID" ;;
  }

  dimension: transaction_item_id {
    type: number
    sql: ${TABLE}."TRANSACTION_ITEM_ID" ;;
  }

  dimension: transaction_type {
    type: string
    sql: ${TABLE}."TRANSACTION_TYPE" ;;
  }

  dimension: transaction_type_id {
    type: number
    sql: ${TABLE}."TRANSACTION_TYPE_ID" ;;
  }

  dimension: url_track {
    type: string
    sql: ${TABLE}."URL_TRACK" ;;
  }

  measure: most_recent_transaction {
    type: min
    sql: ${transaction_age_days} ;;
  }

  measure: total_actual_cost {
    type: sum
    sql: ${po_cost_per_line} ;;
  }


}
