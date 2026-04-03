view: line_item_type_erp_refs {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."LINE_ITEM_TYPE_ERP_REFS" ;;
  drill_fields: [line_item_type_erp_ref_id]

  dimension: line_item_type_erp_ref_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."LINE_ITEM_TYPE_ERP_REF_ID" ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: erp_instance_id {
    type: number
    sql: ${TABLE}."ERP_INSTANCE_ID" ;;
  }
  dimension: intacct_gl_account_no {
    type: string
    sql: ${TABLE}."INTACCT_GL_ACCOUNT_NO" ;;
  }
  dimension: line_item_type_id {
    type: number
    sql: ${TABLE}."LINE_ITEM_TYPE_ID" ;;
  }
  measure: count {
    type: count
    drill_fields: [line_item_type_erp_ref_id]
  }
}
