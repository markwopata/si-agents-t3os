connection: "es_snowflake_c_analytics"

include: "/views/ES_WAREHOUSE/asset_purchase_history.view.lkml"
include: "/views/ES_WAREHOUSE/assets.view.lkml"
include: "/views/ES_WAREHOUSE/asset_status_key_values.view.lkml"
include: "/views/ES_WAREHOUSE/assets.view.lkml"
include: "/views/ES_WAREHOUSE/markets.view.lkml"
include: "/views/ES_WAREHOUSE/assets_aggregate.view.lkml"
include: "/views/ES_WAREHOUSE/companies.view.lkml"
include: "/views/ES_WAREHOUSE/net_terms.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/ANALYTICS/dra_monthly_new.view.lkml"
include: "/views/custom_sql/first_rental_and_rapid_rent_ind.view.lkml"
include: "/views/custom_sql/asset_finance_type.view.lkml"
include: "/views/custom_sql/asset_purchase_history_facts.view.lkml"
include: "/views/custom_sql/asset_nbv_all_owners.view.lkml"
include: "/views/custom_sql/asset_recent_paid_invoice.view.lkml"
include: "/views/custom_sql/asset_last_rental.view.lkml"
include: "/views/ES_WAREHOUSE/financial_lenders.view.lkml"
include: "/views/ES_WAREHOUSE/financial_schedules.view.lkml"
include: "/views/ES_WAREHOUSE/rentals.view.lkml"
include: "/views/ES_WAREHOUSE/orders.view.lkml"
include: "/views/ES_WAREHOUSE/contracts.view.lkml"
include: "/views/ES_WAREHOUSE/locations.view.lkml"
include: "/views/ES_WAREHOUSE/states.view.lkml"
include: "/views/ES_WAREHOUSE/rental_location_assignments.view.lkml"
include: "/views/custom_sql/sales_cogs_report.view"
include: "/views/custom_sql/sales_cogs_report_revised.view"
include: "/views/custom_sql/rpo_customer_invoices.view.lkml"
include: "/views/custom_sql/UKG_SAGE_Account_Mismatches.view.lkml"
include: "/views/custom_sql/ukg_sage_status_mismatch.view.lkml"
include: "/views/custom_sql/re_rent_estimate.view.lkml"
include: "/views/custom_sql/Asset_4000_Depreciation.view.lkml"
include: "/views/custom_sql/aztec_inventory.view.lkml"

#Asset Information - Re-Rent Inventory Information
explore: asset_audit {
  from: assets
  label: "Asset Audits"
  group_label: "Asset Information"
  case_sensitive: no

  join: asset_status_key_values {
    type:  left_outer
    relationship: one_to_one
    sql_on: ${asset_audit.asset_id} = ${asset_status_key_values.asset_id} ;;
  }

  join: asset_purchase_history {
    type: left_outer
    relationship: one_to_one
    sql_on: ${asset_audit.asset_id}=${asset_purchase_history.asset_id} ;;
  }

  join: asset_purchase_history_facts_final {
    type:  left_outer
    relationship:  one_to_one
    sql_on: ${asset_audit.asset_id} = ${asset_purchase_history_facts_final.asset_id} ;;
  }

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: coalesce(${asset_audit.market_id},${asset_audit.rental_branch_id},${asset_audit.inventory_branch_id})=${markets.market_id} ;;
  }

  join: assets_aggregate {
    type: left_outer
    relationship: one_to_one
    sql_on: ${asset_audit.asset_id}=${assets_aggregate.asset_id} ;;
  }

  join: companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets_aggregate.company_id} = ${companies.company_id} ;;
  }

  join: net_terms {
    type: left_outer
    relationship: one_to_one
    sql_on: ${companies.net_terms_id} = ${net_terms.net_terms_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: one_to_one
    sql_on: ${markets.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: dra_monthly_new {
    type: left_outer
    relationship: one_to_many
    sql_on: ${asset_audit.asset_id}=${dra_monthly_new.asset_id} ;;
  }

  join: first_rental_and_rapid_rent_ind {
    type: left_outer
    relationship: one_to_one
    sql_on: ${asset_audit.asset_id}=${first_rental_and_rapid_rent_ind.asset_id} ;;
  }

  join: asset_nbv_all_owners {
    type: left_outer
    relationship: one_to_one
    sql_on: ${asset_audit.asset_id} = ${asset_nbv_all_owners.asset_id} ;;
  }

  join: asset_finance_type {
    type: left_outer
    relationship: one_to_one
    sql_on: ${asset_audit.asset_id}=${asset_finance_type.asset_id} ;;
  }

}

explore: asset_audit_finance {
  from: assets
  group_label: "Financial Operations"
  description: "Asset Audit Finance"
  case_sensitive: no


  join: asset_status_key_values {
    type:  left_outer
    relationship: one_to_one
    sql_on: ${asset_audit_finance.asset_id} = ${asset_status_key_values.asset_id} ;;
  }

  join: asset_purchase_history {
    type: left_outer
    relationship: one_to_one
    sql_on: ${asset_audit_finance.asset_id}=${asset_purchase_history.asset_id} ;;
  }

  join: asset_purchase_history_facts_final {
    type:  left_outer
    relationship:  one_to_one
    sql_on: ${asset_audit_finance.asset_id} = ${asset_purchase_history_facts_final.asset_id} ;;
  }

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: coalesce(${asset_audit_finance.market_id},${asset_audit_finance.rental_branch_id},${asset_audit_finance.inventory_branch_id})=${markets.market_id} ;;
  }

  join: service_branch {
    from: markets
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_audit_finance.service_branch_id}=${service_branch.market_id} ;;
  }

  join: assets_aggregate {
    type: left_outer
    relationship: one_to_one
    sql_on: ${asset_audit_finance.asset_id}=${assets_aggregate.asset_id} ;;
  }

  join: rental_branch {
    from: markets
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets_aggregate.rental_branch_id}=${markets.market_id} ;;
  }

  join: companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets_aggregate.company_id} = ${companies.company_id} ;;
  }

  join: net_terms {
    type: left_outer
    relationship: one_to_one
    sql_on: ${companies.net_terms_id} = ${net_terms.net_terms_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: one_to_one
    sql_on: ${markets.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: dra_monthly_new {
    type: left_outer
    relationship: one_to_many
    sql_on: ${asset_audit_finance.asset_id}=${dra_monthly_new.asset_id} ;;
  }

  join: first_rental_and_rapid_rent_ind {
    type: left_outer
    relationship: one_to_one
    sql_on: ${asset_audit_finance.asset_id}=${first_rental_and_rapid_rent_ind.asset_id} ;;
  }

  join: asset_last_rental {
    type: left_outer
    relationship: many_to_many
    sql_on: ${asset_audit_finance.asset_id}=${asset_last_rental.asset_id} ;;
  }

  join: contracts {
    type: full_outer
    relationship: many_to_many
    sql_on: ${contracts.order_id}=${asset_last_rental.order_id} ;;
  }

  join: rental_location_assignments {
    type: left_outer
    relationship: one_to_many
    sql_on: ${asset_last_rental.rental_id}=${rental_location_assignments.rental_id} ;;
  }

  join: locations {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rental_location_assignments.location_id}=${locations.location_id} ;;
  }

  join: states {
    type: left_outer
    relationship: many_to_one
    sql_on: ${locations.state_id}=${states.state_id} ;;
  }

  join: asset_recent_paid_invoice {
    type: left_outer
    relationship: one_to_one
    sql_on: ${asset_audit_finance.asset_id}=${asset_recent_paid_invoice.asset_id} ;;
  }

  join: financial_schedules {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_purchase_history.financial_schedule_id}=${financial_schedules.financial_schedule_id} ;;
  }

  join: financial_lenders {
    type: left_outer
    relationship: many_to_one
    sql_on: ${financial_schedules.originating_lender_id}=${financial_lenders.financial_lender_id} ;;
  }

  # join: asset_nbv_all_owners {
  #   type: left_outer
  #   relationship: one_to_one
  #   sql_on: ${asset_audit_finance.asset_id} = ${asset_nbv_all_owners.asset_id} ;;
  # }

  join: asset_finance_type {
    type: left_outer
    relationship: one_to_one
    sql_on: ${asset_audit_finance.asset_id}=${asset_finance_type.asset_id} ;;
  }
}

explore: sales_cogs_report {}

explore: ukg_sage_account_mismatches {
  label: "UKG - Sage Account Mismatches"
}

explore: ukg_sage_status_mismatch {
  label: "UKG - Sage Status Mismatches"
}

explore: sales_cogs_report_revised {}


explore: rpo_customer_invoices {
  label: "RPO Customer Invoices"
  case_sensitive: no
  description: "Invoice details for RPO customers [c.name ilike '%(RPO)']"
}

explore: re_rent_estimate {
  case_sensitive: no
}

explore: asset_4000_depreciation {
  case_sensitive: no
}

explore: aztec_inventory {
  label: "Aztec Inventory"
}

#testing
#new test comment
