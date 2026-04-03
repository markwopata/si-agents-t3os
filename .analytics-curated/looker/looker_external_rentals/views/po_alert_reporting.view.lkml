view: po_alert_reporting {
  derived_table: {
    sql: with po_info as (
      select
        purchase_order_id,
        name as po_name,
        company_id,
        coalesce(sum(budget_amount),0) as budget_amount
      from
        ES_WAREHOUSE.PUBLIC.PURCHASE_ORDERS
      where
        active = TRUE
        and company_id = {{ _user_attributes['company_id'] }}::integer
      group by
        purchase_order_id,
        company_id,
        name
      )
      ,budget_invoice_combine as (
      SELECT
        pi.po_name,
        pi.budget_amount,
        pi.company_id,
        sum(i.billed_amount) as billed_amount,
        max(i.billing_approved_date::date) as last_invoice_date
      FROM
        --po_info pi
        --join ES_WAREHOUSE.PUBLIC.ORDERS o on o.purchase_order_id = pi.purchase_order_id
        --join users u on o.user_id = u.user_id
        --JOIN ES_WAREHOUSE.PUBLIC.PURCHASE_ORDERS po ON o.PURCHASE_ORDER_ID =  po.PURCHASE_ORDER_ID
        --JOIN ES_WAREHOUSE.PUBLIC.INVOICES i ON o.ORDER_ID = i.ORDER_ID
          po_info pi
          --JOIN es_warehouse_stage.PUBLIC.GLOBAL_INVOICES i ON i.purchase_order_id = pi.purchase_order_id
          JOIN ES_WAREHOUSE.PUBLIC.GLOBAL_INVOICES i on i.purchase_order_id = pi.purchase_order_id
          JOIN ES_WAREHOUSE.PUBLIC.PURCHASE_ORDERS po ON po.purchase_order_id = i.purchase_order_id
          left join users u on i.ordered_by_user_id = u.user_id
      WHERE
          i.billing_approved_date::date >= po.start_date::date
          and i.billing_approved_date::date between '2018-01-01' and current_date()
      GROUP BY
          pi.po_name,
          pi.budget_amount,
          pi.company_id
      )
      ,budget_by_po as (
      SELECT
        po_name,
        company_id,
        budget_amount,
        billed_amount as cumulative_amount,
        budget_amount - cumulative_amount as remaining_budget,
        last_invoice_date
      FROM
        budget_invoice_combine
      )
      select
          po_name,
          company_id,
          coalesce(budget_amount,0) as budget_amount,
          coalesce(remaining_budget,0) as budget_remaining,
          round(coalesce(cumulative_amount,0),2) as total_spend_amount,
          round(case when budget_amount > 0 then ((coalesce(budget_amount,0) - coalesce(sum(cumulative_amount),0)) / coalesce(budget_amount,0)) else 0 end,2) as pcnt_budget_remaining,
          last_invoice_date,
          case when last_invoice_date >= dateadd(day,-14,current_date()) then TRUE else FALSE end as invoiced_in_last_two_weeks
      from
          budget_by_po
      group by
          po_name,
          company_id,
          budget_amount,
          remaining_budget,
          cumulative_amount,
          last_invoice_date
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: po_name {
    type: string
    sql: ${TABLE}."PO_NAME" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: budget_amount {
    type: number
    sql: ${TABLE}."BUDGET_AMOUNT" ;;
    value_format_name: usd
  }

  dimension: budget_remaining {
    type: number
    sql: ${TABLE}."BUDGET_REMAINING" ;;
    value_format_name: usd
  }

  dimension: total_spend_amount {
    type: number
    sql: ${TABLE}."TOTAL_SPEND_AMOUNT" ;;
    value_format_name: usd
  }

  dimension: pcnt_budget_remaining {
    label: "% of Budget Remaining"
    type: number
    sql: ${TABLE}."PCNT_BUDGET_REMAINING" ;;
    value_format_name: percent_1
  }

  dimension: last_invoice_date {
    type: date
    sql: ${TABLE}."LAST_INVOICE_DATE" ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: invoiced_in_last_two_weeks {
    type: string
    sql: ${TABLE}."INVOICED_IN_LAST_TWO_WEEKS" ;;
  }

  measure: budget_under_threshold {
    view_label: "Only Show Budgets Under Set Threshold?"
    label: " "
    type: yesno
    sql: ${pcnt_budget_remaining} <= ${dynamic_percentage_left_value} AND ${invoiced_in_last_two_weeks} = true ;;
  }

  parameter: budget_alert_level {
    view_label: "Budget Alert Level"
    label: " "
    type: string
    allowed_value: { value: "0%"}
    allowed_value: { value: "5%"}
    allowed_value: { value: "10%"}
    allowed_value: { value: "15%"}
    allowed_value: { value: "20%"}
    allowed_value: { value: "25%"}
    allowed_value: { value: "50%"}
  }

  measure: dynamic_percentage_left_value {
    label_from_parameter: budget_alert_level
    sql:{% if budget_alert_level._parameter_value == "'0%'" %}
      0
    {% elsif budget_alert_level._parameter_value == "'5%'" %}
      .05
    {% elsif budget_alert_level._parameter_value == "'10%'" %}
      .10
    {% elsif budget_alert_level._parameter_value == "'15%'" %}
      .15
    {% elsif budget_alert_level._parameter_value == "'20%'" %}
      .20
    {% elsif budget_alert_level._parameter_value == "'25%'" %}
      .25
    {% elsif budget_alert_level._parameter_value == "'50%'" %}
      .5
    {% else %}
      NULL
    {% endif %} ;;
  }

  set: detail {
    fields: [
      po_name,
      company_id,
      budget_amount,
      budget_remaining,
      total_spend_amount,
      pcnt_budget_remaining,
      last_invoice_date,
      invoiced_in_last_two_weeks
    ]
  }
}
