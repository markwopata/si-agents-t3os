view: credit_note_erp_refs {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."CREDIT_NOTE_ERP_REFS"
    ;;
  drill_fields: [credit_note_erp_ref_id]

  dimension: credit_note_erp_ref_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."CREDIT_NOTE_ERP_REF_ID" ;;
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

  dimension: credit_note_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."CREDIT_NOTE_ID" ;;
  }

  dimension: erp_instance_id {
    type: number
    sql: ${TABLE}."ERP_INSTANCE_ID" ;;
  }

  dimension: intacct_record_no {
    type: string
    sql: ${TABLE}."INTACCT_RECORD_NO" ;;
  }

  measure: count {
    type: count
    drill_fields: [credit_note_erp_ref_id, credit_notes.credit_note_id]
  }
}
