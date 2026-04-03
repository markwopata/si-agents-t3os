view: salesperson_admin_check {
  derived_table: {
    sql: SELECT
        concat(us.first_name, ' ',us.last_name) as Full_Name
      , cd.employee_id
      , us.email_address
      , cd.employee_title
      , us. security_level_id
      , us.company_id
      from ES_WAREHOUSE.PUBLIC.USERS us
      left join ANALYTICS.PAYROLL.COMPANY_DIRECTORY cd on us.employee_id = TO_CHAR(cd.employee_id)
      where us.security_level_id = 1
      and us.company_id = 1854
      and cd.employee_status = 'Active'
      and cd.employee_title = 'Territory Account Manager'
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: full_name {
    type: string
    sql: ${TABLE}."FULL_NAME" ;;
  }

  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }

  dimension: email_address {
    type: string
    sql: ${TABLE}."EMAIL_ADDRESS" ;;
  }

  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }

  dimension: security_level_id {
    type: number
    sql: ${TABLE}."SECURITY_LEVEL_ID" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  set: detail {
    fields: [
      full_name,
      employee_id,
      email_address,
      employee_title,
      security_level_id,
      company_id
    ]
  }
}
