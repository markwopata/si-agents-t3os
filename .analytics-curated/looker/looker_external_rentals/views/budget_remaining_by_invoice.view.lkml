view: budget_remaining_by_invoice {
  derived_table: {
    sql:
      with budget_invoice_combine as (
      SELECT
        i.BILLING_APPROVED_DATE,
        po.name,
        i.invoice_id as invoice_id,
        i.invoice_no,
        i.billed_amount,
        po.budget_amount,
        'ES' as rental_type
      FROM
        ES_WAREHOUSE.PUBLIC.GLOBAL_INVOICES i
        JOIN es_warehouse.public.PURCHASE_ORDERS po ON i.purchase_order_id = po.purchase_order_id
        left join es_warehouse.public.users u on i.ordered_by_user_id = u.user_id
      WHERE
          u.company_id = {{ _user_attributes['company_id'] }}::integer
          and i.billing_approved_date >= po.start_date
      GROUP BY
          i.BILLING_APPROVED_DATE, po.name, i.billed_amount, po.budget_amount, i.invoice_id, i.invoice_no
      )
      ,budget_combo as (
      select
        name,
        max(budget_amount) as budget_amount
      from
        budget_invoice_combine
      group by
        name
      )
      ,budget_by_invoice as (
      SELECT
        BILLING_APPROVED_DATE,
        bic.name,
        invoice_id,
        invoice_no,
        billed_amount,
        bc.budget_amount,
        rental_type,
        sum(billed_amount) over (partition by bic.name order by BILLING_APPROVED_DATE rows between unbounded preceding and current row) as cumulative_amount,
        bc.budget_amount - cumulative_amount as remaining_budget
      FROM
        budget_invoice_combine bic
        join budget_combo bc on bc.name = bic.name
      GROUP BY
          BILLING_APPROVED_DATE, bic.name, billed_amount, bc.budget_amount, invoice_id, rental_type, invoice_no
      ORDER BY
          bic.name, BILLING_APPROVED_DATE
      )
      select
          invoice_id,
          name,
          rental_type,
          invoice_no,
          coalesce(budget_amount,0) as budget_amount,
          coalesce(remaining_budget,0) as budget_remaining,
          --coalesce(budget_amount, 0) - coalesce(sum(billed_amount),0) as budget_remaining,
          case when budget_amount > 0 then ((coalesce(budget_amount,0) - coalesce(sum(cumulative_amount),0)) / coalesce(budget_amount,0)) else 0 end as pcnt_budget_remaining
      from
          budget_by_invoice
      group by
          invoice_id,
          invoice_no,
          name,
          budget_amount,
          remaining_budget,
          rental_type
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
    value_format_name: id
  }

  dimension: invoice_no {
    group_label: "Table Value"
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  # dimension: purchase_order_id {
  #   type: number
  #   sql: ${TABLE}."PURCHASE_ORDER_ID" ;;
  #   value_format_name: id
  # }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: rental_type {
    type: string
    sql: ${TABLE}."RENTAL_TYPE" ;;
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

  dimension: pcnt_budget_remaining {
    label: "% of Budget Remaining"
    type: number
    sql: ${TABLE}."PCNT_BUDGET_REMAINING" ;;
    value_format_name: percent_1
  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(${invoice_no},${name}) ;;
  }

  dimension: view_invoice {
    label: "Invoice No"
    type: string
    sql: ${invoice_no} ;;
    required_fields: [invoice_id,rental_type,invoice_no]
    html:
    {% if rental_type._value == "ES" %}
    <font color="#0063f3"><u><a href="https://app.estrack.com/#/billing/{{invoice_id._value}}" target="_blank">{{value}}</a></font></u>
    {% else %}
    <p>{{ rendered_value }}</p>
    {% endif %} ;;
  }

  set: detail {
    fields: [invoice_id, name, budget_amount, budget_remaining, pcnt_budget_remaining]
  }
}
