view: budget_sub_departments {
  sql_table_name: "ANALYTICS"."CORPORATE_BUDGET"."BUDGET_SUB_DEPARTMENTS" ;;

  dimension: _fivetran_synced {
    type: date_raw
    sql: ${TABLE}."_FIVETRAN_SYNCED";;
  }
  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }
  dimension: budget_year {
    type: number
    sql: ${TABLE}."BUDGET_YEAR" ;;
  }
  dimension: cost_capture_id {
    type: number
    sql: ${TABLE}."COST_CAPTURE_ID" ;;
  }
  dimension: cost_center_string {
    type: string
    sql: ${TABLE}."COST_CENTER_STRING" ;;
  }
  dimension: department {
    type: string
    sql: ${TABLE}."DEPARTMENT" ;;
  }
  dimension: department_id {
    type: string
    sql: ${TABLE}."DEPARTMENT_ID" ;;
  }
  dimension: sub_department_id {
    type: number
    sql: ${TABLE}."SUB_DEPARTMENT_ID" ;;
  }
  dimension: sub_department_name {
    type: string
    sql: ${TABLE}."SUB_DEPARTMENT_NAME" ;;
  }
  measure: count {
    type: count
    drill_fields: [sub_department_name]
  }
}
