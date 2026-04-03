connection: "es_warehouse"

include: "/views/*.view.lkml"
include: "/views/asset_downtime_report/*.view.lkml"
include: "/views/uptime_research/*.view.lkml"

explore: asset_down_time {
  group_label: "Service"
  label: "Asset Down Time"
  case_sensitive: no
  # persist_for: "10 minutes"

  join: assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${asset_down_time.asset_id} ;;
  }

  join: categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${categories.category_id} = ${assets.category_id} ;;
  }

  join: asset_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_type_id} = ${asset_types.asset_type_id} ;;
  }

  join: asset_status_key_values {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_status_key_values.asset_id} = ${assets.asset_id} ;;
  }

  join: asset_down_time_work_orders {
    type: inner
    relationship: many_to_one
    sql_on: ${asset_down_time.asset_id} = ${asset_down_time_work_orders.asset_id} and ${asset_down_time.month_month} = ${asset_down_time_work_orders.month_month} ;;
  }

  join: asset_last_location {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets.asset_id} = ${asset_last_location.asset_id} ;;
  }

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${markets.market_id} = ${assets.inventory_branch_id} ;;
  }

}

explore: uptime_research {
  group_label: "Service"
  label: "Uptime Research"
  case_sensitive: no
  persist_for: "45 minutes"

  join: assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${uptime_research.asset_id} ;;
  }

  join: categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${categories.category_id} = ${assets.category_id} ;;
  }

  join: companies {
    type: inner
    relationship: many_to_one
    sql_on: ${companies.company_id} = ${uptime_research.company_id} ;;
  }

}
