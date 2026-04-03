view: credit_note_allocation_erp_refs {
  sql_table_name: "PUBLIC"."CREDIT_NOTE_ALLOCATION_ERP_REFS"
    ;;
  drill_fields: [credit_note_allocation_erp_ref_id]

  dimension: credit_note_allocation_erp_ref_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."CREDIT_NOTE_ALLOCATION_ERP_REF_ID" ;;
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

  dimension: credit_note_allocation_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."CREDIT_NOTE_ALLOCATION_ID" ;;
  }

  dimension: erp_instance_id {
    type: number
    sql: ${TABLE}."ERP_INSTANCE_ID" ;;
  }

  dimension_group: intacct_synced {
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
    sql: CAST(${TABLE}."INTACCT_SYNCED_DATE" AS TIMESTAMP_NTZ) ;;
  }

  measure: count {
    type: count
    drill_fields: [credit_note_allocation_erp_ref_id, credit_note_allocations.credit_note_allocation_id]
  }
}
