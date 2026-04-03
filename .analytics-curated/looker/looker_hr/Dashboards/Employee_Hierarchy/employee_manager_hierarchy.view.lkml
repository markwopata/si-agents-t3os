view: employee_manager_hierarchy {
  sql_table_name: "PAYROLL"."PA_EMPLOYEE_MANAGER_HIERARCHY" ;;

  dimension: employee_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }
  dimension: level_1_manager {
    type: string
    sql: ${TABLE}."LEVEL_1_MANAGER" ;;
  }
  dimension: level_1_manager_title {
    type: string
    sql: ${TABLE}."LEVEL_1_MANAGER_TITLE" ;;
  }
  dimension: level_2_manager {
    type: string
    sql: ${TABLE}."LEVEL_2_MANAGER" ;;
  }
  dimension: level_2_manager_title {
    type: string
    sql: ${TABLE}."LEVEL_2_MANAGER_TITLE" ;;
  }
  dimension: level_3_manager {
    type: string
    sql: ${TABLE}."LEVEL_3_MANAGER" ;;
  }
  dimension: level_3_manager_title {
    type: string
    sql: ${TABLE}."LEVEL_3_MANAGER_TITLE" ;;
  }
  dimension: level_4_manager {
    type: string
    sql: ${TABLE}."LEVEL_4_MANAGER" ;;
  }
  dimension: level_4_manager_title {
    type: string
    sql: ${TABLE}."LEVEL_4_MANAGER_TITLE" ;;
  }
  dimension: level_5_manager {
    type: string
    sql: ${TABLE}."LEVEL_5_MANAGER" ;;
  }
  dimension: level_5_manager_title {
    type: string
    sql: ${TABLE}."LEVEL_5_MANAGER_TITLE" ;;
  }
  dimension: level_6_manager {
    type: string
    sql: ${TABLE}."LEVEL_6_MANAGER" ;;
  }
  dimension: level_6_manager_title {
    type: string
    sql: ${TABLE}."LEVEL_6_MANAGER_TITLE" ;;
  }
  dimension: level_7_manager {
    type: string
    sql: ${TABLE}."LEVEL_7_MANAGER" ;;
  }
  dimension: level_7_manager_title {
    type: string
    sql: ${TABLE}."LEVEL_7_MANAGER_TITLE" ;;
  }
  dimension: level_8_manager {
    type: string
    sql: ${TABLE}."LEVEL_8_MANAGER" ;;
  }
  dimension: level_8_manager_title {
    type: string
    sql: ${TABLE}."LEVEL_8_MANAGER_TITLE" ;;
  }
  dimension: manager_list {
    type: string
    sql: ${TABLE}."MANAGER_LIST" ;;
  }
  dimension: manager_list_title {
    type: string
    sql: ${TABLE}."MANAGER_LIST_TITLE" ;;
  }

  dimension: direct_manager_name {
    type: string
    sql: ${TABLE}."DIRECT_MANAGER_NAME" ;;
  }

  dimension: direct_manager_title {
    type: string
    sql: ${TABLE}."DIRECT_MANAGER_TITLE" ;;
  }

  dimension: level_2_manager_direct {
    type: number
    sql: CASE WHEN CONCAT(${level_2_manager},')') = ${direct_manager_name} THEN 1 ELSE 0 END;;
  }

  dimension: depth_number {
    type: number
    sql: CASE WHEN ${level_1_manager} ='' THEN 0
    WHEN WHEN ${level_2_manager} ='' THEN 1
    WHEN WHEN ${level_3_manager} ='' THEN 2
    WHEN WHEN ${level_4_manager} ='' THEN 3
    WHEN WHEN ${level_5_manager} ='' THEN 4
    WHEN WHEN ${level_6_manager} ='' THEN 5
    WHEN WHEN ${level_7_manager} ='' THEN 6
    WHEN WHEN ${level_8_manager} ='' THEN 7
    ELSE 8 END;;
  }

  measure: count {
    type: count
  }
  measure: count_distinct_number_managers {
    type: count_distinct
    sql:  ${direct_manager_name} ;;
  }

  measure: sum_level_2_direct{
    type: sum
    sql:  ${level_2_manager_direct} ;;
    value_format_name: decimal_0
  }
}
