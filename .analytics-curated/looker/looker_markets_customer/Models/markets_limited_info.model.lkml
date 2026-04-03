connection: "es_snowflake_c_analytics"

include: "/views/custom_sql/market_rental_revenue_history.view.lkml"
include: "/views/custom_sql/salesperson_to_market.view.lkml"
include: "/views/custom_sql/market_financial_utilization.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/ANALYTICS/market_goals.view.lkml"
include: "/views/ANALYTICS/new_account_competition.view.lkml"
include: "/views/ANALYTICS/national_accounts.view.lkml"
include: "/views/ANALYTICS/region_market_comparison_xwalk.view.lkml"
include: "/views/ES_WAREHOUSE/orders.view.lkml"
include: "/views/ES_WAREHOUSE/markets.view.lkml"
include: "/views/ES_WAREHOUSE/invoices.view.lkml"
include: "/views/ES_WAREHOUSE/line_items.view.lkml"
include: "/views/ES_WAREHOUSE/users.view.lkml"
include: "/views/ES_WAREHOUSE/companies.view.lkml"
include: "/views/ES_WAREHOUSE/order_salespersons.view.lkml"
include: "/views/ES_WAREHOUSE/line_item_types.view.lkml"
include: "/views/custom_sql/created_vs_billed_revenue.view.lkml"
include: "/views/custom_sql/markets_datadump.view.lkml"
include: "/views/custom_sql/region_datadump.view.lkml"
include: "/views/custom_sql/district_datadump.view.lkml"

# datagroup: 6AM_update {
#   sql_trigger: SELECT FLOOR((DATE_PART('EPOCH_SECOND', CURRENT_TIMESTAMP) - 60*60*12)/(60*60*24)) ;;
#   max_cache_age: "24 hours"
# }

# datagroup: Every_Hour_Update {
#   sql_trigger: SELECT HOUR(CURRENT_TIME()) ;;
#   max_cache_age: "1 hour"
# }

# datagroup: Every_Two_Hours_Update {
#   sql_trigger: SELECT FLOOR(DATE_PART('EPOCH_SECOND', CURRENT_TIMESTAMP) / (2*60*60)) ;;
#   max_cache_age: "2 hours"
# }

# datagroup: Every_5_Min_Update {
#   sql_trigger: SELECT DATE_PART('minute', CURRENT_TIMESTAMP) ;;
#   max_cache_age: "5 minutes"
# }

#Markets Overview - Market Rental Revenue History
# explore: market_rental_revenue_history {
#   group_label: "Markets Overview"
#   label: "Market Rental Revenue History"
#   case_sensitive: no
#   sql_always_where: ${market_region_xwalk.District_Region_Market_Access} ;;
#
#   join: market_region_xwalk {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${market_region_xwalk.market_name} = ${market_rental_revenue_history.market_name} ;;
#   }
# }

#Markets Overview - Market Information by Invoice Created Date
explore: Markets_Overview {
  from: orders
  label: "Market Information by Invoice Created Date"
  group_label: "Markets Overview"
  case_sensitive: no
  sql_always_where: ${market_region_xwalk.District_Region_Market_Access}  ;;
  # and ${invoices.invoice_id} <> 724307 --removing the call for this invoice since it was four years ago and no reporting at this time goes back that far

  join: order_salespersons {
    type: left_outer
    relationship: many_to_one
    sql_on: ${order_salespersons.order_id} = ${Markets_Overview.order_id} ;;
  }

  join: markets {
    type: inner
    relationship: one_to_many
    sql_on: ${markets.market_id} = ${Markets_Overview.market_id};;
  }

  join: invoices {
    type: inner
    relationship: one_to_many
    sql_on: ${invoices.order_id} = ${Markets_Overview.order_id};;
  }

  join: line_items {
    type: inner
    relationship: many_to_many
    sql_on: ${line_items.invoice_id} = ${invoices.invoice_id} ;;
  }

  join: line_item_types {
    type: inner
    relationship: many_to_one
    sql_on: ${line_items.line_item_type_id} = ${line_item_types.line_item_type_id};;
  }

  join: market_goals {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_goals.market_id} = ${markets.market_id} AND ${market_goals.months_month} = ${line_items.gl_date_created_month} and ${market_goals.end_month} is null;;
  }

  join: market_financial_utilization {
    type: left_outer
    relationship: many_to_one
    sql_on: ${markets.market_id} = ${market_financial_utilization.marketid} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: one_to_one
    sql_on: ${markets.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: region_market_comparison_xwalk {
    type: left_outer
    relationship:  many_to_one
    sql_on: ${market_region_xwalk.region} = ${region_market_comparison_xwalk.region};;
  }

  join: new_account_competition {
    type: left_outer
    relationship: many_to_one
    sql_on: ${markets.market_id} = ${new_account_competition.market_id} ;;
  }

  # join: collector_mktassignments {
  #   view_label: "Collector Market Assignments"
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${collector_mktassignments.market_id} = ${markets.market_id} ;;
  # }

  # join: rateachievement_points {
  #   type: left_outer
  #   relationship: many_to_many
  #   sql_on: ${rateachievement_points.salesperson_user_id} = ${Markets_Overview.salesperson_user_id} and ${line_items.invoice_id} = ${rateachievement_points.invoice_id} ;;
  # }

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${users.user_id} = coalesce(${order_salespersons.user_id},${Markets_Overview.salesperson_user_id}) ;;
  }

  join: national_account_reps {
    from: national_accounts
    type: left_outer
    relationship: one_to_one
    sql_on: ${users.Full_Name_with_ID_national} = ${national_account_reps.full_name_with_id} ;;
  }

  join: salesperson_to_market {
    type: left_outer
    relationship: one_to_one
    sql_on: ${users.user_id} = ${salesperson_to_market.salesperson_user_id} ;;
  }

  join: customer_users {
    from: users
    type: left_outer
    relationship: many_to_one
    sql_on: ${Markets_Overview.user_id} = ${users.user_id} ;;
  }

  # join: collector_customer_assignments {
  #   type: left_outer
  #   relationship: one_to_one
  #   sql_on: ${markets.market_id}=${collector_customer_assignments.final_market_id} ;;
  # }
}

explore: Markets_Overview_by_Approved_Date {
  from: orders
  label: "Market Information by Invoice Approved Date"
  group_label: "Markets Overview"
  case_sensitive: no
  sql_always_where: ${market_region_xwalk.District_Region_Market_Access} ;;
  # and ${invoices.invoice_id} <> 724307 --removing the call for this invoice since it was four years ago and no reporting at this time goes back that far

  # join: markets {
  #   type: inner
  #   relationship: one_to_many
  #   sql_on: ${markets.market_id} = ${Markets_Overview_by_Approved_Date.market_id};;
  # }


##removing from explore as this information is not needed nor used and causing revenue to not be displayed -JW 2/22/23
  # join: order_salespersons {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${order_salespersons.order_id} = ${Markets_Overview_by_Approved_Date.order_id} ;;
  # }

  join: invoices {
    type: inner
    relationship: one_to_many
    sql_on: ${invoices.order_id} = ${Markets_Overview_by_Approved_Date.order_id};;
  }

  join: line_items {
    type: inner
    relationship: many_to_many
    sql_on: ${line_items.invoice_id} = ${invoices.invoice_id} ;;
  }

  join: line_item_types {
    type: inner
    relationship: many_to_one
    sql_on: ${line_items.line_item_type_id} = ${line_item_types.line_item_type_id};;
  }


  join: market_region_xwalk {
    type: left_outer
    relationship: one_to_many
    sql_on: ${invoices.ship_from_branch_id} = ${market_region_xwalk.market_id} ;;
  }

  join: market_goals {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_goals.market_id} = ${market_region_xwalk.market_id} AND ${market_goals.months_month} = ${line_items.gl_billing_approved_date_month} and ${market_goals.end_month} is null ;;
  }

  # join: looker_market_goals {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${looker_market_goals.market_id} = ${market_region_xwalk.market_id} AND ${looker_market_goals.month_month} = ${invoices.billing_approved_month} ;;
  # }

  # join: collector_mktassignments {
  #   view_label: "Collector Market Assignments"
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${collector_mktassignments.market_id} = ${Markets_Overview_by_Approved_Date.market_id} ;;
  # }

  # join: rateachievement_points {
  #   type: left_outer
  #   relationship: many_to_many
  #   sql_on: ${rateachievement_points.salesperson_user_id} = ${Markets_Overview_by_Approved_Date.salesperson_user_id} and ${line_items.invoice_id} = ${rateachievement_points.invoice_id} ;;
  # }

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${users.user_id} = ${Markets_Overview_by_Approved_Date.salesperson_user_id} ;;
  }

  join: national_account_reps {
    from: national_accounts
    type: left_outer
    relationship: one_to_one
    sql_on: ${users.Full_Name_with_ID_national} = ${national_account_reps.full_name_with_id} ;;
  }

  join: salesperson_to_market {
    type: left_outer
    relationship: one_to_one
    sql_on: ${users.user_id} = ${salesperson_to_market.salesperson_user_id} ;;
  }

  join: customer_users {
    from: users
    type: left_outer
    relationship: many_to_one
    sql_on: ${Markets_Overview_by_Approved_Date.user_id} = ${users.user_id} ;;
  }


  # join: collector_customer_assignments {
  #   type: left_outer
  #   relationship: one_to_one
  #   sql_on: ${market_region_xwalk.market_id}=${collector_customer_assignments.final_market_id} ;;
  # }

  # join: markets {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${collector_customer_assignments.final_market_id}  =${markets.market_id};;
  # }
}


explore: invoices {
  label: "Market Ancillary Revenue"
  group_label: "Markets Overview"
  case_sensitive: no
  sql_always_where: ${market_region_xwalk.District_Region_Market_Access} ;;
  # and ${invoices.invoice_id} <> 724307 --removing the call for this invoice since it was four years ago and no reporting at this time goes back that far

  join: line_items {
    type: left_outer
    relationship: one_to_many
    sql_on: ${invoices.invoice_id} = ${line_items.invoice_id} ;;
  }

  join: line_item_types {
    type: inner
    relationship: many_to_one
    sql_on: ${line_items.line_item_type_id} = ${line_item_types.line_item_type_id};;
  }

  join: orders {
    type: left_outer
    relationship: one_to_many
    sql_on: ${invoices.order_id}=${orders.order_id} ;;
  }

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders.salesperson_user_id} = ${users.user_id} ;;
  }

  join: customer {
    from: users
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders.user_id} = ${customer.user_id} ;;
  }

  join: companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${customer.company_id} = ${companies.company_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: coalesce(${line_items.branch_id}, ${orders.market_id}) =  ${market_region_xwalk.market_id};;
  }

  join: created_vs_billed_revenue {
    type: inner
    relationship: one_to_one
    sql_on: ${line_items.line_item_id} = ${created_vs_billed_revenue.line_item_id} ;;
  }
}

explore: markets_datadump {
  group_label: "Export"
}

explore: region_datadump {
  group_label: "Export"
}

explore: district_datadump {
  group_label: "Export"
}
