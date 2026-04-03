connection: "es_snowflake_analytics"
include: "/Dashboards/Rates/Deal_Rates/GPM_by_district_eq_class.view.lkml"
include: "/views/custom_sql/salesperson_company_activity_feed.view.lkml"
include: "/views/custom_sql/salesperson_qtd_revenue_ranking.view.lkml"
include: "/views/custom_sql/salesperson_to_market.view.lkml"
include: "/views/custom_sql/company_salesperson_history.view.lkml"
include: "/views/custom_sql/companies_actively_renting_by_sales_rep_past_90.view.lkml"
include: "/views/custom_sql/market_region_sales_manager.view.lkml"
include: "/views/custom_sql/sales_rep_main_market.view.lkml"
include: "/views/custom_sql/command_audit.view.lkml"
include: "/views/custom_sql/asset_purchase_history_facts.view.lkml"
include: "/views/custom_sql/line_items_dates_combined.view.lkml"
#include: "/views/custom_sql/discount_competition.view.lkml"
include: "/views/custom_sql/admin_book_rates.view.lkml"
include: "/views/custom_sql/admin_bench_rates.view.lkml"
include: "/views/custom_sql/admin_floor_rates.view.lkml"
include: "/views/ES_WAREHOUSE/assets.view.lkml"
include: "/views/ES_WAREHOUSE/orders.view.lkml"
include: "/views/ES_WAREHOUSE/markets.view.lkml"
include: "/views/ES_WAREHOUSE/rentals.view.lkml"
include: "/views/ES_WAREHOUSE/invoices.view.lkml"
include: "/views/ES_WAREHOUSE/users.view.lkml"
include: "/views/ES_WAREHOUSE/line_items.view.lkml"
include: "/views/ES_WAREHOUSE/locations.view.lkml"
include: "/views/ES_WAREHOUSE/net_terms.view.lkml"
include: "/views/ES_WAREHOUSE/companies.view.lkml"
include: "/views/ES_WAREHOUSE/asset_statuses.view.lkml"
include: "/views/ES_WAREHOUSE/asset_status_key_values.view.lkml"
include: "/views/ES_WAREHOUSE/order_salespersons.view.lkml"
include: "/views/ES_WAREHOUSE/company_erp_refs.view.lkml"
include: "/views/ES_WAREHOUSE/branch_rental_rates.view.lkml"
include: "/views/ES_WAREHOUSE/categories.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/ANALYTICS/national_accounts.view.lkml"
include: "/views/ANALYTICS/collector_customer_assignments.view.lkml"
include: "/views/ANALYTICS/market_region_salesperson.view.lkml"
#include: "/views/ANALYTICS/new_account_all_time.view.lkml"
include: "/views/ANALYTICS/rateachievement_rolling_28_days.view.lkml"
include: "/views/ANALYTICS/rateachievement_points.view.lkml"
#include: "/views/ANALYTICS/new_account_competition.view.lkml"
include: "/views/ANALYTICS/credit_app_master_list.view.lkml"
include: "/views/ANALYTICS/collector_mktassignments.view.lkml"
include: "/views/ANALYTICS/historical_utilization.view.lkml"
include: "/views/ANALYTICS/district_rate_adjustments.view.lkml"
include: "/views/ANALYTICS/markets_without_rates.view.lkml"
include: "/views/ANALYTICS/equipment_class_division_master.view.lkml"
#include: "/views/custom_sql/natl_rates_duplicates_and_missing.view.lkml"
include: "/views/ANALYTICS/district_discounts.view.lkml"
include: "/views/ES_WAREHOUSE/states.view.lkml"
include: "/views/ANALYTICS/disc_master.view.lkml"
include: "/views/ANALYTICS/employee_branch_ukg.view.lkml"
#include: "/views/ANALYTICS/paycor_employees_managers.view.lkml"
include: "/views/ANALYTICS/location_mapping.view.lkml"
include: "/views/ANALYTICS/market_region_salesperson.view.lkml"
#include: "/views/ANALYTICS/employee_branch_allocation.view.lkml"
include: "/views/ANALYTICS/financial_utilization.view.lkml"
include: "/views/ANALYTICS/equipment_classes_itl.view.lkml"
include: "/views/GS/hr_links_to_resumes.view.lkml"
include: "/views/GS/itl_master_list.view.lkml"
include: "/views/custom_sql/prospects_folders_v2.view.lkml"
# include: "/views/custom_sql/discount_leaderboard.view.lkml"
include: "/views/custom_sql/companies_revenue_last_90_days.view.lkml"
include: "/views/custom_sql/companies_revenue_last_30_days.view.lkml"
include: "/views/custom_sql/market_class_inventory_status_count.view.lkml"
include: "/views/ES_WAREHOUSE/rental_statuses.view.lkml"
include: "/views/ES_WAREHOUSE/equipment_classes_models_xref.view.lkml"
include: "/views/ES_WAREHOUSE/equipment_classes.view.lkml"
include: "/views/custom_sql/substitution_report.view.lkml"
include: "/views/custom_sql/equipment_classes_active.view.lkml"
include: "/views/ES_WAREHOUSE/admin_cycle.view.lkml"
include: "/views/ES_WAREHOUSE/remaining_rental_cost.view.lkml"
include: "/views/ES_WAREHOUSE/assets_aggregate.view.lkml"
include: "/views/ANALYTICS/prospects__mapping__v4.view.lkml"
include: "/views/ES_WAREHOUSE/sales_track_logins.view.lkml"
include: "/views/ANALYTICS/company_directory.view.lkml"
# include: "/views/custom_sql/conversion_competition_Q2_2022.view.lkml"
include: "/views/custom_sql/admin_rates_view.view.lkml"
include: "/views/custom_sql/secondary_sales_rep_revenue.view.lkml"
include: "/views/custom_sql/hr_greenhouse_link.view.lkml"
include: "/views/ANALYTICS/missing_rate_assignments.view.lkml"
include: "/views/custom_sql/rates_refresh.view.lkml"
include: "/views/custom_sql/actively_renting_past_90.view.lkml"
include: "/views/custom_sql/classes_missing_rates.view.lkml"
include: "/views/ANALYTICS/salesperson_admin_check.view.lkml"
include: "/views/custom_sql/forklift_contest.view.lkml"
include: "/views/custom_sql/forklift_contest_daily_on_rent.view.lkml"
include: "/views/custom_sql/proposed_rates_2024Q1.view.lkml"
include: "/views/custom_sql/salesperson_data_dump.view.lkml"
include: "/views/custom_sql/new_customers.view.lkml"
include: "/views/ANALYTICS/collection_targets_branch_district.view.lkml"
include: "/views/ANALYTICS/collection_targets_salesperson.view.lkml"
include: "/views/ANALYTICS/collection_targets_collector.view.lkml"
include: "/views/ANALYTICS/collections_actuals.view.lkml"
include: "/views/cash_collection_goals/salesrep_cash_collection_goal.view.lkml"
include: "/views/cash_collection_goals/salesrep_cash_collection_goal_drill.view.lkml"
include: "/views/cash_collection_goals/branch_cash_collection_goals.view.lkml"
include: "/views/cash_collection_goals/branch_cash_collection_goals_drill.view.lkml"
include: "/views/custom_sql/salesperson_customer_revenue.view.lkml"
include: "/views/ANALYTICS/sales_goals_rental.view.lkml"
include: "/views/ANALYTICS/sales_goals_rental_historic.view.lkml"
include: "/views/ANALYTICS/tam_monthly_rr_by_company.view.lkml"
include: "/views/ANALYTICS/discount_rates.view.lkml"
include: "/views/ANALYTICS/rate_regions.view.lkml"
include: "/national_accounts/national_account_companies.view.lkml"
include: "/views/custom_sql/bulk_rental_rates.view.lkml"
include: "/views/ES_WAREHOUSE/company_rental_rates.view.lkml"
include: "/views/ANALYTICS/company_rental_rates_extended.view.lkml"
include: "/views/ANALYTICS/bulk_rate_submissions.view.lkml"
include: "/views/ANALYTICS/rate_refresh_overrides.view.lkml"
include: "/views/ANALYTICS/rate_refresh_impact.view.lkml"
include: "/views/custom_sql/rate_refresh_updates.view.lkml"
include: "/views/ANALYTICS/discount_rates.view.lkml"
include: "/views/custom_sql/floor_rates_by_district.view.lkml"
include: "/views/custom_sql/time_utilization_district.view.lkml"
include: "/views/custom_sql/deal_rate_utilization.view.lkml"
include: "/views/custom_sql/temp_rate_refresh_dispatch_tool.view.lkml"
include: "/T3_tam_referral_program/tam_saas_referral_program.view.lkml"
include: "/views/ANALYTICS/t3_tam_attendance_tracker.view.lkml"

include: "/views/custom_sql/last_6_months_rental_rev.view.lkml"
include: "/views/custom_sql/last_6_months_rental_rev_agg.view.lkml"
include: "/views/custom_sql/equipmentshare_assets.view.lkml"
include: "/views/custom_sql/unavailable_oec_district.view.lkml"
include: "/views/custom_sql/rouse_time_utilization.view.lkml"
include: "/views/custom_sql/four_week_achieved_rate_by_district.view.lkml"
include: "/views/custom_sql/daily_time_utilization_district.view.lkml"
include: "/Dashboards/Rates/views/rolling_achieved_rates.view.lkml"
include: "/views/custom_sql/company_salesperson_relationship.view.lkml"
include: "/views/ANALYTICS/int_assets.view.lkml"

include: "/Dashboards/Market_Operations_1378/location_permissions/location_permissions.view.lkml"
# Salesperson - Salesperson Information
explore: orders {
  group_label: "Salesperson Information"
  label: "Salesperson"
  description: "Use this explore to investigate information relating to the Sales Team"
  view_name: orders
  case_sensitive: no
  sql_always_where:
  (
  ('salesperson' = {{ _user_attributes['department'] }} AND ${users.deleted} = 'No' AND ${users.email_address} ILIKE '{{ _user_attributes['email'] }}')
  )
  OR
  (
  ${users.user_id} = COALESCE(${order_salespersons.user_id}, ${orders.salesperson_user_id})
  AND
  ('salesperson' != {{ _user_attributes['department'] }}
  AND
  ('developer' = {{ _user_attributes['department'] }}
  OR 'god view' = {{ _user_attributes['department'] }}
  OR 'managers' = {{ _user_attributes['department'] }}
  OR 'collectors' = {{ _user_attributes['department'] }})
  )
  )
  OR
  ${market_region_salesperson.Salesperson_District_Region_Market_Access} ;;


    join: order_salespersons {
      type: left_outer
      relationship: one_to_many
      sql_on: ${orders.order_id} = ${order_salespersons.order_id} ;;
    }

    join: rentals {
      type:  inner
      relationship:  many_to_one
      sql_on: ${orders.order_id} = ${rentals.order_id} ;;
    }

    join: assets {
      type: inner
      relationship: many_to_one
      sql_on: ${rentals.asset_id} = ${assets.asset_id} ;;
    }

  join: asset_status_key_values {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_status_key_values.asset_id} = ${assets.asset_id} ;;
  }

  join: asset_purchase_history_facts_final {
    type:  left_outer
    relationship:  one_to_one
    sql_on: ${assets.asset_id} = ${asset_purchase_history_facts_final.asset_id} ;;
  }

  join: invoices {
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders.order_id} = ${invoices.order_id} ;;
  }

  join: collector_mktassignments {
    view_label: "Collector Market Assignments"
    type: left_outer
    relationship: many_to_one
    sql_on: ${collector_mktassignments.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: line_items {
    type: left_outer
    relationship: one_to_many
    sql_on: ${invoices.invoice_id} = ${line_items.invoice_id} ;;
  }

  join: users {
    view_label: "Salesperson"
    type: left_outer
    relationship: many_to_one
    sql_on: ${invoices.salesperson_user_id} = ${users.user_id} ;;
  }

  join: salesperson_customer_revenue {
    type: left_outer
    relationship: many_to_one
    sql_on: ${salesperson_customer_revenue.user_id} = ${users.user_id} ;;
  }

  join: employee_branch_ukg {
    type: left_outer
    relationship: many_to_one
    sql_on: TRIM(LOWER(${users.email_address})) = TRIM(LOWER(${employee_branch_ukg.employee_email})) ;;
  }

  join: location_mapping {
    type: left_outer
    relationship: many_to_one
    sql_on: TRIM(LOWER(${employee_branch_ukg.work_location}))=TRIM(LOWER(${location_mapping.loc_name})) ;;
  }

  join: disc_master {
    type: left_outer
    relationship: one_to_one
    sql_on: TRIM(LOWER(${users.email_address})) = TRIM(LOWER(${disc_master.email_address})) or trim(lower(${company_directory.personal_email})) = TRIM(LOWER(${disc_master.email_address})) ;;
  }

  join: hr_links_to_resumes {
    type: left_outer
    relationship: one_to_one
    sql_on: lower(trim(${users.email_address}))=lower(trim(${hr_links_to_resumes.sales_rep_email})) ;;
  }

  join: hr_greenhouse_link {
    type: left_outer
    relationship: one_to_one
    sql_on: lower(trim(${company_directory.employee_id}))=lower(trim(${hr_greenhouse_link.employee_id})) ;;
  }

  join: salesperson_to_market {
    type: left_outer
    relationship: one_to_one
    sql_on: ${users.user_id} = ${salesperson_to_market.salesperson_user_id} ;;
  }

  join: rateachievement_points {
    view_label: "Salesperson Metrics"
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders.salesperson_user_id} = ${rateachievement_points.salesperson_user_id} and ${line_items.invoice_id} = ${rateachievement_points.invoice_id}  ;;
  }

  join: rateachievement_rolling_28_days {
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders.salesperson_user_id} = ${rateachievement_rolling_28_days.salesperson_user_id} ;;
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

  join: new_customers {
    type:  left_outer
    relationship: many_to_one
    sql_on: ${customer.company_id} = ${new_customers.company_id} ;;
  }

  join: collector_customer_assignments {
    type: left_outer
    relationship: one_to_one
    sql_on: ${companies.company_id}=${collector_customer_assignments.company_id} ;;
  }

  join: net_terms {
    type: left_outer
    relationship: one_to_one
    sql_on: ${companies.net_terms_id} = ${net_terms.net_terms_id} ;;
  }

  join: market_region_salesperson {
    type: left_outer
    relationship: many_to_one
    sql_on: ${users.user_id} = ${market_region_salesperson.salesperson_user_id} ;;
  }

  join: market_region_sales_manager {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_salesperson.salesperson_user_id} = ${market_region_sales_manager.salesperson_user_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: one_to_one
    sql_on: ${orders.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: market_region_xwalk_salesperson_home_market {
    from:  market_region_xwalk
    type: left_outer
    relationship: one_to_one
    sql_on:  ${market_region_sales_manager.market_id} = ${market_region_xwalk_salesperson_home_market.market_id};;
  }

  join: national_accounts {
    type: left_outer
    relationship: many_to_one
    sql_on: ${companies.company_id} = ${national_accounts.company_id} ;;
  }

  join: credit_app_master_list {
    type: left_outer
    relationship: one_to_many
    sql_on: ${users.user_id} = ${credit_app_master_list.salesperson_user_id} ;;
  }

  join: national_account_reps {
    from: national_accounts
    type: left_outer
    relationship: one_to_one
    sql_on: ${users.Full_Name_with_ID_national} = ${national_account_reps.full_name_with_id} ;;
    }

  join: sales_rep_main_market {
    type: left_outer
    relationship: one_to_one
    sql_on: ${users.user_id} = ${sales_rep_main_market.salesperson_user_id} ;;
  }

  join: locations {
    type: left_outer
    relationship: one_to_one
    sql_on: ${companies.billing_location_id}=${locations.location_id} ;;
  }

  join: states {
    sql_table_name: ES_WAREHOUSE.PUBLIC.STATES ;;
    type: left_outer
    relationship: many_to_one
    sql_on: ${locations.state_id}=${states.state_id} ;;
  }

  join: command_audit {
    type: left_outer
    relationship: one_to_one
    sql_on: ${companies.company_id}=${command_audit.company_id} ;;
  }

  join: salesperson_qtd_revenue_ranking {
    type: left_outer
    relationship: one_to_one
    sql_on: ${users.user_id} = ${salesperson_qtd_revenue_ranking.salesperson_user_id} ;;
  }

  #join: employee_branch_allocation {
  #  type: left_outer
  #  relationship: one_to_many
  #  sql_on: trim(lower(${users.email_address}))=trim(lower(${employee_branch_allocation.employee_email})) ;;
  #}

  join: company_erp_refs {
    type: left_outer
    relationship: one_to_one
    sql_on: ${companies.company_id}=${company_erp_refs.company_id} ;;
  }

  join: company_directory {
    type: left_outer
    relationship: one_to_one
    sql_on: TRY_TO_NUMBER(${users.employee_id}) = ${company_directory.employee_id} ;;
  }

  #join: intaact_code_by_ee {
  #  type: left_outer
  #  relationship: one_to_one
  #  sql_on: ${company_directory.employee_id} = ${intaact_code_by_ee.employee_id} ;;
  #}

  join: salesperson_market_info {
    from: market_region_xwalk
    type: left_outer
    relationship: one_to_one
    sql_on: ${company_directory.market_id} = ${salesperson_market_info.market_id} ;;
  }

  }


# explore: discount_leaderboard { --MB comment out 10-10-23 due to inactivity
#   group_label: "Rate Achievement"
#   label: "Discount Leaderboard"
#   case_sensitive: no

#   join: users {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${discount_leaderboard.salesperson_user_id} = ${users.user_id} ;;
#   }

#   join: market_region_xwalk {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${discount_leaderboard.main_market} = ${market_region_xwalk.market_name} ;;
#   }
# }


#MB commented out 5/22/24 for unused explore
# #Rate Achievement - Rolling 28 Day Rate Achievement
# explore: rateachievement_rolling_28_days {
#   group_label: "Rate Achievement"
#   label: "Rolling 28 Day Rate Achievement"
#   case_sensitive: no
#   sql_always_where: (('collectors' = {{ _user_attributes['department'] }}
#   OR 'salesperson' = {{ _user_attributes['department'] }}
#   AND ${users.email_address} ILIKE '{{ _user_attributes['email'] }}' ))
#   OR ${market_region_xwalk.District_Region_Market_Access}
#   OR TRIM(LOWER('{{ _user_attributes['email'] }}')) = 'joyce.edwards@equipmentshare.com';;

#   join: users {
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${users.user_id} = ${rateachievement_rolling_28_days.salesperson_user_id} ;;
#   }

#   join: market_region_xwalk {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${rateachievement_rolling_28_days.market_id} = ${market_region_xwalk.market_id} ;;
#   }

#   join: national_account_reps {
#     from: national_accounts
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${users.Full_Name_with_ID_national} = ${national_account_reps.full_name_with_id} ;;
#   }
# }

#MB commented out 5/22/24 for unused explore
#Rate Achievement - Rolling 28 Day Rate Achievement with Open Access
# explore: rateachievement_rolling_28_days_open_access {
#   from: rateachievement_rolling_28_days
#   group_label: "Rate Achievement"
#   label: "Rolling 28 Day Rate Achievement with Open Access"
#   case_sensitive: no

#   join: users {
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${users.user_id} = ${rateachievement_rolling_28_days_open_access.salesperson_user_id} ;;
#   }

#   join: market_region_xwalk {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${rateachievement_rolling_28_days_open_access.market_id} = ${market_region_xwalk.market_id} ;;
#   }
# }

# #Rate Achievement - Asset Swaps
# explore: rateachievement_swaps {
#   group_label: "Rate Achievement"
#   label: "Rate Achievement - Asset Swaps"
#   case_sensitive: no
# }


explore: rateachievement_points {
  group_label: "Rate Achievement"
  label: "Rate Achievement Points"
  case_sensitive: no
  sql_always_where:
  ('salesperson' = {{ _user_attributes['department'] }}
  AND ${users.email_address} ILIKE '{{ _user_attributes['email'] }}')
  OR TRIM(LOWER('{{ _user_attributes['email'] }}')) = 'joyce.edwards@equipmentshare.com'
  OR ${market_region_xwalk.District_Region_Market_Access}
  OR 'developers' = {{ _user_attributes['department'] }}
  OR 'collectors' = {{ _user_attributes['department'] }}
  OR 'god view'= {{ _user_attributes['department'] }}
  ;;

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on:  ${rateachievement_points.salesperson_user_id}=${users.user_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rateachievement_points.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: invoices {
    type: left_outer
    relationship: one_to_many
    sql_on: ${invoices.invoice_id} = ${rateachievement_points.invoice_id} ;;
  }

  join: equipment_classes {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rateachievement_points.new_class_id} = ${equipment_classes.equipment_class_id};;
  }

  join: company_directory {
    type: inner
    relationship: one_to_one
    sql_on: ${users.employee_id}::number = ${company_directory.employee_id} ;;
  }

  join: market_region_xwalk_home_market {
    from:  market_region_xwalk
    type: left_outer
    relationship: many_to_one
    sql_on: ${company_directory.market_id} = ${market_region_xwalk_home_market.market_id} ;;
  }

  # join: rateachievement_swaps {
  #   type: left_outer
  #   relationship: one_to_one
  #   sql_on: ${rateachievement_points.invoice_id} = ${rateachievement_swaps.invoice_id} ;;
  # }

  join: companies_revenue_last_90_days {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rateachievement_points.company_id}=${companies_revenue_last_90_days.company_id} ;;
  }

  join: companies_revenue_last_30_days {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rateachievement_points.company_id}=${companies_revenue_last_30_days.company_id} ;;
  }

  join: market_class_inventory_status_count {
    type: left_outer
    relationship: many_to_many
    sql_on: lower(trim(${rateachievement_points.equipment_class}))=lower(trim(${market_class_inventory_status_count.class_name})) ;;
  }

  join: financial_utilization {
    type: left_outer
    relationship: one_to_many
    sql_on: ${market_class_inventory_status_count.category_id} = ${financial_utilization.category_id} ;;
  }

  join: equipment_classes_itl {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rateachievement_points.new_class_id}::INT=${equipment_classes_itl.equipment_class_id}::INT ;;
  }

  join: financial_utilization_itl {
    from: financial_utilization
    type: left_outer
    relationship: many_to_many
    sql_on:${rateachievement_points.new_class_id}::INT= ${financial_utilization_itl.equipment_class_id}::INT ;;
  }

  join: rentals {
    type: left_outer
    relationship: one_to_many
    sql_on: ${rentals.rental_id} = ${rateachievement_points.rental_id};;
  }

  join: missing_rate_assignments {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rateachievement_points.new_class_id} = ${missing_rate_assignments.equipment_class_id} ;;
  }

  join: markets_without_rates {
    type: inner
    relationship: one_to_one
    sql_on: ${market_region_xwalk.market_id} = ${markets_without_rates.market_id} ;;
  }

  join: national_account_companies {
    type: left_outer
    relationship: one_to_one
    sql_on: ${rateachievement_points.company_id} = ${national_account_companies.company_id} ;;
  }

  join: companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rateachievement_points.company_id} = ${companies.company_id} ;;
  }

  join: int_assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rateachievement_points.asset_id} = ${int_assets.asset_id} ;;
  }
}


## NEW market refresh dash

explore: rate_ach_points {
  from: rateachievement_points
  group_label: "Market Dashboard 2.0"
  label: "Rate Achievement Points - Market Dashboard Trial"
  case_sensitive: no
  sql_always_where: ${location_permissions.market_access} OR ${location_permissions.district_access}  OR ${location_permissions.region_access} ;;

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on:  ${rate_ach_points.salesperson_user_id}=${users.user_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rate_ach_points.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: invoices {
    type: left_outer
    relationship: one_to_many
    sql_on: ${invoices.invoice_id} = ${rate_ach_points.invoice_id} ;;
  }

  join: location_permissions {
    type: inner
    relationship: many_to_one
    sql_on: ${location_permissions.market_id} = ${market_region_xwalk.market_id} ;;
  }



}

#Salesperson customer activity feed
explore: salesperson_company_activity_feed {
  case_sensitive: no

  join: assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${salesperson_company_activity_feed.asset_id} ;;
  }

  join: markets {
    type: left_outer
    relationship: one_to_many
    sql_on: ${markets.market_id} = ${assets.rental_branch_id}  ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: one_to_many
    sql_on: ${market_region_xwalk.market_id} = ${markets.market_id} ;;
  }

  join: national_accounts {
    type: left_outer
    relationship: many_to_one
    sql_on: ${salesperson_company_activity_feed.company_id} = ${national_accounts.company_id} ;;
  }
}

#Salesperson QTD Revenue Rankings
explore: salesperson_qtd_revenue_ranking {
  group_label: "Salesperson QTD Revenue Rankings"
}

#MB commented out unused explore on 5/22/24
#Company salesperson history
# explore: company_salesperson_history {
#   case_sensitive: no
#   label: "Company Salesperson History"
# }

explore: companies_actively_renting_by_sales_rep_past_90 {
  case_sensitive: no
  group_label: "Salesperson"
  label: "Companies Actively Renting by Sales Rep"
}

explore: actively_renting_past_90 {
  case_sensitive: no
  label: "Past 90 Days Active Rental Totals"
}

explore: orders_salesperson_list {
  from: orders
  group_label: "Salesperson Information"
  label: "Salesperson List based on Order"
  description: "Use this explore to populate users for the Salesperson Dashboard based on orders"
  case_sensitive: no
  sql_always_where:
  (
  ('salesperson' = {{ _user_attributes['department'] }} AND ${users.deleted} = 'No' AND ${users.email_address} ILIKE '{{ _user_attributes['email'] }}')
  )
  OR
  (
  ${users.user_id} = COALESCE(${order_salespersons.user_id}, ${orders_salesperson_list.salesperson_user_id})
  AND
  ('salesperson' != {{ _user_attributes['department'] }}
  AND
  ('developer' = {{ _user_attributes['department'] }}
  OR 'god view' = {{ _user_attributes['department'] }}
  OR 'managers' = {{ _user_attributes['department'] }}
  OR 'collectors' = {{ _user_attributes['department'] }})
  )
  )
  OR
  ${market_region_salesperson.Salesperson_District_Region_Market_Access} ;;

  # (('collectors' = {{ _user_attributes['department'] }} OR 'salesperson' = {{ _user_attributes['department'] }}
  # AND ${users.deleted} = 'No' AND ${users.email_address} =  '{{ _user_attributes['email'] }}' ))
  # OR
  # (${users.user_id} = ${orders_salesperson_list.salesperson_user_id} AND
  # ('salesperson' != {{ _user_attributes['department'] }}
  # AND ('developer' = {{ _user_attributes['department'] }}
  # OR 'god view' = {{ _user_attributes['department'] }}
  # OR 'managers' = {{ _user_attributes['department'] }} )))
  # OR ${market_region_salesperson.Salesperson_District_Region_Market_Access} ;;


  join: order_salespersons {
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders_salesperson_list.order_id} = ${order_salespersons.order_id} ;;
  }

  join: rentals {
    type:  inner
    relationship:  many_to_one
    sql_on: ${orders_salesperson_list.order_id} = ${rentals.order_id} ;;
  }

  join: assets {
    type: inner
    relationship: many_to_one
    sql_on: ${rentals.asset_id} = ${assets.asset_id} ;;
  }

  join: invoices {
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders_salesperson_list.order_id} = ${invoices.order_id} ;;
  }

  join: line_items {
    type: left_outer
    relationship: one_to_many
    sql_on: ${invoices.invoice_id} = ${line_items.invoice_id} ;;
  }

  join: users {
    view_label: "Salesperson"
    type: left_outer
    relationship: many_to_one
    sql_on: coalesce(${order_salespersons.user_id},${orders_salesperson_list.salesperson_user_id}) = ${users.user_id} ;;
  }

  join: market_region_salesperson {
    type: left_outer
    relationship: many_to_one
    sql_on: ${users.user_id} = ${market_region_salesperson.salesperson_user_id} ;;
  }

  join: salesperson_to_market {
    type: left_outer
    relationship: one_to_one
    sql_on: ${users.user_id} = ${salesperson_to_market.salesperson_user_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: one_to_many
    sql_on: ${market_region_xwalk.market_id} = ${orders_salesperson_list.market_id} ;;
  }

}

#   explore: sales_manager_prospects {
#     from: prospects__mapping__v4
#     case_sensitive: no
#     sql_always_where:
#     (
#     ('salesperson' = {{ _user_attributes['department'] }} AND ${users.email_address} ILIKE '{{ _user_attributes['email'] }}' )
#     )
#     OR
#     (
#     'salesperson' != {{ _user_attributes['department'] }}
#     AND
#     (
#     'developer' = {{ _user_attributes['department'] }}
#     OR 'god view' = {{ _user_attributes['department'] }}
#     OR 'managers' = {{ _user_attributes['department'] }}
#     OR 'collectors' = {{ _user_attributes['department'] }}
#     )
#     )
#     OR ${market_region_salesperson.Salesperson_District_Region_Market_Access}
#     ;;

#     join: users {
#       type: left_outer
#       relationship: many_to_one
#       sql_on: LOWER(${sales_manager_prospects.sales_representative_email_address}) = LOWER(${users.email_address}) ;;
#     }

#     join: market_region_salesperson {
#       type: left_outer
#       relationship: many_to_one
#       sql_on: ${users.user_id} = ${market_region_salesperson.salesperson_user_id} ;;
#     }

#     join: company_directory {
#       type: inner
#       relationship: one_to_one
#       sql_on: ${users.employee_id}::number = ${company_directory.employee_id} ;;
#     }

#     join: salesperson_market_info {
#       from: market_region_xwalk
#       type: left_outer
#       relationship: one_to_one
#       sql_on: ${company_directory.market_id} = ${salesperson_market_info.market_id} ;;
#     }

#     join: market_region_sales_manager {
#       type: left_outer
#       relationship: many_to_one
#       sql_on: ${market_region_salesperson.salesperson_user_id} = ${market_region_sales_manager.salesperson_user_id} ;;
#     }

#     join: market_region_xwalk {
#       type: left_outer
#       relationship: many_to_one
#       sql_on: ${market_region_sales_manager.market_id} =  ${market_region_xwalk.market_id} ;;
#     }

# }


explore: historical_salesperson_revenue {
  from: line_items_dates_combined
  group_label: "Salesperson Information"
  label: "Date Created vs. Invoice Approved Date"
  description: "Only use this explore if you are comparing invoice_approved_date to date_created_date data"
  case_sensitive: no
  sql_always_where:
  (
  (
  ('salesperson' = {{ _user_attributes['department'] }} AND ${users.deleted} = 'No' AND ${users.email_address} ILIKE '{{ _user_attributes['email'] }}')
  )
  OR
  (
  ('salesperson' != {{ _user_attributes['department'] }}
  AND
  ('developer' = {{ _user_attributes['department'] }}
  OR 'god view' = {{ _user_attributes['department'] }}
  OR 'managers' = {{ _user_attributes['department'] }}
  OR 'collectors' = {{ _user_attributes['department'] }})
  )
  )
  OR
  ${market_region_salesperson.Salesperson_District_Region_Market_Access}
  ) AND ${historical_salesperson_revenue.invoice_no} NOT ILIKE '%deleted%';;


  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${historical_salesperson_revenue.salesperson_user_id} = ${users.user_id} ;;
  }

  join: market_region_salesperson {
    type: left_outer
    relationship: one_to_many
    sql_on: ${users.user_id} = ${market_region_salesperson.salesperson_user_id} ;;
  }

  join: companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${historical_salesperson_revenue.company_id} = ${companies.company_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${historical_salesperson_revenue.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: salesperson_to_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${users.user_id} = ${salesperson_to_market.salesperson_user_id} ;;
  }
}

explore: substitution_report {
  from: substitution_report
  label: "Substitution Report"
  group_label: "Salesperson Information"
  description: "Use this report to find rentals where substitutions where used in place of requested asset."
  case_sensitive: no
}

explore: cycle_report {
  from: admin_cycle
  label: "Cycle Report"
  case_sensitive: no
  sql_always_where:
   (('collectors' = {{ _user_attributes['department'] }} OR 'developer' = {{ _user_attributes['department'] }} OR 'managers' = {{ _user_attributes['department'] }}
                          OR 'rental coordinators' = {{ _user_attributes['department'] }} OR 'hr' = {{ _user_attributes['department'] }})
                          OR  ((('salesperson' = {{ _user_attributes['department'] }} AND ${users.email_address} ILIKE '{{ _user_attributes['email'] }}' )))
                          OR 'god view' = {{ _user_attributes['department'] }}) ;;


  join: remaining_rental_cost {
    type: left_outer
    relationship: one_to_one
    sql_on: ${cycle_report.rental_id} = ${remaining_rental_cost.rental_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${cycle_report.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${cycle_report.salesperson_user_id} = ${users.user_id} ;;
  }
}

# MB comment out May 21, 2024
# explore: conversion_competition_q2_2022 {
#   case_sensitive: no

#   join: companies {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${conversion_competition_q2_2022.company_id} = ${companies.company_id} ;;
#   }

#   join: market_region_xwalk {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${conversion_competition_q2_2022.invoice_branch} = ${market_region_xwalk.market_id} ;;
#   }
# }

explore: secondary_salesperson_revenue {
  from: secondary_sales_rep_revenue
  group_label: "Secondary Salesperson Information"
  label: "Secondary Salesperson Revenue"
  description: "Compares invoice_approved_date to date_created_date data for the secondary rep on historical invoices."
  case_sensitive: no
  sql_always_where:
  (
  ('salesperson' = {{ _user_attributes['department'] }} AND ${secondary_salesperson.deleted} = 'No' AND ${secondary_salesperson.email_address} ILIKE '{{ _user_attributes['email'] }}')
  )
  OR
  (
  ('salesperson' != {{ _user_attributes['department'] }}
  AND
  ('developer' = {{ _user_attributes['department'] }}
  OR 'god view' = {{ _user_attributes['department'] }}
  OR 'managers' = {{ _user_attributes['department'] }}
  OR 'collectors' = {{ _user_attributes['department'] }})
  )
  )
  OR
  ${market_region_salesperson.Salesperson_District_Region_Market_Access} ;;


    join: secondary_salesperson {
      from: users
      type: left_outer
      relationship: many_to_one
      sql_on: ${secondary_salesperson_revenue.secondary_salesperson_id} = ${secondary_salesperson.user_id} ;;
    }

    join: primary_salesperson {
      from: users
      type: left_outer
      relationship: many_to_one
      sql_on: ${secondary_salesperson_revenue.primary_salesperson_id} = ${primary_salesperson.user_id} ;;
    }

    join: market_region_salesperson {
      type: left_outer
      relationship: one_to_many
      sql_on: ${secondary_salesperson.user_id} = ${market_region_salesperson.salesperson_user_id} ;;
    }

    join: companies {
      type: left_outer
      relationship: many_to_one
      sql_on: ${secondary_salesperson_revenue.company_id} = ${companies.company_id} ;;
    }

    join: market_region_xwalk {
      type: left_outer
      relationship: many_to_one
      sql_on: ${secondary_salesperson_revenue.market_id} = ${market_region_xwalk.market_id} ;;
    }
  }

  explore: branch_rental_rates {
    label: "Admin Rates"
    group_label: "Rate Achievement"
    sql_always_where: ${equipment_classes.company_id} = 1854 and ${equipment_classes.deleted} = FALSE;; # and ${equipment_classes.rentable} = TRUE ;;

    join: admin_floor_rates {
      type: left_outer
      relationship: many_to_one
      sql_on: ${branch_rental_rates.branch_id} = ${admin_floor_rates.branch_id} and
              ${branch_rental_rates.equipment_class_id} = ${admin_floor_rates.equipment_class_id};;
    }

    join: admin_bench_rates {
      type: left_outer
      relationship: many_to_one
      sql_on: ${branch_rental_rates.branch_id} = ${admin_bench_rates.branch_id} and
        ${branch_rental_rates.equipment_class_id} = ${admin_bench_rates.equipment_class_id};;
    }

    join: admin_book_rates {
      type: left_outer
      relationship: many_to_one
      sql_on: ${branch_rental_rates.branch_id} = ${admin_book_rates.branch_id} and
        ${branch_rental_rates.equipment_class_id} = ${admin_book_rates.equipment_class_id};;
    }

    join: market_region_xwalk {
      type: left_outer
      relationship: many_to_one
      sql_on: ${branch_rental_rates.branch_id} = ${market_region_xwalk.market_id} ;;
    }

    join: rate_regions {
      type: left_outer
      relationship: one_to_one
      sql_on: ${market_region_xwalk.market_id} = ${rate_regions.market_id} ;;
    }

    join: discount_rates {
      type: left_outer
      relationship: many_to_one
      sql_on: ${rate_regions.district} = ${discount_rates.district} and ${branch_rental_rates.equipment_class_id} = ${discount_rates.equipment_class_id}
              and ${discount_rates.active} = TRUE;;
    }

    join: equipment_classes {
      type: inner
      relationship: many_to_one
      sql_on: ${branch_rental_rates.equipment_class_id} = ${equipment_classes.equipment_class_id};;
    }

    join: categories {
      type: left_outer
      relationship: many_to_one
      sql_on: ${equipment_classes.category_id} = ${categories.category_id} ;;
    }

    join: parent_categories {
      from: categories
      type: left_outer
      relationship: many_to_one
      sql_on: ${parent_categories.category_id} = ${categories.parent_category_id} ;;
    }
    join: rolling_achieved_rates {

      type: left_outer
      relationship: one_to_many
      sql_on: ${rolling_achieved_rates.equipment_class_id} = ${equipment_classes.equipment_class_id} and ${rolling_achieved_rates.region_name} = ${market_region_xwalk.region_name} ;;


    }
  }


  explore: company_rental_rates_extended {
    sql_always_where:
    ('salesperson' != {{ _user_attributes['department'] }} AND ${company_salesperson_relationship.District_Region_Market_Access}) or
    ('salesperson' = {{ _user_attributes['department'] }} AND ${company_salesperson_relationship.salesperson_email} ILIKE '{{ _user_attributes['email'] }}')
    or 'developer' = {{ _user_attributes['department'] }}
    or 'admin' = {{ _user_attributes['department'] }}
    or 'god view'= {{ _user_attributes['department'] }}
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'jabbok@equipmentshare.com';;
    label: "Customer Rates"
    group_label: "Rate Achievement"

    join: equipment_classes {
      type: inner
      relationship: many_to_one
      sql_on: ${company_rental_rates_extended.equipment_class_id} = ${equipment_classes.equipment_class_id};;
    }

    join: categories {
      type: left_outer
      relationship: many_to_one
      sql_on: ${equipment_classes.category_id} = ${categories.category_id} ;;
    }

    join: companies {
      type: left_outer
      relationship: many_to_one
      sql_on: ${company_rental_rates_extended.company_id} = ${companies.company_id} ;;
    }

    join: rate_refresh_impact {
      type: left_outer
      relationship: many_to_one
      sql_on: ${company_rental_rates_extended.equipment_class_id} = ${rate_refresh_impact.equipment_class_id}
            and ${company_rental_rates_extended.company_id} = ${rate_refresh_impact.company_id};;
    }

    join: company_salesperson_relationship {
      type: left_outer
      relationship: many_to_many
      sql_on:${company_rental_rates_extended.company_id} = ${company_salesperson_relationship.company_id};;
    }
  }


  explore: financial_utilization {
    group_label: "Rate Achievement"

    join: equipment_classes {
      type: left_outer
      relationship: many_to_one
      sql_on: ${financial_utilization.equipment_class_id} = ${equipment_classes.equipment_class_id} ;;
    }

    join: market_region_xwalk {
      type: left_outer
      relationship: many_to_one
      sql_on: ${financial_utilization.rental_branch_id} = ${market_region_xwalk.market_id} ;;
    }
  }

  explore: classes_missing_rates {
    group_label: "Rate Achievement"
  }

  # explore: salesperson_admin_check { --MB comment out 10-10-23 due to inactivity
  #   group_label: "Sales Person Admin Check"
  # }

  # explore: forklift_contest {
  #   group_label: "Rate Achievement"
  # }

  # explore: forklift_contest_daily_on_rent {
  #   group_label: "Rate Achievement"
  # }

  explore: salesperson_data_dump {}

explore:collections_actuals {
  group_label: "Collections"
  label: "Salesperson and Branch Collection Goals"
  case_sensitive: no
  sql_always_where:
  (
  ('salesperson' = {{ _user_attributes['department'] }} AND ${users.deleted} = 'No' AND ${users.email_address} ILIKE '{{ _user_attributes['email'] }}')
  )
  OR
  (
  ('salesperson' != {{ _user_attributes['department'] }}
  AND
  ('developer' = {{ _user_attributes['department'] }}
  OR 'god view' = {{ _user_attributes['department'] }}
  OR 'managers' = {{ _user_attributes['department'] }}
  OR 'collectors' = {{ _user_attributes['department'] }})
  )
  ) ;;


  join: collection_targets_branch_district {
    type: full_outer
    relationship: many_to_one
    sql_on: ${collections_actuals.branch_id} = ${collection_targets_branch_district.branch_id}  ;;
  }

  join: collection_targets_salesperson   {
    type: full_outer
    relationship: many_to_one
    sql_on: ${collections_actuals.salesperson_user_id} = ${collection_targets_salesperson.salesperson_user_id} ;;
  }

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${users.user_id} = ${collection_targets_salesperson.salesperson_user_id} ;;
  }

  join: market_region_xwalk {
    type: full_outer
    relationship: many_to_one
    sql_on: ${collections_actuals.region_district} = ${market_region_xwalk.region_district} ;;
  }
}

explore: salesrep_cash_collection_goal {
  group_label: "Salesperson"
  label: "Salesperson Collection Goals"
  case_sensitive: no

  join: salesrep_cash_collection_goal_drill {
    type: inner
    relationship: one_to_many
    sql_on: ${salesrep_cash_collection_goal.salesperson_user_id} = ${salesrep_cash_collection_goal_drill.salesperson_user_id} ;;
  }
}

explore: branch_cash_collection_goals {
  group_label: "Markets"
  label: "Market Collection Goals"
  case_sensitive: no

  join: branch_cash_collection_goals_drill {
    type: inner
    relationship: one_to_many
    sql_on: ${branch_cash_collection_goals.branch_id} = ${branch_cash_collection_goals_drill.branch_id} ;;
  }
}

explore: bulk_rental_rates {
  group_label: "Rate Achievement"
}

explore: bulk_rate_submissions {
  group_label: "Rate Achievement"
}

explore: rate_refresh_overrides {
  group_label: "Rate Achievement"

  join: equipment_classes {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rate_refresh_overrides.equipment_class_id} = ${equipment_classes.equipment_class_id} ;;
  }

  join: rate_regions {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rate_refresh_overrides.region_id} = ${rate_regions.region} ;;
  }
}

# explore: salesperson_customer_revenue {}

explore: proposed_rates_2024q1 {
  group_label: "Rate Achievement"
  }


datagroup: tam_goals_current_data_update {
  sql_trigger: select max(_update_timestamp) from analytics.bi_ops.tam_goals_current;;
  max_cache_age: "2 hours"
  description: "Looking at analytics.bi_ops.tam_goals_current to get most recent update."
}

explore: sales_goals_rental {
  group_label: "Sales Rep Goals"
  persist_with: tam_goals_current_data_update
  join: tam_monthly_rr_by_company {
    type: left_outer
    relationship: one_to_many
    sql_on: ${sales_goals_rental.pk} = ${tam_monthly_rr_by_company.fk_sgr};;
  }
  case_sensitive: no
  description: "Pulls from tam_goals_current table: the current month's rental revenue by tam as well as their DSM-set goals.
                tam_goals_current updates hourly. Includes measures with advanced html for cards on Salesperson dashboard."
}



explore: sales_goals_rental_historic {
  group_label: "Sales Rep Goals"
  persist_with: tam_goals_current_data_update
  join: tam_monthly_rr_by_company {
    type: left_outer
    relationship: one_to_many
    sql_on: ${sales_goals_rental_historic.pk} = ${tam_monthly_rr_by_company.fk_sgr};;
  }
  case_sensitive: no
  description: "A union of tam_goals_current and tam_goals_historic, equivalent to current and past two calendar years' history
                of monthly rental revenue by tam up to today's date. Joined to tam monthly rental revenue by company for drill down.
                tam_goals_historic updates monthly."
}


explore: historical_salesperson_rental_rev {
  from: last_6_months_rental_rev
  group_label: "Salesperson Information"
  description: "Last 6 Months of Billing Approved Rental Revenue"
  case_sensitive: no

  sql_always_where:

  (
  (
  ('salesperson' = {{ _user_attributes['department'] }}AND ${historical_salesperson_rental_rev.salesperson_email_address} ILIKE '{{ _user_attributes['email'] }}')
  )
  OR
  (
  ('salesperson' != {{ _user_attributes['department'] }}
  AND
  ('developer' = {{ _user_attributes['department'] }}
  OR 'god view' = {{ _user_attributes['department'] }}
  OR 'managers' = {{ _user_attributes['department'] }}
  OR 'collectors' = {{ _user_attributes['department'] }})
  )
  )
  OR
  ${market_region_salesperson.Salesperson_District_Region_Market_Access}
  ) ;;




  join: market_region_salesperson {
    type: left_outer
    relationship: one_to_many
    sql_on: ${historical_salesperson_rental_rev.salesperson_user_id} = ${market_region_salesperson.salesperson_user_id} ;;
  }

  join: companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${historical_salesperson_rental_rev.company_id} = ${companies.company_id} ;;
  }


  join: market_region_xwalk {
    type: full_outer
    relationship: many_to_one
    sql_on: ${historical_salesperson_rental_rev.market_id} = ${market_region_xwalk.market_id} ;;
  }

}

explore: tam_saas_referral_program {
  group_label: "T3 TAM Referral Program"
  label: "TAM Referrals"
  case_sensitive: no
  description: "Explore to pull all T3 TAM referrals and the current status of each referral."
  persist_for: "2 hours"
}

explore: t3_tam_attendance_tracker {
  case_sensitive: no
  description: "For dashboard that reports TAM attendance of ESU and T3 referral training"

}


explore: agg_historical_salesperson_rental_rev {
  from: last_6_months_rental_rev_agg
  group_label: "Salesperson Information"
  description: "Aggregated Last 6 Months of Billing Approved Rental Revenue"
  case_sensitive: no

  sql_always_where:

  (
  (
  ('salesperson' = {{ _user_attributes['department'] }}AND ${agg_historical_salesperson_rental_rev.salesperson_email_address} ILIKE '{{ _user_attributes['email'] }}')
  )
  OR
  (
  ('salesperson' != {{ _user_attributes['department'] }}
  AND
  ('developer' = {{ _user_attributes['department'] }}
  OR 'god view' = {{ _user_attributes['department'] }}
  OR 'managers' = {{ _user_attributes['department'] }}
  OR 'collectors' = {{ _user_attributes['department'] }})
  )
  )
  OR
  ${market_region_salesperson.Salesperson_District_Region_Market_Access}
  ) ;;

  join: last_6_months_rental_rev {
    type: left_outer
    relationship: many_to_one
    sql_on: ${agg_historical_salesperson_rental_rev.salesperson_with_id} = ${last_6_months_rental_rev.salesperson_with_id}
      AND ${agg_historical_salesperson_rental_rev.month_date} = date_trunc(month, ${last_6_months_rental_rev.date_date})
      AND ${agg_historical_salesperson_rental_rev.business_segment_name} = ${last_6_months_rental_rev.business_segment_name}
      AND ${agg_historical_salesperson_rental_rev.is_main_market} = ${last_6_months_rental_rev.is_main_market}
      AND ${agg_historical_salesperson_rental_rev.rate_tier} = ${last_6_months_rental_rev.rate_tier}
      AND ${agg_historical_salesperson_rental_rev.market_id} = ${last_6_months_rental_rev.market_id} ;;
  }


  join: market_region_salesperson {
    type: left_outer
    relationship: one_to_many
    sql_on: ${agg_historical_salesperson_rental_rev.salesperson_user_id} = ${market_region_salesperson.salesperson_user_id} ;;
  }

  join: companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${companies.company_id} = ${last_6_months_rental_rev.company_id};;
  }


  join: market_region_xwalk {
    type: full_outer
    relationship: many_to_one
    sql_on: ${agg_historical_salesperson_rental_rev.market_id} = ${market_region_xwalk.market_id} ;;
  }

}

explore: discount_rates {
  group_label: "Rate Achievement"

  join: equipment_classes {
    type: left_outer
    relationship: many_to_one
    sql_on: ${discount_rates.equipment_class_id} = ${equipment_classes.equipment_class_id} ;;
  }

  join: rate_regions {
    type: left_outer
    relationship: many_to_one
    sql_on: ${discount_rates.district} = ${rate_regions.district} ;;
  }

  join: floor_rates_by_district {
    type: left_outer
    relationship: many_to_one
    sql_on: ${discount_rates.equipment_class_id} = ${floor_rates_by_district.equipment_class_id}
            and ${discount_rates.district} = ${floor_rates_by_district.district};;
  }

  join: time_utilization_district {
    type: left_outer
    relationship: one_to_one
    sql_on: ${discount_rates.equipment_class_id} = ${time_utilization_district.equipment_class_id}
            and ${discount_rates.district} = ${time_utilization_district.district};;
  }

  join: users {
    type: left_outer
    relationship: one_to_one
    sql_on: ${discount_rates.created_by} = ${users.email_address} ;;
  }

  join: deal_rate_utilization {
    type: inner
    relationship: one_to_one
    sql_on: ${rate_regions.district} = ${deal_rate_utilization.district} ;;
  }

  join: four_week_achieved_rate_by_district {
    type: left_outer
    relationship: many_to_one
    sql_on: ${discount_rates.equipment_class_id} = ${four_week_achieved_rate_by_district.equipment_class_id}
      and ${discount_rates.district} = ${four_week_achieved_rate_by_district.district};;
  }

  join: daily_time_utilization_created {
    from: daily_time_utilization_district
    type: left_outer
    view_label: "Time Utilization as of Deal Rate Created Date"
    relationship: many_to_one
    sql_on: ${discount_rates.equipment_class_id} = ${daily_time_utilization_created.equipment_class_id}
      and ${discount_rates.district} = ${daily_time_utilization_created.district}
      and ${discount_rates.date_created_date} = ${daily_time_utilization_created.calendar_date};;

  }

  join: daily_time_utilization_voided {
    from: daily_time_utilization_district
    type: left_outer
    view_label: "Time Utilization as of Deal Rate Voided Date"
    relationship: many_to_one
    sql_on: ${discount_rates.equipment_class_id} = ${daily_time_utilization_voided.equipment_class_id}
      and ${discount_rates.district} = ${daily_time_utilization_voided.district}
      and ${discount_rates.date_voided_date} = ${daily_time_utilization_voided.calendar_date};;
  }
  join: gpm_by_district_eq_class {
    type: left_outer
    relationship: one_to_many
    sql_on:
    ${gpm_by_district_eq_class.equipment_class_id} = CAST(${equipment_classes.equipment_class_id} AS VARCHAR)
    and ${gpm_by_district_eq_class.district} = ${rate_regions.district} ;;
  }
  }


explore: suggested_discount_rates {
  group_label: "Rate Achievement"
  from:  equipmentshare_assets
  sql_always_where:
    ${equipment_classes.business_segment} = 'Core'
    AND ${equipment_classes.rentable} = 'true'
    AND ${equipment_classes.name} NOT ILIKE '%fuel tank%'
    AND ${equipment_classes.name} NOT ILIKE '%fuel cell%'
    AND ${equipment_classes.name} NOT ILIKE '%fuel storage tank%'
    AND ${equipment_classes.name} NOT ILIKE '%golf cart gas%'
    AND ${equipment_classes.name} NOT ILIKE '%utiity vehicle%'
    and ${floor_rates_by_district.floor_rate} is not null
    and ${floor_rates_by_district.floor_rate} >0
  ;;

  join: equipment_classes {
    type: left_outer
    relationship: many_to_one
    sql_on: ${suggested_discount_rates.equipment_class_id} = ${equipment_classes.equipment_class_id} ;;
  }

  join: rate_regions {
    type: inner
    relationship: many_to_one
    sql_on: ${suggested_discount_rates.district} = ${rate_regions.district} ;;
  }

  join: floor_rates_by_district {
    type: left_outer
    relationship: many_to_one
    sql_on: ${suggested_discount_rates.equipment_class_id} = ${floor_rates_by_district.equipment_class_id}
      and ${suggested_discount_rates.district} = ${floor_rates_by_district.district};;
  }

  join: time_utilization_district {
    type: left_outer
    relationship: one_to_one
    sql_on: ${suggested_discount_rates.equipment_class_id} = ${time_utilization_district.equipment_class_id}
      and ${suggested_discount_rates.district} = ${time_utilization_district.district};;
  }

  join: unavailable_oec_district {
    type: left_outer
    relationship: one_to_one
    sql_on: ${suggested_discount_rates.equipment_class_id} = ${unavailable_oec_district.equipment_class_id}
      and ${suggested_discount_rates.district} = ${unavailable_oec_district.district};;
  }

  join: rouse_time_utilization {
    type: left_outer
    relationship: one_to_one
    sql_on: ${suggested_discount_rates.equipment_class_id} = ${rouse_time_utilization.equipment_class_id}
      and ${suggested_discount_rates.district} = ${rouse_time_utilization.district} ;;
  }

  join: four_week_achieved_rate_by_district {
    type: left_outer
    relationship: many_to_one
    sql_on: ${suggested_discount_rates.equipment_class_id} = ${four_week_achieved_rate_by_district.equipment_class_id}
      and ${suggested_discount_rates.district} = ${four_week_achieved_rate_by_district.district};;
  }
}


explore: rate_refresh_updates {
  group_label: "Rate Achievement"
}

explore: temp_rate_refresh_dispatch_tool {
  group_label: "Rate Achievement"
  sql_always_where:  ('salesperson' != {{ _user_attributes['department'] }} AND ${temp_rate_refresh_dispatch_tool.District_Region_Market_Access}) or
    ('salesperson' = {{ _user_attributes['department'] }} AND ${temp_rate_refresh_dispatch_tool.salesperson_email} ILIKE '{{ _user_attributes['email'] }}')
    or 'developer' = {{ _user_attributes['department'] }}
    or 'admin' = {{ _user_attributes['department'] }}
    or 'god view'= {{ _user_attributes['department'] }}
    OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'jabbok@equipmentshare.com';;
}

explore: rate_regions {
  group_label: "Rate Achievement"
}

explore: rate_refresh_impact {
  group_label: "Rate Achievement"
  sql_always_where: (
  ('salesperson' = {{ _user_attributes['department'] }} AND ${users.deleted} = 'No' AND ${users.email_address} ILIKE '{{ _user_attributes['email'] }}')
  )
  OR
  (
  ${users.user_id} = COALESCE(${order_salespersons.user_id}, ${orders.salesperson_user_id})
  AND
  ('salesperson' != {{ _user_attributes['department'] }}
  AND
  ('developer' = {{ _user_attributes['department'] }}
  OR 'god view' = {{ _user_attributes['department'] }}
  OR 'managers' = {{ _user_attributes['department'] }}
  OR 'collectors' = {{ _user_attributes['department'] }})
  )
  )
  OR
  ${market_region_salesperson.Salesperson_District_Region_Market_Access} ;;


  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rate_refresh_impact.branch_id} = ${market_region_xwalk.market_id} ;;
  }

  join: companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rate_refresh_impact.company_id} = ${companies.company_id} ;;
  }

  join: equipment_classes {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rate_refresh_impact.equipment_class_id} = ${equipment_classes.equipment_class_id} ;;
  }

  join: categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${equipment_classes.category_id} = ${categories.category_id} ;;
  }

  join: rentals {
    type: inner
    relationship: many_to_one
    sql_on: ${rate_refresh_impact.rental_id} = ${rentals.rental_id} ;;
  }

  join: invoices {
    type: inner
    relationship: many_to_one
    sql_on: ${rate_refresh_impact.invoice_id} = ${invoices.invoice_id} ;;
  }

  join: orders {
    type: inner
    relationship: many_to_one
    sql_on: ${rentals.order_id} = ${orders.order_id} ;;
  }

  join: order_salespersons {
    type: left_outer
    relationship: one_to_many
    sql_on: ${orders.order_id} = ${order_salespersons.order_id} ;;
  }

  join: market_region_salesperson {
    type: left_outer
    relationship: many_to_one
    sql_on: ${users.user_id} = ${market_region_salesperson.salesperson_user_id} ;;
  }

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${invoices.salesperson_user_id} = ${users.user_id} ;;
  }

  join: rolling_achieved_rates {

    type: left_outer
    relationship: one_to_many
    sql_on: ${rolling_achieved_rates.equipment_class_id} = ${equipment_classes.equipment_class_id} and ${rolling_achieved_rates.region_name} = ${market_region_xwalk.region_name} ;;


  }

}
