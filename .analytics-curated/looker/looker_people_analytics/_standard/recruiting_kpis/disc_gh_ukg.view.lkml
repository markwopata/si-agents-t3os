view: disc_gh_ukg {
  sql_table_name: "ANALYTICS"."PUBLIC"."DISC_GH_UKG"
  ;;

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
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }

  dimension: disc_code {
    type: string
    sql: ${TABLE}."DISC_CODE" ;;
  }

  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }

  dimension: employee_status {
    type: string
    sql: ${TABLE}."EMPLOYEE_STATUS" ;;
  }

  dimension: external_id {
    type: number
    sql: ${TABLE}."EXTERNAL_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
