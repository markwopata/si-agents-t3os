connection: "es_snowflake_analytics"

include: "/views/ES_WAREHOUSE/deliveries.view.lkml"
include: "/views/ES_WAREHOUSE/delivery_types.view.lkml"
include: "/views/ES_WAREHOUSE/rental_part_assignments.view.lkml"
include: "/views/ES_WAREHOUSE/rentals.view.lkml"
include: "/views/INVENTORY/parts.view.lkml"
include: "/views/ES_WAREHOUSE/orders.view.lkml"
include: "/views/INVENTORY/providers.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/ES_WAREHOUSE/users.view.lkml"
include: "/views/ES_WAREHOUSE/invoices.view.lkml"
include: "/views/ES_WAREHOUSE/line_items.view.lkml"
include: "/views/ES_WAREHOUSE/purchase_orders.view.lkml"
include: "/views/ES_WAREHOUSE/companies.view.lkml"
include: "/views/ES_WAREHOUSE/INVENTORY/rental_items.view.lkml"
include: "/views/custom_sql/bulk_parts_on_rent.view.lkml"

# Commented out due to low usage on 2026-03-27
# explore: deliveries {
#   case_sensitive: no
#   join: delivery_types {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${delivery_types.delivery_type_id} = ${deliveries.delivery_type_id} ;;
#   }
#
#   join: rental_part_assignments {
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${rental_part_assignments.drop_off_delivery_id}  = ${deliveries.delivery_id}
#       or ${rental_part_assignments.return_delivery_id} = ${deliveries.delivery_id};;
#   }
#
#   join: rentals {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${rental_part_assignments.rental_id} = ${rentals.rental_id} ;;
#   }
#
#   join: orders {
#     type: inner
#     relationship: one_to_one
#     sql_on: ${orders.order_id} = ${rentals.order_id} ;;
#   }
#
#   join: invoices {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${invoices.order_id} = ${rentals.order_id} ;;
#   }
#
#   join: users {
#     type:  left_outer
#     relationship: many_to_one
#     sql_on: ${invoices.created_by_user_id} = ${users.user_id} ;;
#   }
#
#   join: market_region_xwalk {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${orders.market_id} = ${market_region_xwalk.market_id} ;;
#   }
#
#   join: parts {
#     type: left_outer
#     relationship: many_to_one
#     sql_on:  ${rental_part_assignments.part_id} = ${parts.part_id};;
#   }
#
#   join: providers {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${parts.provider_id} = ${providers.provider_id}  ;;
#   }
# }

# Commented out due to low usage on 2026-03-27
# explore: rentals {
#   case_sensitive: no
#   join: rpa_partial_return{
#      from: rental_part_assignments
#      type: inner
#      relationship: many_to_one
#      sql_on: ${rpa_partial_return.rental_id} = ${rentals.rental_id} ;;
#      #sql_where:${rpa_partial_return.end_date} != ${rentals.end_date};;
#  }
#
#   join: rpa_normal {
#     from:  rental_part_assignments
#     type: inner
#     relationship: many_to_one
#     sql_on: ${rpa_normal.rental_id} = ${rentals.rental_id}  ;;
#     #sql_where: ${rpa_normal.end_date} = ${rentals.end_date} ;;
#   }
#
#   join: drop_off {
#     from: deliveries
#     type: inner
#     relationship: many_to_one
#     sql_on: ${drop_off.drop_off} = ${rpa_normal.drop_off_delivery_id};;
#   }
#
#   join: final_return {
#     from: deliveries
#     type: inner
#     relationship: many_to_one
#     sql_on: ${final_return.final_return} =  ${rpa_normal.return_delivery_id};;
#   }
#
#   join: partial_return {
#     from: deliveries
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${partial_return.partial_return} = ${rpa_partial_return.return_delivery_id};;
#     #sql_where: ${partial_return.delivery_type_id} = 5;;
#
#   }
#
#   #join: normal_drop_off_type {
#   #  from: delivery_types
#   #  type: left_outer
#   #  relationship: many_to_one
#   #  sql_on: ${drop_off.delivery_type_id} = ${drop_off.delivery_type_id} ;;
#  # }
#
#   #join: return_type {
#    # from: delivery_types
#    # type: inner
#    # relationship: many_to_one
#    # sql_on: ${drop_off_type.delivery_type_id} = ${return.delivery_type_id} ;;
#  # }
#
#   join: line_items {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${rentals.rental_id} = ${line_items.rental_id} ;;
#   }
#
#   join: invoices {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${line_items.invoice_id} = ${invoices.invoice_id} ;;
#   }
#
#   join: orders {
#     type: inner
#     relationship: one_to_one
#     sql_on: ${orders.order_id} = ${rentals.order_id} ;;
#   }
#
#   join: purchase_orders {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${purchase_orders.purchase_order_id} = ${orders.purchase_order_id} ;;
#   }
#
#   join: companies {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${companies.company_id} = ${purchase_orders.company_id} ;;
#   }
#
#   join: sales_users {
#     from:  users
#     type:  left_outer
#     relationship: many_to_one
#     sql_on: ${sales_users.user_id} = ${orders.salesperson_user_id} ;;
#   }
#
#   join: market_region_xwalk {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${orders.market_id} = ${market_region_xwalk.market_id} ;;
#   }
#
#   join: parts {
#     type: left_outer
#     relationship: many_to_one
#     sql_on:  ${rpa_normal.part_id} = ${parts.part_id};;
#   }
#
#   join: providers {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${parts.provider_id} = ${providers.provider_id}  ;;
#   }
# }

explore: bulk_parts_on_rent {
  label: "Bulk Parts On/Off Rent"

  join: rental_items {
    type: left_outer
    relationship: one_to_many
    sql_on: ${bulk_parts_on_rent.rental_id} = ${rental_items.rental_id};;
  }
}

# Commented out due to low usage on 2026-03-27
# explore: rental_items {
#   label: "not sure what to call this yet"
#
# }
