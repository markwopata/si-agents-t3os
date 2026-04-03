view: work_orders {
  sql_table_name: "WORK_ORDERS"."WORK_ORDERS"
    ;;
  drill_fields: [work_order_id]

  dimension: work_order_id {
    primary_key: yes
    type: number
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
    type: number
    sql: ${TABLE}."_WORK_ORDER_ID" ;;
  }

  dimension: _work_order_status_id {
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
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: billing_notes {
    type: string
    sql: ${TABLE}."BILLING_NOTES" ;;
  }

  dimension: billing_type_id {
    type: number
    sql: ${TABLE}."BILLING_TYPE_ID" ;;
  }

  dimension: branch_id {
    type: number
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
      quarter,
      year
    ]
    sql: CAST(${TABLE}."DATE_COMPLETED" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_created {
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
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  measure: first_WO_date {
    type: date
    sql: MIN(${TABLE}."DATE_CREATED") ;;
    convert_tz: no
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

  dimension: mileage_at_service {
    type: number
    sql: ${TABLE}."MILEAGE_AT_SERVICE" ;;
  }

  dimension: severity_level_id {
    type: number
    sql: ${TABLE}."SEVERITY_LEVEL_ID" ;;
  }

  dimension: solution {
    type: string
    sql: ${TABLE}."SOLUTION" ;;
  }

  dimension: urgency_level_id {
    type: number
    sql: ${TABLE}."URGENCY_LEVEL_ID" ;;
  }

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

  measure: count {
    type: count
    drill_fields: [work_order_id, work_order_status_name]
  }
}
