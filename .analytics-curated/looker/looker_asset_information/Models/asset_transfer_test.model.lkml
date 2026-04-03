connection: "es_snowflake_analytics"

include: "/views/ASSET_TRANSFER/transfer_orders.view.lkml"
include: "/views/BUSINESS_INTELLIGENCE/v_dim_users_bi.view.lkml"
include: "/views/BUSINESS_INTELLIGENCE/v_dim_employees.view.lkml"
include: "/views/PLATFORM/v_markets.view.lkml"
include: "/views/PLATFORM/v_assets.view.lkml"

explore: transfer_orders {
  group_label: "Asset Transfer Approval Log"
  label: "Asset Transfer Approvals"

  join: v_dim_users_bi_requester {
    from: v_dim_users_bi
    type: left_outer
    relationship: many_to_one
    sql_on: ${transfer_orders.requester_id} = ${v_dim_users_bi_requester.user_id} ;;
  }

  join: v_dim_users_bi_approver {
    from: v_dim_users_bi
    type: left_outer
    relationship: many_to_one
    sql_on: ${transfer_orders.approver_id} = ${v_dim_users_bi_approver.user_id} ;;
  }

  join: v_dim_employees_requester {
    from: v_dim_employees
    type: left_outer
    relationship: many_to_one
    sql_on: ${v_dim_users_bi_requester.user_employee_key} = ${v_dim_employees_requester.employee_key} ;;
  }

  join: v_dim_employees_approver {
    from: v_dim_employees
    type: left_outer
    relationship: many_to_one
    sql_on: ${v_dim_users_bi_approver.user_employee_key} = ${v_dim_employees_approver.employee_key} ;;
  }

  join: v_markets_requestor {
    from: v_markets
    type: left_outer
    relationship: many_to_one
    sql_on: ${v_dim_employees_requester.market_key} = ${v_markets_requestor.market_key} ;;
  }

  join: v_markets_approver {
    from: v_markets
    type: left_outer
    relationship: many_to_one
    sql_on: ${v_dim_employees_approver.market_key} = ${v_markets_approver.market_key} ;;
  }

  join: v_markets_from_branch {
    from: v_markets
    type: left_outer
    relationship: many_to_one
    sql_on: ${transfer_orders.from_branch_id} = ${v_markets_from_branch.market_id} ;;
  }

  join: v_markets_to_branch {
    from: v_markets
    type: left_outer
    relationship: many_to_one
    sql_on: ${transfer_orders.to_branch_id} = ${v_markets_to_branch.market_id} ;;
  }

  join: v_assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${transfer_orders.asset_id} = ${v_assets.asset_id} ;;
  }

  join: v_assets_markets {
    from: v_markets
    type: left_outer
    relationship: many_to_one
    sql_on: ${v_assets.asset_market_id} = ${v_assets_markets.market_id} ;;
  }


}
