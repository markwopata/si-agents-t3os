view: labor_allocations {
  sql_table_name: "LOOKER"."LABOR_ALLOCATIONS" ;;

  dimension: allocation_percent {
    type: number
    sql: ${TABLE}."ALLOCATION_PERCENT" ;;
  }
  dimension: business_title {
    type: string
    sql: ${TABLE}."BUSINESS_TITLE" ;;
  }
  dimension: department {
    type: string
    sql: ${TABLE}."DEPARTMENT" ;;
  }
  dimension: department_allocation {
    type: string
    sql: ${TABLE}."DEPARTMENT_ALLOCATION" ;;
  }
  dimension: department_reference_id_allocation {
    type: string
    sql: ${TABLE}."DEPARTMENT_REFERENCE_ID_ALLOCATION" ;;
  }
  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }
  dimension: district_allocation {
    type: string
    sql: ${TABLE}."DISTRICT_ALLOCATION" ;;
  }
  dimension: division {
    type: string
    sql: ${TABLE}."DIVISION" ;;
  }
  dimension: division_allocation {
    type: string
    sql: ${TABLE}."DIVISION_ALLOCATION" ;;
  }
  dimension: employee_id {
    type: string
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }
  dimension: labor_profile {
    type: string
    sql: ${TABLE}."LABOR_PROFILE" ;;
  }
  dimension: location {
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }
  dimension: location_allocation {
    type: string
    sql: ${TABLE}."LOCATION_ALLOCATION" ;;
  }
  dimension: market_id_allocation {
    type: string
    sql: ${TABLE}."MARKET_ID_ALLOCATION" ;;
  }
  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }
  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }
  dimension: region_allocation {
    type: string
    sql: ${TABLE}."REGION_ALLOCATION" ;;
  }

  dimension: snapshot_timestamp {
    type: date_raw
    sql: ${TABLE}."SNAPSHOT_TIMESTAMP" ;;
    hidden: yes
  }


  measure: count {
    type: count
  }
}
