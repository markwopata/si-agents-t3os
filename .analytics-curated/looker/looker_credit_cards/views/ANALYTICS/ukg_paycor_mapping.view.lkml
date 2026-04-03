view: ukg_paycor_mapping {
  sql_table_name: "PAYROLL"."UKG_PAYCOR_MAPPING"
    ;;

  dimension: paycor_base_home_department {
    type: string
    sql: ${TABLE}."PAYCOR_BASE_HOME_DEPARTMENT" ;;
  }

  dimension: paycor_dept_name {
    type: string
    sql: ${TABLE}."PAYCOR_DEPT_NAME" ;;
  }

  dimension: paycor_loc_name {
    type: string
    sql: ${TABLE}."PAYCOR_LOC_NAME" ;;
  }

  dimension: paycor_sub_dept_name {
    type: string
    sql: ${TABLE}."PAYCOR_SUB_DEPT_NAME" ;;
  }

  dimension: ukg_department_code {
    type: string
    sql: ${TABLE}."UKG_DEPARTMENT_CODE" ;;
  }

  dimension: ukg_district {
    type: string
    sql: ${TABLE}."UKG_DISTRICT" ;;
  }

  dimension: ukg_region {
    type: string
    sql: ${TABLE}."UKG_REGION" ;;
  }

  measure: count {
    type: count
    drill_fields: [paycor_loc_name, paycor_dept_name, paycor_sub_dept_name]
  }
}
