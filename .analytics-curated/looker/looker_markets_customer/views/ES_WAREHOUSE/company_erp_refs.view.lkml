view: company_erp_refs {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."COMPANY_ERP_REFS"
    ;;
  drill_fields: [company_erp_ref_id]

  dimension: company_erp_ref_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."COMPANY_ERP_REF_ID" ;;
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

  dimension: erp_instance_id {
    type: number
    sql: ${TABLE}."ERP_INSTANCE_ID" ;;
  }

  dimension: intacct_customer_id {
    type: string
    sql: ${TABLE}."INTACCT_CUSTOMER_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [company_erp_ref_id]
  }
}
