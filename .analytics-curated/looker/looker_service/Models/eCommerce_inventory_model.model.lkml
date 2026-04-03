connection: "es_snowflake_analytics"

include: "/views/OPERATIONAL_ANALYTICS/*.view.lkml"
include: "/views/ANALYTICS/INTACCT/glaccount.view.lkml"
include: "/views/ANALYTICS/INTACCT_MODELS/gl_detail.view.lkml"
include: "/views/ANALYTICS/net_price.view.lkml"
include: "/views/ES_WAREHOUSE/INVENTORY/parts.view.lkml"
include: "/views/PROCUREMENT/price_list_entries.view.lkml"

explore: dim_shopify_order_line {
  label: "eCommerce Revenue"
  sql_always_where: ${dim_shopify_order_line.name} not ilike '%navidium%' ;;

join: dim_shopify_order_header {
  type: inner
  relationship: one_to_many
  sql_on: ${dim_shopify_order_line.match_id} = ${dim_shopify_order_header.match_id} ;;
}

join: oa_dim_dates {
  type: inner
  relationship: many_to_one
  sql_on: ${dim_shopify_order_header.order_created_date} = ${oa_dim_dates.dt_standard_date} ;;
}

join: int_part_category {
  type: left_outer
  relationship: many_to_one
  sql_on: ${dim_shopify_order_line.product_id} = ${int_part_category.product_id};;
}

join: int_inventory_item {
  type: left_outer
  relationship: many_to_one
  sql_on: ${dim_shopify_order_line.inventory_item_id} = ${int_inventory_item.inventory_item_id} ;;
}

join: int_shopify_cost {
  type: left_outer
  relationship: many_to_one
  sql_on: ${dim_shopify_order_line.inventory_item_id} = ${int_shopify_cost.inventory_item_id}
        and ${dim_shopify_order_header.cost_matching_date} = ${int_shopify_cost.snapshot_month} ;;
}

join: dim_customers {
  type: left_outer
  relationship: many_to_one
  sql_on: ${dim_shopify_order_header.customer_id} = ${dim_customers.customer_id} ;;
}

join: tam_flag_list {
  type: left_outer
  relationship: one_to_one
  sql_on: ${dim_shopify_order_header.order_id} = ${tam_flag_list.order_id} ;;
}
} ## end eCommerce Revenue explore

explore: gl_detail {
  label: "eCommerce Profit and Loss"
  sql_always_where: ${gl_detail.department_id} = '38653' --eCommerce only
                and ${glaccount.accounttype} = 'incomestatement' --p&l gl accounts only
                and ${gl_detail.intacct_module} not in ('3.AP', '4.AR', '9.PO')
                and try_to_number(${gl_detail.account_number}) is not null
                and ${gl_detail.journal_title} not ilike '%Ap Accrual Prod - Adjustment Entries%'
                and ${glaccount.account_is_fulfillment_center_specific} = 'No'
                and ${glaccount.account_is_payroll_or_benefits_related} = 'No';;

join: glaccount {
  type: inner
  relationship: many_to_one
  sql_on: ${gl_detail.account_number} = ${glaccount.accountno} ;;
}
} ## end eCommerce Profit and Loss explore

# Commented out due to low usage on 2026-03-27
# explore: shopify_ops_price_snapshot {
#   label: "Pricing comparison across eCommerce and T3 - trending"
#
#   join: shopify_ops_t3_identifier_metafields {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${shopify_ops_price_snapshot.product_id} = ${shopify_ops_t3_identifier_metafields.shopify_product_id} ;;
#   }
#
#   join: net_price {
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${shopify_ops_t3_identifier_metafields.t3_part_id} = ${net_price.part_id}
#         and ${shopify_ops_price_snapshot.last_day_snapshot_month} between ${net_price.start_date} and ${net_price.end_date};;
#   }
# } ## end Pricing comparison across eCommerce and T3 - trending explore

explore: int_inventory_item {
  label: "Pricing comparison across eCommerce and T3 - current"

  join: shopify_ops_t3_identifier_metafields {
    type: left_outer
    relationship: many_to_one
    sql_on: ${int_inventory_item.product_id} = ${shopify_ops_t3_identifier_metafields.shopify_product_id} ;;
  }

  join: parts {
    type: left_outer
    relationship: many_to_one
    sql_on: ${shopify_ops_t3_identifier_metafields.t3_part_id} = ${parts.part_id};;
  }

  join: price_list_entries {
    type: left_outer
    relationship: one_to_one
    sql_on: ${parts.item_id} = ${price_list_entries.item_id} ;;
  }
} ## end Pricing comparison across eCommerce and T3 - current explore
