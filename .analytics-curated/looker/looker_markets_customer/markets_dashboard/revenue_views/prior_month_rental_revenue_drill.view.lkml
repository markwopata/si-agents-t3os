view: prior_month_rental_revenue_drill {
  derived_table: {
    sql: select m.market_id,
       --i.invoice_order_id as order_id,
       c.company_id as customer_id,
       c.name as customer_name,
       coalesce(case when position(' ',coalesce(cd.NICKNAME,cd.FIRST_NAME)) = 0 then concat(coalesce(cd.NICKNAME,cd.FIRST_NAME), ' ', cd.LAST_NAME,' - ',salesperson_user.USER_ID)
       else concat(coalesce(cd.NICKNAME,concat(cd.FIRST_NAME, ' ',cd.LAST_NAME)),' - ',salesperson_user.USER_ID) end, concat(salesperson_user.first_name, ' ', salesperson_user.last_name, ' - ',salesperson_user.USER_ID) ) as salesperson,
       sum(ild.invoice_line_details_amount) as total_revenue
from platform.gold.v_line_items r
       JOIN platform.gold.v_invoice_line_details ild on ild.INVOICE_LINE_DETAILS_LINE_ITEM_KEY = r.line_item_key
       JOIN platform.gold.v_markets m on m.market_key = ild.INVOICE_LINE_DETAILS_MARKET_KEY
       JOIN platform.gold.v_dates dd on ild.invoice_line_details_gl_billing_approved_date_key = dd.date_key
       JOIN platform.gold.v_invoices i on r.line_item_key = i.invoice_key
       JOIN es_warehouse.public.orders o on i.invoice_key = o.order_id
       JOIN es_warehouse.public.users as company_user on o.user_id = company_user.user_id
       JOIN es_warehouse.public.companies c on company_user.company_id = c.company_id
       JOIN es_warehouse.public.invoices oi on i.invoice_id = oi.invoice_id
       JOIN es_warehouse.public.users as salesperson_user on oi.salesperson_user_id = salesperson_user.user_id
       LEFT JOIN analytics.payroll.company_directory cd on salesperson_user.email_address = cd.work_email
where dd.prior_month = TRUE
        AND r.LINE_ITEM_RENTAL_REVENUE = TRUE
        --AND m.market_id = 1
group by m.market_id,
       --i.invoice_order_id,
       c.company_id,
       c.name,
       coalesce(case when position(' ',coalesce(cd.NICKNAME,cd.FIRST_NAME)) = 0 then concat(coalesce(cd.NICKNAME,cd.FIRST_NAME), ' ', cd.LAST_NAME,' - ',salesperson_user.USER_ID)
       else concat(coalesce(cd.NICKNAME,concat(cd.FIRST_NAME, ' ',cd.LAST_NAME)),' - ',salesperson_user.USER_ID) end, concat(salesperson_user.first_name, ' ', salesperson_user.last_name, ' - ',salesperson_user.USER_ID) );;
  }

  measure: count {
    type: count
  }

  dimension: primary_key {
    type: string
    sql: concat(${market_id},${salesperson},${customer_id},${customer}) ;;
    primary_key: yes
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: order_id {
    type: string
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension: customer_id {
    type: string
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension: customer {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
    html: <font color="0063f3 "><a href="https://equipmentshare.looker.com/dashboards/28?Company+Name={{filterable_value}}&Company+ID="target="_blank">{{rendered_value}}</a></font>
          <td>
          <span style="color: #8C8C8C;"> ID: {{customer_id._value}} </span>
          </td>;;
  }

  dimension: salesperson {
    type: string
    sql: ${TABLE}."SALESPERSON" ;;
    html: <font color="0063f3 "><a href="https://equipmentshare.looker.com/dashboards/5?Sales+Rep={{rendered_value}}"target="_blank">{{rendered_value}}</a></font>;;
  }

  dimension: total_revenue {
    type: number
    sql: ${TABLE}."TOTAL_REVENUE" ;;
    value_format_name: usd_0
  }

  measure: total_rental_revenue {
    type: sum
    sql: ${total_revenue} ;;
    value_format_name: usd_0
  }

}
