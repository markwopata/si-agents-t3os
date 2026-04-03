connection: "es_snowflake_analytics"

# include: "/views/INVENTORY/stores.view.lkml"
include: "//asset_information/views/custom_sql/daily_rev_calculation.view.lkml"
include: "/views/be_market_start_month.view.lkml"
########### ANALYTICS ###########
include: "/views/ANALYTICS/company_directory.view.lkml"
include: "/views/ANALYTICS/es_companies.view.lkml"
include: "/views/ANALYTICS/fulfillment_center_markets.view.lkml"
include: "/views/ANALYTICS/generator_and_fuel_cell_rentals.view.lkml"
include: "/views/ANALYTICS/incorrect_onsite_fueling_reporting.view.lkml"
include: "/views/ANALYTICS/inventory_balances_snapshot.view.lkml"
include: "/views/ANALYTICS/line_item_types.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/ANALYTICS/net_price.view.lkml"
include: "/views/ANALYTICS/parts_inventory_parts.view.lkml"
include: "/views/ANALYTICS/part_inventory_transactions.view.lkml" ## possible problem
include: "/views/ANALYTICS/telematics_part_ids.view.lkml"
include: "/views/ANALYTICS/v_line_items.view.lkml"
include: "/views/ANALYTICS/INTACCT/vendor.view.lkml"
include: "/views/ANALYTICS/INTACCT/glaccount.view.lkml"
include: "/views/ANALYTICS/INTACCT/glentry.view.lkml"
include: "/views/ANALYTICS/INTACCT_MODELS/ap_detail.view.lkml"
include: "/views/ANALYTICS/INTACCT_MODELS/part_inventory_transactions_b.view.lkml"
include: "/views/ANALYTICS/PUBLIC/historical_utilization.view.lkml"
include: "/views/ANALYTICS/PARTS_INVENTORY/fulfillment_parts_attributes.view.lkml"
include: "/views/ANALYTICS/PARTS_INVENTORY/part_mapping.view.lkml"
include: "/views/ANALYTICS/PARTS_INVENTORY/part_substitutes.view.lkml"
include: "/views/ANALYTICS/PARTS_INVENTORY/part_suppression_categories.view.lkml"
include: "/views/ANALYTICS/PARTS_INVENTORY/parts_attributes.view.lkml"
include: "/views/ANALYTICS/PARTS_INVENTORY/part_categorization_structure.view.lkml"

########### CUSTOM_SQL ###########
include: "/views/custom_sql/asset_class_30_day_utilization.view.lkml"
include: "/views/custom_sql/back_order_parts.view.lkml"
include: "/views/custom_sql/back_order_work_orders.view.lkml"
include: "/views/custom_sql/cost_by_provider.view.lkml"
include: "/views/custom_sql/current_deadstock.view.lkml"
include: "/views/custom_sql/deadstock_consumption_locations.view.lkml"
include: "/views/custom_sql/filtered_in_out_transactions.view.lkml"
include: "/views/custom_sql/historical_wo_revenue_impact.view.lkml"
include: "/views/custom_sql/inventory_allocation.view.lkml"
include: "/views/custom_sql/inventory_dead_stock.view.lkml"
include: "/views/custom_sql/lead_time_2023.view.lkml"
include: "/views/custom_sql/lead_time.view.lkml"
include: "/views/custom_sql/non_adjustment_transactions.view.lkml"
include: "/views/custom_sql/part_average_cost.view.lkml"
include: "/views/custom_sql/part_demand.view.lkml"
include: "/views/custom_sql/part_purchase_order_lookup.view.lkml"
include: "/views/custom_sql/part_sales_fulfillment.view.lkml"
include: "/views/custom_sql/part_spend_vs_consumption.view.lkml"
include: "/views/custom_sql/parts_consumption.view.lkml"
include: "/views/custom_sql/parts_demand.view.lkml"
include: "/views/custom_sql/parts_inventory_addition_fields.view.lkml"
include: "/views/custom_sql/purchase_order_line_items_historical.view.lkml"
include: "/views/custom_sql/t3_purchase_order_details.view.lkml"
include: "/views/custom_sql/total_inventory_allocation.view.lkml"
include: "/views/custom_sql/total_inventory_per_store_history.view.lkml"
include: "/views/custom_sql/total_inventory_per_store.view.lkml"
include: "/views/custom_sql/trending_dead_stock.view.lkml"
include: "/views/custom_sql/trending_store_to_store_transfers.view.lkml"
include: "/views/custom_sql/unreceived_pos.view.lkml"
include: "/views/custom_sql/vendor_accountability.view.lkml"
include: "/views/custom_sql/preferred_nonpreferred_vendor_comparison.view.lkml"
include: "/views/custom_sql/wac_date_vendor_accountability.view.lkml"
include: "/views/custom_sql/weighted_average_cost.view.lkml"
include: "/views/custom_sql/weighted_average_cost.view.lkml"
include: "/views/custom_sql/wo_parts_cost.view.lkml"
include: "/views/custom_sql/wo_tagged_warranty.view.lkml"
include: "/views/custom_sql/wo_tags_aggregate.view.lkml"
include: "/views/custom_sql/missed_savings.view.lkml"
include: "/views/custom_sql/Shopify_Inventory.view.lkml"
########### ES_WAREHOUSE ###########
include: "/views/ES_WAREHOUSE/approved_invoice_salespersons_itl.view.lkml"
include: "/views/ES_WAREHOUSE/assets_aggregate.view.lkml"
include: "/views/ES_WAREHOUSE/assets.view.lkml"
include: "/views/ES_WAREHOUSE/companies.view.lkml"
include: "/views/ES_WAREHOUSE/command_audit.view.lkml"
include: "/views/ES_WAREHOUSE/equipment_classes.view.lkml"
include: "/views/ES_WAREHOUSE/invoices.view.lkml"
include: "/views/ES_WAREHOUSE/line_items_w_avg_cost.view.lkml"
include: "/views/ES_WAREHOUSE/line_items.view.lkml"
include: "/views/ES_WAREHOUSE/markets.view.lkml"
include: "/views/ES_WAREHOUSE/orders.view.lkml"
include: "/views/ES_WAREHOUSE/PURCHASES/entities.view.lkml"
include: "/views/ES_WAREHOUSE/users.view.lkml"
########### INVENTORY ###########
include: "/views/INVENTORY/deadstock_snapshot.view.lkml"
include: "/views/INVENTORY/inventory_locations.view.lkml"
include: "/views/INVENTORY/part_categories.view.lkml"
include: "/views/INVENTORY/part_types.view.lkml"
include: "/views/INVENTORY/parts.view.lkml"
include: "/views/INVENTORY/providers.view.lkml"
include: "/views/INVENTORY/reservations.view.lkml"
include: "/views/INVENTORY/store_parts.view.lkml"
include: "/views/INVENTORY/stores.view.lkml"
include: "/views/INVENTORY/transaction_items_w_avg_cost.view.lkml"
include: "/views/INVENTORY/transaction_items.view.lkml"
include: "/views/INVENTORY/transaction_types.view.lkml"
include: "/views/INVENTORY/transactions.view.lkml"
include: "/views/INVENTORY/weighted_average_cost_snapshots.view.lkml"
########### PROCUREMENT ###########
include: "/views/PROCUREMENT/purchase_order_line_items.view.lkml"
include: "/views/PROCUREMENT/purchase_orders.view.lkml"
include: "/views/PROCUREMENT/purchase_order_receivers.view.lkml"
include: "/views/PROCUREMENT/price_list_entries.view.lkml"
include: "/views/PROCUREMENT/demand_request_line_items.view.lkml"
include: "/views/PROCUREMENT/demand_requests.view.lkml"
########### WORK_ORDERS ###########
include: "/views/WORK_ORDERS/billing_types.view.lkml"
include: "/views/WORK_ORDERS/work_order_statuses.view.lkml"
include: "/views/WORK_ORDERS/work_orders.view.lkml"
include: "/views/WORK_ORDERS/work_order_company_tags.view.lkml"
include: "/views/WORK_ORDERS/company_tags.view.lkml"
include: "/views/ANALYTICS/MONDAY/part_back_order_requests_board.view.lkml"
include: "/views/ANALYTICS/top_vendor_mapping.view.lkml"
include: "/views/ANALYTICS/fuel_revenue.view.lkml"
########### FLEET OPTIMIZATION ###########
include: "/views/FLEET_OPTIMIZATION/dim_markets_fleet_opt.view.lkml"
include: "/views/FLEET_OPTIMIZATION/dim_dates_fleet_opt.view.lkml"
include: "/views/FLEET_OPTIMIZATION/dim_parts_fleet_opt.view.lkml"

include: "/Dashboards/Inventory_Branch_Scorecard/views/branch_contact.view.lkml"

include: "/views/custom_sql/new_total_inventory_allocation_test.view.lkml"

# Commented out due to low usage on 2026-03-27
# explore: new_total_inventory_allocation_test {
#   case_sensitive: no
# }

explore: non_adjustment_transactions {
  case_sensitive: no
  label: "Redistribution Trend"

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: ${non_adjustment_transactions.branch_id} = ${market_region_xwalk.market_id} ;;
  }
  join: fulfillment_center_markets {
    type: left_outer
    relationship: one_to_one
    sql_on: ${market_region_xwalk.market_name} = ${fulfillment_center_markets.location} ;;
  }
  join: users {
    view_label: "Transactions Created by Corporate Parts Team"
    type: left_outer
    relationship: many_to_one
    sql_on: ${users.user_id} = ${non_adjustment_transactions.created_by_user_id} and ${users.company_id}=1854 ;;
  }
  join: company_directory {
    type: inner
    relationship: one_to_one
    sql_on: ${company_directory.employee_id} = to_char(${users.employee_id}) ;;
  }
}
explore: trending_store_to_store_transfers {
  case_sensitive: no

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: ${trending_store_to_store_transfers.receiving_branch}= ${market_region_xwalk.market_id} ;;
  }
  join: parts {
    type: inner
    relationship: many_to_one
    sql_on: ${parts.part_id} = ${trending_store_to_store_transfers.part_id} ;;
  }
  join: part_substitutes_flag_sub_type {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_id} = ${part_substitutes_flag_sub_type.part_id} ;;
  }
  join: part_suppression_categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_id} = ${part_suppression_categories.part_id} ;;
  }

  join: parts_attributes_part_id_level {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_id} = ${parts_attributes_part_id_level.part_id} ;;
  }
  join: part_categorization_structure {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts_attributes_part_id_level.part_categorization_id} = ${part_categorization_structure.part_categorization_id} ;;
  }

  join: providers {
    type: left_outer
    relationship: many_to_one
    sql_on: ${providers.provider_id} = ${parts.provider_id} ;;
  }
  join: telematics_part_ids {
    type: left_outer
    relationship: many_to_one
    sql_on: ${telematics_part_ids.part_id} = ${parts.part_id} ;;
  }
}
explore: part_purchase_order_lookup {
  case_sensitive: no

  join: parts {
    type: left_outer
    relationship: many_to_one
    sql_on: ${part_purchase_order_lookup.part_id} = ${parts.part_id} ;;
  }
  join: part_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_type_id} = ${part_types.part_type_id} ;;
  }
  join: providers {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.provider_id} = ${providers.provider_id} ;;
  }
}
explore: unreceived_pos {
  case_sensitive: no
  description: "Used to pull list of unapproved POs that have an invoice in Concur. This version includes POs that have been partially delivered."
  join: market_region_xwalk {
    view_label: "Requesting branch"
    type: left_outer
    relationship: many_to_one
    sql_on: try_cast(${unreceived_pos.requesting_branch} as INTEGER) = ${market_region_xwalk.market_id} ;;
  }
}
# Adding type 9 to this always_where to account for parts coming off WOs. -Jack
explore: transactions {
  group_label: "Parts Inventory"
  label: "Parts to Work Orders"
  sql_always_where: ${transaction_type_id} in (7, 9) ;;
  case_sensitive: no

  join: transaction_items {
    type: inner
    relationship: many_to_one
    sql_on: ${transactions.transaction_id} = ${transaction_items.transaction_id} ;;
  }
  # left join "ES_WAREHOUSE"."INVENTORY"."PARTS" p
  #     on m.part_id = p.part_id
  # left join ES_WAREHOUSE.INVENTORY.PARTS p2
  #     on p.DUPLICATE_OF_ID = p2.PART_ID
  # left join ES_WAREHOUSE.INVENTORY.PART_TYPES pt
  #     on coalesce(p2.part_type_id, p.part_type_id) = pt.PART_TYPE_ID
  join: p1 {
    from: parts
    type: left_outer
    relationship: many_to_one
    sql_on: ${p1.part_id} = ${transaction_items.part_id} ;;
  }
  join: p2 {
    from:  parts
    type: left_outer
    relationship: one_to_one
    sql_on:${p1.duplicate_of_id} = ${p2.part_id} ;;
  }
  join: parts {
    type: left_outer
    relationship: one_to_one
    sql_on: coalesce(${p2.part_id}, ${p1.part_id}) = ${parts.part_id} ;;
  }
  join: providers {
    type: left_outer
    relationship: one_to_one
    sql_on: ${parts.provider_id} = ${providers.provider_id} ;;
  }
  join: part_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_type_id} = ${part_types.part_type_id} ;;
  }
  join: work_orders {
    type: inner
    relationship: many_to_one
    sql_on: ${transactions.to_id} = ${work_orders.work_order_id}
            or ${transactions.from_id} = ${work_orders.work_order_id};;
  }
  join: billing_types {
    type: inner
    relationship: one_to_one
    sql_on: ${work_orders.billing_type_id} = ${billing_types.billing_type_id} ;;
  }
  join: work_order_statuses {
    type: inner
    relationship: many_to_one
    sql_on: ${work_orders.work_order_status_id} = ${work_order_statuses.work_order_status_id} ;;
  }
  join: wo_tagged_warranty {
    type: left_outer
    relationship: one_to_one
    sql_on: ${wo_tagged_warranty.work_order_id} = ${work_orders.work_order_id} ;;
  }
  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_orders.branch_id} = ${markets.market_id} ;;
  }
  join: companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${companies.company_id} = ${markets.company_id} ;;
  }
  join: assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_orders.asset_id} = ${assets.asset_id} ;;
  }
  join: assets_aggregate {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_orders.asset_id} = ${assets_aggregate.asset_id} ;;
  }
  join: market_region_xwalk {
    type: left_outer
    relationship: one_to_one
    sql_on: ${market_region_xwalk.market_id} = ${markets.market_id} ;;
  }
  join: telematics_part_ids {
    type: left_outer
    relationship: many_to_one
    sql_on: ${telematics_part_ids.part_id} =  ${parts.part_id};;
  }
}

# Commented out due to low usage on 2026-03-27
# explore: transactions_store_to_store {
#   from: transactions
#   group_label: "Parts Inventory"
#   label: "Parts Store to Store Transfer"
#   sql_always_where: ${transaction_type_id} = 6 ;;
#   case_sensitive: no
#
#   join: transaction_items {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${transactions_store_to_store.transaction_id} = ${transaction_items.transaction_id} ;;
#   }
# #Remove when finished
#   # join: stores {
#   #   from: stores
#   #   view_label: "From Store"
#   #   type: left_outer
#   #   relationship: many_to_one
#   #   sql_on: ${stores.store_id} = ${transactions_store_to_store.from_id} ;;
#   # }
#   join: inventory_locations {
#     type:  left_outer
#     relationship: many_to_one
#     sql_on: ${inventory_locations.inventory_location_id} = ${transactions_store_to_store.from_id} ;;
#   }
#   # join: to_stores {
#   #   from: stores
#   #   view_label: "To Store"
#   #   type: left_outer
#   #   relationship: many_to_one
#   #   sql_on: ${to_stores.store_id} = ${transactions_store_to_store.to_id} ;;
#   # }
#   join: to_stores {
#     from: inventory_locations
#     view_label: "To Store"
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${inventory_locations.inventory_location_id} = ${transactions_store_to_store.to_id} ;;
#   }
#   join: market_region_xwalk {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${market_region_xwalk.market_id} = ${inventory_locations.inventory_location_id} ;;
#   }
#   join: parts {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${transaction_items.part_id} = ${parts.part_id} ;;
#   }
#   join: providers {
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${parts.provider_id} = ${providers.provider_id} ;;
#   }
#   join: work_orders {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${transactions_store_to_store.to_id} = ${work_orders.work_order_id}
#       or ${transactions_store_to_store.from_id} = ${work_orders.work_order_id} ;;
#   }
#   join: billing_types {
#     type: inner
#     relationship: one_to_one
#     sql_on: ${work_orders.billing_type_id} = ${billing_types.billing_type_id} ;;
#   }
# }
explore: vendor_accountability {

  join: parts {
    type: inner
    relationship: many_to_one
    sql_on: ${vendor_accountability.part_id} = ${parts.part_id};;
  }
  join: providers {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.provider_id} = ${providers.provider_id} ;;
  }
  join: vendor {
    type: left_outer
    relationship: many_to_one
    sql_on: ${vendor_accountability.vendor} = ${vendor.vendorid} ;;
  }
  join: top_vendor_mapping {
    type: left_outer
    relationship: one_to_one
    sql_on: ${vendor.vendorid} = ${top_vendor_mapping.vendorid} ;;
  }
  join: dim_markets_fleet_opt {
    type: left_outer
    relationship: many_to_one
    sql_on: ${vendor_accountability.market_id} = ${dim_markets_fleet_opt.market_id} ;;
  }
}
explore: parts {
  label: "WAC Date Vendor Accountability"

  join: part_mapping {
    type: left_outer
    relationship: one_to_many
    sql_on: ${parts.part_id} = ${part_mapping.part_id} ;;
  }
  join: wac_date_vendor_accountability {
    type: inner
    relationship: one_to_many
    sql_on: ${wac_date_vendor_accountability.part_id} = ${parts.part_id};;
  }
  join: providers {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.provider_id} = ${providers.provider_id} ;;
  }
  join: vendor_accountability {
    type: left_outer
    relationship: one_to_many
    sql_on: ${parts.part_id} = ${vendor_accountability.part_id} ;;
  }
  join: net_price {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_id} = ${net_price.part_id} and ${net_price.end_date} > current_date and ${wac_date_vendor_accountability.vendor_id} = ${net_price.vendor_id} ;;
  }
  join: vendor {
    type: left_outer
    relationship: many_to_one
    sql_on: ${wac_date_vendor_accountability.vendor_id} = ${vendor.vendorid} ;;
  }
}
explore: transactions_from_providers {
  from: transactions
  group_label: "Parts Inventory"
  label: "Parts Received from Provider"
  sql_always_where: ${transaction_type_id} = 1 ;;
  case_sensitive: no

  join: transaction_items {
    type: inner
    relationship: many_to_one
    sql_on: ${transactions_from_providers.transaction_id} = ${transaction_items.transaction_id} ;;
  }
  join: parts {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_id} = ${transaction_items.part_id} ;;
  }
  join: part_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_type_id} = ${part_types.part_type_id} ;;
  }
  join: providers {
    type: left_outer
    relationship: many_to_one
    sql_on: ${transactions_from_providers.from_id} = ${providers.provider_id} ;;
  }
#Remove when finished
  # join: stores {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${stores.store_id} = ${transactions_from_providers.to_id} ;;
  # }
  join: inventory_locations {
    type:  left_outer
    relationship: many_to_one
    sql_on: ${inventory_locations.inventory_location_id} = ${transactions_from_providers.to_id} ;;
  }
  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${inventory_locations.branch_id} ;;
  }
  join: work_orders {
    type: left_outer
    relationship: one_to_one
    sql_on: ${transactions_from_providers.to_id} = ${work_orders.work_order_id}
      or ${transactions_from_providers.from_id} = ${work_orders.work_order_id} ;;
  }
  join: billing_types {
    type: inner
    relationship: one_to_one
    sql_on: ${work_orders.billing_type_id} = ${billing_types.billing_type_id} ;;
  }
}
explore: purchase_order_line_items {
  label: "Purchase Orders"

  join: purchase_orders {
    type: inner
    relationship: many_to_one
    sql_on: ${purchase_order_line_items.purchase_order_id} = ${purchase_orders.purchase_order_id} ;;
  }
  join: purchase_order_receivers {
    type: left_outer
    relationship: one_to_many
    sql_on: ${purchase_orders.purchase_order_id} = ${purchase_order_receivers.purchase_order_id} ;;
  }
  join: parts {
    type: inner
    relationship: many_to_many
    sql_on: ${purchase_order_line_items.item_id} = ${parts.item_id};;
  }
  join: allocated_po_lines {
    type: left_outer
    relationship: one_to_one
    sql_on: ${purchase_order_line_items.purchase_order_line_item_id}= ${allocated_po_lines.purchase_order_line_item_id};;
  }
  join: part_inventory_transactions_b { #this is to see if what was allocated on PO has a transaction moving it to the work order or invoice
    view_label: "PO Allocated Transactions"
    type: left_outer
    relationship: one_to_many #not sure this is the right relationship yet
    sql_on: (${allocated_po_lines.allocation_type}='WORK_ORDER'
    and ${allocated_po_lines.allocation_id}= ${part_inventory_transactions_b.work_order_id} and ${parts.part_id}=${part_inventory_transactions_b.part_id})
    or (${allocated_po_lines.allocation_type}='INVOICE'
    and ${allocated_po_lines.allocation_id}= ${part_inventory_transactions_b.invoice_id} and ${parts.part_id}=${part_inventory_transactions_b.part_id});;
  }
join: dim_parts_fleet_opt_attributes {
  type: inner
  relationship: one_to_one
  sql_on: ${parts.part_id}=${dim_parts_fleet_opt_attributes.part_id} ;;
}
  join: parts_attributes {
    type: left_outer
    relationship: one_to_one
    sql_on: ${dim_parts_fleet_opt_attributes.part_id} = ${parts_attributes.part_id} and ${parts_attributes.end_date} = '2999-01-01' ;;
  }
  join: part_categorization_structure {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts_attributes.part_categorization_id} = ${part_categorization_structure.part_categorization_id} ;;
  }
  join: fulfillment_parts_attributes {
    type: left_outer
    relationship: one_to_one
    sql_on: ${dim_parts_fleet_opt_attributes.part_id}=${fulfillment_parts_attributes.part_id}and ${fulfillment_parts_attributes.end_date} = '2999-01-01' ;;
  }
  join: providers {
    type: inner
    relationship: many_to_one
    sql_on: ${parts.provider_id} = ${providers.provider_id} ;;
  }
  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: ${purchase_orders.requesting_branch_id} = ${market_region_xwalk.market_id} ;;
  }
  join: users {
    type: inner
    relationship: many_to_many
    sql_on: ${purchase_orders.created_by_id} = ${users.user_id} ;;
  }
  join: company_directory {
    type: inner
    relationship: one_to_one
    sql_on: ${users.employee_id} = ${company_directory.employee_id} ;;
  }
  join: fulfillment_center_markets {
    type: left_outer
    relationship: one_to_one
    sql_on: ${market_region_xwalk.market_name} = ${fulfillment_center_markets.location} ;;
  }
  ## Added historical records to view for employees no longer with the company
  join:  purchase_order_line_items_historical{
    type:  left_outer
    relationship: one_to_one
    sql_on: TO_CHAR(${users.employee_id}) = TO_CHAR(${purchase_order_line_items_historical.employee_id})
          AND ${purchase_orders.date_created_date} >= ${purchase_order_line_items_historical.start_date_date}
          AND ${purchase_orders.date_created_date} <= ${purchase_order_line_items_historical.end_date_date};;
  }
  join: be_market_start_month {
    type: left_outer
    relationship: one_to_one
    sql_on: ${be_market_start_month.market_id} = ${market_region_xwalk.market_id} ;;
  }
}
explore: store_parts {
  group_label: "Parts Inventory"
  label: "Store Parts Inventory"
  case_sensitive: no

  join: parts {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_id} = ${store_parts.part_id} ;;
  }
  join: part_substitutes_flag_sub_type {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_id} = ${part_substitutes_flag_sub_type.part_id} ;;
  }
  join: part_suppression_categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_id} = ${part_suppression_categories.part_id} ;;
  }
  join: part_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_type_id} = ${part_types.part_type_id} ;;
  }
  join: providers {
    type: left_outer
    relationship: many_to_one
    sql_on: ${providers.provider_id} = ${parts.provider_id} ;;
  }
#Remove when finished
  # join: stores {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${stores.store_id} = ${store_parts.store_id} ;;
  # }
  join: inventory_locations {
    type: left_outer
    relationship: many_to_one
    sql_on: ${inventory_locations.inventory_location_id} = ${store_parts.store_id} ;;
  }
  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${inventory_locations.branch_id} ;;
  }
  join: cost_by_provider {
    type: left_outer
    relationship: many_to_one
    sql_on: ${store_parts.store_part_id} = ${cost_by_provider.store_part_id} ;;
  }
  join: inventory_dead_stock {
    type: inner
    relationship: one_to_one
    sql_on: ${inventory_dead_stock.inventory_location_id} = ${inventory_locations.inventory_location_id} and
            ${inventory_dead_stock.part_id} = ${store_parts.part_id} ;;
  }
  join: weighted_average_cost {
    type: left_outer
    relationship: one_to_one
    sql_where: ${weighted_average_cost.is_current} = 'TRUE' or ${weighted_average_cost.weighted_average_cost} is null ;;
    sql_on: ${weighted_average_cost.part_id} = ${parts.part_id} and
            ${weighted_average_cost.store_id} = ${inventory_locations.inventory_location_id} ;;
  }
}
explore: inventory_balances_snapshot {
  group_label: "Parts Inventory"
  label: "Store Parts Inventory - History"
  case_sensitive: no

  join: parts {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_id} = ${inventory_balances_snapshot.part_id} ;;
  }
  join: part_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_type_id} = ${part_types.part_type_id} ;;
  }
  join: providers {
    type: left_outer
    relationship: many_to_one
    sql_on: ${providers.provider_id} = ${parts.provider_id} ;;
  }
  join: inventory_locations {
    type: left_outer
    relationship: many_to_one
    sql_on: ${inventory_locations.inventory_location_id} = ${inventory_balances_snapshot.store_id} ;;
  }
  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${inventory_locations.branch_id} ;;
  }
} #end of store_parts_history explore
explore: transactions_all_types {
  from: transactions
  group_label: "Parts Inventory"
  label: "Store Parts Inventory - All Transaction Types"
  case_sensitive: no

  join: transaction_items {
    type: inner
    relationship: many_to_one
    sql_on: ${transactions_all_types.transaction_id} = ${transaction_items.transaction_id} ;;
  }
  join: transaction_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${transaction_types.transaction_type_id} = ${transactions_all_types.transaction_type_id} ;;
  }
  join: work_orders {
    type: left_outer
    relationship: many_to_one
    sql_on: ${transactions_all_types.to_id} = ${work_orders.work_order_id}
      or ${transactions_all_types.from_id} = ${work_orders.work_order_id};;
  }
  join: orders {
    type: left_outer
    relationship: many_to_one
    sql_on: ${transactions_all_types.to_id} = ${orders.order_id} ;;
  }
  join: billing_types {
    type: left_outer
    relationship: one_to_one
    sql_on: ${work_orders.billing_type_id} = ${billing_types.billing_type_id} ;;
  }
  join: parts {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_id} = ${transaction_items.part_id} ;;
  }
  join: part_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_type_id} = ${part_types.part_type_id} ;;
  }
  join: part_categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${part_types.part_category_id} = ${part_categories.part_category_id} ;;
  }
  join: providers {
    type: left_outer
    relationship: many_to_one
    sql_on: ${transactions_all_types.from_id} = ${providers.provider_id} ;;
  }
#Remove when finished
  # join: stores {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${stores.store_id} = ${transactions_all_types.from_id} ;;
  # }
  join: inventory_locations {
    type: left_outer
    relationship: many_to_one
    sql_on: ${inventory_locations.inventory_location_id} = ${transactions_all_types.from_id} ;;
  }
  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${inventory_locations.branch_id} ;;
  }
}

# Commented out due to low usage on 2026-03-27
# explore: transactions_all_types_with_avg_cost {
#   from: transactions
#   group_label: "Parts Inventory"
#   label: "All Transaction Types with Average Cost Snap in Items"
#   case_sensitive: no
#
#   join: transaction_items_2 {
#     from: transaction_items_w_avg_cost
#     type: inner
#     relationship: many_to_one
#     sql_on: ${transactions_all_types_with_avg_cost.transaction_id} = ${transaction_items_2.transaction_id} ;;
#   }
#   join: transaction_types {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${transaction_types.transaction_type_id} = ${transactions_all_types_with_avg_cost.transaction_type_id} ;;
#   }
#   join: work_orders {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${transactions_all_types_with_avg_cost.to_id} = ${work_orders.work_order_id}
#       or ${transactions_all_types_with_avg_cost.from_id} = ${work_orders.work_order_id};;
#   }
#   join: orders {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${transactions_all_types_with_avg_cost.to_id} = ${orders.order_id} ;;
#   }
#   join: billing_types {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${work_orders.billing_type_id} = ${billing_types.billing_type_id} ;;
#   }
#   join: parts {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${parts.part_id} = ${transaction_items_2.joining_part_id} ;;
#   }
#   join: part_types {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${parts.part_type_id} = ${part_types.part_type_id} ;;
#   }
#   join: part_categories {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${part_types.part_category_id} = ${part_categories.part_category_id} ;;
#   }
#   join: providers {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${parts.provider_id} = ${providers.provider_id} ;;
#   }
#   join: inventory_locations {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${inventory_locations.inventory_location_id} = ${transactions_all_types_with_avg_cost.from_id} ;;
#   }
#   join: market_region_xwalk {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${market_region_xwalk.market_id} = ${inventory_locations.branch_id} ;;
#   }
# }
explore: invoices {
  label: "All Line Item Types with Average Cost Snap"
  case_sensitive: no

  join: line_items_w_avg_cost {
    type: inner
    relationship: many_to_one
    sql_on: ${line_items_w_avg_cost.invoice_id} = ${invoices.invoice_id} ;;
  }
  join: line_items_w_avg_cost_calculations {
    type: inner
    relationship: one_to_one
    sql_on: ${line_items_w_avg_cost.line_item_id} = ${line_items_w_avg_cost_calculations.line_item_id} ;;
  }
  join: parts {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_id} = ${line_items_w_avg_cost.part_id} ;;
  }
  join: part_substitutes_flag_sub_type {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_id} = ${part_substitutes_flag_sub_type.part_id} ;;
  }
  join: part_suppression_categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_id} = ${part_suppression_categories.part_id} ;;
  }
  join: part_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_type_id} = ${part_types.part_type_id} ;;
  }
  join: part_categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${part_types.part_category_id} = ${part_categories.part_category_id} ;;
  }
  join: providers {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.provider_id} = ${providers.provider_id} ;;
  }
  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${line_items_w_avg_cost.branch_id} ;;
  }
  join: companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${companies.company_id} = ${invoices.company_id} ;;
  }
  join: approved_invoice_salespersons_itl {
    type:  left_outer
    relationship: many_to_one
    sql_on: ${approved_invoice_salespersons_itl.invoice_id} = ${line_items_w_avg_cost.invoice_id} ;;

  }
  join: dim_dates_fleet_opt {
    type: left_outer
    relationship: many_to_one
    sql_on: ${invoices.billing_approved_date} = ${dim_dates_fleet_opt.dt_date} ;;
  }
}
explore: line_items {
  group_label: "Parts Inventory"
  label: "Parts Sales 30/60/90"
  case_sensitive: no

  join: parts {
    type: left_outer
    relationship: many_to_one
    sql_on: ${line_items.part_id} = ${parts.part_id} ;;
  }
  join: part_types {
    type: inner
    relationship: one_to_one
    sql_on: ${parts.part_type_id} = ${part_types.part_type_id} ;;
  }
  join: providers {
    type: left_outer
    relationship: one_to_one
    sql_on: ${parts.provider_id} = ${providers.provider_id} ;;
  }
  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${line_items.branch_id} = ${market_region_xwalk.market_id} ;;
  }
#Remove when finished
  # join: stores {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${line_items.branch_id} = ${stores.branch_id} ;;
  # }
  join: inventory_locations {
    type: left_outer
    relationship: many_to_one
    sql_on: ${inventory_locations.branch_id} = ${line_items.branch_id} ;;
  }
}
explore: parts_demand {
  case_sensitive: no
  label: "Parts Demand - WOs, Sales"
  description: "Actual usage of parts on WOs and parts sold as a retail sale"
}
explore: lead_time_2023 {
  from:  lead_time_2023
  case_sensitive: no
  description: "Lead time for part orders. If there the market and part is not represented in the 2023 data then the data back to 2021 is pulled for that market and part combination."

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${lead_time_2023.market_id} ;;
  }
  join: parts {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_id} = ${lead_time_2023.part_id} ;;
  }
  join: part_substitutes_flag_sub_type {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_id} = ${part_substitutes_flag_sub_type.part_id} ;;
  }
  join: part_suppression_categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_id} = ${part_suppression_categories.part_id} ;;
  }

  join: parts_attributes_part_id_level {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_id} = ${parts_attributes_part_id_level.part_id} ;;
  }
  join: part_categorization_structure {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts_attributes_part_id_level.part_categorization_id} = ${part_categorization_structure.part_categorization_id} ;;
  }

  join: providers {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.provider_id} = ${providers.provider_id} ;;
  }
}
explore: back_order_parts {
  from:  back_order_parts
  case_sensitive: no
  description: "Parts ordered greater than 10 days ago."

  join: part_substitutes_flag_sub_type {
    type: left_outer
    relationship: many_to_one
    sql_on: ${back_order_parts.part_id} = ${part_substitutes_flag_sub_type.part_id} ;;
  }

  join: part_suppression_categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${back_order_parts.part_id} = ${part_suppression_categories.part_id} ;;
  }

  join: parts_attributes_part_id_level {
    type: left_outer
    relationship: many_to_one
    sql_on: ${back_order_parts.part_id} = ${parts_attributes_part_id_level.part_id} ;;
  }
  join: part_categorization_structure {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts_attributes_part_id_level.part_categorization_id} = ${part_categorization_structure.part_categorization_id} ;;
  }


  join: back_order_work_orders {
    type: left_outer
    relationship: many_to_one
    sql_on: ${back_order_parts.purchase_order_number} = ${back_order_work_orders.purchase_order_number} ;;
  }
  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${back_order_parts.market_id} ;;
  }
  join: providers {
    type: left_outer
    relationship: many_to_one
    sql_on: ${back_order_parts.provider_id} = ${providers.provider_id} ;;
  }
}
explore: back_order_parts_and_wo_impact {
  from: back_order_parts
  case_sensitive: no
  description: "Back-ordered parts and WOs that cannot be completed as a result"

  join: back_order_work_orders_listed {
    type: left_outer
    relationship: many_to_one
    sql_on: ${back_order_parts_and_wo_impact.purchase_order_number} = ${back_order_work_orders_listed.purchase_order_number} ;;
  }
  join: purchase_orders {
    type: inner
    relationship: many_to_one
    sql_on: ${back_order_work_orders_listed.purchase_order_number} = ${purchase_orders.purchase_order_number} ;;
  }
  join: unreceived_pos{
    type: left_outer
    relationship: many_to_one
    sql_on: ${back_order_parts_and_wo_impact.purchase_order_number}::string = ${unreceived_pos.purchase_order_number}::string ;;
  }
  join: entities {
    type: inner
    relationship: many_to_one
    sql_on: ${purchase_orders.vendor_id} = ${entities.entity_id} ;;
  }
  join: work_orders {
    type: left_outer
    relationship: many_to_one
    sql_on: ${back_order_work_orders_listed.wo_id} = ${work_orders.work_order_id};;
  }
  join: assets_aggregate {
    type: left_outer
    relationship: many_to_one
    sql_on: ${back_order_work_orders_listed.asset_id} = ${assets_aggregate.asset_id} ;;
  }
  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_orders.branch_id} = ${market_region_xwalk.market_id} ;;
  }
  join: daily_rev_calculation {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets_aggregate.equipment_class_id} = ${daily_rev_calculation.equipment_class_id}
      and ${market_region_xwalk.district} = ${daily_rev_calculation.district};;
  }
  join: part_back_order_requests_board { #this is the monday board corp parts is using to follow up on BO parts and add comments
    type: left_outer
    relationship: one_to_one
    sql_on: to_char(${back_order_parts_and_wo_impact.purchase_order_number}) =
            to_char(${part_back_order_requests_board.equipmentshare_po_number}) and
            ${back_order_parts_and_wo_impact.part_number}=${part_back_order_requests_board.part_number} ;;
  }
  join: parts {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_id} = ${back_order_parts_and_wo_impact.part_id} ;;
  }
  join: part_substitutes_flag_sub_type {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_id} = ${part_substitutes_flag_sub_type.part_id} ;;
  }
  join: part_suppression_categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_id} = ${part_suppression_categories.part_id} ;;
  }

  join: parts_attributes_part_id_level {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_id} = ${parts_attributes_part_id_level.part_id} ;;
  }
  join: part_categorization_structure {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts_attributes_part_id_level.part_categorization_id} = ${part_categorization_structure.part_categorization_id} ;;
  }

  join: providers {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.provider_id} = ${providers.provider_id} ;;
  }
}
explore: total_inventory_allocation {
  from:  total_inventory_allocation
  case_sensitive: no
  description: "At the Market level. A parts quantity on hand, on rent, and on order."

  join: telematics_part_ids {
    type: left_outer
    relationship: many_to_one
    sql_on: ${telematics_part_ids.part_id} = ${total_inventory_allocation.part_id};;
  }
  join: part_substitutes_flag_sub_type {
    type: left_outer
    relationship: many_to_one
    sql_on: ${total_inventory_allocation.part_id} = ${part_substitutes_flag_sub_type.part_id} ;;
  }
  join: part_suppression_categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${total_inventory_allocation.part_id} = ${part_suppression_categories.part_id} ;;
  }

  join: parts_attributes_part_id_level {
    type: left_outer
    relationship: many_to_one
    sql_on: ${total_inventory_allocation.part_id} = ${parts_attributes_part_id_level.part_id} ;;
  }
  join: part_categorization_structure {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts_attributes_part_id_level.part_categorization_id} = ${part_categorization_structure.part_categorization_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${total_inventory_allocation.market_id} ;;
  }
  join: default_branch {
    from: inventory_locations
    type: left_outer
    relationship: many_to_many
    sql_on: ${market_region_xwalk.market_id} = ${default_branch.branch_id} and
            ${default_branch.default_location} = true ;;
  }
  join: providers {
    type: left_outer
    relationship: many_to_one
    sql_on: ${total_inventory_allocation.provider_id} = ${providers.provider_id} ;;
  }
  # join: inventory_allocation {
  #   type: left_outer
  #   relationship: one_to_one
  #   sql_on: ${total_inventory_allocation.market_id} = ${inventory_allocation.market_id} and
  #           ${total_inventory_allocation.part_id} = ${inventory_allocation.part_id} ;;
  # }
}
explore: deadstock {
  from: current_deadstock
  case_sensitive: no
  description: "Parts in that have not been pulled in over 12 months."

  join: non_adjustment_transactions {
    type: left_outer
    relationship: one_to_many
    sql_on: ${deadstock.part_id} = ${non_adjustment_transactions.part_id} ;;
  }
  # join: telematics_part_ids {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${deadstock.part_id} = ${telematics_part_ids.part_id} ;;
  # }
  join: total_inventory_per_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${total_inventory_per_market.market_id} = ${non_adjustment_transactions.branch_id} and
            ${total_inventory_per_market.part_id} = ${non_adjustment_transactions.part_id};;
  }
  join: parts {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_id} = ${deadstock.part_id} ;;
  }
  join: part_substitutes_flag_sub_type {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_id} = ${part_substitutes_flag_sub_type.part_id} ;;
  }
  join: part_suppression_categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_id} = ${part_suppression_categories.part_id} ;;
  }
  join: providers {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.provider_id} = ${providers.provider_id} ;;
  }
}
explore: inventory {
  from: total_inventory_per_store
  case_sensitive: no
  label: "Inventory"
  description: "Inventory Overview"

  join: parts {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_id} = ${inventory.part_id} ;;
  }
  join: part_substitutes_flag_sub_type {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_id} = ${part_substitutes_flag_sub_type.part_id} ;;
  }
  join: part_suppression_categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_id} = ${part_suppression_categories.part_id} ;;
  }
  join: parts_inventory_parts {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts_inventory_parts.part_id} = ${inventory.part_id} ;;
  }
  join: part_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_type_id} = ${part_types.part_type_id} ;;
  }
  join: parts_attributes_part_id_level {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_id} = ${parts_attributes_part_id_level.part_id} ;;
  }
  join: part_categorization_structure {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts_attributes_part_id_level.part_categorization_id} = ${part_categorization_structure.part_categorization_id} ;;
  }
  join: store_parts {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_id} = ${store_parts.part_id}
      and ${store_parts.store_id} = ${inventory.store_id};;
  }
  join: providers {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.provider_id} = ${providers.provider_id} ;;
  }
  join: inventory_locations {
    type: left_outer
    relationship: many_to_one
    sql_on: ${inventory.store_id} = ${inventory_locations.inventory_location_id} ;;
  }
  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${inventory_locations.branch_id} ;;
  }
  join: total_inventory_per_store_history {
    type: left_outer
    relationship: many_to_one
    sql_on: ${inventory.store_part_id} = ${total_inventory_per_store_history.store_part_id} ;;
  }
  join: part_inventory_transactions {
    type: full_outer
    relationship: many_to_many
    sql_on: ${part_inventory_transactions.part_id} = ${parts.part_id} ;;
  }
  join: telematics_part_ids {
    type: left_outer
    relationship: many_to_one
    sql_on: ${telematics_part_ids.part_id} = ${parts.part_id};;
  }
  join: default_branch {
    from: inventory_locations
    type: left_outer
    relationship: many_to_many
    sql_on: ${inventory_locations.inventory_location_id} = ${default_branch.inventory_location_id}
      and ${default_branch.default_location} = true ;;
  }
  join: total_inventory_allocation {
    type: left_outer
    relationship: many_to_many
    sql_on: ${total_inventory_allocation.part_id} = ${parts_inventory_parts.master_part_id}
      and ${total_inventory_allocation.market_id} = ${default_branch.branch_id} ;;
  }
}

# Commented out due to low usage on 2026-03-27
# explore: store_parts_w_consumption {
#   from: store_parts
#   case_sensitive: no
#
#   join: parts {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${parts.part_id} = ${store_parts_w_consumption.part_id} ;;
#     sql_where: ${parts.provider_id} not in (select api.provider_id from ANALYTICS.PARTS_INVENTORY.ATTACHMENT_PROVIDER_IDS as api) ;;
#   }
#   join: part_spend_vs_consumption {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${part_spend_vs_consumption.part_number} = ${parts.part_number}
#       and ${part_spend_vs_consumption.store_id} = ${store_parts_w_consumption.store_id};;
#   }
#   join: inventory_locations {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${store_parts_w_consumption.store_id} = ${inventory_locations.inventory_location_id} ;;
#   }
#   join: market_region_xwalk {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${inventory_locations.branch_id} = ${market_region_xwalk.market_id} ;;
#   }
# }
# explore: inventory_turnover {
#   from: total_inventory_per_store
#   case_sensitive: no
#   label: "Inventory Turnover"
#   description: "Inventory Turnover Rate based on Cost of Goods Consumed"

# join: parts_consumption_current { #most current is limited to last month close due to avg cost -- so ensure snapshot date ties out
#     from: parts_consumption
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${inventory_turnover.part_id} = ${parts_consumption_current.part_id}
#       --and ${inventory_turnover.store_id} = ${parts_consumption_current.store_id}
#       --and ${inventory_turnover.snap_reference_date} = ${parts_consumption_current.snap_match_date_date}
#       ;;
#   }
# join: total_inventory_per_store_history {
#   type: left_outer
#   relationship: many_to_one
#   sql_on: ${inventory_turnover.store_part_id} = ${total_inventory_per_store_history.store_part_id} ;;
#   }
# join: parts_consumption_history { #make this history?? -- add in snapshot date match??
#   from: parts_consumption
#   type: left_outer
#   relationship: many_to_one
#   sql_on: ${total_inventory_per_store_history.part_id} = ${parts_consumption_history.part_id}
#     and ${total_inventory_per_store_history.store_id} = ${parts_consumption_history.store_id}
#     and ${total_inventory_per_store_history.snapshot_date_date} = last_day(${parts_consumption_history.consumption_date_date});;
# }
# join: part_inventory_transactions {
#   type: left_outer
#   relationship: many_to_one
#   sql_on: ${inventory_turnover.store_part_id} = ${part_inventory_transactions.store_part_id} ;;
#   sql_where: ${part_inventory_transactions.consumption_transaction} ;; #unsure if this will work as intended
# }
# join: cost_of_consumption {
#   from: average_cost_snapshot
#   type: left_outer
#   relationship: many_to_one
#   sql_on: ${current_parts_consumption.part_id} = ${cost_of_consumption.current_part_id}
#       and ${current_parts_consumption.store_id} = ${cost_of_consumption.store_id}
#       and ${current_parts_consumption.snap_match_date} = ${cost_of_consumption.snapshot_date}
#       ;;
# }
# } #end of inventory turnover explore
explore: parts_purchased {
  from: part_inventory_transactions
  case_sensitive: no
  label: "Parts Purchased YTD"
  description: "Parts Purchased YTD"

  join: parts {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts_purchased.part_id} = ${parts.part_id} ;;
    sql_where: ${parts.provider_id} not in (select api.provider_id from ANALYTICS.PARTS_INVENTORY.ATTACHMENT_PROVIDER_IDS as api) ;;
  }
  join: providers {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.provider_id} = ${providers.provider_id} ;;
  }
  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${parts_purchased.market_id} ;;
  }
} #end of parts purchased explore

# Commented out due to low usage on 2026-03-27
# explore: test {
#   from: store_parts #encompasses non-ES stores
#   case_sensitive: no
#   label: "testing my sql"
#   description: "just a test"
#
#   join: inventory_locations {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${test.store_id} = ${inventory_locations.inventory_location_id} ;;
#   }
# # join: parent_stores {
# #     from: stores
# #     type: left_outer
# #     relationship: many_to_one
# #     sql_on: ${stores.parent_id} = ${parent_stores.store_id} ;;
# #   }
#   join: market_region_xwalk {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${inventory_locations.branch_id} = ${market_region_xwalk.market_id} ;;
#   }
#   # join: part_inventory_transactions {
#   #   type: left_outer
#   #   relationship: one_to_many
#   #   sql_on: ${test.store_part_id} = ${part_inventory_transactions.store_part_id} ;;
#   # }
# } #end of test explore
explore: part_demand {
  case_sensitive: no
  label: "Part Demand for Parts DB Rebuild"

   join: inventory_locations {
     type: inner
     relationship: many_to_one
     sql_on: ${part_demand.inventory_location_id} = ${inventory_locations.inventory_location_id} ;;
  }

   join: market_region_xwalk {
     type: inner
     relationship: many_to_one
     sql_on: ${inventory_locations.branch_id} = ${market_region_xwalk.market_id} ;;
   }

  join: fulfillment_center_markets {
    type: left_outer
    relationship: one_to_one
    sql_on: ${market_region_xwalk.market_name} = ${fulfillment_center_markets.location} ;;
  }
  join: parts {
    type: left_outer
    relationship: many_to_one
    sql_on: ${part_demand.part_id} = ${parts.part_id} ;;
  }
  join: part_substitutes_flag_sub_type {
    relationship: many_to_one
    sql_on:  ${parts.part_id} = ${part_substitutes_flag_sub_type.part_id};;
  }
  join: part_suppression_categories {
    relationship: many_to_one
    sql_on:  ${parts.part_id} = ${part_suppression_categories.part_id};;
  }

  join: parts_attributes_part_id_level {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_id} = ${parts_attributes_part_id_level.part_id};;
  }
  join: part_categorization_structure {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts_attributes_part_id_level.part_categorization_id} = ${part_categorization_structure.part_categorization_id} ;;
  }

  join: fulfillment_parts_attributes {
    type: left_outer
    relationship: one_to_one
    sql_on: ${parts.part_id}=${fulfillment_parts_attributes.part_id} and ${fulfillment_parts_attributes.end_date} = '2999-01-01'  ;;
  }
  join: providers {
    type: left_outer
    relationship: one_to_one
    sql_on: ${parts.provider_id} = ${providers.provider_id} ;;
  }
  join: part_types {
    type: left_outer
    relationship: one_to_one
    sql_on: ${parts.part_type_id} = ${part_types.part_type_id} ;;
  }
  join: assets_aggregate {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets_aggregate.asset_id} = ${part_demand.asset_id};;
  }
  join: telematics_part_ids {
    type: left_outer
    relationship: many_to_one
    sql_on: ${telematics_part_ids.part_id} =  ${parts.part_id};;
  }
  join: part_demand_wac {
    type: left_outer
    relationship: one_to_one
    sql_on: ${parts.part_id} = ${part_demand_wac.part_id} ;;
  }
  join: recent_po_info {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_id} = ${recent_po_info.part_id} and ${market_region_xwalk.market_id} = ${recent_po_info.market_id} ;;
  }
  join: fc_open_po_info {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_id} = ${fc_open_po_info.part_id};;
  }

  join: part_min_net_price{
    type: left_outer
    relationship: one_to_one
    sql_on: ${parts.part_id} = ${part_min_net_price.part_id} ;;
  }

  join: shopify_inventory {
    type: left_outer
    relationship: one_to_one
    sql_on: ${parts.part_id} = ${shopify_inventory.part_id};;
  }
}

explore: preferred_nonpreferred_vendor_comparison {

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${preferred_nonpreferred_vendor_comparison.market_id} = ${market_region_xwalk.market_id} ;;
  }
  join: top_vendor_mapping {
    type: left_outer
    relationship: one_to_many
    sql_on: ${preferred_nonpreferred_vendor_comparison.vendor_id} = ${top_vendor_mapping.vendorid} ;;
  }
  join: purchase_orders {
    type: left_outer
    relationship: one_to_one
    sql_on: ${preferred_nonpreferred_vendor_comparison.purchase_order_number} = ${purchase_orders.purchase_order_number} ;;
  }
}


explore: trending_dead_stock {
  case_sensitive: no
  label: "Trending Dead Stock last 12 complete months with current WAC value."

  join: inventory_locations {
    type: left_outer
    relationship: many_to_one
    sql_on: ${trending_dead_stock.inventory_location_id} = ${inventory_locations.inventory_location_id} ;;
  }
  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${inventory_locations.branch_id} ;;
  }
  join: fulfillment_center_markets {
    type: left_outer
    relationship: one_to_one
    sql_on: ${market_region_xwalk.market_name} = ${fulfillment_center_markets.location} ;;
  }
  join: providers {
    type: left_outer
    relationship: many_to_one
    sql_on: ${trending_dead_stock.provider_id} = ${providers.provider_id} ;;
  }
  join: part_substitutes_flag_sub_type {
    type: left_outer
    relationship: many_to_one
    sql_on: ${trending_dead_stock.part_id} = ${part_substitutes_flag_sub_type.part_id} ;;
  }
  join: part_suppression_categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${trending_dead_stock.part_id} = ${part_suppression_categories.part_id} ;;
  }

  join: parts_attributes_part_id_level {
    type: left_outer
    relationship: many_to_one
    sql_on: ${trending_dead_stock.part_id} = ${parts_attributes_part_id_level.part_id} ;;
  }
  join: part_categorization_structure {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts_attributes_part_id_level.part_categorization_id} = ${part_categorization_structure.part_categorization_id} ;;
  }

}
explore: inventory_dead_stock {
  case_sensitive: no
  label: "Complete inventory at store level + Dead Stock status"

  join: telematics_part_ids {
    type: left_outer
    relationship: many_to_one
    sql_on: ${telematics_part_ids.part_id} = ${inventory_dead_stock.part_id};;
  }
  join: inventory_locations {
    type: left_outer
    relationship: many_to_one
    sql_on: ${inventory_dead_stock.inventory_location_id} = ${inventory_locations.inventory_location_id} ;;
  }
  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${inventory_locations.branch_id} ;;
  }
  join: parts {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_id} = ${inventory_dead_stock.part_id} ;;
  }
  join: part_substitutes_flag_sub_type {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_id} = ${part_substitutes_flag_sub_type.part_id} ;;
  }
  join: part_suppression_categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_id} = ${part_suppression_categories.part_id} ;;
  }

  join: parts_attributes_part_id_level {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_id} = ${parts_attributes_part_id_level.part_id} ;;
  }
  join: part_categorization_structure {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts_attributes_part_id_level.part_categorization_id} = ${part_categorization_structure.part_categorization_id} ;;
  }

  join: providers {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.provider_id} = ${providers.provider_id} ;;
  }
}
explore: weighted_average_cost_override_assistant {
  from: weighted_average_cost
  case_sensitive: no
  label: "Weighted average cost override assistant"

  join: parts {
    type: left_outer
    relationship: one_to_many
    sql_on: ${weighted_average_cost_override_assistant.part_id} = ${parts.part_id} ;;
    sql_where: ${parts.provider_id} not in (select api.provider_id from ANALYTICS.PARTS_INVENTORY.ATTACHMENT_PROVIDER_IDS as api) ;;
  }
  join: inventory_locations {
    type: left_outer
    relationship: many_to_one
    sql_on: ${weighted_average_cost_override_assistant.store_id} = ${inventory_locations.inventory_location_id} ;;
  }
  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${inventory_locations.branch_id} = ${market_region_xwalk.market_id} ;;
  }
  join: transactions {
    type: left_outer
    relationship: many_to_one
    sql_on: ${weighted_average_cost_override_assistant.source_transaction_id} = ${transactions.transaction_id} ;;
  }
  join: t3_purchase_order_details {
    type: left_outer
    relationship: many_to_one
    sql_on: ${transactions.po_id} = ${t3_purchase_order_details.purchase_order_id} ;;
  }
} # end of weighted_average_cost_override_assistant explore

# Commented out due to low usage on 2026-03-27
# explore: part_inventory_transactions_b{
#
#   join: transactions {
#     type: inner
#     relationship: one_to_many
#     sql_on: ${part_inventory_transactions_b.transaction_id} = ${transactions.transaction_id} ;;
#   }
#   join: transaction_items {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${part_inventory_transactions_b.transaction_item_id} = ${transaction_items.transaction_item_id} ;;
#   }
#   join: market_region_xwalk { #required due to drill through fields in transactions
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${part_inventory_transactions_b.market_id} = ${market_region_xwalk.market_id} ;;
#   }
#   join: work_orders { #required due to drill through fields in transaction_items
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${part_inventory_transactions_b.to_id} = ${work_orders.work_order_id};;
#   }
#   join: billing_types { #required due to drill through fields in transaction_items
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${work_orders.billing_type_id} = ${billing_types.billing_type_id} ;;
#   }
# }
explore: fuel_revenue {

  join: invoices {
    type: inner
    relationship: many_to_one
    sql_on: ${fuel_revenue.invoice_id} = ${invoices.invoice_id} ;;
  }
  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: ${fuel_revenue.branch_id} = ${market_region_xwalk.market_id} ;;
  }
  join: es_companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${invoices.company_id} = ${es_companies.company_id} ;;
  }
  join: line_item_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fuel_revenue.line_item_type_id} = ${line_item_types.line_item_type_id} ;;
  }
  join: incorrect_onsite_fueling_reporting {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fuel_revenue.invoice_id} = ${incorrect_onsite_fueling_reporting.invoice_id} ;;
  }
  join: assets_aggregate {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets_aggregate.asset_id} = ${fuel_revenue.asset_id} ;;
  }
  join: equipment_classes {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets_aggregate.equipment_class_id} = ${equipment_classes.equipment_class_id} ;;
  }
} ##end fuel revenue explore

# Commented out due to low usage on 2026-03-27
# explore: fuel_expenses {
#   from: glentry
#
#   join: glaccount {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${glaccount.accountno} = ${fuel_expenses.accountno} ;;
#   }
# }
explore: generator_and_fuel_cell_rentals {}
explore: filtered_in_out_transactions {
  description: "This is an extended view of part_inventory_transactions_b"
  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${filtered_in_out_transactions.market_id} = ${market_region_xwalk.market_id} ;;
  }
  join: fulfillment_center_markets {
    type: left_outer
    relationship: one_to_one
    sql_on: ${market_region_xwalk.market_name} = ${fulfillment_center_markets.location} ;;
  }
  join: work_orders {
    type: left_outer
    relationship: many_to_many
    sql_on: ${filtered_in_out_transactions.work_order_id} = ${work_orders.work_order_id} ;;
  }
  join: wo_tags_aggregate {
    type: left_outer
    relationship: one_to_one
    sql_on: ${work_orders.work_order_id} = ${wo_tags_aggregate.work_order_id} ;;
  }
}

# Commented out due to low usage on 2026-03-27
# explore: historical_utilization {
#   join: assets_aggregate {
#     type: inner
#     relationship: one_to_many
#     sql_on: ${assets_aggregate.asset_id} = ${historical_utilization.asset_id} ;;
#   }
#   join: market_region_xwalk {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${historical_utilization.market_id} = ${market_region_xwalk.market_id} ;;
#   }
#   join: work_orders {
#     type: left_outer
#     relationship: many_to_many
#     sql_on:  ${historical_utilization.asset_id} = ${work_orders.asset_id} ;;
#   }
#   join: wo_tags_aggregate {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${work_orders.work_order_id} = ${wo_tags_aggregate.work_order_id} ;;
#   }
# }

# Commented out due to low usage on 2026-03-27
# explore: work_orders_with_high_rental_revenue{
#   from: work_orders
#   label: "Work Orders"
#   join: assets_aggregate {
#     type: inner
#     relationship: one_to_many
#     sql_on: ${assets_aggregate.asset_id} = ${work_orders_with_high_rental_revenue.asset_id} ;;
#   }
#   join: asset_class_30_day_utilization {
#     #this is a derived view of historical_utilization
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${assets_aggregate.class} = ${asset_class_30_day_utilization.asset_class} and
#             ${work_orders_with_high_rental_revenue.branch_id} = ${asset_class_30_day_utilization.market_id} ;;
#   }
#   join: wo_tags_aggregate {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${work_orders_with_high_rental_revenue.work_order_id} = ${wo_tags_aggregate.work_order_id} ;;
#   }
#   join: markets {
#     type: left_outer
#     relationship:many_to_one
#     sql_on: ${work_orders_with_high_rental_revenue.branch_id} = ${markets.market_id} ;;
#   }
#   join: market_region_xwalk {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${market_region_xwalk.market_id} = ${markets.market_id} ;;
#   }
# }
explore: ap_detail {

  join: market_region_xwalk {
    type: left_outer
    relationship: one_to_one
    sql_on: to_char(${market_region_xwalk.market_id}) = ${ap_detail.department_id} ;;
  }
  join: top_vendor_mapping {
    type: left_outer
    relationship: one_to_one
    sql_on: ${ap_detail.vendor_id} = ${top_vendor_mapping.vendorid} ;;
  }
}
explore: part_sales_fulfillment {
  label: "Parts Sales Invoices Needing Fulfillment"

  join: parts {
    type: inner
    relationship: many_to_one
    sql_on: ${part_sales_fulfillment.part_id} = ${parts.part_id} ;;
  }
  join: price_list_entries {
    type: left_outer
    relationship: one_to_one
    sql_on: ${parts.item_id}=${price_list_entries.item_id} ;;
  }
  join: providers {
    type: inner
    relationship: many_to_one
    sql_on: ${parts.provider_id} = ${providers.provider_id} ;;
  }
  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: ${part_sales_fulfillment.market_id} = ${market_region_xwalk.market_id} ;;
  }
  join: parts_ordered_pos {
    type: left_outer
    relationship: many_to_many
    sql_on: ${part_sales_fulfillment.part_id} = ${parts_ordered_pos.part_id} and ${part_sales_fulfillment.market_id} = ${parts_ordered_pos.market_id} ;;
  }
  join: vendor {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts_ordered_pos.vendor_id} = ${vendor.vendorid} ;;
  }
}

# Commented out due to low usage on 2026-03-27
# explore: deadstock_snapshot {label:"Daily snapshot of deadstock"}

# Commented out due to low usage on 2026-03-27
# explore: deadstock_status_aggregate {}
explore: deadstock_purchases {
  label: "Purchase Orders with deadstock inventory"
  from: parts_ordered_on_deadstock
  sql_always_where: ${deadstock_purchases.date_archived_date} is null and ${purchase_orders.status} not in ('ARCHIVED','NEEDS_APPROVAL') ;;
  join: purchase_orders {
    type: inner
    relationship: many_to_one
    sql_on: ${deadstock_purchases.purchase_order_id} = ${purchase_orders.purchase_order_id} ;;
  }
  join: purchase_order_receivers {
    type: left_outer
    relationship: one_to_many
    sql_on: ${purchase_orders.purchase_order_id} = ${purchase_order_receivers.purchase_order_id} ;;
  }
  join: parts {
    type: inner
    relationship: many_to_many
    sql_on: ${deadstock_purchases.item_id} = ${parts.item_id};;
    sql_where: ${parts.provider_id} not in (select api.provider_id from ANALYTICS.PARTS_INVENTORY.ATTACHMENT_PROVIDER_IDS as api) ;;
  }
  join: deadstock_status_aggregate {
    type: left_outer
    relationship: one_to_many
    sql_on: ${parts.part_id} = ${deadstock_status_aggregate.part_id} AND
            ${purchase_orders.date_created_date} = ${deadstock_status_aggregate.snapdate_date};;
  }
  join: providers {
    type: inner
    relationship: many_to_one
    sql_on: ${parts.provider_id} = ${providers.provider_id} ;;
  }
  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: ${purchase_orders.requesting_branch_id} = ${market_region_xwalk.market_id} ;;
  }
  join: users {
    type: inner
    relationship: many_to_many
    sql_on: ${purchase_orders.created_by_id} = ${users.user_id} ;;
  }
  join: company_directory {
    type: inner
    relationship: one_to_one
    sql_on: ${users.employee_id} = ${company_directory.employee_id} ;;
  }
  join: fulfillment_center_markets {
    type: left_outer
    relationship: one_to_one
    sql_on: ${market_region_xwalk.market_name} = ${fulfillment_center_markets.location} ;;
  }
  ## Added historical records to view for employees no longer with the company
  join:  purchase_order_line_items_historical{
    type:  left_outer
    relationship: one_to_one
    sql_on: TO_CHAR(${users.employee_id}) = TO_CHAR(${purchase_order_line_items_historical.employee_id})
          AND ${purchase_orders.date_created_date} >= ${purchase_order_line_items_historical.start_date_date}
          AND ${purchase_orders.date_created_date} <= ${purchase_order_line_items_historical.end_date_date};;
  }
  join: be_market_start_month {
    type: left_outer
    relationship: one_to_one
    sql_on: ${be_market_start_month.market_id} = ${market_region_xwalk.market_id} ;;
  }
}
explore: historical_wo_revenue_impact {
  join: assets_aggregate {
    type: left_outer
    relationship: one_to_many
    sql_on: ${assets_aggregate.asset_id} = ${historical_wo_revenue_impact.asset_id} ;;
  }
  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${historical_wo_revenue_impact.market_id} = ${market_region_xwalk.market_id} ;;
  }
  join: work_orders {
    type: inner
    relationship: one_to_one
    sql_on:  ${historical_wo_revenue_impact.work_order_id} = ${work_orders.work_order_id} ;;
  }
}
explore: deadstock_consumption_locations {
#Branch Contact - Orders by Part Manager first, then Parts Associate, Service Manager and finally General Manager.  Grabs whoever is available in that order
  join: branch_contact {
    type: left_outer
    relationship: one_to_one
    sql_on: ${deadstock_consumption_locations.consuming_market_id} = ${branch_contact.market_id} ;;
  }
  }

explore: demand_requests {
  label: "Demand Requests"
  description: "Demand requests with line items, target type lookup, and requesting inventory location details."

  join: demand_request_line_items {
    type: inner
    sql_on: ${demand_requests.demand_request_id} = ${demand_request_line_items.demand_request_id} ;;
    relationship: one_to_many
  }

  join: inventory_locations {
    type: left_outer
    sql_on: ${demand_requests.requesting_inventory_id} = ${inventory_locations.inventory_location_id} ;;
    relationship: many_to_one
  }

  join: market_region_xwalk {
    type: left_outer
    sql_on: ${inventory_locations.branch_id} = ${market_region_xwalk.market_id} ;;
    relationship: many_to_one
  }

  join: parts {
    type: left_outer
    sql_on: ${demand_request_line_items.product_id} = ${parts.part_id} ;;
    relationship: many_to_one
  }

  join: part_types {
    type: left_outer
    sql_on: ${parts.part_type_id} = ${part_types.part_type_id} ;;
    relationship: many_to_one
  }
}
