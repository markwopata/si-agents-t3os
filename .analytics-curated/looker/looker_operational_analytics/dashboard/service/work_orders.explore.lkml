include: "/_base/fleet_optimization/dim_asset_company_pit.view.lkml"
include: "/_base/fleet_optimization/dim_assets_fleet_opt.view.lkml"
include: "/_base/fleet_optimization/dim_companies_fleet_opt.view.lkml"
include: "/_base/fleet_optimization/dim_markets_fleet_opt.view.lkml"
include: "/_base/fleet_optimization/dim_parts_fleet_opt.view.lkml"
include: "/_base/platform/gold/fact_work_order_lines.view.lkml" #need to be careful not to fan out
include: "/_base/analytics/warranties/warranty_reviews.view.lkml"
include: "/_base/es_warehouse/work_orders/work_order_company_tags.view.lkml" #need to be careful not to fan out
include: "/_base/es_warehouse/work_orders/company_tags.view.lkml"
include: "/_standard/es_warehouse/time_entries.layer.lkml" #need to be careful not to fan out
include: "/_standard/fleet_optimization/dim_work_orders_fleet_opt.layer.lkml"

#starting concepts of a work orders explore, mostly for service dashboard but likely useful in other places too
explore: dim_work_orders_fleet_opt {
  group_label: "Operational Analytics"
  label: "Work Orders"
sql_always_where: ${work_order_date_archived_date} is null and ${dim_markets_fleet_opt.reporting_market};;
#only want to see non-archived work orders that are for the markets we care about

join: dim_assets_fleet_opt {
  type: left_outer #keeping as left since some work orders dont have assets
  relationship: many_to_one
  sql_on: ${dim_work_orders_fleet_opt.work_order_asset_key}=${dim_assets_fleet_opt.asset_key} ;;
}
join: current_asset_company {
  from: dim_companies_fleet_opt
  type: inner
  relationship: many_to_one
  sql_on: ${dim_assets_fleet_opt.asset_company_key}=${current_asset_company.company_key} ;;
}
# join: dim_asset_company_pit { #think this will be needed at some point, but not sure if on created,completed, or billed date.
#   type: left_outer
#   relationship: many_to_one
#   sql_on: ${dim_work_orders_fleet_opt.work_order_asset_id}=${dim_asset_company_pit.asset_id}
#   and ${dim_work_orders_fleet_opt.work_order_completed_date}>= ${dim_asset_company_pit.company_ownership_start_date}
#   and ${dim_work_orders_fleet_opt.work_order_completed_date}< ${dim_asset_company_pit.company_ownership_start_date};;
# }
# join: asset_company_pit
#   from: dim_companies_fleet_opt { #this is the asset company at a point in time "current" label is misleading
#   view_label: "Asset Company At Work Order Closure"
#   type: inner
#   relationship: many_to_one
#   sql_on: ${dim_asset_company_pit.current_company_id}=${asset_company_name_pit.company_id}  ;;
# }

join: dim_markets_fleet_opt {
  type: inner
  relationship: many_to_one
  sql_on: ${dim_work_orders_fleet_opt.work_order_market_key}=${dim_markets_fleet_opt.market_key} ;;
}

join: warranty_reviews { #only current warranty state of a work order, started spring 2025
  type: left_outer
  relationship: one_to_one
  sql_on: ${dim_work_orders_fleet_opt.work_order_id}=${warranty_reviews.work_order_id}
  and ${warranty_reviews.is_current} ;;
}

join: fact_work_order_lines { #ill be getting time entries elsewhere to get nonapproved hours too, but keeping broad for others' use
  #this join will cause fan out if using more than measures
  type: left_outer
  relationship: one_to_many
  sql_on: ${dim_work_orders_fleet_opt.work_order_key}= ${fact_work_order_lines.work_order_line_work_order_key};;
}

join: dim_parts_fleet_opt {
  type: left_outer
  relationship: many_to_many
  sql_on: ${fact_work_order_lines.work_order_line_part_key}=${dim_parts_fleet_opt.part_key}
  and ${dim_parts_fleet_opt.part_id}!=-1;; #default part record
}

join: time_entries { #grabbing time here because work order lines only has approved time which will make reality lag
  #this join will cause fan out if using more than measures
  type: left_outer
  relationship: one_to_many
  sql_on: ${dim_work_orders_fleet_opt.work_order_id}=${time_entries.work_order_id}
  and ${time_entries.archived_date} is null
  and ${time_entries.event_type_id}=1 ;;
}

join: work_order_company_tags {
  #this join will cause fan out if using more than measures
  type: left_outer
  relationship: one_to_many
  sql_on: ${dim_work_orders_fleet_opt.work_order_id}=${work_order_company_tags.work_order_id}
  and ${work_order_company_tags.deleted_date} is null;;
}

join: company_tags {
  type: left_outer
  relationship: many_to_one
  sql_on: ${work_order_company_tags.company_tag_id}=${company_tags.company_tag_id} ;;
}
}
