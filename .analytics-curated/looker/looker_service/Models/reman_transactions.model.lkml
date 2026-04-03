connection: "es_snowflake_analytics"

include: "/views/ANALYTICS/INTACCT_MODELS/part_inventory_transactions_reman.view.lkml"
include: "/views/INVENTORY/transaction_types.view.lkml"
include: "/views/ES_WAREHOUSE/users.view.lkml"
include: "/views/PLATFORM/v_parts.view.lkml"
include: "/views/PLATFORM/v_markets.view.lkml"
include: "/views/PROCUREMENT/purchase_orders.view.lkml"
include: "/views/ES_WAREHOUSE/PURCHASES/entity_vendor_settings.view.lkml"
include: "/views/ANALYTICS/INTACCT/vendor.view.lkml"
include: "/views/ANALYTICS/PARTS_INVENTORY/part_substitutes.view.lkml"
include: "/views/ANALYTICS/net_price.view.lkml"

explore: part_inventory_transactions {
  from: part_inventory_transactions_reman
  label: "REMAN Parts Transacitons"

  join: transaction_types {
    type: inner
    relationship: many_to_one
    sql_on: ${part_inventory_transactions.transaction_type_id} = ${transaction_types.transaction_type_id} ;;
  }

  join: created_users {
    from: users
    type: inner
    relationship: many_to_one
    sql_on: ${part_inventory_transactions.created_by_user_id} = ${created_users.user_id} ;;
  }

  join: modify_users {
    from: users
    type: inner
    relationship: many_to_one
    sql_on: ${part_inventory_transactions.updated_by_user_id} = ${modify_users.user_id} ;;
  }

  join: v_parts {
    type: inner
    relationship: many_to_one
    sql_on: ${part_inventory_transactions.part_id} = ${v_parts.part_id} ;;
  }

  join: v_markets {
    type: inner
    relationship: many_to_one
    sql_on: ${part_inventory_transactions.market_id} = ${v_markets.market_id} ;;
  }

  join: purchase_orders {
    type: inner
    relationship: many_to_one
    sql_on: ${part_inventory_transactions.purchase_order_id} = ${purchase_orders.purchase_order_id} ;;
  }

  join: entity_vendor_settings {
    type: inner
    relationship: many_to_one
    sql_on: ${purchase_orders.vendor_id} = ${entity_vendor_settings.entity_id} ;;
  }

  join: vendor {
    type: inner
    relationship: one_to_one
    sql_on: ${entity_vendor_settings.external_erp_vendor_ref} = ${vendor.vendorid} ;;
  }

  join: part_substitutes {
    type: left_outer
    relationship: many_to_many
    sql_on: (${part_inventory_transactions.part_id} = ${part_substitutes.part_id} or ${part_inventory_transactions.part_id} = ${part_substitutes.sub_part_id}) and ${part_substitutes.substitution_type} = 'REMAN' and ${part_substitutes.isactive} ;;
  }

  join: new_net_price {
    from: net_price
    type: left_outer
    relationship: many_to_one
    sql_on: ${part_substitutes.part_id} = ${new_net_price.part_id} and ${vendor.vendorid} = ${new_net_price.vendor_id} and ${purchase_orders.date_created_raw} between ${new_net_price.start_date} and ${new_net_price.end_date} and ${part_substitutes.part_type} = 'REMAN' ;;
  }

  join: reman_net_price {
    from: net_price
    type: left_outer
    relationship: many_to_one
    sql_on: ${part_substitutes.sub_part_id} = ${reman_net_price.part_id} and ${vendor.vendorid} = ${reman_net_price.vendor_id} and ${purchase_orders.date_created_raw} between ${reman_net_price.start_date} and ${reman_net_price.end_date} and ${part_substitutes.part_type} = 'NEW' ;;
  }
}
