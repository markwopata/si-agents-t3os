view: budget_amount_remaining_by_day {
  derived_table: {
    sql: with budget_by_total_invoice as (
      SELECT
        i.BILLING_APPROVED_DATE::date as invoice_approved_date,
        po.name,
        po.budget_amount,
        po.start_date::date as po_start_date,
        sum(i.billed_amount) as total_billed_amount
      FROM
        ES_WAREHOUSE.PUBLIC.ORDERS o
        join users u on o.user_id = u.user_id
        JOIN ES_WAREHOUSE.PUBLIC.PURCHASE_ORDERS po ON o.PURCHASE_ORDER_ID =  po.PURCHASE_ORDER_ID
        --JOIN es_warehouse_stage.PUBLIC.GLOBAL_INVOICES i ON o.ORDER_ID = i.ORDER_ID
        JOIN ES_WAREHOUSE.PUBLIC.GLOBAL_INVOICES i ON o.ORDER_ID = i.ORDER_ID
      WHERE
          u.company_id = {{ _user_attributes['company_id'] }}::integer
          --21330::integer
          and o.deleted = FALSE
          and i.billing_approved_date >= po.start_date
      GROUP BY
          i.BILLING_APPROVED_DATE::date, po.name, po.budget_amount, po.start_date::date
      --ORDER BY
        --  PURCHASE_ORDER_ID, i.BILLING_APPROVED_DATE::date
      )
      ,budget_combo as (
      select
        name,
        sum(budget_amount) as budget_amount
      from
        budget_by_total_invoice
      group by
        name
      )
      ,remaining_budget_by_invoice as (
      select
          invoice_approved_date,
          bti.name,
          po_start_date,
          bc.budget_amount,
          sum(total_billed_amount) over (partition by bc.name order by invoice_approved_date rows between unbounded preceding and current row) as cumulative_amount,
          bc.budget_amount - cumulative_amount as remaining_budget
      from
          budget_by_total_invoice bti
          join budget_combo bc on bc.name = bti.name
    --  union
    --  select
    --      min(po.start_date)::date as min_start_date,
    --      po.name,
    --      po.start_date::date as po_start_date,
    --      po.budget_amount,
    --      0,
    --      po.budget_amount as remaining_budget
    --  FROM
    --      ES_WAREHOUSE.PUBLIC.ORDERS o
    --      join users u on o.user_id = u.user_id
    --      JOIN ES_WAREHOUSE.PUBLIC.PURCHASE_ORDERS po ON o.PURCHASE_ORDER_ID =  po.PURCHASE_ORDER_ID
    --      JOIN ES_WAREHOUSE.PUBLIC.INVOICES i ON o.ORDER_ID = i.ORDER_ID
    --  where
    --      u.company_id = {{ _user_attributes['company_id'] }}::integer
          --21330::integer
    --      and o.deleted = FALSE
    -- group by
    --      po.name,
    --      po.budget_amount,
    --      po.start_date::date
      )
      , invoice_info as (
      select
          invoice_approved_date,
          name,
          min(po_start_date) po_start_date,
          coalesce(budget_amount,0) as budget_amount,
          cumulative_amount,
          coalesce(remaining_budget,0) as remaining_budget,
          ifnull(lead(invoice_approved_date) OVER (partition by name order by invoice_approved_date),current_date) as next_invoice
      from
          remaining_budget_by_invoice
      group by
          invoice_approved_date,
          name,
          coalesce(budget_amount,0),
          cumulative_amount,
          coalesce(remaining_budget,0)
      ),
      generate_series as (
      select * from table(generate_series(
      '2019-01-01'::timestamp_tz,
      current_date::timestamp_tz,
      'day')
      )
      )
      select
          series::date as generated_date,
          name as purchase_order_name,
          po_start_date,
          budget_amount,
          round(remaining_budget,2) as remaining_budget,
          cumulative_amount,
          case when budget_amount > 0 then ((coalesce(budget_amount,0) - coalesce(cumulative_amount,0)) / coalesce(budget_amount,0)) else 0 end as pcnt_budget_remaining
      from
          generate_series gs
          join invoice_info ii on gs.series >= invoice_approved_date and gs.series < next_invoice
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: generated_date {
    label: "Date"
    type: date
    sql: ${TABLE}."GENERATED_DATE" ;;
  }

  dimension: purchase_order_name {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_NAME" ;;
  }

  dimension: po_start_date {
    type: date
    sql: ${TABLE}."PO_START_DATE" ;;
  }

  dimension: budget_amount {
    type: number
    sql: ${TABLE}."BUDGET_AMOUNT" ;;
    value_format_name: usd
  }

  dimension: remaining_budget {
    type: number
    sql: ${TABLE}."REMAINING_BUDGET" ;;
    value_format_name: usd
  }

  dimension: cumulative_amount {
    type: number
    sql: ${TABLE}."CUMULATIVE_AMOUNT" ;;
    value_format_name: usd
  }

  dimension: pcnt_budget_remaining {
    type: number
    sql: ${TABLE}."PCNT_BUDGET_REMAINING" ;;
    value_format_name: percent_1
  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(${generated_date},${purchase_order_name}) ;;
  }

  measure: has_budget_or_spend {
    type: yesno
    sql: ${overall_budget} >= 0 AND ${overall_spend} > 0 ;;
  }

  measure: overall_budget {
    type: max
    sql: ${budget_amount} ;;
    value_format_name: usd
  }

  measure: overall_spend {
    type: max
    sql: ${cumulative_amount} ;;
    value_format_name: usd
  }

  measure: overall_budget_remaining {
    type: max
    sql: ${remaining_budget} ;;
    value_format_name: usd
  }

  measure: overall_percent_budget_remaining {
    type: min
    sql: ${pcnt_budget_remaining} ;;
    value_format_name: percent_1
    filters: [budget_amount: ">0"]
  }

  measure: overall_budget_remaining_and_percent_remaining {
    type: max
    sql: ${remaining_budget} ;;
    html: Budget Remaining: ${{rendered_value}} <br /> Budget % Remaining: {{overall_percent_budget_remaining._rendered_value}} ;;
  }

  dimension: start_date_formatted {
    group_label: "HTML Passed Date Format" label: "PO Start Date"
    sql: ${po_start_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  set: detail {
    fields: [
      generated_date,
      purchase_order_name,
      budget_amount,
      remaining_budget,
      cumulative_amount,
      pcnt_budget_remaining
    ]
  }
}
