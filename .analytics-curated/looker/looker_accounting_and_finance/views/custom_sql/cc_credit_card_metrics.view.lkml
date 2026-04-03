view: cc_credit_card_metrics {
  derived_table: {
    sql:
    select
  date_trunc('month', pr.date_created) as month,
  count(distinct pr.purchase_receipt_id) as total_cc_purchases,
  sum(pli.total_accepted * pli.price_per_unit) as total_accepted_value,
  count(distinct pli.purchase_line_item_id) as total_line_items,
  sum(pli.quantity) as total_quantity
from procurement.public.purchase_receipts as pr
join procurement.public.purchases as p on p.purchase_id = pr.purchase_id
join procurement.public.purchase_line_items as pli on pli.purchase_id = pr.purchase_id
join es_warehouse.public.users as u on u.user_id = p.user_id
where u.company_id = '1854'
group by 1
order by 1 asc
        ;;
  }

  dimension_group: month {
    type: time
    timeframes: [raw, month, year]
    sql: ${TABLE}.MONTH ;;
  }

  measure: total_cc_purchases {
    type: sum
    sql: ${TABLE}.total_cc_purchases ;;
  }

  measure: total_line_items {
    type: sum
    sql: ${TABLE}.total_line_items ;;
  }

  measure: total_quantity {
    type: sum
    sql: ${TABLE}.total_quantity ;;
  }


  measure: total_accepted_value {
    type: sum
    sql: ${TABLE}.total_accepted_value ;;
    value_format_name: "usd"
  }

  dimension: is_before_current_month {
    type: yesno
    label: "Before Current Month"
    sql: ${month_raw} < date_trunc('month', current_date) ;;
  }


# Optional: Derived metrics
measure: avg_value_per_purchase {
  type: number
  sql: CASE WHEN ${total_cc_purchases} > 0 THEN ${total_accepted_value}value} / ${total_cc_purchases} ELSE NULL END ;;
  value_format_name: usd
  group_label: "Derived"
}

measure: avg_quantity_per_purchase {
  type: number
  sql: CASE WHEN ${total_cc_purchases} > 0 THEN ${total_quantity} / ${total_cc_purchases} ELSE NULL END ;;
  value_format_name: decimal_1
  group_label: "Derived"
}

measure: avg_value_per_line_item {
  type: number
  sql: CASE WHEN ${total_line_items} > 0 THEN ${total_accepted_value} / ${total_line_items} ELSE NULL END ;;
  value_format_name: usd
  group_label: "Derived"
}

measure: avg_quantity_per_line_item {
  type: number
  sql: CASE WHEN ${total_line_items} > 0 THEN ${total_quantity} / ${total_line_items} ELSE NULL END ;;
  value_format_name: decimal_1
  group_label: "Derived"
}

measure: line_items_per_purchase {
  type: number
  sql: CASE WHEN ${total_cc_purchases} > 0 THEN ${total_line_items}::float / ${total_cc_purchases} ELSE NULL END ;;
  value_format_name: decimal_1
  group_label: "Derived"
}
}
