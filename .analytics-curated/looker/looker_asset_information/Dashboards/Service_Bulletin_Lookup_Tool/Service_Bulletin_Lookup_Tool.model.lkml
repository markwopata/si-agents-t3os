connection: "es_snowflake_analytics"

include: "/Dashboards/Service_Bulletin_Lookup_Tool/Views/assets_service_bulletin.view.lkml"
include: "/Dashboards/Service_Bulletin_Lookup_Tool/Views/warranty_work_orders.view.lkml"
include: "/views/ES_WAREHOUSE/assets.view.lkml"
include: "/views/ES_WAREHOUSE/markets.view.lkml"
include: "/views/ES_WAREHOUSE/companies.view.lkml"
include: "/views/ES_WAREHOUSE/asset_purchase_history.view.lkml"
#include: "/views/ES_WAREHOUSE/work_orders.view.lkml"
include: "/views/ES_WAREHOUSE/billing_types.view.lkml"
include: "/views/ES_WAREHOUSE/work_orders_by_tag.view.lkml"
include: "/views/market_region_xwalk.view.lkml"
include: "/views/SCD/scd_asset_inventory_status.view.lkml"
include: "/views/ES_WAREHOUSE/company_tags.view.lkml"
include: "/views/ES_WAREHOUSE/work_order_company_tags.view.lkml"
include: "/views/ES_WAREHOUSE/urgency_levels.view.lkml"


explore: service_bulletin_lookup {
  from: assets_service_bulletin
  label: "Asset Service Bulletin Lookup"
  case_sensitive: no
  sql_always_where: ${include_service_asset} ;;
  fields: [ALL_FIELDS*, -service_bulletin_lookup.purchase_created_date]


  join: companies {
    relationship: one_to_many
    sql_on:  ${service_bulletin_lookup.company_id} = ${companies.company_id} ;;
    }

  join: markets {
    relationship: one_to_many
    sql_on: ${service_bulletin_lookup.market_id_to_use} = ${markets.market_id} ;;
  }

  join: rental_markets {
    from: markets
    relationship: one_to_many
    sql_on: ${service_bulletin_lookup.rental_branch_id} = ${rental_markets.market_id} ;;
  }

  join: service_markets {
    from: markets
    relationship: one_to_many
    sql_on: ${service_bulletin_lookup.service_branch_id} = ${service_markets.market_id} ;;
  }

  join: warranty_work_orders {
    type: left_outer
    relationship: one_to_one
    sql_on: ${service_bulletin_lookup.asset_id} = ${warranty_work_orders.asset_id} ;;
  }

  join: assets {
    relationship: one_to_one
    sql_on: ${service_bulletin_lookup.asset_id} = ${assets.asset_id} ;;
  }

  join: asset_purchase_history {
    relationship: one_to_one
    sql_on: ${service_bulletin_lookup.asset_id} = ${asset_purchase_history.asset_id} ;;
  }

  #join: work_orders {
  #  relationship: many_to_one
  #  sql_on: ${service_bulletin_lookup.asset_id} = ${work_orders.asset_id} ;;
  #}

  join: billing_types {
    relationship:  one_to_one
    sql_on: ${warranty_work_orders.billing_type_id} = ${billing_types.billing_type_id} ;;
  }

  join: work_orders_by_tag {
    relationship:  one_to_many
    sql_on: ${warranty_work_orders.work_order_id} = ${work_orders_by_tag.work_order_id} ;;
  }

  join: market_region_xwalk {
    relationship: many_to_one
    sql_on: ${service_bulletin_lookup.market_id_to_use} = ${market_region_xwalk.market_id} ;;
  }

  join: scd_asset_inventory_status {
    relationship: one_to_one
    sql_on: ${service_bulletin_lookup.asset_id} = ${scd_asset_inventory_status.asset_id} ;;
  }

  join: work_order_company_tags {
    type: left_outer
    relationship: one_to_many
    sql_on: ${warranty_work_orders.work_order_id} = ${work_order_company_tags.work_order_id} ;;
  }

  join: company_tags {
    type: inner
    relationship: one_to_one
    sql_on: ${work_order_company_tags.company_tag_id} = ${company_tags.company_tag_id} ;;
  }

  join: urgency_levels {
    type: left_outer
    relationship: one_to_many
    sql_on: ${urgency_levels.urgency_level_id} = ${warranty_work_orders.urgency_level_id} ;;
  }
}
