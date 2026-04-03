connection: "es_snowflake_analytics"

include: "/views/ES_WAREHOUSE/INVENTORY/parts.view.lkml"
include: "/views/ANALYTICS/net_price.view.lkml"
include: "/views/PROCUREMENT/price_list_entries.view.lkml"
include: "/views/custom_sql/missed_savings.view.lkml"
# include: "/views/custom_sql/missed_savings_testing_ka.view.lkml"
include: "/views/ANALYTICS/INTACCT/vendor.view.lkml"
include: "/views/PLATFORM/v_markets.view.lkml"
include: "/views/ES_WAREHOUSE/users.view.lkml"
include: "/views/INVENTORY/providers.view.lkml"
include: "/views/ANALYTICS/PARTS_INVENTORY/part_substitutes.view.lkml"
include: "/views/ANALYTICS/PARTS_INVENTORY/part_suppression_categories.view.lkml"
include: "/views/ANALYTICS/PARTS_INVENTORY/yearly_demand_vw.view.lkml"
include: "/views/ANALYTICS/PARTS_INVENTORY/parts_attributes.view.lkml"
include: "/views/ANALYTICS/PARTS_INVENTORY/part_categorization_structure.view.lkml"
include: "/views/custom_sql/sub_part_procurement_comparison.view.lkml"
include: "/views/FLEET_OPTIMIZATION/detailed_part_view.view.lkml"
include: "/views/PLATFORM/v_parts.view.lkml"

explore: parts {
  label: "Parts Pricing"
  join: net_price {
    type: left_outer
    relationship: one_to_many
    sql_on: ${parts.part_id} = ${net_price.part_id} ;;
  }
  join: price_list_entries {
    type: left_outer
    relationship: one_to_one
    sql_on: ${parts.item_id}=${price_list_entries.item_id} ;;
  }
}
explore: net_price_lag {
  label: "Net Price Trend"
  join: parts {
    from: v_parts
    type: inner
    relationship: many_to_one
    sql_on: ${net_price_lag.part_id} = ${parts.part_id} ;;
  }
  join: vendor {
    type: inner
    relationship: many_to_one
    sql_on: ${net_price_lag.vendor_id} = ${vendor.vendorid} ;;
  }
}
explore: missed_savings {
  # join: po_vendor {
  #   from: vendor
  #   type: inner
  #   relationship: many_to_one
  #   sql_on: ${po_vendor.vendorid} = ${missed_savings.po_vendor_id} ;;
  # }
  # join: min_vendor {
  #   from: vendor
  #   type: inner
  #   relationship: many_to_one
  #   sql_on: ${min_vendor.vendorid} = ${missed_savings.min_vendor_id} ;;
  # }
  join: v_markets {
    type: inner
    relationship: many_to_one
    sql_on: ${missed_savings.market_id} = ${v_markets.market_id} ;;
  }
  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${missed_savings.created_by_id} = ${users.user_id} ;;
  }
  join: parts {
    type: left_outer
    relationship: many_to_one
    sql_on: ${missed_savings.part_id} = ${parts.part_id} ;;
  }
  join: part_substitutes_flag_sub_type {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_id} = ${part_substitutes_flag_sub_type.part_id} ;;
   }
  # join: part_substitutes { #this only works well on the detail level, not agged
  #   type: left_outer
  #   relationship: many_to_many
  #   sql_on: ${parts.part_id} = ${part_substitutes.part_id} and ${part_substitutes.isactive} ;;
  #   fields: [part_substitutes.has_reman_sub,part_substitutes.has_aftermarket_sub]
  # }
  join: part_suppression_categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_id} = ${part_suppression_categories.part_id} ;;
  }
  join: yearly_demand_vw { #this is causing issues, the view runs its logic everytime and cant compute fast enough
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_id} = ${yearly_demand_vw.part_id} ;;
  }
  join: parts_attributes {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_id} = ${parts_attributes.part_id} and ${parts_attributes.end_date} = '2999-01-01' ;;
  }
  join: part_categorization_structure {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts_attributes.part_categorization_id} = ${part_categorization_structure.part_categorization_id} ;;
  }
  join: providers {
    type: left_outer
    relationship: many_to_one
    sql_on: ${providers.provider_id} = ${parts.provider_id} ;;
  }
}

explore: sub_part_procurement_comparison {}

explore: detailed_part_view {
  sql_always_where: ${v_markets.market_region_name} not ilike '%default%' and ${v_markets.market_active_reporting} ;;

  join: missed_savings_by_part_number { #this name is misleading, its actually current minimum price by part id
    type: left_outer
    relationship: one_to_one
    sql_on: ${detailed_part_view.part_id} = ${missed_savings_by_part_number.part_id}
      ;;
  }

  join: v_markets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${missed_savings_by_part_number.market_region} = ${v_markets.market_region} ;;
  }

  join: missed_savings { #this is actually missed savings at the PO level, not sure its use in this explore though
    type: left_outer
    relationship: one_to_many
    sql_on: ${detailed_part_view.part_id} = ${missed_savings.part_id}
    and ${v_markets.market_id} = ${missed_savings.market_id}
    ;;
  }

  join: yearly_demand_vw {
    type: left_outer
    relationship: many_to_one
    sql_on: ${detailed_part_view.part_id} = ${yearly_demand_vw.part_id} ;;
  }

  join: part_suppression_categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${detailed_part_view.part_id} = ${part_suppression_categories.part_id} ;;
  }
}
