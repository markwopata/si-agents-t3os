## I created this view because when I added the below dimensnion and measures, some of the fields we'ren't accessible in other explores that were using the part_inventory_transactions.view (such as service_parts:inventory and service_parts:parts_purchased).  Hopefully, this will provide a way around these issues without having to join onto data and possibly running into a fan out situation.  This needed to be an extended view so I could still retain access to all the other information from part_inventory_transactions when I created the model.
include: "/views/ANALYTICS/INTACCT_MODELS/part_inventory_transactions_b.view"
view: filtered_in_out_transactions {
  extends: [part_inventory_transactions_b]

  dimension: transaction_status_flag {
    sql:
    case
      --when ${transaction_type_id} = 7 then 'outgoing'
      when ${transaction_type_id} = 7 and ${wo_tags_aggregate.tags} ilike any ('%Inventory%','%Cycle Count%','%Adjustment%') and ${work_orders.work_order_status_id} = 3 then 'outgoing'
      when ${transaction_type_id} = 7 and ${wo_tags_aggregate.tags} ilike any ('%Inventory%','%Cycle Count%','%Adjustment%')  and ${work_orders.work_order_status_id} = 4 then 'outgoing'
      when ${transaction_type_id} = 18 and (${manual_adjustment_reason_id} = 4 or  ${manual_adjustment_reason_id} = 10) then 'outgoing'
      when ${transaction_type_id} = 17 and (${manual_adjustment_reason_id} = 1 or  ${manual_adjustment_reason_id} = 10) then 'incoming'
      end ;;
  }
  measure: sum_outgoing_transactions {
    label: "Outgoing Adjustment Transactions"
    type: count
    html: {{sum_outgoing_transactions}} ({{outgoing_transactions_amount._rendered_value}}) Total Outgoing Adjustments: {{outgoing_transactions_percent._rendered_value}} of Total Transactions ;;
    filters: [transaction_status_flag: "outgoing"]
    drill_fields: [filtered_transaction_detail_region*]
    #sql: ${transaction_status_flag} ;;  Got a warning when i set this field saying not to use SQL with count.  Removed and the numbers are accurate. Looker appears to know to count the transactions on the filter I set above.
  }
  measure: sum_incoming_transactions {
    label: "Incoming Adjustment Transactions"
    type: count
    html: {{sum_incoming_transactions}} ({{incoming_transactions_amount._rendered_value}}) Total Incoming Adjustments: {{incoming_transactions_percent._rendered_value}} of Total Transactions ;;
    filters: [transaction_status_flag: "incoming"]
    drill_fields: [filtered_transaction_detail_region*]
    #sql: ${transaction_status_flag} ;;
  }
  measure: outgoing_transactions_percent {
    value_format_name: percent_1
    sql: ${sum_outgoing_transactions} / ${count_distinct_transaction_ids} ;;
  }
  measure: incoming_transactions_percent {
    value_format_name: percent_1
    sql: ${sum_incoming_transactions} / ${count_distinct_transaction_ids} ;;
  }
  measure: outgoing_transactions_abs_amount {
    label: "Absolute value for Outgoing Transactions"
    type: sum
    value_format_name: usd_0
    sql: abs(${amount});;
    html: {{sum_outgoing_transactions}} ({{outgoing_transactions_abs_amount._rendered_value}}) Total Outgoing Adjustments: {{outgoing_transactions_percent._rendered_value}} of Total Transactions ;;
    filters: [transaction_status_flag: "outgoing"]
    drill_fields: [filtered_transaction_detail_region_abs*]
  }
  measure: outgoing_transactions_amount {
    type: sum
    value_format_name: usd_0
    sql: ${amount};;
    html: {{sum_outgoing_transactions}} ({{outgoing_transactions_amount._rendered_value}}) Total Outgoing Adjustments: {{outgoing_transactions_percent._rendered_value}} of Total Transactions ;;
    filters: [transaction_status_flag: "outgoing"]
    drill_fields: [filtered_transaction_detail_region*]
  }
  measure: incoming_transactions_amount {
    type: sum
    value_format_name: usd_0
    sql: abs(${amount}) ;;
    html: {{sum_incoming_transactions}} ({{incoming_transactions_amount._rendered_value}}) Total Incoming Adjustments: {{incoming_transactions_percent._rendered_value}} of Total Transactions ;;
    filters: [transaction_status_flag: "incoming"]
    drill_fields: [filtered_transaction_detail_region*]
  }



  measure: count_distinct_transaction_ids {
    label: "Count of Distinct Transaction IDs"
    type: count_distinct
    #drill_fields: [just_test*]
    drill_fields: [filtered_transaction_detail_market*]
    sql: ${transaction_id} ;;
  }
  #used for absolute values done on outgoing transaction amounts.
  measure: count_distinct_transaction_ids_abs {
    label: "Count of Distinct Transaction IDs"
    type: count_distinct
    #drill_fields: [just_test*]
    drill_fields: [filtered_transaction_detail_market_abs*]
    sql: ${transaction_id} ;;
  }
  set: filtered_transaction_detail_region {
    fields: [
            market_region_xwalk.market_name,
            count_distinct_transaction_ids,
            total_value
            ]
  }
  set: filtered_transaction_detail_market {
    fields: [
            market_name,
            transaction_id,
            transaction_type,
            manual_adjustment_reason,
            number_of_items,
            total_value,
            created_by_username
            ]
  }
  #used for absolute values done on outgoing transaction amounts.
  set: filtered_transaction_detail_region_abs {
    fields: [
      market_region_xwalk.market_name,
      count_distinct_transaction_ids_abs,
      abs_total_value
    ]
  }
  #used for absolute values done on outgoing transaction amounts.
  set: filtered_transaction_detail_market_abs {
    fields: [
      market_name,
      transaction_id,
      transaction_type,
      manual_adjustment_reason,
      number_of_items,
      abs_total_value,
      created_by_username
    ]
  }
}
