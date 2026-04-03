view: payroll_census_live {
  derived_table: {
    sql:
      select
          cd.market_id::number market_id,
          cd.employee_id,
          cd.first_name,
          cd.last_name,
          cd.employee_title
      from
          analytics.payroll.company_directory cd
      where cd.employee_status = 'Active'
    ;;
  }

  measure: count {
    type: count
    drill_fields: [first_name, last_name]
  }

  dimension: market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }
}
