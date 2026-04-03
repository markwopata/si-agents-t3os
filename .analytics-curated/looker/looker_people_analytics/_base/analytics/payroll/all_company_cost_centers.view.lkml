view: all_company_cost_centers {
  sql_table_name: "ANALYTICS"."PAYROLL"."ALL_COMPANY_COST_CENTERS" ;;

  dimension: abbrev {
    type: string
    sql: ${TABLE}."ABBREV" ;;
  }
  dimension: full_name {
    type: string
    sql: ${TABLE}."FULL_NAME" ;;
  }
  dimension: intaact {
    type: number
    sql: ${TABLE}."INTAACT" ;;
  }
  dimension: location {
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }
  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }
  measure: count {
    type: count
    drill_fields: [name, full_name]
  }
}
