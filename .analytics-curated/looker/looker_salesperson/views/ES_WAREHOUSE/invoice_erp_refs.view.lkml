view: invoice_erp_refs {
  sql_table_name: "PUBLIC"."INVOICE_ERP_REFS"
    ;;
  drill_fields: [invoice_erp_ref_id]

  dimension: invoice_erp_ref_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."INVOICE_ERP_REF_ID" ;;
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

  dimension: erp_instance_id {
    type: number
    sql: ${TABLE}."ERP_INSTANCE_ID" ;;
  }

  dimension: intacct_invoice_no {
    type: string
    sql: ${TABLE}."INTACCT_INVOICE_NO" ;;
  }

  dimension: intacct_record_no {
    type: string
    sql: ${TABLE}."INTACCT_RECORD_NO" ;;
  }

  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [invoice_erp_ref_id]
  }
}
