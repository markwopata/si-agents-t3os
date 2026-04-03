view: workday_district_cleanup {
  sql_table_name: "PEOPLE_ANALYTICS"."LOOKER"."WORKDAY_DISTRICT_CLEANUP" ;;

  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }
  dimension: full_name {
    type: string
    sql: ${TABLE}."FULL_LEGAL_NAME" ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }
  dimension: workday_district {
    type: string
    sql: ${TABLE}."WORKDAY_DISTRICT" ;;
  }
  dimension: organization_district {
    type: string
    sql: ${TABLE}."ORGANIZATION_DISTRICT" ;;
  }
  dimension: date_hired {
    type: date_raw
    sql: ${TABLE}."DATE_HIRED" ;;
    hidden: yes
  }
  dimension: date_rehired {
    type: date_raw
    sql: ${TABLE}."DATE_REHIRED" ;;
    hidden: yes
  }
  dimension: date_terminated {
    type: date_raw
    sql: ${TABLE}."DATE_TERMINATED" ;;
    hidden: yes
  }
  dimension: employee_status {
    type: string
    sql: ${TABLE}."EMPLOYEE_STATUS" ;;
  }
}
