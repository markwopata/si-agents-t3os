connection: "es_warehouse"

include: "/views/*.view.lkml"

explore: work_orders {
  group_label: "Work Orders"
  label: "Time Spent on WO"
  case_sensitive: no
  # sql_always_where: ${asset_id} in (select asset_id from table(assetlist({{ _user_attributes['user_id'] }}::numeric))) ;;
  sql_always_where: ${markets_branch.company_id} in ('{{ _user_attributes['company_id'] }}'::numeric) ;;

  join: work_order_user_times {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_order_user_times.work_order_id} = ${work_orders.work_order_id} ;;
  }

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${users.user_id} = ${work_order_user_times.user_id} ;;
  }

  join: assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_orders.asset_id} = ${assets.asset_id} ;;
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

  join: organization_asset_xref {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${organization_asset_xref.asset_id} ;;
  }

  join: markets_branch {
    from: markets
    type: left_outer
    relationship: many_to_one
    sql_on: ${markets_branch.market_id} = ${work_orders.branch_id} ;;
  }
}
