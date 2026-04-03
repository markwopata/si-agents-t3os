view: market_rental_revenue_history {
  derived_table: {
    # datagroup_trigger: Every_5_Min_Update
    sql: select
        date_trunc('month',li.gl_billing_approved_date)::DATE as Billing_approved_date,
        m.market_name,
        mg.revenue_goals,
        sum(li.amount) as total_rev
      from
        ES_WAREHOUSE.PUBLIC.orders o
        join ES_WAREHOUSE.PUBLIC.invoices i on i.order_id = o.order_id
        join ANALYTICS.PUBLIC.v_line_items li on li.invoice_id = i.invoice_id
        left join market_region_xwalk m on m.market_id = i.ship_from:branch_id
        left join market_goals mg on mg.market_id = m.market_id and (date_trunc('month',li.gl_billing_approved_date::DATE) = date_trunc('month',mg.months::date) and date_trunc('year',li.gl_billing_approved_date::DATE) = date_trunc('year',mg.months::date))
      where
        li.line_item_type_id in (6,8,108,109)
        and date_trunc('month',li.gl_billing_approved_date::DATE) >= (date_trunc('month',current_date) - interval '5 months')
      group by
        date_trunc('month',li.gl_billing_approved_date),
        m.market_name,
        mg.revenue_goals
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: billing_approved_date {
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
    sql: ${TABLE}."BILLING_APPROVED_DATE" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: revenue_goals {
    type: string
    sql: ${TABLE}."REVENUE_GOALS" ;;
  }

  dimension: total_rev {
    type: number
    sql: ${TABLE}."TOTAL_REV" ;;
  }

  measure: goal {
    type: sum
    sql: ${revenue_goals} ;;
    value_format_name: usd_0
  }

  measure: Total_Revenue {
    type: sum
    sql: ${total_rev} ;;
    value_format_name: usd_0
  }

  set: detail {
    fields: [billing_approved_date_month, market_name, revenue_goals, total_rev]
  }
}
