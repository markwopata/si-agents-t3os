connection: "es_snowflake_analytics"

include: "/views/custom_sql/intacct_gl_activity.view.lkml"

include: "/views/custom_sql/intacct_gl_activity_dds.view.lkml"

include: "/views/custom_sql/sage_permissions.view.lkml"

include: "/views/custom_sql/concur_user_permissions.view.lkml"

include: "/views/custom_sql/intacct_gl_activity_dds_new.view.lkml"

include: "/views/custom_sql/gl_detail_v3.view.lkml"

include: "/views/custom_sql/intacct_dup_apa_apj.view.lkml"

include: "/views/custom_sql/intacct_dup_apa_apj_v2.view.lkml"

include: "/views/custom_sql/closed_pos_no_gl_entry.view.lkml"

include: "/views/custom_sql/one_sided_entries_pos.view.lkml"

include: "/views/custom_sql/out_of_balance_entries.view.lkml"

include: "/views/custom_sql/gl_reviewer_v2.view.lkml"

include: "/views/custom_sql/intacct_gl_high_detail.view.lkml"

include: "/views/custom_sql/bills_with_pos_after_closing_period.view.lkml"

include: "/views/custom_sql/pos_to_close_partial_conversions.view.lkml"

include: "/views/custom_sql/aprecord_time_difference.view.lkml"

include: "/views/custom_sql/ecommerce_vendor_test.view.lkml"

include: "/views/custom_sql/gl_approver_audit.view.lkml"

include: "/views/custom_sql/gl_pipeline_impact_purchasing.view.lkml"

include: "/views/custom_sql/gl_pipeline_impact_gl.view.lkml"

include: "/views/custom_sql/gl_pipeline_impact_ap.view.lkml"

include: "/views/custom_sql/market_recon.view.lkml"

include: "/views/custom_sql/Clustdoc_Vendor_Log.view.lkml"

include: "/views/custom_sql/vendor_change_log.view.lkml"

include: "/views/custom_sql/vendor_change_log_all_time.view.lkml"

include: "/views/custom_sql/ap_ar_related_party.view.lkml"

include: "/views/custom_sql/ar_related_party.view.lkml"

include: "/views/custom_sql/damaged_goods.view.lkml"

include: "/views/custom_sql/Expense_line_impact.view.lkml"

include: "/views/custom_sql/t3_damaged_goods.view.lkml"

include: "/views/custom_sql/vendor_contact_info.view.lkml"

include: "/views/custom_sql/excluded_po_lines.view.lkml"

include: "/views/custom_sql/vendor_contact_pay_info.view.lkml"

include: "/views/custom_sql/vendor_comparison.view.lkml"

include: "/views/custom_sql/accounting_month_end_close_status_floqast.view.lkml"

include: "/views/custom_sql/BisTrack_Product_Import.view.lkml"

include: "/views/custom_sql/vendor_comparison_entity.view.lkml"

include: "/views/custom_sql/invoices_unextracted_unapproved.view.lkml"

include: "/views/custom_sql/eagleproducts.view.lkml"

include: "/views/custom_sql/sage_dept_hierarchy.view.lkml"

include: "/views/custom_sql/branch_manager_history.view.lkml"

include: "/views/custom_sql/sage_materials_hierarchy.view.lkml"

include: "/views/custom_sql/Sage_Department_Expense_Line_Relationships.view.lkml"

include: "/views/custom_sql/intacct_gl_high_detail_filtered.view.lkml"

include: "/views/custom_sql/clio_newly_imported_matters.view.lkml"

include: "/views/custom_sql/bistrack_vendor_pay_terms.view.lkml"

include: "/views/custom_sql/Expense_lines_sage_vs_budget_variations.view.lkml"

include: "/views/custom_sql/t3_vendors_mapping.view.lkml"

include: "/views/custom_sql/new_vendor_setup.view.lkml"

include: "/views/custom_sql/pending_invoices_per_concur_approver.view.lkml"

include: "/views/custom_sql/concur_approvers_per_sage_location.view.lkml"

include: "/views/custom_sql/bistrack_vendor_change_log.view.lkml"

include: "/views/custom_sql/cc_purchase_order_metrics.view.lkml"

include: "/views/custom_sql/cc_credit_card_metrics.view.lkml"

include: "/views/custom_sql/bt_employee_pricing_margins.view.lkml"

include: "/views/custom_sql/bt_cycle_count.view.lkml"

include: "/views/custom_sql/costcapture_monthly_backdating.view.lkml"

include: "/views/custom_sql/intacct_monthly_backdating.view.lkml"

include: "/views/custom_sql/intacct_user_backdating.view.lkml"

include: "/views/custom_sql/costcapture_user_backdating.view.lkml"

include: "/views/custom_sql/costcapture_branch_backdating.view.lkml"

include: "/views/custom_sql/intacct_department_backdating.view.lkml"

include: "/views/custom_sql/costcapture_inventory_backdating.view.lkml"

include: "/views/custom_sql/receipt_backdating_cc.view.lkml"

include: "/views/custom_sql/receipt_backdating_intacct.view.lkml"

include: "/views/custom_sql/bt_smartbuild_pricing.view.lkml"

include: "/views/custom_sql/bt_ar_reserve.view.lkml"

include: "/views/custom_sql/fleettrack_user_permissions.view.lkml"

include: "/views/custom_sql/t3_sage_intacct_location_mapping.view.lkml"

# Commented out due to low usage on 2026-03-30
# explore: intacct_gl_activity {}

explore: intacct_gl_activity_dds {
  label: "Intacct GL Activity DDS"
}

explore: sage_permissions {
  label: "Sage Permissions"
}

explore: concur_user_permissions {
  label: "Concur User Permissions"
}

explore: intacct_gl_activity_dds_new {
  label: "Intacct GL Activity DDS New"
}

# Commented out due to low usage on 2026-03-30
# explore: gl_detail_v3 {
#   label: "GL Detail V3"
# }

explore: aprecord_time_difference {
  label: "Time Difference for AP Records"
}

explore: ecommerce_vendor_test {
  label: "ECommerce Vendor Test"
}

# Commented out due to low usage on 2026-03-30
# explore: intacct_dup_apa_apj {
#   label: "Potential Duplicate APJ/APA"
# }

explore: intacct_dup_apa_apj_v2 {
  label: "Potential Duplicate Bill/APA"
}

explore: closed_pos_no_gl_entry {
  label: "Closed POs without GL Entries"
}

explore: one_sided_entries_pos {
  label: "One-sided Entries - POs"
}

explore: out_of_balance_entries {
  label: "Out of Balance Entries"
}

explore: gl_reviewer_v2 {
  label: "GL Reviewer V2"
}

explore: intacct_gl_high_detail{
  label: "Intacct GL High Detail"
}

explore: bills_with_pos_after_closing_period {
  label: "Bills with POs after Closing Period"
}

# Commented out due to low usage on 2026-03-30
# explore: pos_to_close_partial_conversions {
#   label: "Potential POs to Close - Partial Conversions"
# }

explore: gl_approver_audit {
  label: "GL Approver Audit"
}

explore: gl_pipeline_impact_purchasing {
  label: "GL Pipeline Impact - Purchasing"
}

explore: gl_pipeline_impact_gl {
  label: "GL Pipeline Impact - GL"
}

# Commented out due to low usage on 2026-03-30
# explore: gl_pipeline_impact_ap {
#   label: "GL Pipeline Impact - AP"
# }

explore: market_recon {
  label: "Market Hierarchy Reconciliation"
}

explore: clustdoc_vendor_log {
  label: "Clustdoc Vendor Log"
}

explore: vendor_change_log {
  label: "Vendor Change Log"
}

explore: vendor_change_log_all_time {
  label: "Vendor Change Log - All Time"
}

explore: ap_ar_related_party {
  label: "AP Related Party"
}

explore: ar_related_party {
  label: "AR Related Party"
}

# Commented out due to low usage on 2026-03-30
# explore: damaged_goods {
#   label: "Damaged Goods"
# }

explore: Expense_line_impact {
  label: "Expense Line Impact"
}

explore: t3_damaged_goods {
  label: "T3 Damaged Goods"
}

explore: vendor_contact_info {
  label: "Vendor Contact Info"
}

# Commented out due to low usage on 2026-03-30
# explore: excluded_po_lines {
#   label: "Excluded PO Lines"
# }

explore: vendor_contact_pay_info {
  label: "Vendor Contact/Payment Info"
}

explore: vendor_comparison {
  label: "Vendor Comparison"
}

explore: accounting_month_end_close_status_floqast {
  label: "Accounting MEC-FQ"
}

explore: bistrack_product_import {
  label: "BisTrack Product-Import"
}

explore: vendor_comparison_entity {
  label: "Vendor Comparison Entity"
}

# Commented out due to low usage on 2026-03-30
# explore: invoices_unextracted_unapproved {
#   label: "Invoices Unextracted and Unapproved"
# }

explore: eagleproducts {
  label: "eagleproducts"
}

explore: sage_dept_hierarchy {
  label: "Sage Department Hierarchy"
}

explore: branch_manager_history {
  label: "Branch Manager History"
}

# Commented out due to low usage on 2026-03-30
# explore: sage_materials_hierarchy {
#   label: "Sage Materials Hierarchy"
# }

explore: sage_department_expense_line_relationships  {
  label: "Sage_Department_Expense_Line_Relationships"
}

explore: intacct_gl_high_detail_filtered {
  label: "GL High Detail - Filtered Vendors"
}

explore: clio_newly_imported_matters {
  label: "Clio Matters"
}

explore: bistrack_vendor_pay_terms {
  label: "Bistrack/Forge and Build Pay Terms"
}

explore: expense_lines_sage_vs_budget_variations {
  label: "Expense Lines Sage vs Budget Variations 2025"
}

explore: t3_vendors_mapping {
  label: "T3 Vendors Mapping"
}

explore: new_vendor_setup {
  label: "New Vendor Setup"
}

explore: pending_invoices_per_concur_approver {
  label: "Pending Invoices Per Concur Approver"
}

explore: concur_approvers_per_sage_location {
  label: "Concur Approvers Per Sage Location"
}

explore: bistrack_vendor_change_log {
  label: "Bistrack Vendor Change Log"
}

explore: cc_purchase_order_metrics {
  label: "CostCapture PO Metrics"
}

explore: cc_credit_card_metrics {
  label: "CostCapture Credit Card Metrics"
}

explore: bt_employee_pricing_margins {
  label: "BisTrack Employee Pricing Margins"
}

explore: bt_cycle_count {
  label: "BisTrack Cycle Count"
}

explore: receipt_backdating_cc {
  label: "CostCapture Receipt Backdating"
}

explore: receipt_backdating_intacct {
  label: "Sage Intacct Receipt Backdating"
}

explore: bt_smartbuild_pricing {
  label: "BisTrack Smartbuild Pricing"
}

explore: bt_ar_reserve {
  label: "BisTrack AR Reserve"
}

explore: fleettrack_user_permissions {
  label: "FleetTrack User Permissions"
}

explore: t3_sage_intacct_location_mapping {
  label: "T3 ↔ Sage Intacct Location Mapping"
}
