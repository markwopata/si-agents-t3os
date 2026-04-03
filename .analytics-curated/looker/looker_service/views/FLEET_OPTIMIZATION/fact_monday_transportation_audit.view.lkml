view: fact_monday_transportation_audit {
  sql_table_name: "FLEET_OPTIMIZATION"."GOLD"."FACT_MONDAY_TRANSPORTATION_AUDIT" ;;

  dimension: fk_date_key {
    type: string
    sql: ${TABLE}."FK_DATE_KEY" ;;
  }
  dimension: fk_market_key {
    type: string
    sql: ${TABLE}."FK_MARKET_KEY" ;;
  }
  dimension: pk_audit_id {
    type: string
    sql: ${TABLE}."PK_AUDIT_ID" ;;
  }
  dimension: transportation_audit_name {
    type: string
    sql: ${TABLE}."TRANSPORTATION_AUDIT_NAME" ;;
  }
  dimension: transportation_audit_process_score {
    type: number
    sql: ${TABLE}."TRANSPORTATION_AUDIT_PROCESS_SCORE" ;;
  }
  dimension: transportation_audit_score {
    type: number
    sql: ${TABLE}."TRANSPORTATION_AUDIT_SCORE" ;;
  }
  dimension: transportation_audit_status {
    type: string
    sql: ${TABLE}."TRANSPORTATION_AUDIT_STATUS" ;;
  }
  dimension: transportation_audit_work_score {
    type: number
    sql: ${TABLE}."TRANSPORTATION_AUDIT_WORK_SCORE" ;;
  }
  dimension: transportation_auditor {
    type: string
    sql: ${TABLE}."TRANSPORTATION_AUDITOR" ;;
  }
  measure: count {
    type: count
    drill_fields: [transportation_audit_name]
  }
}
