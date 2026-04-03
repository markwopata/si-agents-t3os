view: po_spend_by_invoice_date_filter {
  derived_table: {
    sql: with po_info as (
      select
        purchase_order_id,
        name as po_name,
        coalesce(sum(budget_amount),0) as budget_amount
      from
        ES_WAREHOUSE.PUBLIC.PURCHASE_ORDERS
      where
        company_id = {{ _user_attributes['company_id'] }}
      group by
        purchase_order_id,
        name
      )
      ,budget_invoice_combine as (
      SELECT
        i.BILLING_APPROVED_DATE,
        po.name,
        i.invoice_id as invoice_id,
        i.invoice_no,
        --i.billed_amount,
        sum(coalesce(vli.amount,0) + coalesce(vli.tax_amount,0)) as billed_amount,
        pi.budget_amount,
        'ES' as rental_type
      FROM
        po_info pi
        join ES_WAREHOUSE.PUBLIC.ORDERS o on o.purchase_order_id = pi.purchase_order_id
        join users u on o.user_id = u.user_id
        JOIN ES_WAREHOUSE.PUBLIC.PURCHASE_ORDERS po ON o.PURCHASE_ORDER_ID =  po.PURCHASE_ORDER_ID
        JOIN ES_WAREHOUSE.PUBLIC.GLOBAL_INVOICES i ON o.ORDER_ID = i.ORDER_ID
        LEFT JOIN ANALYTICS.PUBLIC.V_LINE_ITEMS vli on i.invoice_id = vli.invoice_id
        --JOIN es_warehouse_stage.PUBLIC.GLOBAL_INVOICES i ON o.ORDER_ID = i.ORDER_ID
      WHERE
          u.company_id = {{ _user_attributes['company_id'] }}::integer
          and o.deleted = FALSE
          --and i.billing_approved_date >= po.start_date
          and i.billing_approved_date between CONVERT_TIMEZONE('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start po_spend_date_filter.date_filter %}) and CONVERT_TIMEZONE('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end po_spend_date_filter.date_filter %})
      GROUP BY
          i.BILLING_APPROVED_DATE,
          po.name,
          --i.billed_amount,
          pi.budget_amount,
          i.invoice_id,
          i.invoice_no
      )
      ,budget_by_invoice as (
      SELECT
        BILLING_APPROVED_DATE,
        name,
        invoice_id,
        invoice_no,
        billed_amount,
        budget_amount,
        rental_type,
        sum(billed_amount) over (partition by name order by BILLING_APPROVED_DATE rows between unbounded preceding and current row) as cumulative_amount,
        budget_amount - cumulative_amount as remaining_budget
      FROM
        budget_invoice_combine
      GROUP BY
          BILLING_APPROVED_DATE, name, billed_amount, budget_amount, invoice_id, rental_type, invoice_no
      )
      select
          invoice_id,
          billing_approved_date,
          name as po_name,
          rental_type,
          invoice_no,
          billed_amount,
          coalesce(budget_amount,0) as budget_amount,
          coalesce(remaining_budget,0) as budget_remaining,
          case when budget_amount > 0 then ((coalesce(budget_amount,0) - coalesce(sum(cumulative_amount),0)) / coalesce(budget_amount,0)) else 0 end as pcnt_budget_remaining
      from
          budget_by_invoice
      group by
          invoice_id,
          billing_approved_date,
          invoice_no,
          billed_amount,
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
    primary_key: yes
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension_group: billing_approved_date {
    label: "Billing Approved"
    type: time
    sql: ${TABLE}."BILLING_APPROVED_DATE" ;;
  }

  dimension: po_name {
    label: "PO"
    type: string
    sql: ${TABLE}."PO_NAME" ;;
  }

  dimension: rental_type {
    type: string
    sql: ${TABLE}."RENTAL_TYPE" ;;
  }

  dimension: invoice_no {
    label: "Invoice Number"
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  dimension: billed_amount {
    label: "Invoice Amount"
    type: number
    sql: ${TABLE}."BILLED_AMOUNT" ;;
    value_format_name: usd
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
    label: "% Budget Remaining"
    type: number
    sql: ${TABLE}."PCNT_BUDGET_REMAINING" ;;
    value_format_name: percent_1
  }

  set: detail {
    fields: [
      invoice_id,
      billing_approved_date_time,
      po_name,
      rental_type,
      invoice_no,
      budget_amount,
      budget_remaining,
      pcnt_budget_remaining
    ]
  }
}
