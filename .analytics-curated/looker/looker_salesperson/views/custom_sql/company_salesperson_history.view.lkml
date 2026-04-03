view: company_salesperson_history {
  derived_table: {
    # datagroup_trigger: Every_Two_Hours_Update
    sql: with sp_company as (
      select
      u.first_name
      ,u.last_name
      ,i.salesperson_user_id
      ,u2.company_id
      ,min(i.billing_approved_date) as sp_company_first_bill_date
      ,sum(li.amount) as salesperson_company_volume
      from ES_WAREHOUSE.PUBLIC.orders o
      left join ES_WAREHOUSE.PUBLIC.invoices i
              on o.order_id  = i.order_id
      left join ANALYTICS.PUBLIC.v_line_items li
              on i.invoice_id = li.invoice_id
      left join ES_WAREHOUSE.PUBLIC.users u
              on i.salesperson_user_id  = u.user_id
      left join ES_WAREHOUSE.PUBLIC.users u2
              on u2.user_id  = o.user_id
      where i.billing_approved
      and i.line_item_amount > 0
      group by
      u.first_name
      ,u.last_name
      ,i.salesperson_user_id
      ,u2.company_id
      )
      --
      ,company_first_bill as (
      select
      u2.company_id
      ,min(i.billing_approved_date) as company_first_bill_date
      ,sum(li.amount) as total_company_volume
      from ES_WAREHOUSE.PUBLIC.orders o
      left join ES_WAREHOUSE.PUBLIC.invoices i
              on o.order_id  = i.order_id
      left join ANALYTICS.PUBLIC.v_line_items li
              on i.invoice_id = li.invoice_id
      left join ES_WAREHOUSE.PUBLIC.users u
              on i.salesperson_user_id  = u.user_id
      left join ES_WAREHOUSE.PUBLIC.users u2
              on u2.user_id  = o.user_id
      where i.billing_approved
      and i.line_item_amount > 0
      group by
      u2.company_id
      )
      --
      select
      s.first_name
      ,s.last_name
      ,s.salesperson_user_id
      ,s.company_id
      ,c2.name as compnay_name
      ,s.sp_company_first_bill_date::date as sp_company_first_bill_date
      ,s.salesperson_company_volume
      ,c.company_first_bill_date::Date as company_first_bill_date
      ,c.total_company_volume
      from sp_company s
      left join company_first_bill c
              on s.company_id = c.company_id
      left join ES_WAREHOUSE.PUBLIC.companies c2
              on c2.company_id  = s.company_id
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPNAY_NAME" ;;
  }

  dimension: sp_company_first_bill_date {
    type: date
    sql: ${TABLE}."SP_COMPANY_FIRST_BILL_DATE" ;;
  }

  dimension: salesperson_company_volume {
    type: number
    sql: ${TABLE}."SALESPERSON_COMPANY_VOLUME" ;;
  }

  dimension: company_first_bill_date {
    type: date
    sql: ${TABLE}."COMPANY_FIRST_BILL_DATE" ;;
  }

  dimension: total_company_volume {
    type: number
    sql: ${TABLE}."TOTAL_COMPANY_VOLUME" ;;
  }

  dimension: full_name {
    type: string
    sql: concat(${first_name},' ',${last_name}) ;;
  }

  set: detail {
    fields: [
      first_name,
      last_name,
      salesperson_user_id,
      company_id,
      company_name,
      sp_company_first_bill_date,
      salesperson_company_volume,
      company_first_bill_date,
      total_company_volume
    ]
  }
}
