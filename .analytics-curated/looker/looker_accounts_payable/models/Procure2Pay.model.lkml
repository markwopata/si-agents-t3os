connection: "es_snowflake_analytics"

include: "/views/**/*.view.lkml"               # include all views in the views/ folder in this project
include: "/views/ANALYTICS/*.view.lkml"
include: "/views/concur/*.view.lkml"
include: "/views/intacct/*view.lkml"
include: "/views/custom_sql/fleet_track_lines.view.lkml"
include: "/views/custom_sql/gm_data.view.lkml"
include: "/views/custom_sql/sm_data.view.lkml"
include: "/views/custom_sql/submitted_user_data.view.lkml"
include: "/views/custom_sql/employee_details_lookup_data.view.lkml"
include: "/views/custom_sql/unsub_accrual.view.lkml"
week_start_day: sunday

explore: ap_po_amt_remaining {
  from: ap_po_amt_remaining
  label: "AP PO Amount Remaining"
}

explore: unsub_accrual {
  from: unsub_accrual
  label: "p2p Unsub Accrual"

  join: p2p_entry_que_any_status {
    sql_on: ${unsub_accrual.purchase_order_number} = ${p2p_entry_que_any_status.po_entry_number} ;;
    relationship: many_to_one
    type: left_outer
  }
}

explore: fleet_track_lines {
  from: fleet_track_lines
  label: "Fleet Track Lines"

  join: asset_nbv_all_owners {
    sql_on: ${fleet_track_lines.asset_id} = ${asset_nbv_all_owners.asset_id} ;;
    relationship: many_to_one
    type: left_outer
  }
}

explore: shipped_serial {
  from: fleet_track_lines
  label: "Shipped/Serial"

  join: gm_data {
    sql_on: ${shipped_serial.market_id} = ${gm_data.market_id} ;;
    relationship: many_to_one
    type: left_outer
  }

  join: sm_data {
    sql_on: ${shipped_serial.market_id} = ${sm_data.market_id} ;;
    relationship: many_to_one
    type: left_outer
  }

  join: submitted_user_data {
    sql_on: ${shipped_serial.submitted_by_user_id} = ${submitted_user_data.user_id} ;;
    relationship: many_to_one
    type: left_outer
  }

  join: employee_details_lookup_data {
    sql_on: ${gm_data.direct_manager_employee_id} = ${employee_details_lookup_data.employee_id} ;;
    relationship: many_to_one
    type: left_outer
  }

  join: asset_nbv_all_owners {
    sql_on: ${shipped_serial.asset_id} = ${asset_nbv_all_owners.asset_id} ;;
    relationship: many_to_one
    type: left_outer
  }
}

explore: processed_invoices_by_ap_user_plus_history {


}
#these are for the productivity table
explore: processed_invoices_by_ap_user_history_raw {}

explore: proc_inv_system_percent_clean_vs_user_submitted_daily {}


explore: proc_inv_ap_prod_year_to_date_submissions {}
explore: processed_invoices_by_ap_user {}

#these are for visualizing the pending approval in concur
# Commented out due to low usage on 2026-03-31
# explore: pending_branch_approval {}
explore: pending_hq_approval {}


#this is for data on the accrual initiative where 45 days and older gets closed out
explore: intacct_ap_p2p_master {}

explore: gs_p_2_p_receipt_log {}

#
explore: deleted_invoices {}

##alerts
explore: sync_log_po {}

explore: sync_alert_from_t3 {}

# explore: p2p_concur_invoices_received {}

explore: p2p_concur_invoices_received {
  join: p2p_ap_rep_vendor_assignments {
    # type: inner
    relationship: many_to_one
    sql_on: ${p2p_concur_invoices_received.vendor_code} = ${p2p_ap_rep_vendor_assignments.vendor_code} ;;
  }
}


##percent clean initiative
explore: p2p_auto_submits {}

explore: p2p_adj_auto_submits {}
#trying to track spend for BoB fleet
# Commented out due to low usage on 2026-03-31
# explore: p2p_sage_payables_1307_with_gs_vendors_bob {}
# Commented out due to low usage on 2026-03-31
# explore: p2p_1307_fleet_payments {}
##purchase order entry track approval time
# Commented out due to low usage on 2026-03-31
# explore: p2p_po_entry_approval_flow {}


#APPROVAL REQUIRED
explore: p2p_purchase_order_entry_que {}

#spreadsheet fleet uses for almost everything dallas updates daily in the morning by 9am
# Commented out due to low usage on 2026-03-31
# explore: p2p_fleet_master_spreadsheet {}
#spreadsheet for bob
explore:book_of_business_april_24 {}
# Commented out due to low usage on 2026-03-31
# explore:finance_status_bob {}
# explore: p2p_bob_finance_status_download {}
#for dallas to show fleet track items
# Commented out due to low usage on 2026-03-31
# explore:
# company_purchase_order_line_items {}

# Commented out due to low usage on 2026-03-31
# explore: p2p_fleet_payables_status {}

# Commented out due to low usage on 2026-03-31
# explore: p2p_fleet_payables_spend {}

explore: avg_vendor_time_to_pay {}
# Commented out due to low usage on 2026-03-31
# explore: aprecord {
#
#     join: intacct_vendors {
#       # type: inner
#       relationship: many_to_one
#       sql_on: ${aprecord.vendorid} = ${intacct_vendors.vendorid} ;;
#     }
#   }

explore: unsubmitted_invoices_db {
  label: "p2p_unsubmitted_invoices_db"
  join: pending_cost_object_by_expense_type {
    sql_on: ${unsubmitted_invoices_db.purchase_order_number} = ${pending_cost_object_by_expense_type.po_number} and ${unsubmitted_invoices_db.purchase_order_number} IS NOT NULL ;;
    type: inner
    relationship: many_to_one
  }
}

explore: pending_cost_object_by_expense_type {}
explore: t3_damaged_items {}
explore: ap_payment_avg_days_to_pay {}
explore: ap_avg_days_dy {}

explore: fleet_assigned_analyst {}


explore: arrecord {
  label: "p2p_reimbursement_summary"
  join: arinvoicepayment {
    sql_on: ${arrecord.recordno} = ${arinvoicepayment.recordkey} ;;
    relationship: one_to_many
  }

    join: arinvoicepayment_sum {
      sql_on: ${arrecord.recordno} = ${arinvoicepayment_sum.recordkey};;
      type: left_outer
      relationship: one_to_one

    }


  join: ardetail {
    sql_on: ${arrecord.recordno} = ${ardetail.recordkey} and ${ardetail.amount} < 0
    ;;
    relationship: one_to_many
  }
  sql_always_where: ${arrecord.customerid} LIKE 'C-%'

  and  ${arrecord.recordtype} = 'arinvoice'

  ;;
}
# Filter to include only customers starting with 'C-'
  # always_filter: {
  #   filters: [arrecord.customer_starts_with_c: "yes"]
  # }


explore: accrual_error_correction_abnormalities {}

explore: ap_accrual_bill_to_receipt {label:"p2p_ap_accrual_bill_to_receipt"}
explore: ap_accrual_bill_to_receipt_filtered_public {label:"p2p_public_filtered_ap_accrual_bill_to_receipt"}

explore: p2p_bob_finance_status_download {}
explore: fleet_analyst_to_bob_gsheets{label:"p2p_fleet_analyst_to_bob_gsheets"}
# Commented out due to low usage on 2026-03-31
# explore: fleet_payables_spreadsheet {label:"p2p_fleet_payables_spreadsheet"}

explore: ap_payment_summary {label:"p2p_ap_payment_summary"}

explore: ap_weekly_payables {label: "p2p_ap_weekly_payables"}

explore: ap_weekly_payables_refined {label: "p2p_ap_weekly_payables_refined"}

explore: ap_fleet_unpaid {
  join: fleet_track_lines {
  type:  left_outer
  sql_on: ${ap_fleet_unpaid.order_number} = ${fleet_track_lines.order_number};;
  relationship: one_to_one
  }
}

explore: ap_fleet_paid {}
explore: intacct_vendors {}

explore: budget_managers {label:"p2p_budget_managers"}
explore: department_heads {label:"p2p_department_heads"}

explore: vendor_coi_audit {
  join: ap_bill_detail {
    type: left_outer
    sql_on: ${vendor_coi_audit.vendor_id} = ${ap_bill_detail.vendor_id};;
    relationship: one_to_many
  }
}

explore: clustdoc_dossiers {
  join: intacct_vendors {
    type:  left_outer
    sql_on: ${clustdoc_dossiers.application_id} = ${intacct_vendors.vendor_portal_id};;
    relationship:  one_to_one
  }
}

# Commented out due to low usage on 2026-03-31
# explore: epay_vendors_in_sync_log {}
# Commented out due to low usage on 2026-03-31
# explore: epay_vendors_intacct {}
# Commented out due to low usage on 2026-03-31
# explore: epay_vendors_not_synced {}
explore: gl_linked_po_lines {}
explore: user_created_assets {label:"p2p_user_created_assets"}

explore: jotform_ap_weekly_payables {label:"p2p_jotform_ap_weekly_payables"}
explore: budget_expense_lines {label: "p2p_budget_expense_lines"}
# explore: cmdetail {label:"p2p_cm_detail"}

explore: cmrecord {
  join: cmdetail {
  type: left_outer
  sql_on: ${cmrecord.recordno} = ${cmdetail.recordkey};;
  relationship: one_to_many
  }
  label:"p2p_cm_record_detail"}

explore: ap_aging_sage_approved_plus_concur_backlog {label:"p2p_ap_aging_sage_approved_plus_concur_backlog"}

explore: p2p_entry_que_any_status {label:"p2p_entry_que_any_status"}

explore: procurement_vendor_lookup {label:"p2p_procurement_vendor_lookup"}
explore: procurements_diversity_no_spend {label:"p2p_procurements_diversity_no_spend"}
# Commented out due to low usage on 2026-03-31
# explore: diversity_thresholds {
#   join: diversity_payments {
#     type: left_outer
#     relationship: one_to_many
#     sql_on:UPPER(TRIM(${diversity_thresholds.diversity_classification})) =
#       UPPER(TRIM(${diversity_payments.contract})) ;;
#
#
#   }
# }

explore: admin_t3_mismatches {label:"p2p_admin_t3_mismatches"}
explore: ap_procurement_non_fleet_rebates {label:"p2p_ap_procurement_non_fleet_rebates"}
