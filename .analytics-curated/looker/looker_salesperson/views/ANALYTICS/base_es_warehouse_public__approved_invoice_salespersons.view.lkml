
view: base_es_warehouse_public__approved_invoice_salespersons {
  sql_table_name: analytics.intacct_models.base_es_warehouse_public__approved_invoice_salespersons ;;


  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: invoice_id {
    type: string
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: primary_salesperson_id {
    type: string
    sql: ${TABLE}."PRIMARY_SALESPERSON_ID" ;;
  }

  dimension: secondary_salesperson_ids {
    type: string
    sql: ${TABLE}."SECONDARY_SALESPERSON_IDS" ;;
  }

  dimension_group: _es_update_timestamp {
    type: time
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }

  set: detail {
    fields: [
        invoice_id,
  primary_salesperson_id,
  secondary_salesperson_ids,
  _es_update_timestamp_time
    ]
  }
}
