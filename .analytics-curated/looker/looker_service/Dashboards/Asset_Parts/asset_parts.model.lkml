connection: "es_snowflake_analytics"

include: "/Dashboards/Asset_Parts/views/*.view.lkml"
include: "/views/WORK_ORDERS/work_orders.view.lkml"
include: "/views/WORK_ORDERS/billing_types.view.lkml"
include: "/views/ES_WAREHOUSE/assets_aggregate.view.lkml"
include: "/views/ANALYTICS/INTACCT_MODELS/part_inventory_transactions_b.view.lkml" #should change over to this but would need some additional joins that are being done in the v_wo_parts, corrected v_wo_parts to_id join for now -HL 2.17.25
include: "/views/FLEET_OPTIMIZATION/dim_work_orders_fleet_opt.view.lkml"
include: "/views/custom_sql/asset_engines.view.lkml"
include: "/views/ANALYTICS/PARTS_INVENTORY/parts_attributes.view.lkml"
include: "/views/ANALYTICS/PARTS_INVENTORY/part_categorization_structure.view.lkml"

explore: asset_parts {
  from: v_wo_parts

  join: asset_market {
    from: market_region_xwalk
    relationship: one_to_one
    type: left_outer
    sql_on: {% if asset_parts.asset_branch_type._parameter_value == "rental" %}
            ${asset_parts.rental_branch_id} = ${asset_market.market_id}
            {% elsif asset_parts.asset_branch_type._parameter_value == "service" %}
            ${asset_parts.service_branch_id} = ${asset_market.market_id}
            {% elsif asset_parts.asset_branch_type._parameter_value == "inventory" %}
            ${asset_parts.inventory_branch_id} = ${asset_market.market_id}
            {% else %}
            ${asset_parts.rental_branch_id} = ${asset_market.market_id}
            {% endif %}
            ;;
  }

  join: assets_aggregate {
    type: inner
    relationship: many_to_one
    sql_on: ${asset_parts.asset_id}=${assets_aggregate.asset_id} ;;
  }
  join: work_orders {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_orders.work_order_id} = ${asset_parts.work_order_id} ;;
  }
  join: dim_work_orders_fleet_opt {
    type: left_outer
    relationship: many_to_one
    sql_on: ${dim_work_orders_fleet_opt.work_order_id} = ${asset_parts.work_order_id}  ;;
  }
  join: billing_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_orders.billing_type_id}=${billing_types.billing_type_id} ;;
  }
  join: asset_engines {
    type: left_outer
    relationship: one_to_one
    sql_on: ${asset_engines.asset_id} = ${asset_parts.asset_id} ;;
  }
  join: parts_attributes_part_id_level {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_parts.part_id} = ${parts_attributes_part_id_level.part_id} ;;
  }
  join: part_categorization_structure {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts_attributes_part_id_level.part_categorization_id} = ${part_categorization_structure.part_categorization_id} ;;
  }
}
