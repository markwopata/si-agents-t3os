connection: "es_snowflake"

include: "/views/ES_WAREHOUSE/invoices.view.lkml"
include: "/views/ES_WAREHOUSE/line_items.view.lkml"
include: "/views/ES_WAREHOUSE/line_item_types.view.lkml"
include: "/views/ES_WAREHOUSE/companies.view.lkml"
include: "/views/ES_WAREHOUSE/users.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/HEAP_MAIN_PRODUCTION/sessions.view.lkml"
include: "/views/HEAP_MAIN_PRODUCTION/heap_users.view.lkml"
include: "/views/HEAP_MAIN_PRODUCTION/all_events.view.lkml"
include: "/views/custom_sql/fleet_value_actions.view.lkml"
include: "/views/custom_sql/company_favorite_action.view.lkml"
include: "/views/custom_sql/company_classifications.view.lkml"
include: "/views/custom_sql/company_revenue.view.lkml"
include: "/views/custom_sql/usage_patterns.view.lkml"
include: "/views/custom_sql/t3_companies.view.lkml"
include: "/views/HEAP_MAIN_PRODUCTION/pageviews.view.lkml"
include: "/views/custom_sql/company_first_seen.view.lkml"
include: "/views/custom_sql/user_session_activity.view.lkml"
include: "/views/custom_sql/daily_active_users.view.lkml"
include: "/views/custom_sql/daily_active_companies.view.lkml"


explore:line_items{
  label: "Revenue"

  join: invoices {
    relationship: many_to_one
    type: inner
    sql_on: ${line_items.invoice_id} = ${invoices.invoice_id} ;;
  }

  join: line_item_types {
    relationship: many_to_one
    type: inner
    sql_on: ${line_items.line_item_type_id} = ${line_item_types.line_item_type_id};;
  }

  join: companies {
    relationship: many_to_one
    type: inner
    sql_on: ${companies.company_id} = ${invoices.company_id} ;;
  }

  join: market_region_xwalk {
    relationship: many_to_one
    type: inner
    sql_on: ${line_items.branch_id} = ${market_region_xwalk.market_id} ;;
  }
}


explore: sessions {
  case_sensitive: no
  # always_join: [heap_users]

  join:  heap_users {
    relationship: many_to_one
    type: inner
    sql_on: ${sessions.user_id} = ${heap_users.user_id} ;;
  }

  join: companies {
    relationship: many_to_one
    type: inner
    sql_on: ${heap_users.company_id} = ${companies.company_id} ;;
  }

  # join: t3_companies {
  #   relationship: one_to_one
  #   type: left_outer
  #   sql_on: ${companies.company_id} = ${t3_companies.company_id} ;;
  # }

  join: admin_users {
    from: users
    relationship: one_to_one
    type: left_outer
    sql_on: TRY_CAST(${heap_users.identity} as number) = ${admin_users.user_id} ;;
  }

  join: pageviews {
    relationship: one_to_many
    type: left_outer
    sql_on: ${sessions.session_id} = ${pageviews.session_id} ;;
  }

  join: all_events {
    relationship: one_to_many
    type: left_outer
    sql_on: ${sessions.session_id} = ${all_events.session_id} ;;
  }

  join: company_revenue {
    type: left_outer
    relationship: one_to_many
    sql_on: ${heap_users.company_id} = ${company_revenue.company_id} ;;
  }

  join: invoices {
    type: left_outer
    relationship: one_to_many
    sql_on: ${companies.company_id} = ${invoices.company_id} ;;
  }

  join: line_items {
    type: inner
    relationship: one_to_many
    sql_on: ${invoices.invoice_id} = ${line_items.invoice_id} ;;
  }

  join: line_item_types {
    type: inner
    relationship: many_to_one
    sql_on: ${line_items.line_item_type_id} = ${line_item_types.line_item_type_id} ;;
  }
}

# explore: user_session_activity { --MB comment out 10-10-23 due to inactivity
#   case_sensitive: no

#   join: companies {
#     relationship: many_to_one
#     type: inner
#     sql_on: ${user_session_activity.company_id} = ${companies.company_id} ;;
#   }

#   join: company_revenue {
#     relationship: one_to_many
#     type: left_outer
#     sql_on: ${companies.company_id} = ${company_revenue.company_id} ;;
#   }

#   join: admin_users {
#     from: users
#     relationship: one_to_one
#     type: left_outer
#     sql_on: TRY_CAST(${user_session_activity.identity} as number) = ${admin_users.user_id} ;;
#   }

# }

explore: daily_active_users {
  case_sensitive: no

  join: heap_users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${daily_active_users.user_id} = ${heap_users.user_id};;
  }

  join: companies {
    type: inner
    relationship: many_to_one
    sql_on: ${heap_users.company_id} = ${companies.company_id} ;;
  }

  join: company_revenue {
    relationship: one_to_many
    type: inner
    sql_on: ${companies.company_id} = ${company_revenue.company_id} ;;
  }

}

# explore: daily_active_companies { --MB comment out 10-10-23 due to inactivity
#   case_sensitive: no

#   join: companies {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${daily_active_companies.company_id} = ${companies.company_id} ;;
#   }

#   join: company_revenue {
#     relationship: one_to_many
#     type: inner
#     sql_on: ${companies.company_id} = ${company_revenue.company_id} ;;
#   }

# }

# explore: all_events { --MB comment out 10-10-23 due to inactivity
#   label: "All Heap Events"
#   case_sensitive: no

#   join: heap_users {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${all_events.user_id} = ${heap_users.user_id} ;;
#   }

#   join: companies {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${heap_users.company_id} = ${companies.company_id} ;;
#   }

#   join: t3_companies {
#     relationship: one_to_one
#     type: left_outer
#     sql_on: ${companies.company_id} = ${t3_companies.company_id} ;;
#   }

#   join: invoices {
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${companies.company_id} = ${invoices.company_id} ;;
#   }

#   join: line_items {
#     type: inner
#     relationship: one_to_many
#     sql_on: ${invoices.invoice_id} = ${line_items.invoice_id} ;;
#   }

#   join: line_item_types {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${line_items.line_item_type_id} = ${line_item_types.line_item_type_id} ;;
#   }

#   join: sessions {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${all_events.session_id} = ${sessions.session_id} ;;
#   }

#   join: company_favorite_action {
#     type: inner
#     relationship: many_to_many
#     sql_on: ${heap_users.company_id} = ${company_favorite_action.company_id} ;;
#   }
# }


# explore: heap_users { --MB comment out 10-10-23 due to inactivity
#   case_sensitive: no

#   join: admin_users {
#     from: users
#     type: full_outer
#     relationship: one_to_one
#     sql_on:TRY_CAST(${heap_users.identity} as number) = ${admin_users.user_id} ;;
#   }

#   join: companies {
#     relationship: many_to_one
#     type: inner
#     sql_on: ${heap_users.company_id} = ${companies.company_id} ;;
#   }

#   join: t3_companies {
#     relationship: one_to_one
#     type: left_outer
#     sql_on: ${companies.company_id} = ${t3_companies.company_id} ;;
#   }

#   join: company_classifications {
#     relationship: one_to_one
#     type: left_outer
#     sql_on: ${companies.company_id} = ${company_classifications.company_id} ;;
#   }

#   join: invoices {
#     relationship: one_to_many
#     type: left_outer
#     sql_on:${companies.company_id} = ${invoices.company_id} ;;
#   }

#   join: line_items {
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${invoices.invoice_id} = ${line_items.invoice_id} ;;
#   }

#   join: line_item_types {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${line_items.line_item_type_id} = ${line_item_types.line_item_type_id} ;;
#   }

#   join: sessions {
#     type: inner
#     relationship: one_to_many
#     sql_on: ${heap_users.user_id} = ${sessions.user_id} ;;
#   }
# }

explore: heap_users_vs_revenue {
  from: company_revenue
  case_sensitive: no

  join: heap_users {
    type: left_outer
    relationship: one_to_many
    sql_on: ${heap_users_vs_revenue.date_month} = ${heap_users.joindate_month} ;;
  }

  join: t3_companies {
    relationship: one_to_one
    type: left_outer
    sql_on: ${heap_users.company_id} = ${t3_companies.company_id} ;;
  }

  join: companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${heap_users_vs_revenue.company_id} = ${companies.company_id} ;;
  }

}

explore: company_first_seen {
  case_sensitive: no

  join: companies {
    type: inner
    relationship: many_to_one
    sql_on: ${company_first_seen.company_id} = ${companies.company_id} ;;
  }

  join: company_revenue {
    relationship: one_to_many
    type: left_outer
    sql_on: ${companies.company_id} = ${company_revenue.company_id} ;;
  }
}

# - - - - - COMPANY DASHBOARD - - - - -

# explore: companies { --MB comment out 10-10-23 due to inactivity
#   case_sensitive: no
#   group_label: "Heap - Company"

#   join: t3_companies {
#     relationship: one_to_one
#     type: left_outer
#     sql_on: ${companies.company_id} = ${t3_companies.company_id} ;;
#   }

#   join: heap_users {
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${companies.company_id} = ${heap_users.company_id} ;;
#   }

#   join: admin_users_by_company {
#     from: users
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${companies.company_id} = ${admin_users_by_company.company_id} ;;
#   }

#   join: admin_users {
#     from: users
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${heap_users.identity} = ${admin_users.user_id} ;;
#   }

#   join: sessions {
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${heap_users.user_id} = ${sessions.user_id} ;;
#   }

#   join: all_events {
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${heap_users.user_id} = ${all_events.user_id} ;;
#   }
# }

explore: company_revenue {
  case_sensitive: no

  join: companies {
    type: inner
    relationship: many_to_one
    sql_on: ${company_revenue.company_id} = ${companies.company_id} ;;
  }

  join: heap_users {
    type: inner
    relationship: many_to_many
    sql_on: ${company_revenue.company_id} = ${heap_users.company_id} ;;
  }

  join: daily_active_companies {
    type: inner
    relationship: many_to_many
    sql_on: ${company_revenue.company_id} = ${daily_active_companies.company_id} ;;
  }

  join: daily_active_users {
    type: inner
    relationship: many_to_many
    sql_on: ${heap_users.company_id} = ${daily_active_users.user_id} ;;
  }

  # join: sessions {
  #   type: left_outer
  #   relationship: one_to_many
  #   sql_on: ${heap_users.user_id} = ${sessions.user_id} ;;
  # }
}

# - - - - Pattern Matching - - - - -
# explore: usage_patterns { --MB comment out 10-10-23 due to inactivity
#   case_sensitive: no
#   group_label: "Heap - Patterns"

#   join: companies {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${usage_patterns.company_id} = ${companies.company_id} ;;
#   }

#   join: t3_companies {
#     relationship: one_to_one
#     type: left_outer
#     sql_on: ${companies.company_id} = ${t3_companies.company_id} ;;
#   }

#   join: heap_users {
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${companies.company_id} = ${heap_users.company_id} ;;
#   }

#   join: sessions {
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${heap_users.user_id} = ${sessions.user_id} ;;
#   }
# }
