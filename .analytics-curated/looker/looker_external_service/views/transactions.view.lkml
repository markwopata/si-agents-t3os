view: transactions {
  sql_table_name: "INVENTORY"."TRANSACTIONS"
    ;;
  drill_fields: [transaction_id]

  dimension: transaction_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."TRANSACTION_ID" ;;
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

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: created_by {
    type: number
    sql: ${TABLE}."CREATED_BY" ;;
  }

  dimension: custom_id {
    type: string
    sql: ${TABLE}."CUSTOM_ID" ;;
  }

  dimension_group: date_cancelled {
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
    sql: ${TABLE}."DATE_CANCELLED" ;;
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
    sql: ${TABLE}."DATE_COMPLETED" ;;
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
    sql: ${TABLE}."DATE_CREATED" ;;
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
    sql: ${TABLE}."DATE_UPDATED" ;;
  }

  dimension: from_id {
    type: number
    sql: ${TABLE}."FROM_ID" ;;
  }

  dimension: memo {
    type: string
    sql: ${TABLE}."MEMO" ;;
  }

  dimension: modified_by {
    type: number
    sql: ${TABLE}."MODIFIED_BY" ;;
  }

  dimension: split_from {
    type: number
    sql: ${TABLE}."SPLIT_FROM" ;;
  }

  dimension: to_id {
    type: number
    sql: ${TABLE}."TO_ID" ;;
  }

  dimension: transaction_group_id {
    type: number
    sql: ${TABLE}."TRANSACTION_GROUP_ID" ;;
  }

  dimension: transaction_status_id {
    type: number
    sql: ${TABLE}."TRANSACTION_STATUS_ID" ;;
  }

  dimension: transaction_type_id {
    type: number
    sql: ${TABLE}."TRANSACTION_TYPE_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [transaction_id]
  }
}
