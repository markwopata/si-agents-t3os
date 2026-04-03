connection: "es_snowflake"
#Had to make a new model for the "POs on Concur Bills" for the Markets Dashboard. Copied some files from other departments and reused SQL from Josh.
include: "/views/custom_sql/cc_open_pos_and_concur_invs.view.lkml"

include: "/views/custom_sql/costcapture_po_users_and_branches.view.lkml"

include: "/views/ANALYTICS/market_region_xwalk.view.lkml"

explore: cc_open_pos_and_concur_invs {
  label: "CostCapture Open POs"
}

explore: cost_capture_open_pos {
  label: "CostCapture Open POs"
  from: cc_open_pos_and_concur_invs
  always_join: [costcapture_po_users_and_branches]
  sql_always_where:
  costcapture_po_users_and_branches.user_login = '{{_user_attributes['email']}}' or costcapture_po_users_and_branches.user_login = 'put test user email in here to see what they would see'
  ;;

  join: costcapture_po_users_and_branches {
    view_label: "cc_po_users_and_branches"
    type: inner
    relationship: many_to_one
    sql_on: ${cost_capture_open_pos.branch_id} = ${costcapture_po_users_and_branches.branch}
      ;;}

  join: market_region_xwalk {
      view_label: "Requesting branch"
      type: inner
      relationship: many_to_one
      sql_on: try_cast(${cost_capture_open_pos.branch_id} as INTEGER) = ${market_region_xwalk.market_id} ;;
  }
}
