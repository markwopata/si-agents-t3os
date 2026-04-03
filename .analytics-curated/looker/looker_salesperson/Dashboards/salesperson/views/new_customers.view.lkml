#
# The purpose of this view is to capture new customer metrics.
# New Customer is defined based on new credit applications within a given date (future state to include new customers based on spend).
#
#Related story:
# [https://app.shortcut.com/businessanalytics/story/278895/salesperson-overview-section-refresh]
#
# Britt Shanklin | Built 2023-08-15 | Modified 2023-09-06
view: new_customers {
derived_table: {
  sql: select IFF((nc.salesperson_user_id is null), '0', translate(nc.salesperson_user_id, ',', ''))        as salesperson_user_id
              , IFF((nc.market_id is null), '0', translate(nc.market_id, ',', ''))                          as market_id
              , date_created::DATE                                                                          as date_created
              , company_id                                                                                  as company_id
              , company_name                                                                                as company_name
              , count(distinct nc.company_id)                                                               as customer_count
          from analytics.public.new_customers nc
          where nc.salesperson_user_id = try_to_number(split_part({{ _filters['salesperson_customers.full_name_with_id'] | sql_quote }}, '-', 2))
          group by salesperson_user_id, market_id, date_created, company_id, company_name
  ;;
  }

  dimension: salesperson_user_id {
    type: string
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension_group: date_created {
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: customer_count {
    type: number
    sql: ${TABLE}."CUSTOMER_COUNT" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: is_create_date_last_month {
    type: yesno
    sql: (date_trunc(month,current_date()) - interval '1 month') = date_trunc(month,${date_created_raw}::DATE) ;;
  }

  dimension: is_create_date_current_month {
    type: yesno
    sql: date_trunc(month,current_date()) =  date_trunc(month,${date_created_raw}::DATE) ;;
  }

  measure: new_customer_count {
    type: sum
    sql: ${customer_count} ;;
  }

  measure: current_month_new_customer_count {
    type: sum
    filters: [is_create_date_current_month: "Yes"]
    sql: ${customer_count} ;;
  }

  measure: last_month_new_customer_count {
    type: sum
    filters: [is_create_date_last_month: "Yes"]
    sql: ${customer_count} ;;
  }
}
