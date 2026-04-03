connection: "es_warehouse"

include: "/views/*.view.lkml"
include: "/views/mechanic_response_time_report/*.view.lkml"


explore: mechanic_response_time {
  group_label: "Work Orders"
  label: "Mechanic WO Reponse Time"
  case_sensitive: no
  sql_always_where: ${markets_branch.company_id} in ('{{ _user_attributes['company_id'] }}'::numeric) ;;

  join: work_orders {
    type: inner
    relationship: one_to_one
    sql_on: ${work_orders.work_order_id} = ${mechanic_response_time.work_order_id} ;;
  }

  join: work_order_user_times {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_order_user_times.work_order_id} = ${work_orders.work_order_id} ;;
  }

  join: markets_branch {
    from: markets
    type: left_outer
    relationship: many_to_one
    sql_on: ${markets_branch.market_id} = ${mechanic_response_time.branch_id} ;;
  }

  join: assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${work_orders.asset_id} ;;
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

  join: urgency_levels {
    type: left_outer
    relationship: many_to_one
    sql_on: ${urgency_levels.urgency_level_id} = ${work_orders.urgency_level_id} ;;
  }


}
