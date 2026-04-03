view: company_po {
  derived_table: {
    sql: select
          --purchase_order_id,
          name,
          sum(budget_amount) as budget_amount
      from
          purchase_orders
      where
          company_id = {{ _user_attributes['company_id'] }}::integer
      group by
          name
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
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

  dimension: budget_amount {
    type: number
    sql: coalesce(${TABLE}."BUDGET_AMOUNT",0) ;;
    value_format_name: usd
  }

  measure: total_budget_amount {
    type: sum
    sql: ${budget_amount} ;;
    value_format_name: usd
    html: <p>{{rendered_value}}<br /></p>
    <p>PO Start Date:<br/ > {{spend_by_po.po_start_date._rendered_value}}</p> ;;
  }

  set: detail {
    fields: [name, budget_amount]
  }
}
