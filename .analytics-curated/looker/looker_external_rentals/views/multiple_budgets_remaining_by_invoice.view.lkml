view: multiple_budgets_remaining_by_invoice {
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
      ,po_budget_from_selection as (
      select
        sum(budget_amount) as budget_amount
      from
        ES_WAREHOUSE.PUBLIC.PURCHASE_ORDERS
      where
        --name in ('3031022-834860','3030740','3031807-937153')
        {% condition po_name_filter %} name {% endcondition %}
      )
      ,budget_invoice_combine as (
      SELECT
        i.BILLING_APPROVED_DATE,
        --po.name,
        i.invoice_id as invoice_id,
        i.invoice_no,
        sum(coalesce(vli.amount,0) + coalesce(vli.tax_amount,0)) as billed_amount,
        pbs.budget_amount,
        --po.budget_amount,
        'ES' as rental_type
      FROM
        po_selection ps
        JOIN ES_WAREHOUSE.PUBLIC.INVOICES i ON ps.purchase_order_id = i.purchase_order_id
        --JOIN ES_WAREHOUSE.PUBLIC.GLOBAL_INVOICES i ON ps.purchase_order_id = i.purchase_order_id
        JOIN ES_WAREHOUSE.PUBLIC.PURCHASE_ORDERS po ON ps.purchase_order_id = po.purchase_order_id
        left join ES_WAREHOUSE.PUBLIC.users u on i.ordered_by_user_id = u.user_id
        LEFT JOIN ANALYTICS.PUBLIC.V_LINE_ITEMS vli on i.invoice_id = vli.invoice_id
        --join ES_WAREHOUSE.PUBLIC.ORDERS o on o.purchase_order_id = ps.purchase_order_id
        --join users u on o.user_id = u.user_id
        --JOIN ES_WAREHOUSE.PUBLIC.PURCHASE_ORDERS po ON o.PURCHASE_ORDER_ID =  po.PURCHASE_ORDER_ID
        --JOIN ES_WAREHOUSE.PUBLIC.GLOBAL_INVOICES i ON o.ORDER_ID = i.ORDER_ID
        join po_budget_from_selection pbs on 1=1
      WHERE
          i.company_id = {{ _user_attributes['company_id'] }}::integer
          --and o.deleted = FALSE
          -- and i.billing_approved_date >= po.start_date
      GROUP BY
          i.BILLING_APPROVED_DATE,
          --po.name,
          --i.billed_amount,
          pbs.budget_amount,
          --po.budget_amount,
          i.invoice_id,
          i.invoice_no
      )
      ,budget_by_invoice as (
      SELECT
        BILLING_APPROVED_DATE,
        --name,
        invoice_id,
        invoice_no,
        billed_amount,
        budget_amount,
        rental_type,
        sum(billed_amount) over (order by BILLING_APPROVED_DATE rows between unbounded preceding and current row) as cumulative_amount,
        --partition by name
        budget_amount - cumulative_amount as remaining_budget
      FROM
        budget_invoice_combine
      GROUP BY
          BILLING_APPROVED_DATE, billed_amount, budget_amount, invoice_id, rental_type, invoice_no
      )
      select
          invoice_id,
          --name,
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
          --name,
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

  dimension: rental_type {
    type: string
    sql: ${TABLE}."RENTAL_TYPE" ;;
  }

  dimension: invoice_no {
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
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
    type: number
    sql: ${TABLE}."PCNT_BUDGET_REMAINING" ;;
    value_format_name: percent_1
  }

  filter: po_name_filter {
    suggest_explore: company_po
    suggest_dimension: company_po.name
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

  dimension: test {
    type: string
    sql: 'Test' ;;
    html:
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24"><path fill="none" d="M0 0h24v24H0z"/><path d="M10 6v2H5v11h11v-5h2v6a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V7a1 1 0 0 1 1-1h6zm11-3v9l-3.794-3.793-5.999 6-1.414-1.414 5.999-6L12 3h9z"/></svg>
    <i class="ri-external-link-line">&nbsp;</i>{{value}}
 ;;
  }

#   <svg style='fill: #4285F4; height: 64px;' class="svg-icon" viewBox="0 0 20 20">

#     <path d="M18.121,9.88l-7.832-7.836c-0.155-0.158-0.428-0.155-0.584,0L1.842,9.913c-0.262,0.263-0.073,0.705,0.292,0.705h2.069v7.042c0,0.227,0.187,0.414,0.414,0.414h3.725c0.228,0,0.414-0.188,0.414-0.414v-3.313h2.483v3.313c0,0.227,0.187,0.414,0.413,0.414h3.726c0.229,0,0.414-0.188,0.414-0.414v-7.042h2.068h0.004C18.331,10.617,18.389,10.146,18.121,9.88 M14.963,17.245h-2.896v-3.313c0-0.229-0.186-0.415-0.414-0.415H8.342c-0.228,0-0.414,0.187-0.414,0.415v3.313H5.032v-6.628h9.931V17.245z M3.133,9.79l6.864-6.868l6.867,6.868H3.133z"></path>

#   </svg>



  #<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24"><path fill="none" d="M0 0h24v24H0z"/><path d="M10 6v2H5v11h11v-5h2v6a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V7a1 1 0 0 1 1-1h6zm11-3v9l-3.794-3.793-5.999 6-1.414-1.414 5.999-6L12 3h9z"/></svg>

  set: detail {
    fields: [
      invoice_id,
      rental_type,
      invoice_no,
      budget_amount,
      budget_remaining,
      pcnt_budget_remaining
    ]
  }
}
