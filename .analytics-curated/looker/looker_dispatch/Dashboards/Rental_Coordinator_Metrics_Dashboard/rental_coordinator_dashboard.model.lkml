connection: "es_snowflake_analytics"

include: "/Dashboards/Rental_Coordinator_Metrics_Dashboard/views/*.view.lkml"
include: "/views/es_warehouse/invoices.view.lkml"
include: "/views/es_warehouse/companies.view.lkml"
include: "/views/es_warehouse/orders.view.lkml"
include: "/views/es_warehouse/users.view.lkml"
include: "/views/analytics/market_region_xwalk.view.lkml"
include: "/views/es_warehouse/rentals.view.lkml"
include: "/views/es_warehouse/line_items.view.lkml"
include: "/views/analytics/v_line_items.view.lkml"
include: "/views/es_warehouse/rental_statuses.view.lkml"


explore: rental_coordinator_metrics {
  view_label: "Users"
  from: users
  sql_always_where: ${rental_coordinator_metrics.company_id} = 1854 ;;

  join: national_account_coordinators {
    # NAC spreadsheet: https://docs.google.com/spreadsheets/d/1dZnMXgWN0fIUT2JvjSmABw-B64Zd3VJScoI5zC0cuoE/edit#gid=0
    type: left_outer # if you inner join this you'll only get NACs in your results
    relationship: many_to_one
    sql_on: ${rental_coordinator_metrics.user_id} = ${national_account_coordinators.user_id} ;;
  }

  join: orders_and_rentals_by_user {
    type: inner
    relationship: one_to_many
    sql_on: ${rental_coordinator_metrics.user_id} = ${orders_and_rentals_by_user.user_id} ;;
  }

  join: rentals_by_user {
    type: inner
    relationship: one_to_one
    sql_on: ${rental_coordinator_metrics.user_id} = ${rentals_by_user.user_id} ;;
  }

  join: rentals {
    type: inner
    relationship: one_to_one
    sql_on: ${rentals_by_user.rental_id} = ${rentals.rental_id} ;;
  }

  join: rental_statuses {
    type: inner
    relationship: many_to_one
    sql_on: ${rentals.rental_status_id} = ${rental_statuses.rental_status_id} ;;
  }

  join: rentals_to_line_items {
    from: v_line_items
    type: left_outer
    relationship: one_to_many
    sql_on: ${rentals.rental_id} = ${rentals_to_line_items.rental_id} ;;
  }

  join: orders_by_user {
    type: inner
    relationship: one_to_many
    sql_on: ${rental_coordinator_metrics.user_id} = ${orders_by_user.user_id} ;;
  }

  join: orders {
    type: inner
    relationship: many_to_one
    sql_on: ${orders_by_user.order_id} = ${orders.order_id} ;;
  }

  join: invoices {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rentals_to_line_items.invoice_id} = ${invoices.invoice_id};;
  }

  join: invoice_market {
    from: market_region_xwalk
    type: inner
    relationship: many_to_one
    sql_on: ${invoices.market_id} = ${invoice_market.market_id} ;;
  }

  join: invoice_company {
    from: companies
    type: inner
    relationship: many_to_one
    sql_on: ${invoices.company_id} = ${invoice_company.company_id} ;;
  }

  join: order_user {
    from: users
    type: inner
    relationship: one_to_one
    sql_on: ${orders.user_id} = ${order_user.user_id} ;;
  }

  join: order_company {
    from: companies
    type: inner
    relationship: many_to_one
    sql_on: ${order_user.company_id} = ${order_company.company_id} ;;
  }


}

# explore: rental_coordinator_timeline { --MB comment out 10-10-23 due to inactivity
#   from: dim_date
#   view_label: "Date"

#   join: orders_by_user {
#     type: inner
#     relationship: one_to_many
#     sql_on: ${rental_coordinator_timeline.date} = ${orders_by_user.date_created_date} ;;
#   }

#   join: orders {
#     type: inner
#     relationship: one_to_one
#     sql_on: ${orders_by_user.order_id} = ${orders.order_id} ;;
#   }

#   join: rentals_by_user {
#     type: inner
#     relationship: one_to_many
#     sql_on: ${rental_coordinator_timeline.date} = ${rentals_by_user.created_date} ;;
#   }

#   join: rentals {
#     type: inner
#     relationship: one_to_one
#     sql_on: ${rentals_by_user.rental_id} = ${rentals.rental_id} ;;
#   }

# }
