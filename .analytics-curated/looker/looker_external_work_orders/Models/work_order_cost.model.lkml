connection: "es_warehouse"

include: "/views/work_order_cost/*.view.lkml"                # include all views in the views/ folder in this project
include: "/views/work_order_cost/cost_by_asset_drills/*.view.lkml"

# Views for filter suggestions
include: "/views/assets.view.lkml"
include: "/views/asset_types.view.lkml"
include: "/views/categories.view.lkml"


explore: work_order_cost {
  group_label: "Service"
  label: "Work Order Cost"
  case_sensitive: no
  persist_for: "30 minutes"
  #sql_always_where: ${company_id} =  {{ _user_attributes['company_id'] }};;

  join: work_order_cost_previous_detail {
    type: full_outer
    relationship: one_to_many
    sql_on: ${work_order_cost.asset_id} = ${work_order_cost_previous_detail.asset_id} ;;
  }

  join: work_order_cost_timeline {
    type: full_outer
    relationship: one_to_many
    sql_on: ${work_order_cost.asset_id} = ${work_order_cost_timeline.asset_id} ;;
  }

  join: work_order_cost_selected_detail {
    type: full_outer
    relationship: one_to_many
    sql_on: ${work_order_cost.asset_id} = ${work_order_cost_selected_detail.asset_id} ;;
  }

  join: assets {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets.asset_id} = ${work_order_cost.asset_id};;
  }

  join: asset_types {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets.asset_type_id} = ${asset_types.asset_type_id};;
  }

  join: categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.category_id} = ${categories.category_id} ;;
  }

}

explore: work_order_cost_detail {
  group_label: "Service"
  label: "Work Order Cost Detail Table"
  case_sensitive: no
  persist_for: "30 minutes"

  join: assets {
    type: inner
    relationship: one_to_one
    sql_on: ${assets.asset_id} = ${work_order_cost_detail.asset_id};;
  }

  join: asset_types {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets.asset_type_id} = ${asset_types.asset_type_id};;
  }

  join: categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.category_id} = ${categories.category_id} ;;
  }

}

explore: date_range_html {
  group_label: "Service"
  label: "Work Order Cost Date Range HTML"
  case_sensitive: no
  persist_for: "5 minutes"
}
