view: approved_invoice_salespersons {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."APPROVED_INVOICE_SALESPERSONS" ;;

  dimension: billing_approved {
    type: date_raw
    sql: ${TABLE}."BILLING_APPROVED_DATE" ;;
  }
  dimension: _es_update_timestamp {
    type: date_raw
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
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
    type: number
    sql: ${TABLE}."PRIMARY_SALESPERSON_ID" ;;
  }
}
