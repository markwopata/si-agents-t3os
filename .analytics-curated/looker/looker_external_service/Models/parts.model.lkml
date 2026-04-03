connection: "es_warehouse"

include: "/views/wo_export/*.view.lkml"                # include all views in the views/ folder in this project


explore: parts_to_work_order {
  group_label: "Service"
  label: "Parts to Work Orders"
  case_sensitive: no
  # persist_for: "20 minutes"
}

# explore: transactions {
#   group_label: "Service"
#   label: "Parts to Work Orders"
#   sql_always_where: ${transaction_type_id} = 7 ;;
#   case_sensitive: no
#   persist_for: "10 minutes"

#   join: transaction_items {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${transactions.transaction_id} = ${transaction_items.transaction_id} ;;
#   }

#   join: parts {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${parts.part_id} = ${transaction_items.part_id} ;;
#   }

#   join: part_types {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${parts.part_type_id} = ${part_types.part_type_id} ;;
#   }

#   join: work_orders {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${transactions.to_id} = ${work_orders.work_order_id} ;;
#   }
# }
