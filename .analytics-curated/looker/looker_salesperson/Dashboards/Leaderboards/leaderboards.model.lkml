connection: "es_snowflake"

include: "/Dashboards/Leaderboards/Views/v_line_items.view.lkml"
include: "/Dashboards/Leaderboards/Views/approved_invoice_salespersons.view.lkml"
include: "/Dashboards/Leaderboards/Views/market_region_xwalk.view.lkml"
include: "/Dashboards/Leaderboards/Views/users.view.lkml"
include: "/Dashboards/Leaderboards/Views/Custom/sales_rep_rank_by_market.view.lkml"
include: "/Dashboards/Leaderboards/Views/Custom/sales_rep_rank_overall_ytd.view.lkml"
include: "/Dashboards/Leaderboards/Views/Custom/sales_rep_rank_monthly.view.lkml"


# explore: line_items { --MB comment out 10-10-23 due to inactivity
#   label: "Sales Rep Leaderboard"
#   view_label: "Line Items"
#   from: v_line_items
#   case_sensitive: no

#   join: approved_invoice_salespersons {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${line_items.invoice_id} = ${approved_invoice_salespersons.invoice_id} ;;
#   }

#   join: invoice_market {
#     from: market_region_xwalk
#     type: inner
#     relationship: many_to_one
#     sql_on: ${line_items.branch_id} = ${invoice_market.market_id} ;;
#   }

#   join: salesperson_user {
#     from: users
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${approved_invoice_salespersons.primary_salesperson_id} = ${salesperson_user.user_id} ;;
#   }
# }

explore: sales_rep_rank_by_market {
  case_sensitive: no

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: ${sales_rep_rank_by_market.market_id} = ${market_region_xwalk.market_id} ;;
  }
}

explore: sales_rep_rank_overall_ytd {
  case_sensitive: no

  join: market_region_xwalk {
    type: left_outer # some reps don't have a home market :\
    relationship: many_to_one
    sql_on: ${sales_rep_rank_overall_ytd.home_market_id} = ${market_region_xwalk.market_id} ;;
  }
}

# explore: sales_rep_rank_monthly {
#   case_sensitive: no

#   join: market_region_xwalk {
#     type: left_outer # some reps don't have a home market :\
#     relationship: many_to_one
#     sql_on: ${sales_rep_rank_monthly.home_market_id} = ${market_region_xwalk.market_id} ;;
#   }
# }
