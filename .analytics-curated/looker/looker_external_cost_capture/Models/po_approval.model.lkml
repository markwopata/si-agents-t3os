connection: "es_warehouse"

include: "/views/po_approval_list.view.lkml"
include: "/views/users.view.lkml"
include: "/views/markets.view.lkml"

explore: po_approval_list {
  group_label: "Cost Capture"
  label: "PO Approval List"
  case_sensitive: no
  persist_for: "5 minutes"

  join: users {
    type: inner
    relationship: many_to_one
    sql_on: ${users.user_id} = ${po_approval_list.approver_id} ;;
  }

  join: markets {
    type: inner
    relationship: many_to_one
    sql_on: ${markets.market_id} = ${po_approval_list.market_id} ;;
  }

  join: users_created_by {
    from: users
    type: inner
    relationship: many_to_one
    sql_on: ${users_created_by.user_id} = ${po_approval_list.requesting_user_id} ;;
  }

}
