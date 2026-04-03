view: rpp_charged_last_90_days {
  derived_table: {
    # datagroup_trigger: Every_Two_Hours_Update
    sql: select
        c.name,
        c.company_id,
        sum(li.amount) as rpp_charged_amount,
        max(i.date_created) last_invoice_created_date
      from
        ES_WAREHOUSE.PUBLIC.orders o
        left join ES_WAREHOUSE.PUBLIC.invoices i on i.order_id = o.order_id
        left join ANALYTICS.PUBLIC.v_line_items li on li.invoice_id = i.invoice_id
        left join ES_WAREHOUSE.PUBLIC.users u on u.user_id = o.user_id
        left join ES_WAREHOUSE.PUBLIC.companies c on c.company_id = u.company_id
      where
        li.line_item_type_id = 9
        and date_trunc('month',li.gl_date_created ::DATE) >= (date_trunc('month',current_date) - interval '90 days')
      group by
        c.name,
        c.company_id
 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
    link: {
      label: "View Customer Information Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/28?Company%20Name={{ name._filterable_value | url_encode }}&Company%20ID="
    }
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: rpp_charged_amount {
    type: number
    sql: ${TABLE}."RPP_CHARGED_AMOUNT" ;;
  }

  dimension_group: last_invoice_created_date {
    type: time
    sql: ${TABLE}."LAST_INVOICE_CREATED_DATE" ;;
  }

  measure: total_rpp_charged {
    type: sum
    sql: ${rpp_charged_amount} ;;
  }

  set: detail {
    fields: [name, company_id, rpp_charged_amount, last_invoice_created_date_time]
  }
}
