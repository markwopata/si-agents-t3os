view: new_customers {
  derived_table: {
    sql:
    select
      ut.COMPANY_ID,
      ut.COMPANY_NAME,
      ut.SALESPERSON_USER_ID,
      ut.MARKET_ID, MARKET_NAME,
      ut.DATE_CREATED,
      concat(trim(regexp_replace(ut.SALESPERSON, '-.*','')),' - ', ut.SALESPERSON_USER_ID) as SALESPERSON,
      ut.HAS_CREDIT_APP,
      rd.last_rental,
      CASE WHEN position(' ', coalesce(cd.nickname, cd.first_name)) = 0
        THEN concat(coalesce(cd.nickname, cd.first_name), ' ', cd.last_name)
        ELSE concat(coalesce(cd.nickname, concat(cd.first_name, ' ', cd.last_name))) END AS salesperson_name_filter
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
        left join ES_WAREHOUSE.PUBLIC.USERS u2 --- Joined this and Company Directory for the salesperson name filter KC 4/2/24
        on ut.SALESPERSON_USER_ID = u2.USER_ID
        left join ANALYTICS.PAYROLL.COMPANY_DIRECTORY cd
        on lower(u2.EMAIL_ADDRESS) = lower(cd.WORK_EMAIL)
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: company_id {
    type: string
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

  dimension: salesperson_name_filter { ### This is here because on the all time accounts I needed to consilidate the names for the filter KC 4/2/24
    type: string
    sql: ${TABLE}."SALESPERSON_NAME_FILTER" ;;
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

  measure: new_customers_count_disticnt_current_month {
    type: count_distinct
    sql: ${company_id} ;;
    filters: [is_create_date_current_month: "Yes"]
    drill_fields: [company_id, company_name, market_name,salesperson,date_created_date]
  }

  measure: new_customers_count_disticnt_last_month {
    type: count_distinct
    sql: ${company_id} ;;
    filters: [is_create_date_last_month: "Yes"]
    drill_fields: [company_id, company_name, market_name,salesperson,date_created_date]
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
