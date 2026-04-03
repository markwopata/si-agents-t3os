view: dept_mapping_mkt_directory {
  sql_table_name: "PAYROLL"."DEPT_MAPPING_MKT_DIRECTORY"
    ;;

  dimension: dept_mapping {
    type: string
    sql: ${TABLE}."DEPT_MAPPING" ;;
  }

  dimension: dept_name {
    type: string
    sql: ${TABLE}."DEPT_NAME" ;;
  }

  measure: count {
    type: count
    drill_fields: [dept_name]
  }
}
