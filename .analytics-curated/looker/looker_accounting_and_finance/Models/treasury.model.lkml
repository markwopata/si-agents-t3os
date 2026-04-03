connection: "es_snowflake_analytics"

#include: "/views/ANALYTICS/*.view.lkml"
#include: "/views/custom_sql/*.view.lkml"
#include: "/views/users.view.lkml"
#include: "/views/ES_WAREHOUSE/*.view.lkml"

include: "/views/ANALYTICS/approved_invoices_by_ap_user.view.lkml"
include: "/views/ANALYTICS/ap_combined_payables.view.lkml"
include: "/views/ANALYTICS/ar_aging_branch_customer.view.lkml"
include: "/views/ANALYTICS/ar_legal_report.view.lkml"
include: "/views/ANALYTICS/ar_legal_report_customers.view.lkml"
include: "/views/ANALYTICS/ar_metrics_dashboard.view.lkml"
include: "/views/ANALYTICS/ar_metrics_detail.view.lkml"
include: "/views/ANALYTICS/ar_payment_posting_team_matrix.view.lkml"
include: "/views/ANALYTICS/cod_report.view.lkml"
include: "/views/ANALYTICS/collections_actuals.view.lkml"
include: "/views/ANALYTICS/collections_actuals_calc.view.lkml"
include: "/views/ANALYTICS/collections_target_branch_district_working.view.lkml"
include: "/views/ANALYTICS/collection_past_due.view.lkml"
include: "/views/ANALYTICS/collection_targets.view.lkml"
include: "/views/ANALYTICS/company_region.view.lkml"
include: "/views/ANALYTICS/credit_note_pmt_matrix.view.lkml"
include: "/views/ANALYTICS/credit_snapshot.view.lkml"
include: "/views/ANALYTICS/crockett_allocated_revenue.view.lkml"
include: "/views/ANALYTICS/crockett_base_revenue.view.lkml"
include: "/views/ANALYTICS/crockett_hard_down.view.lkml"
include: "/views/ANALYTICS/crockett_on_rent.view.lkml"
include: "/views/ANALYTICS/crockett_summary.view.lkml"
include: "/views/ANALYTICS/customers_over_credit_limit.view.lkml"
include: "/views/ANALYTICS/direct_socf_transactions.view.lkml"
include: "/views/ANALYTICS/dispute_credits.view.lkml"
include: "/views/ANALYTICS/dispute_summary.view.lkml"
include: "/views/ANALYTICS/dra_monthly_new.view.lkml"
include: "/views/ANALYTICS/duplicate_accounts_vendors.view.lkml"
include: "/views/ANALYTICS/epay_merchant_vendor_mapping.view.lkml"
include: "/views/ANALYTICS/epay_reporting.view.lkml"
include: "/views/ANALYTICS/epay_vendor_first_set.view.lkml"
include: "/views/ANALYTICS/es_companies.view.lkml"
include: "/views/ANALYTICS/financial_ratios.view.lkml"
include: "/views/ANALYTICS/fin_ops_ar_summary.view.lkml"
include: "/views/ANALYTICS/fin_ops_collections_ttm_revenue.view.lkml"
include: "/views/ANALYTICS/fin_ops_percent_ar.view.lkml"
include: "/views/ANALYTICS/fleet_reimbursements.view.lkml"
include: "/views/ANALYTICS/gl_detail.view.lkml"
include: "/views/ANALYTICS/invoices_by_exception_code.view.lkml"
include: "/views/ANALYTICS/lender_to_company_id.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/ANALYTICS/paycor_employees_managers_full_hierarchy.view.lkml"
include: "/views/ANALYTICS/payments_vendor_mapping.view.lkml"
include: "/views/ANALYTICS/payment_count.view.lkml"
include: "/views/ANALYTICS/payment_processing_details.view.lkml"
include: "/views/ANALYTICS/peer_dso.view.lkml"
include: "/views/ANALYTICS/pending_branch_approval.view.lkml"
include: "/views/ANALYTICS/pending_cost_object_by_expense_type.view.lkml"
include: "/views/ANALYTICS/pending_hq_approval.view.lkml"
include: "/views/ANALYTICS/phoenix_id_types.view.lkml"
include: "/views/ANALYTICS/sources_uses_looks.view.lkml"
include: "/views/ANALYTICS/sources_uses_manual.view.lkml"
include: "/views/ANALYTICS/top_vendors.view.lkml"
include: "/views/ANALYTICS/trovata_connections.view.lkml"
include: "/views/ANALYTICS/trovata_looker_transactions.view.lkml"
include: "/views/ANALYTICS/trovata_transactions_moberly_uk.view.lkml"
include: "/views/ANALYTICS/tv6_xml_debt_table_current.view.lkml"
include: "/views/ANALYTICS/unsubmited_invoices_w_requestor_and_email.view.lkml"
include: "/views/ANALYTICS/unsubmitted_invoices.view.lkml"
include: "/views/ANALYTICS/vault.view.lkml"
include: "/views/ANALYTICS/vault_v2.view.lkml"
include: "/views/ANALYTICS/vendor.view.lkml"
include: "/views/ANALYTICS/v_ap.view.lkml"
include: "/views/ANALYTICS/v_ap_5.view.lkml"
include: "/views/ANALYTICS/v_ap_actual_payments.view.lkml"
include: "/views/ANALYTICS/v_ap_forecast.view.lkml"
include: "/views/ANALYTICS/v_cc_audit.view.lkml"
include: "/views/ANALYTICS/ytd_payables_analysis.view.lkml"
include: "/views/ANALYTICS/collector_quarterly_goals.view.lkml"
include: "/views/ANALYTICS/specialized_billing.view.lkml"
include: "/views/ANALYTICS/national_accounts_collections.view.lkml"
include: "/views/ANALYTICS/cash_forecast_inputs.view.lkml"
include: "/views/ANALYTICS/high_level_collection_metrics.view.lkml"
include: "/views/ANALYTICS/ap_review_dashboard_actuals.view.lkml"
include: "/views/ANALYTICS/spend_summary_mapping.view.lkml"
include: "/views/ANALYTICS/navan_managers_weekly_email.view.lkml"
include: "/views/ANALYTICS/vw_lien_exemptions.view.lkml"
include: "/views/ANALYTICS/internal_research.view.lkml"
include: "/views/ANALYTICS/legal_research.view.lkml"
include: "/views/ANALYTICS/ar_manual_times.view.lkml"
include: "/views/ANALYTICS/vw_ar_total_time_spent.view.lkml"
include: "/views/ANALYTICS/specialized_billing_quarterly.view.lkml"
include: "/views/ANALYTICS/declined_credit_notes.view.lkml"
include: "/views/ANALYTICS/potentially_duplicate_customers.view.lkml"
include: "/views/ANALYTICS/customers_no_address_matches_market.view.lkml"
include: "/views/ANALYTICS/collector_targets_charts.view.lkml"
include: "/views/ANALYTICS/training_invoices.view.lkml"
include: "/views/ANALYTICS/credit_fraud.view.lkml"
include: "/views/ANALYTICS/on_behalf_payments.view.lkml"
include: "/views/ANALYTICS/gold_collector_payment_history.view.lkml"

include: "/views/custom_sql/6b_copy.view.lkml"
include: "/views/custom_sql/abl_cash_forecast.view.lkml"
include: "/views/custom_sql/abl_category.view.lkml"
include: "/views/custom_sql/accounting_month_end_close_status_floqast.view.lkml"
include: "/views/custom_sql/amortization_schedules.view.lkml"
include: "/views/custom_sql/amortization_schedules_hist.view.lkml"
include: "/views/custom_sql/aph_vendor.view.lkml"
include: "/views/custom_sql/aprecord_time_difference.view.lkml"
include: "/views/custom_sql/ap_ar_related_party.view.lkml"
include: "/views/custom_sql/ap_payment_variances.view.lkml"
include: "/views/custom_sql/ap_pmts_by_vendor.view.lkml"
include: "/views/custom_sql/ar_by_bank.view.lkml"
include: "/views/custom_sql/ar_related_party.view.lkml"
include: "/views/custom_sql/ar_transaction_recon_5000.view.lkml"
include: "/views/custom_sql/assetsOEC_to_sage_loanID.view.lkml"
include: "/views/custom_sql/assets_with_duplicate_ids.view.lkml"
include: "/views/custom_sql/assets_with_jj_twin.view.lkml"
include: "/views/custom_sql/Asset_4000_Depreciation.view.lkml"
include: "/views/custom_sql/asset_finance_type.view.lkml"
include: "/views/custom_sql/asset_last_rental.view.lkml"
include: "/views/custom_sql/Asset_Lat_Long.view.lkml"
include: "/views/custom_sql/asset_locations_by_lender.view.lkml"
include: "/views/custom_sql/asset_locations_by_lender_v2.view.lkml"
include: "/views/custom_sql/asset_market_tmstp.view.lkml"
include: "/views/custom_sql/asset_nbv_all_owners.view.lkml"
include: "/views/custom_sql/asset_purchase_history_facts.view.lkml"
include: "/views/custom_sql/asset_recent_paid_invoice.view.lkml"
include: "/views/custom_sql/backlog_changes.view.lkml"
include: "/views/custom_sql/Balance_Sheet_Assets.view.lkml"
include: "/views/custom_sql/bills_with_pos_after_closing_period.view.lkml"
include: "/views/custom_sql/BisTrack_Product_Import.view.lkml"
include: "/views/custom_sql/bulk_inventory_on_rent.view.lkml"
include: "/views/custom_sql/cash_balances_by_entity.view.lkml"
include: "/views/custom_sql/cash_inflow_outflow.view.lkml"
include: "/views/custom_sql/cash_inflow_outflow_level_two_tags.view.lkml"
include: "/views/custom_sql/cash_inflow_outflow_weekly_quarterly.view.lkml"
include: "/views/custom_sql/cash_sources_uses_abl.view.lkml"
include: "/views/custom_sql/cc_spend_receipt_upload.view.lkml"
include: "/views/custom_sql/clio_newly_imported_matters.view.lkml"
include: "/views/custom_sql/closed_pos_no_gl_entry.view.lkml"
include: "/views/custom_sql/Clustdoc_Vendor_Log.view.lkml"
include: "/views/custom_sql/concur_pending_branch_approval.view.lkml"
include: "/views/custom_sql/concur_user_permissions.view.lkml"
include: "/views/custom_sql/construction_in_progress.view.lkml"
include: "/views/custom_sql/credit_limit_changes.view.lkml"
include: "/views/custom_sql/crockett_revenue.view.lkml"
include: "/views/custom_sql/customers_without_assigned_collector.view.lkml"
include: "/views/custom_sql/cust_to_collect_assign.view.lkml"
include: "/views/custom_sql/damaged_goods.view.lkml"
include: "/views/custom_sql/debt_table_cpltd.view.lkml"
include: "/views/custom_sql/debt_table_loan_balances.view.lkml"
include: "/views/custom_sql/Debt_table_Sage_assetOEC_Comparison.view.lkml"
include: "/views/custom_sql/debt_table_total_debt.view.lkml"
include: "/views/custom_sql/dt_to_sage_bal_compare.view.lkml"
include: "/views/custom_sql/dt_to_sage_compare_updated.view.lkml"
include: "/views/custom_sql/eagleproducts.view.lkml"
include: "/views/custom_sql/ecommerce_vendor_test.view.lkml"
include: "/views/custom_sql/epay_reporting_summary.view.lkml"
include: "/views/custom_sql/excluded_po_lines.view.lkml"
include: "/views/custom_sql/Expense_line_impact.view.lkml"
include: "/views/custom_sql/first_rental_and_rapid_rent_ind.view.lkml"
include: "/views/custom_sql/fleet_forecast_no_invoice.view.lkml"
include: "/views/custom_sql/fleet_forecast_promise.view.lkml"
include: "/views/custom_sql/fleet_spend_forecast.view.lkml"
include: "/views/custom_sql/gl_approver_audit.view.lkml"
include: "/views/custom_sql/gl_detail_v3.view.lkml"
include: "/views/custom_sql/gl_pipeline_impact_ap.view.lkml"
include: "/views/custom_sql/gl_pipeline_impact_gl.view.lkml"
include: "/views/custom_sql/gl_pipeline_impact_purchasing.view.lkml"
include: "/views/custom_sql/gl_reviewer_v2.view.lkml"
include: "/views/custom_sql/IES_amort_asset_level.view.lkml"
include: "/views/custom_sql/IES_amort_companywide_level.view.lkml"
include: "/views/custom_sql/IES_amort_dealer_level.view.lkml"
include: "/views/custom_sql/intacct_dup_apa_apj.view.lkml"
include: "/views/custom_sql/intacct_dup_apa_apj_v2.view.lkml"
include: "/views/custom_sql/intacct_gl_activity.view.lkml"
include: "/views/custom_sql/intacct_gl_activity_dds.view.lkml"
include: "/views/custom_sql/intacct_gl_activity_dds_new.view.lkml"
include: "/views/custom_sql/intacct_gl_high_detail.view.lkml"
include: "/views/custom_sql/intacct_gl_high_detail_filtered.view.lkml"
include: "/views/custom_sql/inventory_balance.view.lkml"
include: "/views/custom_sql/invoices_unextracted_unapproved.view.lkml"
include: "/views/custom_sql/invoice_payments_charge_type.view.lkml"
include: "/views/custom_sql/level_2_transaction_breakdown.view.lkml"
include: "/views/custom_sql/loans_maturing_soon.view.lkml"
include: "/views/custom_sql/loan_to_assets.view.lkml"
include: "/views/custom_sql/market_recon.view.lkml"
include: "/views/custom_sql/monthly_payment_breakout.view.lkml"
include: "/views/custom_sql/net_terms_changes.view.lkml"
include: "/views/custom_sql/new_sage_loan_id.view.lkml"
include: "/views/custom_sql/one_sided_entries_pos.view.lkml"
include: "/views/custom_sql/operating_leased_assets.view.lkml"
include: "/views/custom_sql/out_of_balance_entries.view.lkml"
include: "/views/custom_sql/past_due_60_no_pmt_30.view.lkml"
include: "/views/custom_sql/paycor_employees_managers.view.lkml"
include: "/views/custom_sql/payment_forecast.view.lkml"
include: "/views/custom_sql/payment_forecast_new.view.lkml"
include: "/views/custom_sql/PIE_revenue.view.lkml"
include: "/views/custom_sql/pos_to_close_partial_conversions.view.lkml"
include: "/views/custom_sql/po_lifecycle_postings.view.lkml"
include: "/views/custom_sql/quarterly_ar_slt.view.lkml"
include: "/views/custom_sql/recently_added_schedules.view.lkml"
include: "/views/custom_sql/rental_rev_earned_btw_dt.view.lkml"
include: "/views/custom_sql/re_rent_estimate.view.lkml"
include: "/views/custom_sql/rpo_assets_revenue.view.lkml"
include: "/views/custom_sql/rpo_customer_invoices.view.lkml"
include: "/views/custom_sql/sage_cpltd.view.lkml"
include: "/views/custom_sql/Sage_Department_Expense_Line_Relationships.view.lkml"
include: "/views/custom_sql/sage_dept_hierarchy.view.lkml"
include: "/views/custom_sql/sage_id_to_assets.view.lkml"
include: "/views/custom_sql/sage_loan_balances.view.lkml"
include: "/views/custom_sql/sage_total_debt.view.lkml"
include: "/views/custom_sql/sales_cogs_report.view.lkml"
include: "/views/custom_sql/sales_cogs_report_revised.view.lkml"
include: "/views/custom_sql/socf_ending_cash.view.lkml"
include: "/views/custom_sql/sold_assets_payments_credits.view.lkml"
include: "/views/custom_sql/sold_asset_tracker_1A.view.lkml"
include: "/views/custom_sql/sold_asset_tracker_1b.view.lkml"
include: "/views/custom_sql/sold_asset_tracker_2a.view.lkml"
include: "/views/custom_sql/sold_asset_tracker_2b.view.lkml"
include: "/views/custom_sql/sources_temporary.view.lkml"
include: "/views/custom_sql/sources_uses_forecast.view.lkml"
include: "/views/custom_sql/sync_log_po.view.lkml"
include: "/views/custom_sql/t3_damaged_goods.view.lkml"
include: "/views/custom_sql/T3_revenue_support.view.lkml"
include: "/views/custom_sql/T3_revenue_support_all.view.lkml"
include: "/views/custom_sql/T3_revenue_support_data.view.lkml"
include: "/views/custom_sql/T3_revenue_support_low.view.lkml"
include: "/views/custom_sql/terp_equipment_available_at_branch.view.lkml"
include: "/views/custom_sql/top_vendors_filter.view.lkml"
include: "/views/custom_sql/transaction_verification.view.lkml"
include: "/views/custom_sql/UKG_SAGE_Account_Mismatches.view.lkml"
include: "/views/custom_sql/ukg_sage_status_mismatch.view.lkml"
include: "/views/custom_sql/unsubmitted_branch.view.lkml"
include: "/views/custom_sql/vendor_audit_feb25.view.lkml"
include: "/views/custom_sql/vendor_change_log.view.lkml"
include: "/views/custom_sql/vendor_change_log_all_time.view.lkml"
include: "/views/custom_sql/vendor_comparison.view.lkml"
include: "/views/custom_sql/vendor_comparison_entity.view.lkml"
include: "/views/custom_sql/vendor_contact_info.view.lkml"
include: "/views/custom_sql/vendor_contact_pay_info.view.lkml"
include: "/views/custom_sql/manager_preparation.view.lkml"
include: "/views/custom_sql/collector_targets.view.lkml"
include: "/views/custom_sql/pre_over_payments.view.lkml"
include: "/views/custom_sql/legal_payments.view.lkml"
include: "/views/custom_sql/trovata_liquidity.view.lkml"
include: "/views/custom_sql/ap_review_forecast.view.lkml"
include: "/views/custom_sql/total_ar_activity_hours.view.lkml"
include: "/views/custom_sql/collector_notes.view.lkml"

include: "/views/ES_WAREHOUSE/assets.view.lkml"
include: "/views/ES_WAREHOUSE/assets_aggregate.view.lkml"
include: "/views/ES_WAREHOUSE/asset_purchase_history.view.lkml"
include: "/views/ES_WAREHOUSE/asset_status_key_values.view.lkml"
include: "/views/ES_WAREHOUSE/companies.view.lkml"
include: "/views/ES_WAREHOUSE/contracts.view.lkml"
include: "/views/ES_WAREHOUSE/contract_types.view.lkml"
include: "/views/ES_WAREHOUSE/equipment_models.view.lkml"
include: "/views/ES_WAREHOUSE/financial_lenders.view.lkml"
include: "/views/ES_WAREHOUSE/financial_schedules.view.lkml"
include: "/views/ES_WAREHOUSE/line_items.view.lkml"
include: "/views/ES_WAREHOUSE/locations.view.lkml"
include: "/views/ES_WAREHOUSE/markets.view.lkml"
include: "/views/ES_WAREHOUSE/net_terms.view.lkml"
include: "/views/ES_WAREHOUSE/orders.view.lkml"
include: "/views/ES_WAREHOUSE/rentals.view.lkml"
include: "/views/ES_WAREHOUSE/rental_location_assignments.view.lkml"
include: "/views/ES_WAREHOUSE/rental_types.view.lkml"
include: "/views/ES_WAREHOUSE/states.view.lkml"
include: "/views/ES_WAREHOUSE/users.view.lkml"
include: "/views/ANALYTICS/collector_directory.view.lkml"

explore: cash_balances_by_entity {sql_always_where: ${date} >= '2022-08-01' ;;}

# Commented out due to low usage on 2026-03-30
# explore: cash_inflow_outflow {}

# Commented out due to low usage on 2026-03-30
# explore: level_2_transaction_breakdown {}
explore: sources_uses_forecast {}

# Commented out due to low usage on 2026-03-30
# explore: abl_cash_forecast {}

# Commented out due to low usage on 2026-03-30
# explore: cash_sources_uses_abl {}
explore: cash_inflow_outflow_level_two_tags {sql_always_where: ${date_date} >= '2022-07-25' ;;}

# Commented out due to low usage on 2026-03-30
# explore: v_ap {}
explore: cash_inflow_outflow_weekly_quarterly {}

# Commented out due to low usage on 2026-03-30
# explore: ap_pmts_by_vendor {}

# Commented out due to low usage on 2026-03-30
# explore: fleet_spend_forecast {}
explore: v_ap_actual_payments {}

# Commented out due to low usage on 2026-03-30
# explore: pending_cost_object_by_expense_type {}

# Commented out due to low usage on 2026-03-30
# explore: fleet_forecast_no_invoice {}
explore: unsubmitted_branch {}

# Commented out due to low usage on 2026-03-30
# explore: paycor_employees_managers {}
explore: ap_combined_payables {}
explore: fleet_forecast_promise {}

# Commented out due to low usage on 2026-03-30
# explore: vault {}
explore: vault_v2 {}
explore: fleet_reimbursements {}
explore: trovata_looker_transactions {}

# Commented out due to low usage on 2026-03-30
# explore: socf_ending_cash {}

explore: epay_reporting {
  join: epay_vendor_first_set {
    type: full_outer
    relationship: many_to_one
    sql_on: (${epay_reporting.vendor_id} = ${epay_vendor_first_set.vendor_id}) and (${epay_reporting.month_month} = ${epay_vendor_first_set.month_month})  ;;
  }
}

explore: epay_reporting_summary {}
explore: ytd_payables_analysis {}
explore: ar_metrics_detail {}

# Commented out due to low usage on 2026-03-30
# explore: ar_aging_branch_customer {}




explore: ar_by_bank {}

explore: sold_assets_payments_credits {}
explore: invoice_payments_charge_type {}
explore: collection_targets {}
explore: ar_metrics_dashboard {}
explore: quarterly_ar_slt {}

# Commented out due to low usage on 2026-03-30
# explore: sources_uses_looks {}

# Commented out due to low usage on 2026-03-30
# explore: collections_actuals {}

explore: top_vendors {
  join: top_vendors_filter {
    type: left_outer
    relationship: one_to_one
    sql_on: ${top_vendors.vendor_id} = ${top_vendors_filter.vendor_id} ;;
  }
}


# Commented out due to low usage on 2026-03-30
# explore: v_cc_audit {
#
#
#   join: paycor_employees_managers {
#     type: full_outer
#     relationship: one_to_one
#     sql_on: ${paycor_employees_managers.employee_number}=${v_cc_audit.employee_number} ;;
#   }
#
#
#   join: paycor_employees_managers_full_hierarchy {
#     type: full_outer
#     relationship: one_to_one
#     sql_on: ${paycor_employees_managers.employee_number}=${paycor_employees_managers_full_hierarchy.employee_number} ;;
#   }
#
#
#
#   join: users {
#     type: full_outer
#     relationship: one_to_one
#      sql_on: TRIM(LOWER(${paycor_employees_managers.employee_email})) = TRIM(LOWER(${users.correct_email_address})) ;;
#   }
#
#   join: transaction_verification {
#     type: left_outer
#     relationship: one_to_many
#     sql_where: ${transaction_verification.card_type} <> 'cent' ;;
#     sql_on: ${paycor_employees_managers.employee_number} = ${transaction_verification.employee_id}  ;;
#   }
#
#   join: cc_spend_receipt_upload {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${cc_spend_receipt_upload.user_id}=${users.user_id}
#               and (${v_cc_audit.card_type} = ${cc_spend_receipt_upload.card_type} and ${cc_spend_receipt_upload.receipt_source} = 'Cost_Capture')
#               and ${v_cc_audit.transaction_amount_dim}=${cc_spend_receipt_upload.receipt_amount}
#               and ${v_cc_audit.transaction_date_date}>=(${cc_spend_receipt_upload.transaction_date_date}::DATE - interval '30 days')
#               and ${v_cc_audit.transaction_date_date}< (${cc_spend_receipt_upload.transaction_date_date}::DATE + interval '30 days') ;;
#   }
#
#
# }




explore: asset_purchase_history {
  case_sensitive: no
  sql_always_where: coalesce(${invoice_purchase_date}::date,${assets.created_date}::date) >= '1/1/2019'
  and  ${financial_schedule_id} is null and ${finance_status} = 'Dealership Floor Plan'
  and upper(${es_companies.company_name}) like '%IES%'
  ;;

  join: assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id}=${asset_purchase_history.asset_id} ;;
  }

  join: aph_vendor {
    type:  left_outer
    relationship: many_to_one
    sql_on: ${asset_purchase_history.asset_id}=${aph_vendor.asset_id} ;;
  }

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: coalesce(${assets.rental_branch_id},${assets.inventory_branch_id})=${markets.market_id} and ${assets.company_id}=${markets.company_id} ;;
  }

  join: abl_category {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_purchase_history.asset_id}=${abl_category.asset_id}  ;;
  }

  join: es_companies {
    type: inner
    relationship: many_to_one
    sql_on: ${assets.company_id}=${es_companies.company_id}  ;;
  }

}


explore: direct_socf_transactions  {}

explore: collections_target_branch_district_working {}

explore: peer_dso {}

explore: fin_ops_collections_ttm_revenue {}

explore: fin_ops_percent_ar {}

explore: fin_ops_ar_summary  {}

explore: crockett_summary {}

explore: crockett_on_rent{}

explore: crockett_hard_down {}

explore: crockett_base_revenue {}

explore: crockett_allocated_revenue {}

explore: dispute_summary {}

explore: dispute_credits {}

explore: construction_in_progress {}

explore: payment_count {}

explore: credit_note_pmt_matrix {}

explore: trovata_transactions_moberly_uk {}

explore: duplicate_accounts_vendors {}



explore: past_due_60_no_pmt_30 {}

explore: customers_without_assigned_collector {}

explore: manager_preparation {
  join: collector_targets  {
    type:  full_outer
    relationship: many_to_one
    sql_on: ${manager_preparation.customer_id} = ${collector_targets.customer_id} ;;
  }
  join: pre_over_payments  {
    type:  left_outer
    relationship: many_to_one
    sql_on: ${manager_preparation.customer_id} = ${pre_over_payments.company_id} ;;
  }
  join: collector_notes  {
    type:  full_outer
    relationship: many_to_one
    sql_on: ${collector_targets.collector} = ${collector_notes.collector} ;;
  }
}

explore: payment_processing_details {}

explore: collection_past_due {}

explore: credit_snapshot {
  join: company_region {
    type:  left_outer
    relationship: many_to_one
    sql_on: ${credit_snapshot.customer_id} = ${company_region.company_id} ;;
  }
}

explore: customers_over_credit_limit {}

explore: ar_legal_report {
  join: ar_legal_report_customers {
    type: left_outer
    relationship: many_to_one
    sql_on: ${ar_legal_report.customer_id}=${ar_legal_report_customers.customer_id}  ;;
  }
}

explore: ar_payment_posting_team_matrix {
  sql_always_where: ${ar_payment_posting_team_matrix.is_user} or ${total_ar_activity_hours.is_user} ;;
  join: ar_legal_report_customers {
    type: left_outer
    relationship: many_to_one
    sql_on: ${ar_payment_posting_team_matrix.customer_id}=${ar_legal_report_customers.customer_id}  ;;
  }
  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${ar_payment_posting_team_matrix.posted_user_id}=${users.user_id}  ;;
  }
  join: total_ar_activity_hours {
    type: left_outer
    relationship: many_to_one
    sql_on: ${ar_payment_posting_team_matrix.key}=${total_ar_activity_hours.key};;
  }
}

explore: cod_report {
  join: ar_legal_report_customers {
    type: left_outer
    relationship: many_to_one
    sql_on: ${cod_report.customer_id}=${ar_legal_report_customers.customer_id}  ;;
  }
}

explore: collector_quarterly_goals {}

explore: specialized_billing {}

explore: national_accounts_collections {}

explore: legal_payments {}

explore: trovata_liquidity {}

explore: cash_forecast_inputs {}

explore: high_level_collection_metrics {}

explore: internal_research {}

explore: legal_research {}

explore: navan_managers_weekly_email {
  sql_always_where: ${is_manager} ;;
}

explore: collector_directory {}

explore: vw_lien_exemptions {}

# Commented out due to low usage on 2026-03-30
# explore: ap_review_dashboard_actuals {
#
#   join: ap_review_forecast {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: (${ap_review_dashboard_actuals.key}=${ap_review_forecast.key}) ;;
#   }
#
#   join: spend_summary_mapping {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: (${ap_review_dashboard_actuals.account_v2}::string=${spend_summary_mapping.account}::string) ;;
#   }
# }

explore: ar_manual_times {}

explore: specialized_billing_quarterly {}

explore: vw_ar_total_time_spent {
  sql_always_where: ${vw_ar_total_time_spent.is_user} ;;
}

explore: declined_credit_notes {}

explore: potentially_duplicate_customers {}

explore: customers_no_address_matches_market {}

explore: collector_targets_charts {
  sql_always_where: ${collector_targets_charts.is_collector} ;;
}

explore: training_invoices {}

explore: credit_fraud {}

explore: on_behalf_payments {}

explore: gold_collector_payment_history {
  sql_always_where: ${gold_collector_payment_history.is_manager} ;;
}
