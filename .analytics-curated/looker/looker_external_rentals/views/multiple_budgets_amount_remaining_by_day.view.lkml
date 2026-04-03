view: multiple_budgets_amount_remaining_by_day {
  derived_table: {
    sql: with po_selection as (
      select
        purchase_order_id
      from
        ES_WAREHOUSE.PUBLIC.PURCHASE_ORDERS
      where
        --name in ('3031022-834860','3030740','3031807-937153')
        {% condition po_name_filter %} name {% endcondition %}
      )
      ,po_budget_from_selection as ( --sum budget here because different ids with the same name may exist
      select
        sum(budget_amount) as budget_amount
      from
        ES_WAREHOUSE.PUBLIC.PURCHASE_ORDERS
      where
        --name in ('3031022-834860','3030740','3031807-937153')
        {% condition po_name_filter %} name {% endcondition %}
      )
      ,budget_by_total_invoice as (
        SELECT
          i.BILLING_APPROVED_DATE::date as invoice_approved_date,
          --po.name,
          pbs.budget_amount,
          --po.start_date::date as po_start_date,
          sum(coalesce(vli.amount,0) + coalesce(vli.tax_amount,0)) as total_billed_amount
        FROM
          po_selection ps
          --JOIN ES_WAREHOUSE.PUBLIC.GLOBAL_INVOICES i ON ps.purchase_order_id = i.purchase_order_id --commented out for staging changes
          --JOIN es_warehouse_stage.PUBLIC.GLOBAL_INVOICES i ON ps.purchase_order_id = i.purchase_order_id
          JOIN ES_WAREHOUSE.PUBLIC.INVOICES i ON ps.purchase_order_id = i.purchase_order_id
          JOIN ES_WAREHOUSE.PUBLIC.PURCHASE_ORDERS po ON ps.purchase_order_id = po.purchase_order_id
          left join users u on i.ordered_by_user_id = u.user_id
          join po_budget_from_selection pbs on 1=1
          LEFT JOIN ANALYTICS.PUBLIC.V_LINE_ITEMS vli on i.invoice_id = vli.invoice_id
          --join ES_WAREHOUSE.PUBLIC.ORDERS o on o.purchase_order_id = ps.purchase_order_id
          --join users u on o.user_id = u.user_id
          --JOIN ES_WAREHOUSE.PUBLIC.PURCHASE_ORDERS po ON o.PURCHASE_ORDER_ID =  po.PURCHASE_ORDER_ID
          --JOIN ES_WAREHOUSE.PUBLIC.GLOBAL_INVOICES i ON o.ORDER_ID = i.ORDER_ID
          --join po_budget_from_selection pbs on 1=1
        WHERE
            i.company_id = {{ _user_attributes['company_id'] }}::integer
            --21330::integer
            --and o.deleted = FALSE
            --and i.billing_approved_date >= po.start_date
        GROUP BY
            i.BILLING_APPROVED_DATE::date,
            pbs.budget_amount
        --, po.name, po.budget_amount, po.start_date::date
        --ORDER BY
          --  PURCHASE_ORDER_ID, i.BILLING_APPROVED_DATE::date
        )
        ,remaining_budget_by_invoice as (
        select
            invoice_approved_date,
            --name,
            --po_start_date,
            budget_amount,
            sum(total_billed_amount) over (order by invoice_approved_date rows between unbounded preceding and current row) as cumulative_amount,
            budget_amount - cumulative_amount as remaining_budget
            --partition by name
        from
            budget_by_total_invoice
        )
        , invoice_info as (
        select
            invoice_approved_date,
            --name,
            --min(po_start_date) po_start_date,
            coalesce(budget_amount,0) as budget_amount,
            cumulative_amount,
            coalesce(remaining_budget,0) as remaining_budget,
            ifnull(lead(invoice_approved_date) OVER (order by invoice_approved_date),current_date) as next_invoice
          --partition by name
        from
            remaining_budget_by_invoice
        group by
            invoice_approved_date,
            --name,
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
            --name as purchase_order_name,
            --po_start_date,
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
    type: date
    label: "Date"
    sql: ${TABLE}."GENERATED_DATE" ;;
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

  filter: po_name_filter {
    suggest_explore: company_po
    suggest_dimension: company_po.name
  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(${generated_date},${remaining_budget}) ;;
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

  set: detail {
    fields: [generated_date, budget_amount, remaining_budget, cumulative_amount, pcnt_budget_remaining]
  }
}
