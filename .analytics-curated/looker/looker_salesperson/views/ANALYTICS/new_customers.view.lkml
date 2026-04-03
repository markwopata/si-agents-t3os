view: new_customers {
  sql_table_name: "PUBLIC"."NEW_CUSTOMERS"
    ;;

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
    value_format_name: id
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension_group: date_created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
    value_format_name: id
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: salesperson {
    type: string
    sql: ${TABLE}."SALESPERSON" ;;
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
    value_format_name: id
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: is_create_date_last_month {
    type: yesno
    sql: (date_trunc(month,current_date()) - interval '1 month') = date_trunc(month,${date_created_raw}::DATE) ;;
  }

  dimension: is_create_date_current_month {
    type: yesno
    sql: date_trunc(month,current_date()) =  date_trunc(month,${date_created_raw}::DATE);;
  }

  measure: new_customers_count_current_month {
    type: count
    filters: [is_create_date_current_month: "Yes"]
    drill_fields: [company_id, company_name, market_name,salesperson,date_created_date]
    link: {
      label: "View Accounts Opened by Former Employees"
      url: "{{ link }}&f[users.user_is_suspended]=yes&sorts=new_customers.date_created_date+desc"
    }
  }

  measure: new_customers_count_last_month {
    type: count
    filters: [is_create_date_last_month: "Yes"]
    drill_fields: [company_id, company_name, market_name,salesperson,date_created_date]
    link: {
      label: "View Accounts Opened by Former Employees"
      url: "{{ link }}&f[users.user_is_suspended]=yes&sorts=new_customers.date_created_date+desc"
    }
  }
  set: detail {
    fields: [
      company_id,
      company_name,
      salesperson_user_id,
      market_id,
      market_name,
      date_created_time,
      salesperson
    ]
  }
}
