view: companies_revenue_by_month {
  derived_table: {
    # datagroup_trigger: Every_Two_Hours_Update
    sql:
   /* select
        c.company_id,
        c.name,
        u.user_id,
        u.first_name,
        u.last_name,
        u2.first_name as order_first_name,
        u2.last_name as order_last_name,
        date_trunc('month',li.gl_date_created)::DATE as date_created,
        sum(li.amount) as total_rev
        from
          ES_WAREHOUSE.PUBLIC.orders o
          join ES_WAREHOUSE.PUBLIC.invoices i on i.order_id = o.order_id
          join ANALYTICS.PUBLIC.v_line_items li on li.invoice_id = i.invoice_id
          join ES_WAREHOUSE.PUBLIC.approved_invoice_salespersons ais on i.invoice_id = ais.invoice_id
          join ES_WAREHOUSE.PUBLIC.users u on u.user_id = ais.primary_salesperson_id
          join ES_WAREHOUSE.PUBLIC.users u2 on u2.user_id = o.user_id
          join ES_WAREHOUSE.PUBLIC.companies c on c.company_id = u2.company_id
        where
          li.line_item_type_id in (6,8,108,109)
          and date_trunc('year',li.gl_date_created::DATE) >= (date_trunc('year',current_date) - interval '3 year')
          AND {% condition customer_name %} REPLACE(TRIM(c.name),CHAR(9), '') {% endcondition %}
        group by
        c.company_id,
        c.name,
        u.user_id,
        u.first_name,
        u.last_name,
        u2.first_name,
        u2.last_name,
        date_trunc('month',li.gl_date_created)*/



        select
        c.company_id,
        c.company_name as name,
        u.user_id,
        u.user_first_name as first_name,
        u.user_last_name as last_name,

        u2.first_name as order_first_name,
        u2.last_name as order_last_name,

        date_trunc(month, dd.date) as date_created,
        SUM(ild.invoice_line_details_amount) as total_rev

        from
        platform.gold.v_line_items r
        JOIN platform.gold.v_invoice_line_details ild on ild.INVOICE_LINE_DETAILS_LINE_ITEM_KEY = r.line_item_key
        --JOIN platform.gold.v_assets va ON va.asset_key = ild.invoice_line_details_asset_key
        JOIN platform.gold.v_dates dd on ild.invoice_line_details_gl_billing_approved_date_key = dd.date_key
        JOIN platform.gold.v_companies c on ild.invoice_line_details_company_key = c.company_key
        JOIN platform.gold.v_users u ON u.user_key = ild.invoice_line_details_salesperson_key
        JOIN platform.gold.v_orders vo ON vo.order_key = ild.invoice_line_details_order_key
        JOIN es_warehouse.public.orders o on vo.order_id = o.order_id
        JOIN ES_WAREHOUSE.PUBLIC.users u2 on u2.user_id = o.user_id
        WHERE r.LINE_ITEM_RENTAL_REVENUE = TRUE and
            date_trunc('year',dd.date) >= (date_trunc('year',current_date) - interval '3 year')
           AND {% condition customer_name %} REPLACE(TRIM(c.company_name),CHAR(9), '') {% endcondition %}
        GROUP BY
            c.company_id,
            c.company_name,
            u.user_id,
            u.user_first_name,
            u.user_last_name,
            u2.first_name,
            u2.last_name ,
            date_trunc(month, dd.date)
 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
    value_format_name: id
  }

  dimension: name {
    type: string
    sql: REPLACE(TRIM(${TABLE}."NAME"),CHAR(9), '') ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
    value_format_name: id
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: order_first_name {
    type: string
    sql: ${TABLE}."ORDER_FIRST_NAME" ;;
  }

  dimension: order_last_name {
    type: string
    sql: ${TABLE}."ORDER_LAST_NAME" ;;
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

  dimension_group: invoice_date {
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
    sql: CAST(${TABLE}."INVOICE_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: total_rev {
    type: number
    sql: ${TABLE}."TOTAL_REV" ;;
  }

  dimension: company_point_of_contact_full_name {
    type: string
    sql: concat(${order_first_name},' ',${order_last_name}) ;;
  }

  measure: total_revenue {
    type: sum
    sql: ${total_rev} ;;
    value_format_name: usd_0
    drill_fields: [name,salesperson_full_name,date_created_date,total_revenue]
  }

  measure: total_revenue_from_companies_users {
    type: sum
    sql: ${total_rev} ;;
    value_format_name: usd_0
    drill_fields: [name,company_point_of_contact_full_name,salesperson_full_name,date_created_date,total_revenue]
  }

  dimension: salesperson_full_name {
    type: string
    sql: concat(${first_name},' ',${last_name}) ;;
  }

  dimension: point_of_contact_name {
    type: string
    sql: concat(${order_first_name},' ',${order_last_name}) ;;
  }

  dimension:  current_ytd_by_date_created {
    type: yesno
    sql: (day(${date_created_raw}) <= day(current_date())
          AND month(${date_created_raw}) = month(current_date())
          AND year(${date_created_raw}) = year(current_date()))
          OR
          (month(${date_created_raw}) < month(current_date())
          AND year(${date_created_raw}) = year(current_date())) ;;
  }

  dimension:  last_year_by_date_created {
    type: yesno
    sql: year(${date_created_raw}) = year(current_date() - interval '3 year') ;;
  }

  measure: current_ytd_revenue {
    type: sum
    sql: ${total_rev} ;;
    filters: [current_ytd_by_date_created: "Yes"]
    value_format_name: usd_0
  }

  measure: previous_year_revenue {
    type: sum
    sql: ${total_rev} ;;
    filters: [last_year_by_date_created: "Yes"]
    value_format_name: usd_0
  }

  filter: customer_name {
    type: string
  }

  set: detail {
    fields: [
      company_id,
      name,
      user_id,
      first_name,
      last_name,
      order_first_name,
      order_last_name,
      date_created_date,
      total_rev
    ]
  }
}
