view: approved_invoice_salespersons {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."APPROVED_INVOICE_SALESPERSONS"
    ;;

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

  dimension_group: billing_approved {
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
    sql: CAST(${TABLE}."BILLING_APPROVED_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: primary_salesperson_id {
    type: number
    sql: ${TABLE}."PRIMARY_SALESPERSON_ID" ;;
  }

  dimension: secondary_salesperson_ids {
    type: string
    sql: ${TABLE}."SECONDARY_SALESPERSON_IDS" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
