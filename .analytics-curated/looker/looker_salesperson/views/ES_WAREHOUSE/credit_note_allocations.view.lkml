view: credit_note_allocations {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."CREDIT_NOTE_ALLOCATIONS"
    ;;
  drill_fields: [credit_note_allocation_id]

  dimension: credit_note_allocation_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."CREDIT_NOTE_ALLOCATION_ID" ;;
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

  dimension: allocation_type_id {
    type: number
    sql: ${TABLE}."ALLOCATION_TYPE_ID" ;;
  }

  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }

  dimension: created_by_user_id {
    type: number
    sql: ${TABLE}."CREATED_BY_USER_ID" ;;
  }

  dimension: credit_note_id {
    type: number
    sql: ${TABLE}."CREDIT_NOTE_ID" ;;
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

  dimension: erp_allocated_to_id {
    type: string
    sql: ${TABLE}."ERP_ALLOCATED_TO_ID" ;;
  }

  dimension_group: erp_creation {
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
    sql: CAST(${TABLE}."ERP_CREATION_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [credit_note_allocation_id]
  }
}
