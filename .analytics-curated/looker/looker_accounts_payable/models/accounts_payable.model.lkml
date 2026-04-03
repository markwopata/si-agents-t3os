connection: "es_snowflake"

# include views here

include: "/views/custom_sql/**.view.lkml"                # include all views in the views/ folder in this project

include: "/views/custom_sql/accounts_payable_vendor_activity.view.lkml"

include: "/views/custom_sql/vendor_status.view.lkml"

include: "/views/custom_sql/vendor_activity_summary.view.lkml"

include: "/views/custom_sql/ap_bill_by_method.view.lkml"

include: "/views/custom_sql/vendors_ytd_payments.view.lkml"

include: "/views/custom_sql/total_billed_by_vendor.view.lkml"

include: "/views/custom_sql/yooz_01_last_submitted_by.view.lkml"

include: "/views/custom_sql/unconverted_po_entry.view.lkml"

# include: "/views/custom_sql/poe_to_close.view.lkml"

include: "/views/custom_sql/po_receipts_to_sync.view.lkml"

include: "/views/custom_sql/vendors_without_attachment.view.lkml"

include: "/views/custom_sql/t3_purchase_order_status.view.lkml"

include: "/views/custom_sql/open_rerent_purchase_orders.view.lkml"

include: "/views/custom_sql/t3_receipts_with_bill_refs.view.lkml"

include: "/views/custom_sql/backdated_t3_receipts.view.lkml"

include: "/views/custom_sql/non_bulk_fleet_team_purchases.view.lkml"

include: "/views/custom_sql/t3_backdated_receipts_crossing_months.view.lkml"

include: "/views/custom_sql/t3_vendor_upload.view.lkml"

include: "/views/custom_sql/t3_markets_not_in_sage.view.lkml"

include: "/views/custom_sql/t3_vendors_needing_to_be_uploaded.view.lkml"

include: "/views/custom_sql/t3_purchase_order_exceptions.view.lkml"

include: "/views/custom_sql/t3_sage_vendor_id_edits.view.lkml"

include: "/views/custom_sql/t3_sage_vendor_lookup.view.lkml"

include: "/views/custom_sql/new_parts.view.lkml"

include: "/views/custom_sql/ap_bill_detail.view.lkml"

include: "/views/custom_sql/ap_payment_summary.view.lkml"

include: "/views/custom_sql/t3_missing_receipts_open_po.view.lkml"

include: "/views/custom_sql/ap_payments.view.lkml"

include: "/views/custom_sql/t3_vendors_for_inactivation.view.lkml"

include: "/views/custom_sql/t3_purchase_order_details.view.lkml"

include: "/views/custom_sql/markets_and_gms.view.lkml"

include: "/views/custom_sql/receipt_sync_difference.view.lkml"

include: "/views/custom_sql/sage_purchase_orders.view.lkml"

include: "/views/custom_sql/sage_pos_submitted_not_approved.view.lkml"

include: "/views/custom_sql/t3_user_lookup.view.lkml"

include: "/views/custom_sql/t3_group_permissions.view.lkml"

include: "/views/custom_sql/market_collector_assignments.view.lkml"

include: "/views/custom_sql/concur_invoices_processed_daily.view.lkml"

include: "/views/custom_sql/concur_batch_detail.view.lkml"

include: "/views/custom_sql/concur_not_submitted_invoice_and_detail.view.lkml"

include: "/views/custom_sql/ap_history.view.lkml"

include: "/views/custom_sql/extract_bl_and_exceptions.view.lkml"

include: "/views/custom_sql/concur_dup_inv_for_deletion.view.lkml"

include: "/views/custom_sql/concur_update_pos_select.view.lkml"

include: "/views/custom_sql/fleet_purchasing_ap_invoice_splitter.view.lkml"

include: "/views/custom_sql/clustdoc_vendor_sync_ts.view.lkml"

include: "/views/custom_sql/concur_inv_header_for_reassign.view.lkml"

include: "/views/custom_sql/po_detail_intacct.view.lkml"

include: "/views/custom_sql/intacct_no_billno_update.view.lkml"

include: "/views/custom_sql/concur_bill_detail_with_tax_frt.view.lkml"

include: "/views/custom_sql/t3_role_spending_limits.view.lkml"

include: "/views/custom_sql/vendor_activity.view.lkml"

include: "/views/custom_sql/apbill_to_po_walk.view.lkml"

include: "/views/custom_sql/concur_invoice_approvers.view.lkml"

include: "/views/custom_sql/concur_vendor_update.view.lkml"

include: "/views/custom_sql/sage_restricted_posting_location.view.lkml"

include: "/views/custom_sql/ap_aging_intacct.view.lkml"

include: "/views/custom_sql/budget_concur_missing_expense_lines.view.lkml"

include: "/views/custom_sql/intacct_vendor_pay_method.view.lkml"

include: "/views/custom_sql/cc_open_pos_and_concur_invs.view.lkml"

include: "/views/custom_sql/sage_access_24hr_policy_delta.view.lkml"

include: "/views/custom_sql/sage_access_24hr_role_delta.view.lkml"

include: "/views/custom_sql/sage_access_24hr_rights_delta.view.lkml"

include: "/views/custom_sql/sage_access_24hr_group_delta.view.lkml"

include: "/views/custom_sql/sage_access_24hr_group_role_delta.view.lkml"

include: "/views/custom_sql/sage_access_24hr_user_roles_delta.view.lkml"

include: "/views/custom_sql/sage_access_24hr_group_member_delta.view.lkml"

include: "/views/custom_sql/t3_superuser_po_admin_delta.view.lkml"

include: "/views/custom_sql/cost_capture_permissions.view.lkml"

include: "/views/custom_sql/costcapture_po_to_corporate.view.lkml"

include: "/views/custom_sql/costcapture_po_to_corporate.view.lkml"

include: "/views/custom_sql/costcapture_user_info.view.lkml"

include: "/views/custom_sql/noncorporate_transactions_to_7117.view.lkml"

include: "/views/custom_sql/corp_transactions_no_expense_line.view.lkml"

include: "/views/custom_sql/transactions_million_and_7700.view.lkml"

include: "/views/custom_sql/inaccurate_intaact_email.view.lkml"

include: "/views/custom_sql/invalid_active_managers.view.lkml"

include: "/views/custom_sql/invalid_journal_to_corporate.view.lkml"

include: "/views/custom_sql/transactions_corporate_1400.view.lkml"

include: "/views/ANALYTICS/epay_vendors_io.view"

include: "/views/custom_sql/invalid_gl_mapping.view.lkml"

include: "/views/custom_sql/costcapture_user_info_2.view.lkml"

include: "/views/custom_sql/test_vendor_creation_method.view.lkml"

include: "/views/custom_sql/vendor_intacct_vs_t3_status.view.lkml"

include: "/views/custom_sql/vendor_banking_error_log.view.lkml"

include: "/views/custom_sql/intacct_payments.view.lkml"

include: "/views/custom_sql/t3_invoice_detail.view.lkml"

include: "/views/custom_sql/bill_detail_potential_cc.view.lkml"

include: "/views/custom_sql/vendors_needing_attachment_folder.view.lkml"

include: "/views/custom_sql/purchase_orders.view.lkml"

include: "/views/custom_sql/vendor_history.view.lkml"

include: "/views/custom_sql/ap_dpo.view.lkml"

include: "/views/custom_sql/ap_dpo_terms_calc.view.lkml"

include: "/views/custom_sql/ap_accrual_rev_entry.view.lkml"

include: "/views/custom_sql/po_detail_test.view.lkml"

include: "/views/custom_sql/preferred_vendor.view.lkml"

include: "/views/custom_sql/basic_ap_detail.view.lkml"

include: "/views/custom_sql/vendor_invoice_overconversion.view.lkml"

include: "/views/custom_sql/apa_subledger_reconciliation.view.lkml"

include: "/views/custom_sql/concur_approvers_delegates.view.lkml"

include: "/views/ANALYTICS/spend_summary_mapping.view.lkml"

include: "/views/ANALYTICS/fleet_spend_core_noncore.view.lkml"

include: "/views/custom_sql/DUPLICATE_RECEIPT_CHECK/APA_SUBLEDGER.view.lkml"

include: "/views/custom_sql/ytd_vendor_walk.view.lkml"

include: "/views/custom_sql/t3_all_user_groups.view.lkml"

include: "/views/custom_sql/ci_to_si_compare.view.lkml"

include: "/views/custom_sql/wty_pmt_cust_to_vendor.view.lkml"

include: "/views/custom_sql/wty_pmt_error_log.view.lkml"

include: "/views/custom_sql/wty_pmt_on_hold.view.lkml"

include: "/views/custom_sql/cust_vend_warranty_cr_mapping.view.lkml"

include: "/views/custom_sql/po_approval_limits_by_user.view.lkml"

include: "/views/custom_sql/reversed_warranty_payments.view.lkml"

include: "/views/custom_sql/warranty_reversals_by_user.view.lkml"

include: "/paperless_billing.view.lkml"

include: "/views/custom_sql/FINANCIAL_SYSTEMS/ap_bills_v2.view.lkml"

include: "/views/custom_sql/ap_review_forecast.view.lkml"

include: "/views/custom_sql/po_sage_sync_error.view.lkml"

include: "/views/ANALYTICS/part_substitutes.view.lkml"

include: "/views/ANALYTICS/part_suppression_categories.view.lkml"

include: "/views/ANALYTICS/market_region_xwalk.view.lkml"

include: "/views/concur/unsubmitted_invoices.view.lkml"

include: "/views/vic/vic_po_line_detail.view.lkml"
# explores go here
#explore: accounts_payable_vendor_activity {}

# explore: vendor {}

# explore: vendor_activity_summary { --MB comment out 10-10-23 due to inactivity
#   case_sensitive: no
# }

explore: ap_bill_by_method {}

explore: total_billed_by_vendor {}

# Commented out due to low usage on 2026-03-31
# explore: yooz_01_last_submitted_by {}

explore: unconverted_po_entry {
  label: "Unconverted Purchase Order Entry"
}

# explore: poe_to_close { --BD comment out 11/15 old query, no longer used
#   label: "PO Entry To Close"
# }

explore: po_receipts_to_sync {
  label: "PO Receipts To Sync"
}

explore: vendors_without_attachment {
  label: "Vendors Without Attachment"
}

explore: t3_purchase_order_status {
  label: "PO Status (T3)"
}

explore: warranty_reversals_by_user {
  label: "warranty reversals by user"
}

# Commented out due to low usage on 2026-03-31
# explore: vic_po_line_detail {
#   label: "Vic.ai PO Details"
# }

# Commented out due to low usage on 2026-03-31
# explore: open_rerent_purchase_orders {
#   label: "Open ReRent Purchase Orders (T3)"
# }

# explore: t3_receipts_with_bill_refs { --MB comment out 10-10-23 due to inactivity
#   label: "T3 Receipts With Bill Refs"
# }

# explore: backdated_t3_receipts { --MB comment out 10-10-23 due to inactivity
#   label: "Backdated Receipts Crossing Months"
# }

# Commented out due to low usage on 2026-03-31
# explore: non_bulk_fleet_team_purchases {
#   label: "Non-Bulk Fleet Team Purchases"
# }

explore: t3_backdated_receipts_crossing_months {
  label: "T3 Backdated Receipts Crossing Months"
}

# Commented out due to low usage on 2026-03-31
# explore: t3_vendor_upload {
#   label: "T3 Vendor Upload"
# }

explore: t3_markets_not_in_sage {
  label: "T3 Markets Not In Sage"
}

explore: t3_vendors_needing_to_be_uploaded {
  label: "Vendors For T3 Upload"
}

# Commented out due to low usage on 2026-03-31
# explore: t3_purchase_order_exceptions {
#   label: "Purchase Order Exceptions"
# }

# Commented out due to low usage on 2026-03-31
# explore: t3_sage_vendor_id_edits {
#   label: "Vendor ID Edits"
# }

explore: t3_sage_vendor_lookup {
  label: "Vendor Lookup"
}

explore: new_parts {
  label: "Created Parts"
}

explore: ap_bill_detail {
  label: "AP Bill Detail"
}

# Commented out due to low usage on 2026-03-31
# explore: ap_payment_summary {
#   label: "AP Payment Summary"
# }

# Commented out due to low usage on 2026-03-31
# explore: t3_missing_receipts_open_po {
#   label: "Missing PO Receipts"
# }

explore: ap_payments {
  label: "AP Payments"
}

explore: ap_payments_no_filter {
  label: "AP Payments No Filter"

  join: spend_summary_mapping {
    type: left_outer
    relationship: many_to_one
    sql_on: ${ap_payments_no_filter.account_v2} = ${spend_summary_mapping.account};;
  }

  join: ytd_vendor_walk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${ap_payments_no_filter.vendor_id} = ${ytd_vendor_walk.vendor_id};;
  }
}


# Commented out due to low usage on 2026-03-31
# explore: ap_payments_no_filter_summary {
#   label: "AP Payments No Filter Summary"
# }

explore: t3_vendors_for_inactivation {
  label: "Vendors for T3 Inactivation"
}

explore: t3_purchase_order_details {
  label: "Purchase Order Details"

  join: part_substitutes_flag_sub_type {
    type: left_outer
    relationship: many_to_one
    sql_on: ${t3_purchase_order_details.part_id} = ${part_substitutes_flag_sub_type.part_id} ;;
  }
  join: part_suppression_categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${t3_purchase_order_details.part_id} = ${part_suppression_categories.part_id} ;;
  }
  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${t3_purchase_order_details.deliver_to_branch_id}=${market_region_xwalk.market_id} ;;
  }
  join: unsubmitted_invoices {
    type:  left_outer
    relationship: one_to_many
    sql_on: ${t3_purchase_order_details.po_number}=${unsubmitted_invoices.purchase_order_number}
    and ${t3_purchase_order_details.vendor_id} = ${unsubmitted_invoices.supplier_code}
    and
    ${unsubmitted_invoices._es_update_timestamp_raw} = (
  select max(_es_update_timestamp)
  from analytics.concur.unsubmitted_invoices
  );;
  }
}

explore: markets_and_gms {
  label: "Markets And GMs"
}

# Commented out due to low usage on 2026-03-31
# explore: receipt_sync_difference {
#   label: "Receipt Sync Difference"
# }

explore: sage_purchase_orders {
  label: "Sage Purchase Orders"
}

explore: sage_pos_submitted_not_approved {
  label: "Sage Purchase Orders Submitted but not Approved"
}

# Commented out due to low usage on 2026-03-31
# explore: t3_user_lookup {
#   label: "T3 User Lookup"
# }

# Commented out due to low usage on 2026-03-31
# explore: t3_group_permissions {
#   label: "T3 Group Permissions"
# }

explore: market_collector_assignments {
  label: "Market Collector Assignments"
}

explore: concur_invoices_processed_daily {
  label: "Concur Invoices Processed - Daily"
}

explore: concur_batch_detail {
  label: "Concur Batch Detail"
}

explore: concur_not_submitted_invoice_and_detail {
  label: "Concur All Unsubmitted Invoices"
}

# Commented out due to low usage on 2026-03-31
# explore: ap_history {
#   label: "AP History"
# }

explore: intacct_payments {
  label: "Intacct Payments"
}

explore: ap_open_po_in_intacct_not_edited {
  label: "ap_open_po_in_intacct_not_edited"
}

explore: extract_bl_and_exceptions {
  label: "Concur Extract Backlog"
}

# Commented out due to low usage on 2026-03-31
# explore: concur_dup_inv_for_deletion {
#   label: "Concur Duplicate Invoices"
# }

# Commented out due to low usage on 2026-03-31
# explore: concur_update_pos_select {
#   label: "Concur Update Select POs"
# }

explore: fleet_purchasing_ap_invoice_splitter {
  label: "Fleet Purchasing AP Invoice Splitter"
}

explore: clustdoc_vendor_sync_ts {
  label: "Clustdoc Vendor Sync Troubleshooting"
}

# explore: concur_inv_header_for_reassign { --MB comment out 10-10-23 due to inactivity
#   label: "Concur Invoice Reassignment"
# }

explore: po_detail_intacct {
  label: "Intacct PO Detail"
}

explore: intacct_no_billno_update {
  label: "Intacct No Bill Number Update"
}

explore: sage_out_of_balance {
  label: "sage out of balance"
}

# explore: sync_log_po {
#   label: "sync_log_po"
# }

# explore: concur_bill_detail_with_tax_frt { --MB comment out 10-10-23 due to inactivity
#   label: "Concur Bills with Tax and Freight Detail"
# }

# Commented out due to low usage on 2026-03-31
# explore: t3_role_spending_limits {
#   label: "T3 Role Spending Limits"
# }

explore: vendor_activity {
  label: "Vendor Activity"
}

explore: t3_costcapture_user_permissions {
  label: "CostCapture User Permissions"
}

explore: t3_inventory_transactions {
  label: "T3 Inventory Transactions"
}

# Commented out due to low usage on 2026-03-31
# explore: apbill_to_po_walk {
#   label: "AP Bill to PO Walk"
# }

# Commented out due to low usage on 2026-03-31
# explore: concur_invoice_approvers {
#   label: "Concur Invoice Approvers"
# }

# explore: concur_vendor_update { --MB comment out 10-10-23 due to inactivity
#   label: "Concur Vendor Update"
# }

explore: sage_restricted_posting_location {
  label: "Sage Restricted Posting Location"
}

explore: ap_aging_intacct {
  label: "AP Aging"
}

# Commented out due to low usage on 2026-03-31
# explore: ci_to_si_compare {
#   label: "Concur Extract Variance"
# }

explore: budget_concur_missing_expense_lines {
  label: "Budget - Missing Expense Lines - Concur"
}

explore: intacct_vendor_pay_method {
  label: "Intacct Vendor Pay Method"
  #sql_always_where:  ${epay_vendors_io.epay_status} not like '%#N/A%' ;;
  join: epay_vendors_io {
    view_label: "epay_vendors_io"
    type: left_outer
    relationship: many_to_one
    sql_on: ${intacct_vendor_pay_method.vendor_id} = ${epay_vendors_io.vendor_id};;
  }

  join: vendors_ytd_payments {
    view_label: "vendors_ytd_payments"
    type: left_outer
    relationship: many_to_one
    sql_on: ${intacct_vendor_pay_method.vendor_id} = ${vendors_ytd_payments.vendor_id};;

  }
  }


explore: cc_open_pos_and_concur_invs {
  label: "CostCapture Open POs"
}

explore: cost_capture_open_pos {
  label: "CostCapture Open POs"
  from: cc_open_pos_and_concur_invs
  always_join: [costcapture_po_users_and_branches]
  sql_always_where:
  costcapture_po_users_and_branches.user_login = '{{_user_attributes['email']}}' or costcapture_po_users_and_branches.user_login = 'put test user email in here to see what they would see'
  ;;

  join: costcapture_po_users_and_branches {
    view_label: "cc_po_users_and_branches"
    type: inner
    relationship: many_to_one
    sql_on: ${cost_capture_open_pos.branch_id} = ${costcapture_po_users_and_branches.branch}
      ;;
  }}

  explore: sage_access_24hr_policy_delta {
    label: "Sage Access 24HR Policy Delta"
  }

  explore: sage_access_24hr_role_delta {
    label: "Sage Access 24HR Role Delta"
  }

  explore: sage_access_24hr_rights_delta {
    label: "Sage Access 24HR Rights Delta"
  }

  explore: sage_access_24hr_group_delta {
    label: "Sage Access 24HR Group Delta"
  }

  explore: sage_access_24hr_group_role_delta {
    label: "Sage Access 24HR Group Role Delta"
  }

  explore: sage_access_24hr_user_roles_delta {
    label: "Sage Access 24HR User Roles Delta"
  }

  explore: sage_access_24hr_group_member_delta {
    label: "Sage Access 24HR Group Member Delta"
  }

  explore: t3_superuser_po_admin_delta {
    label: "T3 SuperUser and Received PO Admin"
  }

  # Commented out due to low usage on 2026-03-31
  # explore: cost_capture_permissions {
  #   label: "Cost Capture Permissions"
  # }

  explore: costcapture_po_to_corporate {
    label: "CostCapture PO Written to Corporate"
  }

  explore: costcapture_user_info {
    label: "CostCapture User Info and Permissions"
  }

  explore: noncorporate_transactions_to_7117 {
    label: "Transactions posted to 7117 at a non-corporate location ID"
  }

  explore: corp_transactions_no_expense_line {
    label: "Transactions to Corporate without Expense Lines"
  }

  explore: transactions_million_and_7700 {
    label: "Transactions to 1000000 and Account 7700"
  }

  explore: inaccurate_intaact_email {
    label: "Inaccurate Intaact Emails"
  }

  explore: invalid_active_managers {
    label: "Invalid Active Budget Managers"
  }

  explore: invalid_journal_to_corporate {
    label: "Invalid Journal (APJ) to Corporate"
  }

  explore: transactions_corporate_1400 {
    label: "Transactions to Corporate in Acc 1400"
  }

  explore: invalid_gl_mapping {
    label: "Invalid GL Mapping "
  }

  explore: costcapture_user_info_2 {
    label: "CostCapture User Info 2"
  }

  # Commented out due to low usage on 2026-03-31
  # explore: test_vendor_creation_method {
  #   label: "Test Vendor Creation Method"
  # }

  # Commented out due to low usage on 2026-03-31
  # explore: vendor_intacct_vs_t3_status {
  #   label: "Vendor Intacct-T3 Updates"
  # }

  # Commented out due to low usage on 2026-03-31
  # explore: vendor_banking_error_log {
  #   label: "Vendor Banking Error Log"
  # }

  # Commented out due to low usage on 2026-03-31
  # explore: t3_invoice_detail {
  #   label: "T3 Invoice Detail"
  # }

  # Commented out due to low usage on 2026-03-31
  # explore: vendors_needing_attachment_folder {
  #   label: "Vendors Needing Attachment Folder"
  # }

  explore: purchase_orders {
    label: "Purchase Orders"
  }

  explore: vendor_history {
    label: "Vendor History"

    # Define join to ap_dpo view
  join: ap_dpo {
    type: left_outer
    relationship: one_to_many
    sql_on: ${vendor_history.vendor_id} = ${ap_dpo.vendor_id} ;;
  }

    #Define join to ap_dpo_terms_calc view
  join: ap_dpo_terms_calc {
    type: left_outer
    relationship: one_to_many
    sql_on: ${vendor_history.vendor_id} = ${ap_dpo_terms_calc.vendor_id} ;;
  }
}

  # Commented out due to low usage on 2026-03-31
  # explore: ap_dpo {
  #   label: "AP DPO"
  # }
  # Commented out due to low usage on 2026-03-31
  # explore: ap_dpo_terms_calc {
  #   label: "AP DPO Terms Caculation"
  # }

  explore: ap_accrual_rev_entry {
    label: "AP Accrual Reverse Entry"
  }

  # Commented out due to low usage on 2026-03-31
  # explore: po_detail_test {
  #   label: "PO Detail Test"
  # }

  # Commented out due to low usage on 2026-03-31
  # explore: preferred_vendor {
  #   label: "Preferred Vendor"
  # }

  # Commented out due to low usage on 2026-03-31
  # explore: basic_ap_detail {
  #   label: "Basic AP Detail"
  # }

  explore: vendor_invoice_overconversion {
    label: "Vendor Invoice Overconversion"
  }

  explore: apa_subledger_reconciliation {
    label: "APA Subledger Reconciliation"
  }

  explore: concur_approvers_delegates {
    label: "Concur Approvers & Delegates"
  }

  explore: apa_subledger {
    label: "Duplicate Receipt Check"
  }

  explore: t3_all_user_groups {
    label: "T3 - All User Groups"
  }

  explore: wty_pmt_cust_to_vendor {
    label: "Warranty Payment Vendor"
  }

  explore: wty_pmt_error_log {
    label: "Warranty Payment Error Log"
  }

  explore: wty_pmt_on_hold {
    label: "Warranty Payment Backlog"
  }

  explore: cust_vend_warranty_cr_mapping {
    label: "Customer to Vendor Warranty Credit Mapping"
  }

  explore: reversed_warranty_payments {
    label: "Reversed Warranty Payments"
  }

  explore:  bill_detail_potential_cc {}

  explore: spend_summary {
    view_name: ap_payments_no_filter

    join: spend_summary_mapping {
      type: left_outer
      relationship: many_to_one
      sql_on: ${ap_payments_no_filter.account_v2} = ${spend_summary_mapping.account};;
    }
    join: ytd_vendor_walk {
      type: left_outer
      relationship: many_to_one
      sql_on: ${ap_payments_no_filter.vendor_id} = ${ytd_vendor_walk.vendor_id};;
    }
  }

  explore: spend_summary_forecast {
    view_name: ap_payments_no_filter

    join: spend_summary_mapping {
      type: left_outer
      relationship: many_to_one
      sql_on: ${ap_payments_no_filter.account_v2} = ${spend_summary_mapping.account};;
    }

    join: ytd_vendor_walk {
      type: left_outer
      relationship: many_to_one
      sql_on: ${ap_payments_no_filter.vendor_id} = ${ytd_vendor_walk.vendor_id};;
    }

    join: ap_review_forecast {
      type: full_outer
      relationship: many_to_one
      sql_on: ${ap_payments_no_filter.key_2} = ${ap_review_forecast.key};;
    }
  }

  explore:  fleet_spend_core_noncore {}

  explore:  po_approval_limits_by_user {}

  explore: paperless_billing {
    label: "Paperless Billing"
  }

  explore: ap_bills_v2 {
    label: "AP Bills - Financial Systems"
  }

  explore: po_sage_sync_error {
    label: "PO Sage Sync Error"
  }
