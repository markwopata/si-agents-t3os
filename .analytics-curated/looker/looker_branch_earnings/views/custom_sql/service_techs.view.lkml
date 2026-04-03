view: service_tech_list {
  # Or, you could make this view a derived table, like this:
  derived_table: {
    sql: select cd.FIRST_NAME, cd.LAST_NAME, cd.EMPLOYEE_TITLE, cd.EMPLOYEE_STATUS, cd.market_id
          from analytics.PAYROLL.COMPANY_DIRECTORY cd
          where CD.EMPLOYEE_TITLE ILIKE ANY ('%technician%', '%mechanic%')
          and CD.EMPLOYEE_TITLE NOT ILIKE '%yard technician%' -- Mark W says don't include yard techs
          and cd.EMPLOYEE_STATUS not in ('Not In Payroll',
                                 'Never Started',
                                 'Terminated',
                                 'Inactive')
      ;;
  }

  # Define your dimensions and measures here, like this:
  dimension: first_name {
    type: string
    sql: ${TABLE}.first_name ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}.last_name ;;
  }

  dimension: employee_title {
    type: string
    sql: ${TABLE}.employee_title ;;
  }

  dimension: employee_status {
    type: string
    sql: ${TABLE}.employee_status ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}.market_id ;;
  }
}
