view: new_customers {
  derived_table: {
    sql:
      select
      ut.*,
      rd.last_rental
      from analytics.public.new_customers ut
      left join (select U.COMPANY_ID,
                        max(R.START_DATE::DATE) as LAST_RENTAL
                from ES_WAREHOUSE.PUBLIC.RENTALS R
                join ES_WAREHOUSE.PUBLIC.ORDERS O
                      on R.ORDER_ID = O.ORDER_ID
                join ES_WAREHOUSE.PUBLIC.USERS U
                      on O.USER_ID = U.USER_ID
                  group by u.COMPANY_ID) as rd
        on ut.company_id = rd.COMPANY_ID
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: company_id {
    type: number
    primary_key: yes
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension_group: date_created {
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: salesperson {
    type: string
    sql: ${TABLE}."SALESPERSON" ;;
  }

  dimension: is_create_date_last_month {
    type: yesno
    sql: (date_trunc(month,current_date()) - interval '1 month') = date_trunc(month,${date_created_raw}::DATE) ;;
    # month(${date_created_raw}) = month(current_date() - interval '1' month))) ;;
  }

  dimension: is_create_date_current_month {
    type: yesno
    sql: date_trunc(month,current_date()) =  date_trunc(month,${date_created_raw}::DATE) ;;
    # month(${date_created_raw}) = month(date_trunc('month', current_date()))
    #   and day(${date_created_raw}) <= day(date_trunc('day', current_date())) ;;
  }

  dimension: last_rental {
    type: date
    sql: ${TABLE}."LAST_RENTAL" ;;
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
      salesperson,
      last_rental
    ]
  }
}
