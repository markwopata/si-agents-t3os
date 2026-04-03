connection: "prod_financial_systems"

include: "/views/FINANCIAL_SYSTEMS__PROD/auditing_gold/*"
explore: charge_types {}
explore: internal_rentals {}
explore: over_credit {}
explore: customer_class {}
explore: double_rented_assets {}

include: "/views/FINANCIAL_SYSTEMS__PROD/accrual_gold/*"

# Commented out due to low usage on 2026-03-30
# explore: intacct__po_header_lifecycle {}

# Commented out due to low usage on 2026-03-30
# explore: intacct__po_line_lifecycle {}
explore: intacct__gl_subledger_detail {}
explore: intacct__gl_subledger_detail_v2 {
  join: eqs__po_metrics {
    relationship: many_to_one
    sql_on: ${intacct__gl_subledger_detail_v2.origin_document} = ${eqs__po_metrics.po_number} ;;
  }
}
explore: apa__fs_accrual_job_ingest {
  join:  costentory__po_headers {
    relationship: many_to_one
    sql_on: ${apa__fs_accrual_job_ingest.fk_source_po_header_id} = ${costentory__po_headers.pk_po_header_id};;
  }
  join: intacct__po_headers {
    relationship: many_to_one
    sql_on: ${apa__fs_accrual_job_ingest.fk_source_po_header_id} = ${intacct__po_headers.pk_po_header_id} and ${intacct__po_headers.type_document} in ('Purchase Order', 'Purchasing Order') ;;
  }
}

explore: apa__gl_entries_base_checks {
  join:  costentory__po_headers {
    relationship: many_to_one
    sql_on: ${apa__gl_entries_base_checks.fk_source_po_header_id} = ${costentory__po_headers.pk_po_header_id};;
  }
}

# Commented out due to low usage on 2026-03-30
# explore: apa_concur__true_ups {}

# Commented out due to low usage on 2026-03-30
# explore: apa_corporate__regular_accruals {}

# Commented out due to low usage on 2026-03-30
# explore: apa_costentory__regular_accruals {}

# Commented out due to low usage on 2026-03-30
# explore: apa__bills_posted_in_prior_period_to_por_accrual {}
explore: apa__receipt_accruals_for_prior_period_bills {}

include: "/views/FINANCIAL_SYSTEMS__PROD/concur_gold/*"

# Commented out due to low usage on 2026-03-30
# explore: concur_invoice_audit_trail_approval_workflow {}
explore: concur_invoice_approvers_flattened {}
explore: concur_invoice_comments {}
explore: concur_invoice_exceptions {}
explore: concur_invoice_header_summary {
  join: concur_invoice_audit_trail_approval_workflow {
    relationship:  one_to_many
    sql_on: ${concur_invoice_header_summary.pk_request_key} = ${concur_invoice_audit_trail_approval_workflow.fk_request_key} ;;
  }
  join: concur_invoice_approvers_flattened {
    relationship:  one_to_many
    sql_on: ${concur_invoice_header_summary.pk_request_key} = ${concur_invoice_approvers_flattened.pk_request_key} ;;
  }
  join: concur_invoice_comments {
    relationship: one_to_many
    sql_on: ${concur_invoice_header_summary.pk_request_key} = ${concur_invoice_comments.fk_request_key} ;;
  }
  join: concur_invoice_exceptions {
    relationship: one_to_many
    sql_on: ${concur_invoice_header_summary.pk_request_key} = ${concur_invoice_exceptions.fk_request_key} ;;
  }
}

include: "/views/FINANCIAL_SYSTEMS__PROD/costentory_gold/*"

# Commented out due to low usage on 2026-03-30
# explore: costentory__items {}

# Commented out due to low usage on 2026-03-30
# explore: costentory__markets {}
explore: costentory__po_audit_log {}
explore: costentory__po_headers {

  # One PO Header can have Many PO Lines
  join: costentory__po_lines {
    relationship: one_to_many
    sql_on: ${costentory__po_headers.pk_po_header_id} = ${costentory__po_lines.fk_po_header_id} ;;
  }
  # One PO Header can have Many Receipt Headers
  join: costentory__po_receipt_headers {
    relationship: one_to_many
    sql_on: ${costentory__po_headers.pk_po_header_id} = ${costentory__po_receipt_headers.fk_po_header_id} ;;
  }
  # One PO Line can have Many Receipt Lines
  join: costentory__po_receipt_lines {
    relationship: one_to_many
    sql_on: ${costentory__po_lines.pk_po_line_id} = ${costentory__po_receipt_lines.fk_po_line_id};;
  }
  # One PO Header can show up many times in the lifecycle bc of duplication across documents
  join: intacct__po_header_lifecycle {
      relationship: one_to_many
      sql_on: ${costentory__po_headers.pk_po_header_id} = ${intacct__po_header_lifecycle.fk_t3_po_header_id}} ;;
  }
  # One PO Line can show up many times in the lifecycle bc of duplication
  join: intacct__po_line_lifecycle {
      relationship: one_to_many
      sql_on: ${costentory__po_lines.pk_po_line_id} = ${intacct__po_line_lifecycle.fk_t3_po_line_id} ;;
  }

  # One Vendor could have Many PO Documents
  join: intacct__vendors {
    relationship: many_to_one
    sql_on: ${costentory__po_headers.id_vendor} = ${intacct__vendors.id_vendor} ;;
  }

  # One CostCapture PO can only map to one active Vic.ai PO
  join: vic__po_headers {
    relationship: one_to_one
    sql_on: ${costentory__po_headers.pk_po_header_id} = ${vic__po_headers.fk_source_po_header_id} and ${vic__po_headers.status_po_vic} != 'DELETED';;
  }
  # One CostCapture PO Line maps to one active Vic.ai PO Line
  join: vic__po_lines {
    relationship: one_to_one
    sql_on: ${costentory__po_lines.pk_po_line_id} = ${vic__po_lines.fk_source_po_line_id} and ${vic__po_lines.status_po_vic} != 'DELETED';;
  }
  # One CostCapture PO Line can map to many Vic IL -> POL Match lines
  join: vic__invoice_line_po_items_matched {
    relationship: one_to_many
    sql_on: ${costentory__po_lines.pk_po_line_id} = ${vic__invoice_line_po_items_matched.fk_source_po_line_id} ;;
  }

  # Many IL -> POL matches will map to one invoice header
  join: vic__invoice_headers {
    relationship: many_to_one
    sql_on: ${vic__invoice_line_po_items_matched.fk_invoice_header_id} = ${vic__invoice_headers.pk_invoice_header_id};;
  }
  # Many IL -> POL matches will map to one invoice line
  join: vic__invoice_lines {
    relationship: many_to_one
    sql_on: ${vic__invoice_line_po_items_matched.fk_invoice_line_id} = ${vic__invoice_lines.pk_invoice_line_id};;
  }

  # One Vic Invoice can map to one Sage Bill
  join: intacct__ap_headers {
    relationship: one_to_one
    sql_on: ${vic__invoice_headers.fk_sage_bill_header_id} = ${intacct__ap_headers.pk_ap_header_id} ;;
  }
}

explore: costentory__po_lines {
  join: costentory__po_receipt_lines {
    relationship: one_to_many
    sql_on: ${costentory__po_lines.pk_po_line_id} = ${costentory__po_receipt_lines.fk_po_line_id} ;;
  }
  join: intacct__po_lines {
    relationship: one_to_many
    sql_on: ${costentory__po_lines.pk_po_line_id} = ${intacct__po_lines.fk_t3_po_receipt_line_id} ;;
  }
  join: intacct__po_line_lifecycle {
    relationship: one_to_many
    sql_on: ${costentory__po_lines.pk_po_line_id} = ${intacct__po_line_lifecycle.fk_t3_po_line_id} ;;
  }
  join: vic__po_lines {
    relationship: one_to_one
    sql_on: ${costentory__po_lines.pk_po_line_id} = ${vic__po_lines.fk_source_po_line_id} ;;
  }
  join: vic__invoice_lines {
    relationship: one_to_many
    sql_on: ${vic__po_lines.po_line_number}.} = ${vic__invoice_lines.po_line_number};;
  }

  join: costentory__po_headers {
    relationship: many_to_one
    sql_on: ${costentory__po_lines.fk_po_header_id} = ${costentory__po_headers.pk_po_header_id} ;;
  }
  join: intacct__vendors {
    relationship: many_to_one
    sql_on: ${costentory__po_headers.id_vendor} = ${intacct__vendors.id_vendor} ;;
  }

}

# Commented out due to low usage on 2026-03-30
# explore: costentory__po_receipt_headers {
#   join: costentory__po_receipt_lines {
#     relationship: one_to_many
#     sql_on: ${costentory__po_receipt_headers.pk_po_receipt_header_id} = ${costentory__po_receipt_lines.fk_po_receipt_header_id} ;;
#   }
# }

# Commented out due to low usage on 2026-03-30
# explore: costentory__po_receipt_lines {}

# Commented out due to low usage on 2026-03-30
# explore: costentory__stores {}



include: "/views/FINANCIAL_SYSTEMS__PROD/intacct_gold/*"

# Commented out due to low usage on 2026-03-30
# explore: intacct__expense_lines {}

# Commented out due to low usage on 2026-03-30
# explore: intacct__expense_line_mappings {}

# Commented out due to low usage on 2026-03-30
# explore: intacct__ap_headers {}

# Commented out due to low usage on 2026-03-30
# explore: intacct__ap_lines {
#   join: intacct__ap_headers {
#    relationship: many_to_one
#    sql_on: ${intacct__ap_headers.pk_ap_header_id} = ${intacct__ap_lines.fk_ap_header_id} ;;
#   }
# }
explore: intacct__ap_resolve {
  join: payment_headers {
    from: intacct__ap_headers
    relationship: many_to_one
    sql_on: ${payment_headers.pk_ap_header_id} = ${intacct__ap_resolve.fk_payment_header_id} AND ${payment_headers.type_record} = 'appayment';;
  }
  join: discount_headers {
    from: intacct__ap_headers
    relationship: many_to_one
    sql_on: ${discount_headers.pk_ap_header_id} = ${intacct__ap_resolve.fk_payment_header_id} AND ${discount_headers.type_record} = 'apdiscount';;
  }
  join: adjustment_headers {
    from: intacct__ap_headers
    relationship: many_to_one
    sql_on: ${adjustment_headers.pk_ap_header_id} = ${intacct__ap_resolve.fk_payment_header_id} AND ${adjustment_headers.type_record} = 'apadjustment';;
  }


  join: bill_lines {
    from: intacct__ap_lines
    relationship: many_to_one
    sql_on: ${bill_lines.pk_ap_line_id} = ${intacct__ap_resolve.fk_ap_bill_line_id} AND ${bill_lines.type_record} = 'apbillentry';;
  }
  join: payment_lines {
    from: intacct__ap_lines
    relationship: many_to_one
    sql_on: ${payment_lines.pk_ap_line_id} = ${intacct__ap_resolve.fk_payment_line_id} AND ${payment_lines.type_record} = 'appaymententry';;
  }
  join: discount_lines {
    from: intacct__ap_lines
    relationship: many_to_one
    sql_on: ${discount_lines.pk_ap_line_id} = ${intacct__ap_resolve.fk_ap_bill_line_id} AND ${discount_lines.type_record} = 'apdiscountentry';;
  }
  join: adjustment_lines {
    from: intacct__ap_lines
    relationship: many_to_one
    sql_on: ${discount_lines.pk_ap_line_id} = ${intacct__ap_resolve.fk_ap_bill_line_id} AND ${discount_lines.type_record} = 'apadjustmententry';;
  }

}


# Commented out due to low usage on 2026-03-30
# explore: intacct__po_headers {
#   join: intacct__po_lines {
#     relationship: one_to_many
#     sql_on: ${intacct__po_lines.fk_po_header_id} = ${intacct__po_headers.pk_po_header_id} ;;
#   }
# }

# Commented out due to low usage on 2026-03-30
# explore: intacct__po_lines {}

# Commented out due to low usage on 2026-03-30
# explore: intacct__vendors {}





include: "/views/FINANCIAL_SYSTEMS__PROD/integrations_gold/*"

# Commented out due to low usage on 2026-03-30
# explore: integrations_vic_t3__dimensions {}
explore: integrations_vic_t3__po_header_check {
  join: costentory__po_headers {
    relationship: one_to_one
    sql_on: ${costentory__po_headers.pk_po_header_id} = ${integrations_vic_t3__po_header_check.pk_po_header_id};;
  }
  join: vic__po_headers {
    relationship: one_to_one
    sql_on:  ${vic__po_headers.fk_source_po_header_id} = ${integrations_vic_t3__po_header_check.pk_po_header_id};;
  }
}
explore: integrations_vic_t3__po_line_check {
  join: costentory__po_lines {
    relationship: one_to_one
    sql_on: ${costentory__po_lines.pk_po_line_id} = ${integrations_vic_t3__po_line_check.pk_po_line_id} ;;
  }
}

# Commented out due to low usage on 2026-03-30
# explore: integrations_vic_t3__dimension_sync_plan {}
explore: integrations_vic_t3__po_header_sync_plan {
  join: costentory__po_headers {
    relationship: one_to_one
    sql_on: ${costentory__po_headers.pk_po_header_id} = ${integrations_vic_t3__po_header_sync_plan.pk_po_header_id};;
  }
  join: vic__po_headers {
    relationship: one_to_one
    sql_on:  ${vic__po_headers.fk_source_po_header_id} = ${integrations_vic_t3__po_header_sync_plan.pk_po_header_id};;
  }
}
explore: integrations_vic_t3__po_line_sync_plan {
  join: costentory__po_lines {
    relationship: many_to_one
    sql_on: ${costentory__po_lines.pk_po_line_id} = ${integrations_vic_t3__po_line_sync_plan.pk_po_line_id} ;;
  }
}

include: "/views/FINANCIAL_SYSTEMS__PROD/p2p_gold/*"

# Commented out due to low usage on 2026-03-30
# explore: clustdoc_vendor_app_checks {}
explore: clustdoc_vendor_app_checks_admin {
  join:  clustdoc_vendor_app_checks {
    relationship: one_to_many
    sql_on: ${clustdoc_vendor_app_checks.pk_application_id} = ${clustdoc_vendor_app_checks_admin.pk_application_id} ;;
  }
}

explore: payment_cruncher_detail {
  join: intacct__ap_lines {
    relationship: one_to_one
    sql_on: ${intacct__ap_lines.pk_ap_line_id} = ${payment_cruncher_detail.pk_ap_line_id} ;;
  }
  join: intacct__ap_headers {
    relationship: one_to_one
    sql_on: ${intacct__ap_headers.pk_ap_header_id} = ${payment_cruncher_detail.fk_ap_header_id} ;;
  }
}

# Commented out due to low usage on 2026-03-30
# explore: vendor_coi_requirements_matrix {}


include: "/views/FINANCIAL_SYSTEMS__PROD/universal_models/*"

# Commented out due to low usage on 2026-03-30
# explore: eqs__po_metrics {}

explore: eqs__procurement_headers {
  join: eqs__po_metrics {
    relationship: one_to_one
    sql_on: ${eqs__procurement_headers.pk_procurement_header_id} = ${eqs__po_metrics.pk_procurement_header_id} ;;
  }

  join: intacct__vendors {
    # Many headers will belong to one vendor
    relationship: many_to_one
    sql_on: ${eqs__procurement_headers.vendor_id} = ${intacct__vendors.id_vendor} ;;
  }

  join: costentory__po_headers {
    relationship: one_to_many
    sql_on: coalesce(${eqs__procurement_headers.fk_origin_t3_header_id}, ${eqs__procurement_headers.fk_document_t3_header_id}) = ${costentory__po_headers.pk_po_header_id} ;;
  }
  join: costentory__po_lines {
    relationship: one_to_many
    sql_on: ${costentory__po_headers.pk_po_header_id} = ${costentory__po_lines.fk_po_header_id} ;;
  }

  join: costentory__po_receipt_headers {
    relationship: one_to_one
    sql_on: ${eqs__procurement_headers.fk_document_t3_header_id} = ${costentory__po_receipt_headers.pk_po_receipt_header_id} ;;
  }
  join: costentory__po_receipt_lines {
    relationship: one_to_many
    sql_on: ${costentory__po_receipt_headers.pk_po_receipt_header_id} = ${costentory__po_receipt_lines.fk_po_receipt_header_id} ;;
  }

  join: vic__po_headers {
    relationship: one_to_many
    sql_on: ${eqs__procurement_headers.fk_origin_t3_header_id} = ${vic__po_headers.fk_source_po_header_id} ;;
  }
  join: vic__po_lines {
    relationship: one_to_many
    sql_on: ${vic__po_headers.pk_po_header_id} = ${vic__po_lines.fk_po_header_id} ;;
  }

  join: intacct__po_headers {
    relationship: one_to_one
    sql_on: ${eqs__procurement_headers.fk_document_intacct_header_id} = ${intacct__po_headers.pk_po_header_id} ;;
  }
  join: intacct__po_lines {
    relationship: one_to_many
    sql_on: ${intacct__po_headers.pk_po_header_id} = ${intacct__po_lines.fk_po_header_id} ;;
  }

  join: intacct__departments {
    # Many headers will belong to one department
    # Since procurement headers will have their department IDs concat'd we use a LIKE
    relationship: many_to_one
    sql_on: ${eqs__procurement_headers.department_id} LIKE CONCAT('%', ${intacct__departments.id_department}, '%') ;;
  }
}

include: "/views/FINANCIAL_SYSTEMS__PROD/vic_bronze/*"
explore: _sync_logs {
  join:  costentory__po_headers {
    relationship: many_to_one
    sql_on:  ${costentory__po_headers.pk_po_header_id} = ${_sync_logs.primary_key_sent};;
  }
  join: vic__po_headers {
    relationship: many_to_one
    sql_on:  ${vic__po_headers.pk_po_header_id} = ${_sync_logs.primary_key_returned};;
  }
  join: costentory__po_lines {
    relationship: many_to_one
    sql_on: ${costentory__po_lines.pk_po_line_id} = ${_sync_logs.primary_key_sent};;
  }
  join: vic__po_lines {
    relationship: many_to_one
    sql_on: ${vic__po_lines.pk_po_line_id} = ${_sync_logs.primary_key_sent};;
  }
}

include: "/views/FINANCIAL_SYSTEMS__PROD/vic_gold/*"

# Commented out due to low usage on 2026-03-30
# explore: vic__dimensions {}

# Commented out due to low usage on 2026-03-30
# explore: vic__users {}

# Commented out due to low usage on 2026-03-30
# explore: vic__gl_accounts {}
explore: vic__invoice_headers {
  join: intacct__ap_headers {
    relationship: one_to_one
    sql_on: ${intacct__ap_headers.pk_ap_header_id} = ${vic__invoice_headers.fk_sage_invoice_header_id} ;;
  }
  join: vic__payment_terms {
    relationship: many_to_one
    sql_on: ${vic__payment_terms.pk_payment_term_id} = ${vic__invoice_headers.fk_vic_payment_term_id};;
  }
  join: intacct__vendors {
    relationship: many_to_one
    sql_on: ${intacct__vendors.id_vendor} = ${vic__invoice_headers.id_vendor} ;;
  }
  join: vic__invoice_lines {
    relationship: one_to_many
    sql_on: ${vic__invoice_lines.fk_invoice_header_id} = ${vic__invoice_headers.pk_invoice_header_id} ;;
  }
}
explore: vic__invoice_line_po_items_matched {
  join: vic__invoice_headers {
    relationship: many_to_one
    sql_on: ${vic__invoice_headers.pk_invoice_header_id} = ${vic__invoice_line_po_items_matched.fk_invoice_header_id} ;;
  }
  join: vic__invoice_lines {
    relationship: many_to_one
    sql_on: ${vic__invoice_lines.pk_invoice_line_id} = ${vic__invoice_line_po_items_matched.fk_invoice_line_id} ;;
  }
  join: vic__po_headers {
    relationship: many_to_one
    sql_on: ${vic__po_headers.fk_source_po_header_id} = ${vic__invoice_line_po_items_matched.fk_source_po_header_id};;
  }

}
explore: vic__invoice_lines {}

# Commented out due to low usage on 2026-03-30
# explore: vic__payment_terms {}

# Commented out due to low usage on 2026-03-30
# explore: vic__po_headers {}

# Commented out due to low usage on 2026-03-30
# explore: vic__po_lines {}
