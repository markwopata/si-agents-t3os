# The name of this view in Looker is "Employee Branch Ukg"
view: employee_branch_ukg {
  # The sql_table_name parameter indicates the underlying database table
  # to be used for all fields in this view.
  sql_table_name: "ANALYTICS"."PUBLIC"."EMPLOYEE_BRANCH_UKG"
    ;;
  # No primary key is defined for this view. In order to join this view in an Explore,
  # define primary_key: yes on a dimension that has no repeated values.

  # Here's what a typical dimension looks like in LookML.
  # A dimension is a groupable field that can be used to filter query results.
  # This dimension will be called "District ID" in Explore.

  dimension: district_id {
    type: string
    sql: ${TABLE}."DISTRICT_ID" ;;
  }

  dimension: employee_email {
    type: string
    sql: ${TABLE}."EMPLOYEE_EMAIL" ;;
  }

  dimension: employee_hierarchy {
    type: string
    sql: ${TABLE}."EMPLOYEE_HIERARCHY" ;;
  }

  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }

  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }

  dimension: full_employee_name {
    type: string
    sql: ${TABLE}."FULL_EMPLOYEE_NAME" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: months_since_hired {
    type: number
    sql: ${TABLE}."MONTHS_SINCE_HIRED" ;;
  }

  # A measure is a field that uses a SQL aggregate function. Here are defined sum and average
  # measures for this dimension, but you can also add measures of many different aggregates.
  # Click on the type parameter to see all the options in the Quick Help panel on the right.

  measure: total_months_since_hired {
    type: sum
    sql: ${months_since_hired} ;;
  }

  measure: average_months_since_hired {
    type: average
    sql: ${months_since_hired} ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: work_location {
    type: string
    sql: ${TABLE}."WORK_LOCATION" ;;
  }

  measure: count {
    type: count
    drill_fields: [market_name, region_name, full_employee_name]
  }
}
