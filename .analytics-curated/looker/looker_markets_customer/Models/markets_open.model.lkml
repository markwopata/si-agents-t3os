connection: "es_snowflake_analytics"

include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/ANALYTICS/national_accounts.view.lkml"
include: "/views/ANALYTICS/collector_customer_assignments.view.lkml"
include: "/views/ANALYTICS/vehicle_rental_contract.view.lkml"
include: "/views/ANALYTICS/vehicle_rental_google_form.view.lkml"
include: "/views/ANALYTICS/location_mapping.view.lkml"
include: "/views/ANALYTICS/employee_branch_ukg.view.lkml"
include: "/views/ANALYTICS/disc_master.view.lkml"
include: "/views/ANALYTICS/regions.view.lkml"
include: "/views/ANALYTICS/districts.view.lkml"
include: "/views/ANALYTICS/market_directory.view.lkml"
include: "/views/ANALYTICS/rental_rate_by_company.view.lkml"
include: "/views/custom_sql/salesperson_to_market.view.lkml"
include: "/views/ES_WAREHOUSE/companies.view.lkml"
include: "/views/ES_WAREHOUSE/invoices.view.lkml"
include: "/views/ES_WAREHOUSE/line_items.view.lkml"
include: "/views/ES_WAREHOUSE/markets.view.lkml"
include: "/views/ES_WAREHOUSE/orders.view.lkml"
include: "/views/ES_WAREHOUSE/users.view.lkml"
include: "/views/ES_WAREHOUSE/assets_aggregate.view.lkml"
include: "/views/ES_WAREHOUSE/company_divisions.view.lkml"
include: "/views/ES_WAREHOUSE/equipment_classes.view.lkml"
include: "/views/ES_WAREHOUSE/assets.view.lkml"
include: "/views/ES_WAREHOUSE/asset_types.view.lkml"
include: "/views/ES_WAREHOUSE/rentals.view.lkml"
include: "/views/ES_WAREHOUSE/order_salespersons.view.lkml"
include: "/views/custom_sql/market_financial_utilization.view.lkml"
include: "/views/custom_sql/units_on_rent_rolling_90_days_no_pdt.view.lkml"
include: "/views/custom_sql/contracts_unsigned.view.lkml"
include: "/views/custom_sql/company_salesperson_rank.view.lkml"
include: "/views/GS/hr_links_to_resumes.view.lkml"
include: "/views/custom_sql/plexi_profitability_revenue.view.lkml"
include: "/views/custom_sql/all_hands_data.view.lkml"
include: "/views/ES_WAREHOUSE/line_item_types.view.lkml"
include: "/views/ANALYTICS/company_directory.view.lkml"
include: "/views/custom_sql/hr_greenhouse_link.view.lkml"
include: "/views/ES_WAREHOUSE/locations.view.lkml"
include: "/views/ANALYTICS/mobile_tool_billing.view.lkml"
include: "/views/ANALYTICS/v_real_estate_leads.view.lkml"
include: "/views/custom_sql/market_first_order.view.lkml"
include: "/views/custom_sql/million_dollar_markets.view.lkml"
include: "/views/custom_sql/customer_quarter_revenue.view.lkml"
include: "/views/ANALYTICS/INTACCT_MODELS/int_revenue.view.lkml"
include: "/views/ANALYTICS/ASSETS/int_assets.view.lkml"
include: "/views/Business_Intelligence/dim_companies_bi.view.lkml"
include: "/views/custom_sql/v_dim_dates_bi.view.lkml"
include: "/views/ANALYTICS/int_equipment_assignments.view.lkml"


#Markets Overview - Market Information by Invoice Approved Date with Open Access
explore: Markets_Overview_by_Approved_Date_open_access {
  from: orders
  label: "Market Information by Invoice Approved Date with Open Access"
  group_label: "Markets Overview"
  case_sensitive: no

  join: order_salespersons {
    type: left_outer
    relationship: many_to_one
    sql_on: ${order_salespersons.order_id} = ${Markets_Overview_by_Approved_Date_open_access.order_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: one_to_many
    sql_on: coalesce(${line_items.branch_id}, ${Markets_Overview_by_Approved_Date_open_access.market_id}) = ${market_region_xwalk.market_id};;
  }

  join: invoices {
    type: inner
    relationship: one_to_many
    sql_on: ${invoices.order_id} = ${Markets_Overview_by_Approved_Date_open_access.order_id};;
  }

  join: line_items {
    type: inner
    relationship: many_to_many
    sql_on: ${line_items.invoice_id} = ${invoices.invoice_id};;
  }

  join: line_item_types {
    type: inner
    relationship: many_to_one
    sql_on: ${line_items.line_item_type_id} = ${line_item_types.line_item_type_id};;
  }


  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${users.user_id} = coalesce(${order_salespersons.user_id},${Markets_Overview_by_Approved_Date_open_access.salesperson_user_id}) ;;
  }

  join: employee_branch_ukg {
    type: full_outer
    relationship: one_to_one
    sql_on: TRIM(LOWER(${users.email_address})) = TRIM(LOWER(${employee_branch_ukg.employee_email})) ;;
  }

  join: location_mapping {
    type: left_outer
    relationship: many_to_one
    sql_on: TRIM(LOWER(${employee_branch_ukg.work_location}))=TRIM(LOWER(${location_mapping.loc_name})) ;;
  }

  join: employee_to_market {
    from: market_region_xwalk
    type: left_outer
    relationship: many_to_one
    sql_on: TRIM(LOWER(${location_mapping.mkt_name}))=TRIM(LOWER(${employee_to_market.market_name})) ;;
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

  join: collector_customer_assignments {
    type: left_outer
    relationship: one_to_one
    sql_on: ${Markets_Overview_by_Approved_Date_open_access.market_id}=${collector_customer_assignments.market_id} ;;
  }

  join: markets {
    type: inner
    relationship: one_to_many
    sql_on: ${markets.market_id} = ${Markets_Overview_by_Approved_Date_open_access.market_id} ;;
  }
}

explore: Market_Profitability_And_Revenue {
  from: plexi_profitability_revenue
  label: "Market Profitability and Revenue"
  group_label: "Markets Overview"
  case_sensitive: no

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${Market_Profitability_And_Revenue.market_id} = ${market_region_xwalk.market_id} ;;
  }
}


#Markets Overview - Market Information by Invoice Approved Date with Open Access
explore: Markets_HR_Overview {
  from: users
  label: "Market Information by Employee"
  group_label: "Markets Overview"
  case_sensitive: no

  join: company_directory {
    type: full_outer
    relationship: one_to_one
    sql_on: TRIM(LOWER(${Markets_HR_Overview.email_address})) = TRIM(LOWER(${company_directory.work_email})) ;;
  }

  join: employee_branch_ukg {
    type: full_outer
    relationship: one_to_one
    sql_on: TRIM(LOWER(${company_directory.work_email})) = TRIM(LOWER(${employee_branch_ukg.employee_email})) ;;
  }

  join: market_directory {
    type: left_outer
    relationship: one_to_one
    sql_on: ${employee_branch_ukg.market_id} = ${market_directory.market_id} ;;
  }

  join: districts {
    type: left_outer
    relationship: one_to_one
    sql_on: ${employee_branch_ukg.district_id} = ${districts.district_id} ;;
    }

  join: regions {
    type: left_outer
    relationship: one_to_one
    sql_on: ${employee_branch_ukg.region_name} = ${regions.region_name} ;;
    }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${company_directory.market_id} = ${market_region_xwalk.market_id} ;;
  }


  join: disc_master {
    type: left_outer
    relationship: one_to_one
    sql_on: TRIM(lower(${company_directory.personal_email}))=TRIM(lower(${disc_master.email_address}))
              or TRIM(lower(${company_directory.work_email}))=TRIM(lower(${disc_master.email_address}));;
  }

  join: hr_links_to_resumes {
    type: left_outer
    relationship: one_to_one
    sql_on: lower(trim(${Markets_HR_Overview.email_address}))=lower(trim(${hr_links_to_resumes.sales_rep_email})) ;;
  }

  join: hr_greenhouse_link {
    type: left_outer
    relationship: one_to_one
    sql_on: lower(trim(${employee_branch_ukg.employee_id}))=lower(trim(${hr_greenhouse_link.employee_id})) ;;
  }

  join: markets {
    type: left_outer
    relationship: one_to_one
    sql_on: ${market_region_xwalk.market_id} =${markets.market_id};;
  }
}

#Equipment Rentals - Rentals Open Access Information
explore: rentals_open_access {
  from: rentals
  label: "Rentals Open Access Information"
  group_label: "Equipment Rentals"
  case_sensitive: no

  join: orders {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rentals_open_access.order_id} = ${orders.order_id} ;;
  }

  join: invoices {
    type: left_outer
    relationship: one_to_many
    sql_on: ${orders.order_id} = ${invoices.order_id} ;;
  }

  join: line_items {
    type: inner
    relationship: one_to_many
    sql_on: ${invoices.invoice_id} = ${line_items.invoice_id} ;;
  }

  join: line_item_types {
    type: inner
    relationship: one_to_one
    sql_on: ${line_items.line_item_type_id} = ${line_item_types.line_item_type_id} ;;
  }

  join: order_salespersons {
    type: left_outer
    relationship: many_to_one
    sql_on: ${order_salespersons.order_id} = ${orders.order_id} ;;
  }

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders.market_id} = ${markets.market_id} ;;
  }

  join: assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rentals_open_access.asset_id} = ${assets.asset_id} ;;
  }

  join: asset_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_type_id} = ${asset_types.asset_type_id} ;;
  }

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders.user_id} = ${users.user_id} ;;
  }

  join: users_salesperson {
    from: users
    type: left_outer
    relationship: many_to_one
    sql_on: coalesce(${order_salespersons.user_id},${orders.salesperson_user_id}) = ${users_salesperson.user_id} ;;
  }

  join: companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${users.company_id} = ${companies.company_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: one_to_one
    sql_on: ${markets.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: assets_aggregate {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets.asset_id} = ${assets_aggregate.asset_id} ;;
  }

  join: equipment_classes {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets_aggregate.equipment_class_id} = ${equipment_classes.equipment_class_id} ;;
  }

  join: company_divisions {
    type: left_outer
    relationship: many_to_one
    sql_on: ${company_divisions.company_division_id} = ${equipment_classes.company_division_id} ;;
  }
}

explore: contracts_unsigned {
  group_label: "Contracts"
  join: market_region_xwalk {
    relationship: many_to_one
    sql_on: ${contracts_unsigned.market_id} = ${market_region_xwalk.market_id} ;;
  }
}

explore: invoices {
  label: "Customer Ranking by Market"
  group_label: "Markets Overview"
  case_sensitive: no
  sql_always_where: ${market_region_xwalk.District_Region_Market_Access};;

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

  join: company_salesperson_rank {
    type: left_outer
    relationship: one_to_many
    sql_on: ${companies.company_id} = ${company_salesperson_rank.company_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: coalesce(${line_items.branch_id}, ${orders.market_id}) =  ${market_region_xwalk.market_id};;
  }
}

# explore: all_hands_data {
#   label: "Company Stats"
#   group_label: "Equipmentshare"
# }

# explore: assets {
#   label: "Company Stats - Assets"
#   group_label: "Equipmentshare"
# }

# explore: market_financial_utilization {}

# explore: units_on_rent_rolling_90_days_no_pdt {}

explore: onroad_rental_contract {
  from: orders
  label: "On Road Equipment Rental Contracts"
  sql_always_where: ${assets_aggregate.equipment_class_id} in (
197,
474,
475,
476,
518,
519,
3124,
3437,
3465,
4740
) and ${market_region_xwalk.District_Region_Market_Access}
 and ${order_status_id} <> 8
;;

  join: vehicle_rental_contract {
    relationship: one_to_many
    type:  left_outer
    sql_on:  ${vehicle_rental_contract.order_id} = ${onroad_rental_contract.order_id} ;;
  }

  join: rentals {
    relationship: one_to_many
    type: inner
    sql_on: ${onroad_rental_contract.order_id} = ${rentals.order_id} ;;
  }

  join: assets_aggregate {
    relationship: one_to_many
    type: inner
    sql_on:  ${rentals.asset_id} = ${assets_aggregate.asset_id} ;;
  }

  join: market_region_xwalk {
    relationship: many_to_one
    type:  left_outer
    sql_on: ${onroad_rental_contract.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: users {
    relationship: many_to_one
    type: inner
    sql_on:  ${onroad_rental_contract.user_id} = ${users.user_id} ;;
  }

  join: companies {
    relationship: many_to_one
    type: inner
    sql_on:  ${users.company_id} = ${companies.company_id} ;;
  }

  join: vehicle_rental_google_form {
    relationship: many_to_one
    type: left_outer
    sql_on:  ${vehicle_rental_contract.order_id} = ${vehicle_rental_google_form.order_id} ;;
  }
}

explore: mobile_tool_billing{
  label: "Mobile Tool Billing"
}

explore: v_real_estate_leads {
  label: "Real Estate Leads"
}

explore: market_first_order {
  description: "Displays the first order, first invoice, and first asset assignment for ES markets"
}

explore: million_dollar_markets {}

explore: customer_quarter_revenue {}

explore: solar_plant_camera_report {
  from: int_assets
  case_sensitive: no
  sql_always_where: ${equipment_class} ilike '%solar security%';;

  join: int_revenue {
    relationship: one_to_many
    type: left_outer
    sql_on: ${solar_plant_camera_report.asset_id} = CAST(${int_revenue.asset_id} AS VARCHAR)
      and ${int_revenue.company_id} not in (274, 1854) ;;
  }

  join: v_dim_dates_bi {
    relationship: many_to_one
    type: left_outer
    sql_on: ${int_revenue.gl_date} = ${v_dim_dates_bi.date};;
  }

  join: dim_companies_bi {
    relationship: many_to_one
    type: left_outer
    sql_on: ${int_revenue.company_id} = ${dim_companies_bi.company_id};;
  }

  join: int_equipment_assignments {
    relationship: one_to_one
    type: left_outer
    sql_on: ${int_revenue.rental_id} = ${int_equipment_assignments.rental_id} ;;
  }
}
