view: payment_application_erp_refs {
  sql_table_name: "PUBLIC"."PAYMENT_APPLICATION_ERP_REFS"
    ;;
  drill_fields: [payment_application_erp_ref_id]

  dimension: payment_application_erp_ref_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."PAYMENT_APPLICATION_ERP_REF_ID" ;;
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

  dimension_group: intacct_active {
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
    sql: CAST(${TABLE}."INTACCT_ACTIVE_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: intacct_record_no {
    type: string
    sql: ${TABLE}."INTACCT_RECORD_NO" ;;
  }

  dimension: is_reversed {
    type: yesno
    sql: ${TABLE}."IS_REVERSED" ;;
  }

  dimension: payment_application_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."PAYMENT_APPLICATION_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [payment_application_erp_ref_id, payment_applications.payment_application_id]
  }
}
