view: invoice_summary_by_order {
  derived_table: {
    # Aggregate invoice activity to order grain so quote-level explores can join safely.
    sql:
      select
        ild."INVOICE_LINE_DETAILS_ORDER_KEY" as order_key,
        max(ild."INVOICE_LINE_DETAILS_GL_BILLING_APPROVED_DATE_KEY"),
        max(o."ORDER_ID") as order_id,
        count(distinct i."INVOICE_KEY") as invoice_count,
        iff(max(case when i."INVOICE_PAID" then 1 else 0 end) = 1, true, false) as has_paid_invoice,
        iff(max(case when i."INVOICE_BILLING_APPROVED" then 1 else 0 end) = 1, true, false) as has_billing_approved_invoice,
        sum(coalesce(ild."INVOICE_LINE_DETAILS_AMOUNT", 0)) as invoiced_amount,
        sum(coalesce(ild."INVOICE_LINE_DETAILS_TAX_AMOUNT", 0)) as invoiced_tax_amount,
        sum(CASE WHEN i."INVOICE_PAID" then ild."INVOICE_LINE_DETAILS_AMOUNT" end) as paid_invoiced_amount,
        sum(CASE WHEN i."INVOICE_PAID" then ild."INVOICE_LINE_DETAILS_TAX_AMOUNT" end) as paid_invoiced_tax_amount
      from platform.gold.fact_invoice_line_details as ild
      left join platform.gold.dim_orders as o
        on ild."INVOICE_LINE_DETAILS_ORDER_KEY" = o."ORDER_KEY"
      left join platform.gold.dim_invoices as i
        on ild."INVOICE_LINE_DETAILS_INVOICE_KEY" = i."INVOICE_KEY"
      where ild."INVOICE_LINE_DETAILS_ORDER_KEY" is not null
      group by 1
      ;;
  }

  dimension: order_key {
    primary_key: yes
    type: string
    sql: ${TABLE}."ORDER_KEY" ;;
  }

  dimension: order_id {
    type: string
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension: gl_billing_approved_date_key {
    type: string
    sql: ${TABLE}."INVOICE_LINE_DETAILS_GL_BILLING_APPROVED_DATE_KEY" ;;
  }

  dimension: order_id_link {
    label: "Order Id"
    type: string
    sql: ${TABLE}."ORDER_ID" ;;
    html:
      <a href="https://admin.equipmentshare.com/#/home/orders/{{ value }}"
         style="color: blue; text-decoration: underline;"
         target="_blank">
        {{ rendered_value }}
      </a> ;;
  }

  dimension: invoice_count {
    type: number
    sql: ${TABLE}."INVOICE_COUNT" ;;
  }

  dimension: has_paid_invoice {
    type: yesno
    sql: ${TABLE}."HAS_PAID_INVOICE" ;;
  }

  dimension: has_billing_approved_invoice {
    type: yesno
    sql: ${TABLE}."HAS_BILLING_APPROVED_INVOICE" ;;
  }

  dimension: invoiced_amount {
    type: number
    value_format_name: usd
    sql: ${TABLE}."INVOICED_AMOUNT" ;;
  }

  dimension: invoiced_tax_amount {
    type: number
    value_format_name: usd
    sql: ${TABLE}."INVOICED_TAX_AMOUNT" ;;
  }

    dimension: paid_invoiced_amount {
    type: number
    value_format_name: usd
    sql: ${TABLE}."PAID_INVOICED_AMOUNT" ;;
  }

  dimension: paid_invoiced_tax_amount {
    type: number
    value_format_name: usd
    sql: ${TABLE}."PAID_INVOICED_TAX_AMOUNT" ;;
  }

  measure: count {
    type: count
  }

  measure: invoice_count_sum {
    type: sum
    sql: ${invoice_count} ;;
  }

  measure: invoiced_amount_sum {
    type: sum
    sql: ${invoiced_amount} ;;
    value_format_name: usd
  }

  measure: invoiced_tax_amount_sum {
    type: sum
    sql: ${invoiced_tax_amount} ;;
    value_format_name: usd
  }

   measure: paid_invoiced_amount_sum {
    type: sum
    sql: ${paid_invoiced_amount} ;;
    value_format_name: usd
  }

  measure: paid_tax_amount_sum {
    type: sum
    sql: ${paid_invoiced_tax_amount} ;;
    value_format_name: usd
  }
}
