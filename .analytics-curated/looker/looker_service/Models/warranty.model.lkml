connection: "es_snowflake"

include: "/views/custom_sql/retool_warranty_live_stats.view.lkml"
include: "/views/custom_sql/warranty_dashboards/warranty_work_orders_and_claims.view.lkml"
include: "/views/FLEET_OPTIMIZATION/dim_invoices_fleet_opt.view.lkml"
include: "/views/FLEET_OPTIMIZATION/fact_warranty_credits.view.lkml"
include: "/views/FLEET_OPTIMIZATION/dim_companies_fleet_opt.view.lkml"
include: "/views/FLEET_OPTIMIZATION/dim_dates_fleet_opt.view.lkml"
include: "/views/FLEET_OPTIMIZATION/dim_users_fleet_opt.view.lkml"
include: "/views/FLEET_OPTIMIZATION/dim_employee_title_pit.view.lkml"
include: "/views/FLEET_OPTIMIZATION/dim_markets_fleet_opt.view.lkml"
include: "/views/FLEET_OPTIMIZATION/dim_assets_fleet_opt.view.lkml"
include: "/views/ANALYTICS/WARRANTIES/retool_claims.view.lkml"
include: "/views/custom_sql/warranty_dashboards/monthly_annualized_claims.view.lkml"
include: "/views/custom_sql/warranty_admin_lookup_wo_remainder.view.lkml"
include: "/views/custom_sql/warranty_dashboards/warranty_missed_opp_flipped.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/ANALYTICS/plexi_periods.view.lkml"
include: "/views/be_market_start_month.view.lkml"
include: "/views/WORK_ORDERS/work_orders.view.lkml"

explore: warranty_admin_lookup_wo_remainder {
  persist_for: "24 hours"
}

explore: warranty_missed_opp_trending_be_tile_v2 {
  from: warranty_missed_opp_flipped
  case_sensitive: no
  sql_always_where: ${market_region_xwalk.District_Region_Market_Access}
  or 'developer' = {{ _user_attributes['department'] }}
  or 'admin' = {{ _user_attributes['department'] }}
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\'"}}') = 'jabbok@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\'"}}') = 'lacy.harris@equipmentshare.com' ;;

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: ${warranty_missed_opp_trending_be_tile_v2.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: plexi_periods {
    type: inner
    relationship: many_to_one
    sql_on: ${warranty_missed_opp_trending_be_tile_v2.month} = ${plexi_periods.date} ;;
  }

  join: be_market_start_month {
    type: left_outer
    relationship: many_to_one
    sql_on: ${warranty_missed_opp_trending_be_tile_v2.month} = ${be_market_start_month.market_id} ;;
  }

  join: work_orders {
    type: inner
    relationship: many_to_one
    sql_on: ${warranty_missed_opp_trending_be_tile_v2.work_order_id} = ${work_orders.work_order_id} ;;
  }

  join: dim_assets_fleet_opt {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_orders.asset_id} = ${dim_assets_fleet_opt.asset_id} ;;
  }
}

explore: retool_warranty_live_stats {
  case_sensitive: no
}

explore: retool_warranty_live_stats_lookup_tool {
  case_sensitive: no
}

explore: warranty_work_orders_and_claims {
  label: "Warranty Main"
  description: "Base Explore for Warranty Dashboards as of the July 2025 Rebuild"
  sql_always_where:
  (
    ${dim_invoices_fleet_opt.invoice_billing_approved} = TRUE
    and ${dim_invoices_fleet_opt.invoice_credit_note_indicates_error} = FALSE
  ) or ${warranty_work_orders_and_claims.invoice_id} is null ;;

  join: dim_invoices_fleet_opt {
    type: left_outer
    relationship: one_to_one
    sql_on: ${warranty_work_orders_and_claims.invoice_id} = ${dim_invoices_fleet_opt.invoice_id} ;;
  }

  join: fact_warranty_credits {
    type: left_outer
    relationship: one_to_one
    sql_on: ${fact_warranty_credits.warranty_credits_invoice_key} = ${dim_invoices_fleet_opt.invoice_key} ;;
  }

  join: dim_companies_fleet_opt {
    type: left_outer
    relationship: one_to_many
    sql_on: ${dim_companies_fleet_opt.company_key} = ${dim_invoices_fleet_opt.invoice_company_key} ;;
  }

  join: dim_dates_fleet_opt {
    type: left_outer
    relationship: one_to_many
    sql_on: ${dim_dates_fleet_opt.dt_key} = ${dim_invoices_fleet_opt.invoice_date_key} ;;
  }

  join: dim_paid_dates {
    from: dim_dates_fleet_opt
    type: left_outer
    relationship: one_to_many
    sql_on: ${dim_paid_dates.dt_key} = ${dim_invoices_fleet_opt.invoice_paid_date_key} ;;
  }

  join: dim_users_fleet_opt {
    type: left_outer
    relationship: one_to_many
    sql_on: ${dim_users_fleet_opt.user_key} = ${dim_invoices_fleet_opt.invoice_creator_user_key} ;;
  }

  join: dim_employee_title_pit {
    type: left_outer
    relationship: one_to_many
    sql_on: ${dim_employee_title_pit.employee_id} = ${dim_users_fleet_opt.user_employee_id}
      and ${dim_dates_fleet_opt.dt_date} >= ${dim_employee_title_pit.title_start_window_date}
      and ${dim_dates_fleet_opt.dt_date} <= ${dim_employee_title_pit.title_end_window_date} ;;
  }

  join: dim_markets_fleet_opt {
    type: left_outer
    relationship: one_to_many
    sql_on: ${dim_markets_fleet_opt.market_id} = ${warranty_work_orders_and_claims.branch_id};; #Work Order market
  }

  join: dim_assets_fleet_opt {
    type: left_outer
    relationship: one_to_many
    sql_on: ${dim_assets_fleet_opt.asset_id} = ${warranty_work_orders_and_claims.asset_id} ;;
  }

  join: retool_claims {
    type: left_outer
    relationship: one_to_one
    sql_on: trim(${retool_claims.invoice_no}) = ${dim_invoices_fleet_opt.invoice_no} ;;
  }
#child invoices
  join: dim_child_invoice_fleet_opt {
    from: dim_invoices_fleet_opt
    type: left_outer
    relationship: one_to_one
    sql_on: ${dim_child_invoice_fleet_opt.invoice_no} = trim(${retool_claims.child_invoice_no}) ;;
  }

  join: fact_child_warranty_credits {
    from: fact_warranty_credits
    type: left_outer
    relationship: one_to_one
    sql_on: ${fact_child_warranty_credits.warranty_credits_invoice_key} = ${dim_child_invoice_fleet_opt.invoice_key} ;;
  }
}

explore: monthly_annualized_claims {
  case_sensitive: no
  description: "Using New Warranty OEC Code as of July 2025. At the market - make level of detail."
}

explore: location_filter_options {
  from: dim_markets_fleet_opt
}

explore: billed_company_filter_options {
  from: dim_companies_fleet_opt
}

explore: asset_related_filter_options {
  from: dim_assets_fleet_opt
}

explore: warranty_users {
  from: dim_users_fleet_opt
  case_sensitive: no
  sql_always_where: ${dim_invoices_fleet_opt.invoice_is_warranty_invoice} ;;

  join: dim_invoices_fleet_opt {
    type: left_outer
    relationship: many_to_one
    sql_on: ${warranty_users.user_key} = ${dim_invoices_fleet_opt.invoice_creator_user_key};;
  }
}

explore: invoices_credited_as_error { #Made this as a temporary solution for a tile on claim details for invoices credited as errors. Will be replaced when warranty moves to the team project - TA - 12/23/25
  from: dim_invoices_fleet_opt
  description: "Temporary solution for a tile on claim details for invoices credited as errors"
  sql_always_where: ${invoice_credit_note_indicates_error} and (${fact_warranty_credits.warranty_credits_invoice_key} is not null or ${retool_claims.invoice_no} is not null) ;;
  case_sensitive: no

  join: fact_warranty_credits {
    type: left_outer
    relationship: one_to_one
    sql_on: ${fact_warranty_credits.warranty_credits_invoice_key} = ${invoices_credited_as_error.invoice_key} ;;
  }

  join: retool_claims {
    type: left_outer
    relationship: one_to_one
    sql_on: trim(${retool_claims.invoice_no}) = ${invoices_credited_as_error.invoice_no} and ${retool_claims.deleted} = false;;
  }

  join: warranty_work_orders_and_claims { #Not using this for anything just joining for dependencies in fact warranty credits. Need to make sure this is accounted for in new project - TA
    type: left_outer
    relationship: one_to_one
    sql_on: ${warranty_work_orders_and_claims.invoice_id} = ${invoices_credited_as_error.invoice_id};;
  }
}
