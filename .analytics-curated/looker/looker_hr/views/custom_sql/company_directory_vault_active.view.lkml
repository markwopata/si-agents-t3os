view: company_directory_vault_active {
  derived_table: {
    sql:
    with cd_vault as (select employee_id,
                                        first_name,
                                        last_name,
                                        market_id,
                                        work_email,
                                        employee_status,
                                        employee_title,
                                        date_hired::date as date_hired,
                                        date_rehired::date as date_rehired,
                                        _es_update_timestamp
                                 from analytics.payroll.company_directory_vault
                                 qualify
                                     row_number() over (partition by employee_id, date_trunc('month', _es_update_timestamp) order by _es_update_timestamp desc) =
                                     1)
      select *, date_trunc('month', _es_update_timestamp::date) as date_month
      from cd_vault
      where employee_status not in ('Terminated', 'Never Started', 'Not In Payroll', 'Inactive', 'External Payroll',
                                    'Military Intern')
    ;;
  }

  dimension: market_id {
    label: "Market ID"
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: employee_id {
    label: "Employee ID"
    type: string
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }

  dimension: first_name {
    label: "First Name"
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension: last_name {
    label: "Last Name"
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: work_email {
    type: string
    sql: ${TABLE}."WORK_EMAIL" ;;
  }

  dimension: employee_status {
    type: string
    sql: ${TABLE}."EMPLOYEE_STATUS" ;;
  }

  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }

  dimension: date_hired {
    type: date
    sql: ${TABLE}."DATE_HIRED" ;;
  }

  dimension: date_rehired {
    type: date
    sql: ${TABLE}."DATE_REHIRED" ;;
  }

  dimension: date_month {
    type: date
    sql: ${TABLE}."DATE_MONTH" ;;
  }

}
