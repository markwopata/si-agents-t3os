connection: "es_snowflake_analytics"


include: "/views/ES_WAREHOUSE/line_items_w_avg_cost.view.lkml"
include: "/views/INVENTORY/part_categories.view.lkml"
include: "/views/INVENTORY/part_types.view.lkml"
include: "/views/INVENTORY/parts.view.lkml"
include: "/views/INVENTORY/providers.view.lkml"
include: "/views/ES_WAREHOUSE/invoices.view.lkml"
include: "/views/ES_WAREHOUSE/line_items.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/ES_WAREHOUSE/companies.view.lkml"
include: "/views/ES_WAREHOUSE/assets_aggregate.view.lkml"
include: "/views/ANALYTICS/line_item_types.view.lkml"
include: "/views/ANALYTICS/v_line_items.view.lkml"

explore: invoices {
  label: "Parts and Assets Sales"
  case_sensitive: no

  join: line_items { #these are all line items, needed to get the asset sales
    type: inner
    relationship: many_to_one
    sql_on: ${invoices.invoice_id}=${line_items.invoice_id} ;;
  }

  join: v_line_items {#adding this to adjust for credits HL 6.2.25
    type: inner
    relationship: one_to_many
    sql_on: ${line_items.line_item_id}=${v_line_items.line_item_id} ;;
  }
  join: line_item_types {
    type: inner
    relationship: many_to_one
    sql_on: ${line_items.line_item_type_id}=${line_item_types.line_item_type_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on:${line_items.branch_id}=${market_region_xwalk.market_id} ;;
  }

  join: companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${companies.company_id} = ${invoices.company_id} ;;
  }

  join: assets_aggregate {
    type: left_outer
    relationship: many_to_one
    sql_on: ${line_items.derived_asset_id}=${assets_aggregate.asset_id} ;;
  }
  join: line_items_w_avg_cost { #these are filtered down to parts
    type: left_outer
    relationship: many_to_one
    sql_on: ${line_items.line_item_id}=${line_items_w_avg_cost.line_item_id} ;;
  }

  join: parts {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.part_id} = ${line_items_w_avg_cost.part_id} ;;
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

}
