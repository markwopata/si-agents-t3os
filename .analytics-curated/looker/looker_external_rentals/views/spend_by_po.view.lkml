view: spend_by_po {
  derived_table: {
    sql: with po_billed_amount as (
      SELECT
          po.name,
          min(po.start_date) as start_date,
          sum(coalesce(vli.amount,0) + coalesce(vli.tax_amount,0)) as billed_amount
      FROM
          ES_WAREHOUSE.PUBLIC.INVOICES i
          --es_warehouse_stage.public.global_invoices i
          JOIN ES_WAREHOUSE.PUBLIC.PURCHASE_ORDERS po ON i.purchase_order_id = po.purchase_order_id
          left join users u on i.ordered_by_user_id = u.user_id
          LEFT JOIN ANALYTICS.PUBLIC.V_LINE_ITEMS vli on i.invoice_id = vli.invoice_id
          --ES_WAREHOUSE.PUBLIC.ORDERS o
          --join users u on o.user_id = u.user_id
          --JOIN ES_WAREHOUSE.PUBLIC.PURCHASE_ORDERS po ON o.PURCHASE_ORDER_ID =  po.PURCHASE_ORDER_ID
          --JOIN ES_WAREHOUSE.PUBLIC.GLOBAL_INVOICES i ON o.ORDER_ID = i.ORDER_ID
      WHERE
          i.company_id = {{ _user_attributes['company_id'] }}::numeric
          and i.billing_approved = true
          --21330::integer
          --and o.deleted = FALSE
          --and i.billing_approved_date >= po.start_date
          AND {% condition po_name_filter %} po.name {% endcondition %}
          --and po.name in ('3031022-834860','3030740','3031807-937153')
      GROUP BY
          po.name
      )
      select
          name,
          min(start_date)::date as start_date,
          sum(billed_amount) as billed_amount
      from
          po_billed_amount
      group by
          name
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: start_date {
    type: date
    sql: ${TABLE}."START_DATE" ;;
  }

  dimension: billed_amount {
    type: number
    sql: ${TABLE}."BILLED_AMOUNT" ;;
    value_format_name: usd
  }

  dimension: po_start_date {
    type: date
    sql: ${start_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  measure: total_billed_amount {
    type: sum
    sql: ${billed_amount} ;;
    value_format_name: usd
    html: <p>{{rendered_value}}<br /></p>
    <p>PO Start Date:<br/ > {{po_start_date._rendered_value}}</p> ;;
  }

  filter: po_name_filter {
    suggest_explore: budget_amount_remaining_by_day
    suggest_dimension: purchase_orders.name
  }

  set: detail {
    fields: [name, billed_amount]
  }
}
