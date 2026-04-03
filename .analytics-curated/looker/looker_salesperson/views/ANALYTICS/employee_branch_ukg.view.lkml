view: employee_branch_ukg {
  sql_table_name: "PUBLIC"."EMPLOYEE_BRANCH_UKG"
    ;;

  #dimension: branch_manager {
  #  type: string
  #  sql: ${TABLE}."BRANCH_MANAGER" ;;
  #}

  #dimension: district_manager {
  #  type: string
  #  sql: ${TABLE}."DISTRICT_MANAGER" ;;
  #}

  dimension: employee_email {
    type: string
    sql: ${TABLE}."EMPLOYEE_EMAIL" ;;
  }

  dimension: employee_hierarchy {
    type: string
    sql: ${TABLE}."EMPLOYEE_HIERARCHY" ;;
  }

  #dimension: employee_number {
  #  type: number
  #  sql: ${TABLE}."EMPLOYEE_NUMBER" ;;
  #}

  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }

  #dimension: first_name {
  #  type: string
  #  sql: ${TABLE}."FIRST_NAME" ;;
  #}

  dimension: full_employee_name {
    type: string
    sql: ${TABLE}."FULL_EMPLOYEE_NAME" ;;
  }

  #dimension: last_name {
  #  type: string
  #  sql: ${TABLE}."LAST_NAME" ;;
  #}

  #dimension: regional_manager {
  #  type: string
  #  sql: ${TABLE}."REGIONAL_MANAGER" ;;
  #}

  dimension: work_location {
    type: string
    sql: ${TABLE}."WORK_LOCATION" ;;
  }

  dimension: district_id {
    type: string
    sql: ${TABLE}."DISTRICT_ID" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  measure: count {
    type: count
    #drill_fields: [last_name, first_name, full_employee_name]
    drill_fields: [full_employee_name]

  }

  measure: count_distinct {
    type: count_distinct
    sql: ${employee_email} ;;
  }

  measure: count_of_markets {
    type: count_distinct
    sql: ${market_id} ;;
    drill_fields: [market_id,market_name,district_id,region_name]
  }
}
