view: termination_details {
  sql_table_name: "PEOPLE_ANALYTICS"."LOOKER"."TERMINATION_DETAILS" ;;

  dimension: _es_update_timestamp {
    type: date_raw
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }
  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }
  dimension: reason {
    type: string
    sql: ${TABLE}."REASON" ;;
  }
  dimension: rehireable {
    type: string
    sql: ${TABLE}."REHIREABLE" ;;
  }
  dimension: termination {
    type: date_raw
    sql: ${TABLE}."TERMINATION_DATE" ;;
  }
  measure: count {
    type: count
  }
}
