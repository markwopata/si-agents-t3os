connection: "reportingc_warehouse"

include: "/views/platform_gold/fact_rental_metrics.view.lkml"
include: "/views/platform_gold/fact_invoice_line_allocations.view.lkml"
include: "/views/platform_gold/dim_companies.view.lkml"
include: "/views/platform_gold/dim_rentals.view.lkml"
include: "/views/platform_gold/dim_assets.view.lkml"
include: "/views/platform_gold/dim_markets.view.lkml"
include: "/views/platform_gold/dim_jobs.view.lkml"
include: "/views/platform_gold/dim_dates.view.lkml"
include: "/views/platform_gold/dim_locations.view.lkml"
include: "/views/platform_gold/dim_users.view.lkml"
include: "/views/platform_gold/primary_salesperson.view.lkml"
include: "/views/platform_gold/dim_purchase_orders.view.lkml"
include: "/views/platform_gold/dim_rental_statuses.view.lkml"
include: "/views/platform_gold/dim_parts.view.lkml"
include: "/views/platform_gold/dim_sub_renters.view.lkml"
include: "/views/budget_remaining_by_invoice.view.lkml"
include: "/views/equipment_classes.view.lkml"
include: "/views/rentals.view.lkml"
# include: "/views/states.view.lkml"  # Removed due to broken references in locations view
# Legacy views removed - using dimensional views instead

# Data refresh trigger based on fact table updates
datagroup: rental_metrics_update {
  sql_trigger: select max(FACT_RENTAL_METRICS_RECORDTIMESTAMP) from PLATFORM.GOLD.FACT_RENTAL_METRICS ;;
  max_cache_age: "2 hours"
  description: "Updates when new rental metrics are processed"
}

explore: rental_metrics_v2 {
  from: fact_rental_metrics
  group_label: "Rentals V2"
  label: "Rental Metrics (Dimensional)"
  case_sensitive: no
  persist_with: rental_metrics_update

  # SECURITY: Only show rentals for user's company
  sql_always_where:
    ${dim_companies.company_id} = {{ _user_attributes['company_id'] }} ;;

  # CORE DIMENSION JOINS
  join: dim_rentals {
    type: left_outer
    relationship: one_to_one
    sql_on: ${rental_metrics_v2.rental_key} = ${dim_rentals.rental_key} ;;
  }

  join: dim_rental_statuses {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rental_metrics_v2.rental_status_key} = ${dim_rental_statuses.rental_status_key} ;;
    fields: [
      rental_status_name, rental_status_description, rental_status_active,
      rental_status_id, rental_status_source, count
    ]
  }

  join: dim_companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rental_metrics_v2.customer_company_key} = ${dim_companies.company_key} ;;
    fields: [
      company_name, company_id, company_timezone, company_credit_limit,
      company_has_fleet, company_has_fleet_cam, company_do_not_rent,
      company_has_msa, company_is_national_account, company_net_terms,
      company_preferences_bad_debt, company_preferences_cycle_billing_only,
      company_preferences_disable_monthly_statements, company_preferences_general_services_administration,
      company_preferences_internal_company, company_preferences_in_bankruptcy,
      company_preferences_is_paperless_billing, company_preferences_legal_audit,
      company_preferences_managed_billing, company_preferences_is_national_account,
      company_preferences_primary_billing_contact_user_id, company_preferences_rental_billing_cycle_strategy,
      count, total_credit_limit
    ]
  }

  join: market_company {
    from: dim_companies
    type: left_outer
    relationship: many_to_one
    sql_on: ${rental_metrics_v2.market_company_key} = ${market_company.company_key} ;;
    fields: [company_name, company_id, company_timezone]
  }

  join: dim_assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rental_metrics_v2.asset_key} = ${dim_assets.asset_key} ;;
  }

  join: dim_parts {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rental_metrics_v2.part_key} = ${dim_parts.part_key} ;;
    fields: [part_type_description, part_name, part_number, part_category_name]
  }

  join: dim_users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rental_metrics_v2.user_key} = ${dim_users.user_key} ;;
  }

  join: primary_salesperson {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rental_metrics_v2.primary_salesperson_user_key} = ${primary_salesperson.user_key} ;;
    view_label: "Primary Salesperson"
    fields: [user_full_name, user_email, user_id]
  }

  join: dim_sub_renters {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rental_metrics_v2.sub_renter_key} = ${dim_sub_renters.sub_renter_key} ;;
    fields: [
      sub_renter_id, sub_renter_company_name, sub_renter_ordered_by_name
    ]
  }

  # DATE DIMENSION JOINS - only expose dt_date to prevent redefinition errors
  join: rental_start_date {
    from: dim_dates
    type: left_outer
    relationship: many_to_one
    sql_on: ${rental_metrics_v2.rental_start_date_key} = ${rental_start_date.date_key} ;;
    fields: [dt_date]
  }

  join: rental_end_date {
    from: dim_dates
    type: left_outer
    relationship: many_to_one
    sql_on: ${rental_metrics_v2.rental_end_date_key} = ${rental_end_date.date_key} ;;
    fields: [dt_date]
  }

  join: next_cycle_date {
    from: dim_dates
    type: left_outer
    relationship: many_to_one
    sql_on: ${rental_metrics_v2.next_cycle_date_key} = ${next_cycle_date.date_key} ;;
    fields: [dt_date]
  }

  join: scheduled_drop_off_delivery_date {
    from: dim_dates
    type: left_outer
    relationship: many_to_one
    sql_on: ${rental_metrics_v2.scheduled_drop_off_delivery_date_key} = ${scheduled_drop_off_delivery_date.date_key} ;;
    fields: [dt_date]
  }

  # ADDITIONAL DIMENSIONS (if needed)
  join: dim_markets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rental_metrics_v2.market_key} = ${dim_markets.market_key} ;;
  }

  join: dim_jobs {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rental_metrics_v2.job_key} = ${dim_jobs.job_key} ;;
  }

  join: dim_locations {
    from: dim_locations
    type: left_outer
    relationship: many_to_one
    sql_on: ${rental_metrics_v2.location_key} = ${dim_locations.location_key} ;;
  }

  join: dim_purchase_orders {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rental_metrics_v2.purchase_order_key} = ${dim_purchase_orders.purchase_order_key} ;;
  }
}

# INVOICE ALLOCATION / SPEND ANALYSIS EXPLORE
# Replaces legacy rentals_spend_by with dimensional model approach
explore: rental_spend_allocation {
  from: fact_invoice_line_allocations
  group_label: "Rentals V2"
  label: "Rental Spend Analysis (Dimensional)"
  description: "Invoice spend analysis by Jobsite, Purchase Order, and Equipment Class with budget tracking"
  case_sensitive: no

  # SECURITY: Only show invoices for user's company
  sql_always_where:
    ${rental_spend_allocation.company_id} = {{ _user_attributes['company_id'] }}
        AND {% condition date_filter %} ${billing_approved_date} {% endcondition %} ;;

  # CORE DIMENSION JOINS
  join: dim_locations {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rental_spend_allocation.location_key} = ${dim_locations.location_key} ;;
    fields: [
      location_nickname, location_street_1, location_city,
      location_zip_code, location_id
    ]
  }

  join: dim_purchase_orders {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rental_spend_allocation.purchase_order_key} = ${dim_purchase_orders.purchase_order_key} ;;
    fields: [
      purchase_order_name, purchase_order_id, purchase_order_active,
      purchase_order_budget_amount, purchase_order_start_date_date
    ]
  }

  join: dim_assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rental_spend_allocation.asset_key} = ${dim_assets.asset_key} ;;
    fields: [
      asset_custom_name, asset_id, asset_class, asset_make_model,
      asset_category
    ]
  }

  join: dim_rentals {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rental_spend_allocation.rental_key} = ${dim_rentals.rental_key} ;;
    fields: [rental_id, rental_source]
  }

  join: dim_companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rental_spend_allocation.company_id} = ${dim_companies.company_id} ;;
    fields: [company_name, company_id, company_timezone]
  }

  # Equipment Class join (via rentals)
  join: rentals {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rental_spend_allocation.rental_id} = ${rentals.rental_id} ;;
    fields: []  # Only used for equipment_class join
  }

  join: equipment_classes {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rentals.equipment_class_id} = ${equipment_classes.equipment_class_id} ;;
    fields: [name, equipment_class_id]
  }

  # BUDGET TRACKING JOIN
  join: budget_remaining_by_invoice {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rental_spend_allocation.invoice_id} = ${budget_remaining_by_invoice.invoice_id}
      AND ${dim_purchase_orders.purchase_order_name} = ${budget_remaining_by_invoice.name} ;;
    fields: [
      budget_amount, budget_remaining, pcnt_budget_remaining
    ]
  }

  # RUNTIME HOURS JOIN (for utilization metrics)
  join: rental_metrics_for_runtime {
    from: fact_rental_metrics
    type: left_outer
    relationship: many_to_one
    sql_on: ${rental_spend_allocation.rental_key} = ${rental_metrics_for_runtime.rental_key} ;;
    fields: [run_time_hours]
  }

}
