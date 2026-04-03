connection: "es_snowflake_c_analytics"

# fold include statments Option-Command-0 {

include: "/views/ES_WAREHOUSE/assets.view.lkml"
include: "/views/ES_WAREHOUSE/companies.view.lkml"
include: "/views/ES_WAREHOUSE/credit_notes.view.lkml"
include: "/views/ES_WAREHOUSE/invoices.view.lkml"
include: "/views/ES_WAREHOUSE/markets.view.lkml"
include: "/views/ES_WAREHOUSE/net_terms.view.lkml"
include: "/views/ES_WAREHOUSE/orders.view.lkml"
include: "/views/ES_WAREHOUSE/rentals.view.lkml"
include: "/views/ES_WAREHOUSE/users.view.lkml"
include: "/views/ES_WAREHOUSE/credit_note_statuses.view.lkml"
include: "/views/ES_WAREHOUSE/credit_note_history.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/ANALYTICS/collector_cust_flags.view.lkml"
include: "/views/ANALYTICS/collector_customer_assignments.view.lkml"
include: "/views/ANALYTICS/sales_track_logins.view.lkml"
include: "/views/ANALYTICS/ar_monthly_outstandings.view.lkml"
include: "/views/ANALYTICS/ar_monthly_past_due.view.lkml"
include: "/views/ANALYTICS/ar_weekly_dso.view.lkml"
include: "/views/ANALYTICS/collector_mktassignments.view.lkml"
include: "/views/custom_sql/owed_invoice_amount_by_market.view.lkml"
include: "/views/custom_sql/billed_amount_by_market.view.lkml"
include: "/views/custom_sql/collectors_customer_flag_list.view.lkml"
include: "/views/custom_sql/company_notes_rank.view.lkml"
include: "/views/custom_sql/customers_total_ar.view.lkml"
include: "/views/custom_sql/max_invoice_and_rental_id.view.lkml"
include: "/views/custom_sql/active_ar_customers.view.lkml"
include:  "/views/custom_sql/collections_by_day.view.lkml"
include: "/views/ANALYTICS/collector_remove_customers.view.lkml"
include: "/views/ANALYTICS/collector_goals.view.lkml"
include: "/views/ANALYTICS/customer_rebates.view.lkml"
include: "/views/ES_WAREHOUSE/line_items.view.lkml"
include: "/views/ES_WAREHOUSE/order_salespersons.view.lkml"
include: "/views/ES_WAREHOUSE/credit_note_line_items.view.lkml"
include: "/views/ES_WAREHOUSE/line_item_types.view.lkml"
include: "/views/ES_WAREHOUSE/payment_applications.view.lkml"
include: "/views/ES_WAREHOUSE/credit_note_allocations.view.lkml"
include: "/views/ES_WAREHOUSE/credit_notes.view.lkml"
include: "/views/ES_WAREHOUSE/payments.view.lkml"
include: "/views/custom_sql/ibs_report.view.lkml"
include: "/views/custom_sql/ar_customer_history.view.lkml"
include: "/views/custom_sql/activity_statement.view.lkml"
include: "/views/ANALYTICS/PUBLIC/apbillpayment.view.lkml"
include: "/views/ANALYTICS/PUBLIC/apdetail.view.lkml"
include: "/views/ANALYTICS/PUBLIC/aprecord.view.lkml"
include: "/views/ANALYTICS/SAGE_INTACCT/sage_intacct_vendor.view.lkml"
include: "/views/ES_WAREHOUSE/purchase_orders.view.lkml"
include: "/views/ES_WAREHOUSE/deliveries.view.lkml"
include: "/views/ES_WAREHOUSE/locations.view.lkml"
include: "/views/ES_WAREHOUSE/states.view.lkml"
include: "/views/custom_sql/intacct_ar_cust_bal.view.lkml"
include: "/views/custom_sql/admin_ar_invoice_detail.view.lkml"
include: "/views/custom_sql/stripe_report.view.lkml"
include: "/views/custom_sql/intacct_ar_documents.view.lkml"
include: "/views/ANALYTICS/collectors_wos_columns.view.lkml"
include: "/views/rateachievement_points.view.lkml"
include: "/views/custom_sql/last_collector_comment.view.lkml"
include: "/views/ANALYTICS/credit_app_master_list.view.lkml"
include: "/views/custom_sql/combined_applications_payments_credits.view.lkml"
include: "/views/ar_cash_collections.view.lkml"
include: "/views/custom_sql/ar_aging_detail_intacct.view.lkml"
include: "/views/custom_sql/bad_debt_wo.view.lkml"
include: "/views/custom_sql/cust_to_collect_assign.view.lkml"
include: "/views/custom_sql/cecl_monthly_review.view.lkml"
include: "/views/custom_sql/ar_notes_import.view.lkml"
include: "/views/ES_WAREHOUSE/payment_application_reversal_reasons.view.lkml"
include: "/views/custom_sql/admin_payment_application.view.lkml"
include: "/views/ANALYTICS/collection_targets_collector.view.lkml"
include: "/views/ANALYTICS/collector_individual_targets.view.lkml"
include: "/views/ANALYTICS/collections_actuals.view.lkml"
include: "/views/custom_sql/t3_invoice_detail.view.lkml"
include: "/views/custom_sql/ar_invoice_breakdown.view.lkml"
include: "/views/custom_sql/t3_inactive_platform.view.lkml"
include: "/views/ES_WAREHOUSE/disputes.view.lkml"
include: "/views/ES_WAREHOUSE/dispute_reasons.view.lkml"
include: "/views/ES_WAREHOUSE/dispute_events.view.lkml"
include: "/views/ES_WAREHOUSE/dispute_credit_reasons.view.lkml"
include: "/views/custom_sql/cecl_2021.view.lkml"
include: "/views/custom_sql/collector_actual_payments.view.lkml"
include: "/views/ANALYTICS/collection_targets_master.view.lkml"
include: "/views/ANALYTICS/customer_collector_mapping.view.lkml"
include: "/views/custom_sql/payment_trends.view.lkml"
include: "/views/custom_sql/rebate_activity.view.lkml"
include: "/views/custom_sql/accounts_without_collectors.view.lkml"
include: "/views/custom_sql/cust_collector_notes.view.lkml"
include: "/views/custom_sql/dnr_companies.view.lkml"
include: "/views/custom_sql/ar_aging_comparison.view.lkml"
include: "/views/custom_sql/ar_aging_month_end_comparison.view.lkml"
include: "/views/ANALYTICS/collection_target_dashboard.view.lkml"
include: "/views/ANALYTICS/TREASURY/collection_preparation.view.lkml"
include: "/views/custom_sql/disputed_customers.view.lkml"
include: "/views/custom_sql/admin_invoices.view.lkml"
include: "/views/custom_sql/admin_payments.view.lkml"
include: "/views/custom_sql/admin_credits.view.lkml"
include: "/views/custom_sql/unclaimed_property.view.lkml"
include: "/views/custom_sql/True_Cash_Collection.view.lkml"
include: "/views/custom_sql/ar_aging_with_class.view.lkml"
include: "/views/custom_sql/warranty_review.view.lkml"
include: "/views/custom_sql/chargetypeadditions.view.lkml"
include: "/billing_company_preferences.view.lkml"
include: "/quarterly_company_market_assignments.view.lkml"
include: "/views/custom_sql/company_date_created.view.lkml"
include: "/views/custom_sql/cod_dso.view.lkml"
include: "/views/custom_sql/charge_types.view.lkml"
include: "/views/custom_sql/InterCompanyInvoices.view.lkml"
include: "/views/custom_sql/collections_early_warning_risk_category.view.lkml"
include: "/views/custom_sql/ar_footnote.view.lkml"

# }

# datagroup list {

# datagroup: 6AM_update {
#   sql_trigger: SELECT FLOOR((DATE_PART('EPOCH_SECOND', CURRENT_TIMESTAMP) - 60*60*12)/(60*60*24)) ;;
#   max_cache_age: "24 hours"
# }

# datagroup: Every_Hour_Update {
#   sql_trigger: SELECT HOUR(CURRENT_TIME()) ;;
#   max_cache_age: "1 hour"
# }

# datagroup: Every_Two_Hours_Update {
#   sql_trigger: SELECT FLOOR(DATE_PART('EPOCH_SECOND', CURRENT_TIMESTAMP) / (2*60*60)) ;;
#   max_cache_age: "2 hours"
# }

# datagroup: Every_5_Min_Update {
#   sql_trigger: SELECT DATE_PART('minute', CURRENT_TIMESTAMP) ;;
#   max_cache_age: "5 minutes"
# }

# } / datagroup list

explore: ar_invoice_breakdown {
  label: "Invoice Breakdown"
  from: ar_invoice_breakdown
}

explore: ar_footnote {
  label: "AR Footnote"
  from: ar_footnote
}

explore: intercompanyinvoices {
  from: intercompanyinvoices
}

explore: cash_collections {
  label: "Cash Collections"
  from: ar_cash_collections
}

explore: ar_notes_import {
  label: "Admin Notes"
  from: ar_notes_import
}

explore: chargetypeadditions {
  label: "Charge Type Additions"
}

explore: orders {
  label: "Collectors Dashboard"
  group_label: "Accounts Receivable"
  description: "Use this explore for pulling accounts receivable information related to collectors and sales reps"
  case_sensitive: no

  join: invoices {
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders.order_id} = ${invoices.order_id} AND ${invoices.invoice_no} NOT ILIKE '%deleted%';;
  }

  join: order_salespersons {
    type: left_outer
    relationship: one_to_many
    sql_on: ${orders.order_id} = ${order_salespersons.order_id} ;;
  }

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: COALESCE(${invoices.salesperson_user_id},${order_salespersons.user_id}) = ${users.user_id} ;;
  }

  join: billing_approved_users {
    from: users
    type: left_outer
    relationship: many_to_one
    sql_on: ${invoices.billing_approved_by_user_id} = ${billing_approved_users.user_id} ;;
  }

  join: user_companies {
    from: users
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders.user_id} = ${user_companies.user_id} ;;
  }

  join: companies {
    type: left_outer
    relationship: one_to_one
    sql_on: ${user_companies.company_id} = ${companies.company_id} ;;
  }

  join: company_date_created {
    type: left_outer
    relationship: one_to_one
    sql_on: ${companies.company_id} = ${company_date_created.company_id} ;;
  }

  join: collector_cust_flags {
    type: left_outer
    relationship: one_to_one
    sql_on: TRIM(${collector_cust_flags.customer_id})=TRIM(${companies.company_id}::text)  ;;
  }

  join: customer_credit_notes {
    from: credit_notes
    type: left_outer
    relationship: one_to_many
    sql_on: ${companies.company_id}=${customer_credit_notes.company_id} ;;
  }

  join: payments {
    type: left_outer
    relationship: one_to_one
    sql_on: ${companies.company_id}= ${payments.company_id};;
  }

  join: collectors_wos_columns {
    type: left_outer
    relationship: one_to_one
    sql_on:  ${companies.company_id} = ${collectors_wos_columns.customer_id} ;;
  }

  join: collector_remove_customers {
    type: left_outer
    relationship: one_to_one
    sql_on: ${companies.company_id} = ${collector_remove_customers.customer_id} ;;
  }

  join: net_terms {
    type: left_outer
    relationship: one_to_one
    sql_on: ${companies.net_terms_id} = ${net_terms.net_terms_id} ;;
  }

  join: items {
    from: max_invoice_and_rental_id
    type: left_outer
    relationship: many_to_one
    sql_on: ${items.invoice_id} = ${invoices.invoice_id} ;;
  }

  join: line_items {
    type: left_outer
    relationship: one_to_many
    sql_on: ${invoices.invoice_id} = ${line_items.invoice_id} ;;
  }

  join: rentals {
    type:  left_outer
    relationship:  many_to_one
    sql_on: ${items.rental_id} = ${rentals.rental_id} ;;
  }

  join: assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rentals.asset_id} = ${assets.asset_id} ;;
  }

  join: payment_applications {
    type: left_outer
    relationship: one_to_many
    sql_on: ${invoices.invoice_id}=${payment_applications.invoice_id} ;;
  }

  join: credit_note_allocations {
    type: left_outer
    relationship: one_to_many
    sql_on: ${invoices.invoice_id}=${credit_note_allocations.invoice_id} ;;
  }

  join: own_companies {
    from: companies
    type: left_outer
    relationship: many_to_one
    sql_on: ${user_companies.company_id} = ${own_companies.company_id} ;;
  }

  join: collector_mktassignments {
    view_label: "Collector Market Assignments"
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders.market_id}::text = ${collector_mktassignments.market_id};;
  }

  join: collector_customer_assignments {
    type: left_outer
    relationship: one_to_one
    sql_on: ${companies.company_id}=${collector_customer_assignments.company_id} ;;
  }

  join: collector_companies {
    from: companies
    type: left_outer
    relationship: many_to_one
    sql_on: ${collector_customer_assignments.company_id} = ${collector_companies.company_id} ;;
  }

  join: collector_goals {
    type: left_outer
    relationship: many_to_one
    sql_on: TRIM(${collector_customer_assignments.final_collector})=TRIM(${collector_goals.collector}) ;;
  }
  join: rateachievement_points {
    type: left_outer
    relationship: one_to_many
    sql_on: ${invoices.invoice_id}=${rateachievement_points.invoice_rental_id} ;;
  }

  # join: oil_and_gas_goals {
  #   from: collector_goals
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${collector_cust_flags.oil}=${oil_and_gas_goals.collector} ;;
  # }

  join: sales_track_logins {
    type: left_outer
    relationship: many_to_one
    sql_on: ${companies.company_id} = ${sales_track_logins.company_id} ;;
  }

  join: owed_invoice_amount_by_market {
    type: left_outer
    relationship: one_to_many
    sql_on: ${owed_invoice_amount_by_market.market_id} = ${orders.market_id} ;;
  }

  join: billed_amount_by_market {
    type: left_outer
    relationship: one_to_many
    sql_on: ${billed_amount_by_market.market_id} = ${orders.market_id} ;;
  }

  join: markets {
    type: left_outer
    relationship: many_to_one
    # sql_on: ${orders.market_id} = ${markets.market_id};;
    sql_on: ${line_items.branch_id} = ${markets.market_id};;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: ar_weekly_dso {
    type: left_outer
    relationship: many_to_one
    sql_on: ${ar_weekly_dso.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: ar_monthly_past_due {
    type: left_outer
    relationship: many_to_one
    sql_on: ${ar_monthly_past_due.market_id} =  ${market_region_xwalk.market_id} ;;
  }

  join: ar_monthly_outstandings {
    type: left_outer
    relationship: many_to_one
    sql_on: ${ar_monthly_outstandings.market_id} =  ${market_region_xwalk.market_id} ;;
  }


  # join: credit_notes {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${credit_notes.company_id} = ${companies.company_id} ;;
  # }

  join: credit_notes {
    type: left_outer
    relationship: one_to_many
    sql_on: ${invoices.invoice_no} = ${credit_notes.reference} ;;
  }

  join: credit_note_username {
    from: users
    type: left_outer
    relationship: many_to_one
    sql_on: ${credit_notes.created_by_user_id} = ${credit_note_username.user_id} ;;
  }

  join: credit_note_line_items {
    type: left_outer
    relationship: one_to_many
    sql_on: ${credit_notes.credit_note_id} = ${credit_note_line_items.credit_note_id} ;;
  }

  join: line_item_types {
    type: left_outer
    relationship: one_to_one
    sql_on: ${credit_note_line_items.line_item_type_id} = ${line_item_types.line_item_type_id} ;;
  }

  join: collectors_customer_flag_list {
    type: left_outer
    relationship: many_to_many
    sql_on: ${collectors_customer_flag_list.company_id} = ${companies.company_id} ;;
  }

  join: company_notes_rank {
    type: left_outer
    relationship: many_to_one
    sql_on: ${company_notes_rank.company_id} = ${companies.company_id} ;;
  }

  join: customers_total_ar {
    type: left_outer
    relationship: one_to_one
    sql_on: ${companies.company_id} = ${customers_total_ar.company_id} ;;
  }

  join: active_ar_customers {
    type: left_outer
    relationship: one_to_one
    sql_on: ${active_ar_customers.company_id} = ${collector_companies.company_id} ;;
  }

  join: customer_rebates {
    type: left_outer
    relationship: one_to_many
    sql_on: ${companies.company_id} = ${customer_rebates.customer_id} ;;
  }

  join: purchase_orders {
    type: left_outer
    relationship: one_to_one
    sql_on: ${orders.purchase_order_id} = ${purchase_orders.purchase_order_id} ;;
  }

  join: purchase_order_on_invoice {
    from: purchase_orders
    type: left_outer
    relationship: one_to_one
    sql_on: ${invoices.purchase_order_id} = ${purchase_order_on_invoice.purchase_order_id} ;;
  }

  join: deliveries {
    type: left_outer
    relationship: one_to_many
    sql_on: ${rentals.rental_id} = ${deliveries.rental_id} and ${rentals.drop_off_delivery_id} = ${deliveries.delivery_id} ;;
  }

  join: locations {
    type:  left_outer
    relationship: many_to_one
    sql_on:  ${deliveries.location_id} = ${locations.location_id} ;;
  }

  join: states {
    type: left_outer
    relationship: many_to_one
    sql_on: ${states.state_id} = ${locations.state_id}  ;;
  }

  join: invoices_line_item_types {
    from: line_item_types
    type: left_outer
    relationship: one_to_one
    sql_on: ${line_items.line_item_type_id} = ${invoices_line_item_types.line_item_type_id} ;;
  }
  join: last_collector_comment {
    type: left_outer
    relationship: many_to_one
    sql_on: ${last_collector_comment.company_id} = ${companies.company_id}  ;;
  }

  # aggregate_table: rollup__market_region_xwalk_market_id__market_region_xwalk_market_name {
  #   query: {
  #     dimensions: [market_region_xwalk.market_id, market_region_xwalk.market_name]
  #     measures: [invoices.Current_Total_Amount, invoices.Due_Date_Amount_31_to_60_days, invoices.Due_Date_Amount_61_to_90_days, invoices.Due_Date_Amount_91_to_120_days, invoices.Due_Date_Amount_Below_30_Days, invoices.Due_Date_Amount_over_120_days, invoices.Invoice_Total_Amount]
  #     timezone: "America/Chicago"
  #   }

  #   materialization: {
  #     persist_for: "2 hours"
  #   }
  # }

  # aggregate_table: rollup__companies_company_id__companies_company_name_with_net_terms__company_notes_rank_date_and_note_text__salesperson_user_id__users_Full_Name {
  #   query: {
  #     dimensions: [companies.company_id, companies.company_name_with_net_terms, company_notes_rank.date_and_note_text, salesperson_user_id, users.Full_Name]
  #     measures: [invoices.Current_Total_Amount, invoices.Due_Date_Amount_31_to_60_days, invoices.Due_Date_Amount_61_to_90_days, invoices.Due_Date_Amount_91_to_120_days, invoices.Due_Date_Amount_Below_30_Days, invoices.Due_Date_Amount_over_120_days, invoices.Due_Date_Total_Amount]
  #     filters: [invoices.Due_Date_Total_Amount: ">0"]
  #     timezone: "UTC"
  #   }

  #   materialization: {
  #     persist_for: "2 hours"
  #   }
  # }
  join: credit_app_master_list {
    type: left_outer
    relationship: many_to_one
    sql_on: ${credit_app_master_list.customer_id} = ${companies.company_id}  ;;
  }

  join: disputes {
    type: left_outer
    relationship: many_to_one
    sql_on: ${invoices.invoice_id} = ${disputes.invoice_id} ;;
  }

  join: dispute_reasons {
    type: left_outer
    relationship: many_to_one
    sql_on: ${disputes.dispute_reason_id} = ${dispute_reasons.dispute_reason_id} ;;
  }

  join: dispute_events {
    type: left_outer
    relationship: many_to_one
    sql_on: ${disputes.dispute_id} = ${dispute_events.dispute_id} ;;
  }

  join: dispute_credit_reasons {
    type: left_outer
    relationship: many_to_one
    sql_on: ${disputes.dispute_reason_id} = ${dispute_credit_reasons.dispute_credit_reason_id} ;;
  }

  join: billing_company_preferences {
    sql_on: ${companies.company_id} = ${billing_company_preferences.company_id} ;;
    relationship: one_to_one
    type: left_outer
  }

  join: quarterly_company_market_assignments {
    type: left_outer
    sql_on: ${companies.company_id} = ${quarterly_company_market_assignments.company_id} ;;
    relationship: one_to_one
  }

  join: cust_collector_notes {
    type:  left_outer
    sql_on: ${companies.company_id} = ${cust_collector_notes.customer_id};;
    relationship: many_to_one
  }

  join: invoice_created_by {
    from:  users
    type: left_outer
    relationship: many_to_one
    sql_on: ${invoices.created_by_user_id} = ${invoice_created_by.user_id} ;;
  }

  join: collections_early_warning_risk_category {
    type: left_outer
    relationship: one_to_one
    sql_on: ${companies.company_id} = ${collections_early_warning_risk_category.company_id} ;;
  }

}


explore: ibs_report {
  label: "IBS Report"
  description: "IBS Report recreated from Admin version"
  case_sensitive: no

  join: payments {
    type: left_outer
    relationship: many_to_one
    sql_on: ${ibs_report.company_id} = ${payments.company_id} ;;
  }

}

# explore: ar_customer_history { --MB comment out 10-10-23 due to inactivity
#   label: "Customer AR History"

#   join: companies {
#     fields: [companies.company_id, companies.name]
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${ar_customer_history.customerid} = ${companies.company_id} ;;
#   }
# }


explore: activity_statement {
  label: "AR Activity Statement"

  join: companies {
    fields: [companies.company_id, companies.name, companies.company_name_with_id]
    type: left_outer
    relationship: many_to_one
    sql_on: ${activity_statement.cust_id} = ${companies.company_id}::varchar ;;
  }
}

explore: collector_goals {}

explore: intacct_ar_cust_bal {
  label: "Intacct - Customer Balance"
}

explore: admin_ar_invoice_detail {
  label: "Admin - Invoice Detail"
}

explore: t3_inactive_platform {
  label: "T3 Inactive Platform"
}

explore: bad_debt_wo {
  label: "Bad Debt Write Off"
}

explore: cust_to_collect_assign {
  label: "Customer to Collector Assignment"
}

explore: ar_aging_detail_intacct {
  label: "AR Aging Intacct"
}

explore: stripe_report {}

explore: intacct_ar_documents {
  label: "Intacct - AR Documents"
}

explore: cecl_monthly_review {
  label: "CECL Monthly Review"
}

explore: admin_payment_application {
  label: "Admin AR Payment Application"
}

explore: historical_cecl_review {
  label: "Historical CECL Review"
}

explore: users {
  label: "AR Specialist"
  group_label: "Accounts Receivable"
  description: "Use this explore for pulling accounts receivable information related to AR Specialists"
  case_sensitive: no
  sql_always_where: ${users.user_id} in (10473, 10487, 31495, 31446, 54316, 54462, 75292, 75293, 106719, 127760, 139877, 2185, 143248, 152386, 156075, 156606, 172644, 169210, 165005, 216745, 26268, 226111, 226123, 261636, 276755, 280065, 285915, 286038, 306177,328863,317591,339805,364849,301006,367099,303217,299410,404165,404166) and
  '{{ _user_attributes['email'] }}' in ('jenny.sperry@equipmentshare.com','kris@equipmentshare.com','paul.mason@equipmentshare.com','lisa.evans@equipmentshare.com','ryan.stevens@equipmentshare.com')
  OR TRIM(LOWER(${users.email_address})) = TRIM(LOWER('{{ _user_attributes['email'] }}')) OR 'developer' = {{ _user_attributes['department'] }}
;;

  join: payment_applications {
    #fields:
    type: left_outer
    relationship: one_to_many
    sql_on: ${users.user_id} = ${payment_applications.user_id} ;;
  }

  join: credit_note_allocations {
    #fields:
    type: left_outer
    relationship: one_to_many
    sql_on: ${users.user_id} = ${credit_note_allocations.created_by_user_id} ;;
  }

  join: combined_applications_payments_credits {
    #fields:
    type: left_outer
    relationship: one_to_many
    sql_on: ${users.user_id} = ${combined_applications_payments_credits.user_id} ;;
  }

  join: payment_application_reversal_reasons {
    type: left_outer
    relationship: one_to_many
    sql_on: ${payment_applications.payment_application_reversal_reason_id} = ${payment_application_reversal_reasons.payment_application_reversal_reason_id} ;;
  }

}

explore: collections_actuals {
  sql_always_where: ${collector_individual_targets.is_collector} ;;
  join: collector_individual_targets {
    type: full_outer
    relationship: many_to_one
    sql_on: (${collections_actuals.customer_id} = ${collector_individual_targets.company_id}) and (${collector_individual_targets.quarter} = '2025-Q4')
    ;;
  }
}

explore: collections_by_day  {}


explore: collection_preparation {
  join: collectors_customer_flag_list {
    type: left_outer
    relationship: many_to_one
    sql_on: ${collection_preparation.customer_id}=${collectors_customer_flag_list.company_id}  ;;
  }
  join: disputed_customers {
    type: left_outer
    relationship: many_to_one
    sql_on: ${collection_preparation.customer_id}=${disputed_customers.customer_id}  ;;
  }
}




explore: collector_actual_payments  {}

explore: collection_target_dashboard  {

}



explore: t3_invoice_detail {
  label: "T3 Invoice Detail"
}

explore: payment_trends {
  label: "Payment Trends"
}

explore: rebate_activity {
  label: "Rebate Activity"
}

explore: accounts_without_collectors {
  label: "Accounts Without Collectors"
}

explore: cust_collector_notes {
  label: "Customer Collector Notes"
}

explore: dnr_companies {
  label: "DNR Companies"
}

explore: ar_aging_comparison {
  label: "AR Aging Comparison"
}

explore: ar_aging_month_end_comparison {
  label: "AR Aging Month-End Comparison"
}

explore: admin_invoices {
  label: "Admin Invoices"
}

explore: admin_payments {
  label: "Admin Payments"
}

explore: admin_credits {
  label: "Admin Credits"
}

explore: True_Cash_Collection {
  label: "true_cash_collection"
}

explore: ar_aging_with_class {
  label: "ar_aging_with_class"
}

explore: warranty_review {
  label: "warranty_review"
}

explore: charge_types {
  label: "AR Charge Type Mapping"
}

explore: unclaimed_property {
  label: "Unclaimed Property"

  join: admin_invoices {
    type: left_outer
    relationship: one_to_many
    sql_on: ${unclaimed_property.company_id} = ${admin_invoices.company_id} ;;
  }

  join: admin_payments {
    type: left_outer
    relationship: one_to_many
    sql_on: ${unclaimed_property.company_id} = ${admin_payments.company_id} ;;
  }

  join: admin_credits {
    type: left_outer
    relationship: one_to_many
    sql_on: ${unclaimed_property.company_id} = ${admin_credits.company_id} ;;
  }
}

explore: credit_notes {
  join: credit_note_statuses {
    type: left_outer
    relationship: one_to_many
    sql_on: ${credit_notes.credit_note_status_id} = ${credit_note_statuses.credit_note_status_id} ;;
  }
  join: users {
    type: left_outer
    relationship: one_to_many
    sql_on: ${credit_notes.created_by_user_id} = ${users.user_id} ;;
  }
}

explore: cod_dso {}

explore: orders_treasury {
  from: orders
  label: "Collectors Dashboard Treasury"
  group_label: "Accounts Receivable"
  description: "Use this explore for pulling accounts receivable information related to collectors and sales reps"
  case_sensitive: no
  sql_always_where: ${credit_note_username.is_user} or ${credit_note_approver_username.is_user} ;;

  join: invoices {
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders_treasury.order_id} = ${invoices.order_id} AND ${invoices.invoice_no} NOT ILIKE '%deleted%';;
  }

  join: order_salespersons {
    type: left_outer
    relationship: one_to_many
    sql_on: ${orders_treasury.order_id} = ${order_salespersons.order_id} ;;
  }

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: COALESCE(${invoices.salesperson_user_id},${order_salespersons.user_id}) = ${users.user_id} ;;
  }

  join: user_companies {
    from: users
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders_treasury.user_id} = ${user_companies.user_id} ;;
  }

  join: companies {
    type: left_outer
    relationship: one_to_one
    sql_on: ${user_companies.company_id} = ${companies.company_id} ;;
  }

  join: company_date_created {
    type: left_outer
    relationship: one_to_one
    sql_on: ${companies.company_id} = ${company_date_created.company_id} ;;
  }

  join: collector_cust_flags {
    type: left_outer
    relationship: one_to_one
    sql_on: TRIM(${collector_cust_flags.customer_id})=TRIM(${companies.company_id}::text)  ;;
  }

  join: customer_credit_notes {
    from: credit_notes
    type: left_outer
    relationship: one_to_many
    sql_on: ${companies.company_id}=${customer_credit_notes.company_id} ;;
  }

  join: payments {
    type: left_outer
    relationship: one_to_one
    sql_on: ${companies.company_id}= ${payments.company_id};;
  }

  join: collectors_wos_columns {
    type: left_outer
    relationship: one_to_one
    sql_on:  ${companies.company_id} = ${collectors_wos_columns.customer_id} ;;
  }

  join: collector_remove_customers {
    type: left_outer
    relationship: one_to_one
    sql_on: ${companies.company_id} = ${collector_remove_customers.customer_id} ;;
  }

  join: net_terms {
    type: left_outer
    relationship: one_to_one
    sql_on: ${companies.net_terms_id} = ${net_terms.net_terms_id} ;;
  }

  join: items {
    from: max_invoice_and_rental_id
    type: left_outer
    relationship: many_to_one
    sql_on: ${items.invoice_id} = ${invoices.invoice_id} ;;
  }

  join: line_items {
    type: left_outer
    relationship: one_to_many
    sql_on: ${invoices.invoice_id} = ${line_items.invoice_id} ;;
  }

  join: rentals {
    type:  left_outer
    relationship:  many_to_one
    sql_on: ${items.rental_id} = ${rentals.rental_id} ;;
  }

  join: assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rentals.asset_id} = ${assets.asset_id} ;;
  }

  join: payment_applications {
    type: left_outer
    relationship: one_to_many
    sql_on: ${invoices.invoice_id}=${payment_applications.invoice_id} ;;
  }

  join: credit_note_allocations {
    type: left_outer
    relationship: one_to_many
    sql_on: ${invoices.invoice_id}=${credit_note_allocations.invoice_id} ;;
  }

  join: own_companies {
    from: companies
    type: left_outer
    relationship: many_to_one
    sql_on: ${user_companies.company_id} = ${own_companies.company_id} ;;
  }

  join: collector_mktassignments {
    view_label: "Collector Market Assignments"
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders_treasury.market_id}::text = ${collector_mktassignments.market_id};;
  }

  join: collector_customer_assignments {
    type: left_outer
    relationship: one_to_one
    sql_on: ${companies.company_id}=${collector_customer_assignments.company_id} ;;
  }

  join: collector_companies {
    from: companies
    type: left_outer
    relationship: many_to_one
    sql_on: ${collector_customer_assignments.company_id} = ${collector_companies.company_id} ;;
  }

  join: collector_goals {
    type: left_outer
    relationship: many_to_one
    sql_on: TRIM(${collector_customer_assignments.final_collector})=TRIM(${collector_goals.collector}) ;;
  }
  join: rateachievement_points {
    type: left_outer
    relationship: one_to_many
    sql_on: ${invoices.invoice_id}=${rateachievement_points.invoice_rental_id} ;;
  }

  # join: oil_and_gas_goals {
  #   from: collector_goals
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${collector_cust_flags.oil}=${oil_and_gas_goals.collector} ;;
  # }

  join: sales_track_logins {
    type: left_outer
    relationship: many_to_one
    sql_on: ${companies.company_id} = ${sales_track_logins.company_id} ;;
  }

  join: owed_invoice_amount_by_market {
    type: left_outer
    relationship: one_to_many
    sql_on: ${owed_invoice_amount_by_market.market_id} = ${orders_treasury.market_id} ;;
  }

  join: billed_amount_by_market {
    type: left_outer
    relationship: one_to_many
    sql_on: ${billed_amount_by_market.market_id} = ${orders_treasury.market_id} ;;
  }

  join: markets {
    type: left_outer
    relationship: many_to_one
    # sql_on: ${orders_treasury.market_id} = ${markets.market_id};;
    sql_on: ${line_items.branch_id} = ${markets.market_id};;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders_treasury.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: ar_weekly_dso {
    type: left_outer
    relationship: many_to_one
    sql_on: ${ar_weekly_dso.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: ar_monthly_past_due {
    type: left_outer
    relationship: many_to_one
    sql_on: ${ar_monthly_past_due.market_id} =  ${market_region_xwalk.market_id} ;;
  }

  join: ar_monthly_outstandings {
    type: left_outer
    relationship: many_to_one
    sql_on: ${ar_monthly_outstandings.market_id} =  ${market_region_xwalk.market_id} ;;
  }


  # join: credit_notes {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${credit_notes.company_id} = ${companies.company_id} ;;
  # }

  join: credit_notes {
    type: left_outer
    relationship: one_to_many
    sql_on: ${invoices.invoice_no} = ${credit_notes.reference} ;;
  }

  join: credit_note_username {
    from: users
    type: left_outer
    relationship: many_to_one
    sql_on: ${credit_notes.created_by_user_id} = ${credit_note_username.user_id} ;;
  }

  join: credit_note_history {
    type: left_outer
    relationship: one_to_many
    sql_on: (${credit_notes.credit_note_id} = ${credit_note_history.credit_note_id}) and (${credit_note_history.credit_note_history_event_type_id} = 4) ;;
  }

  join: credit_note_approver_username {
    from: users
    type: left_outer
    relationship: many_to_one
    sql_on: (${credit_note_approver_username.user_id} = ${credit_note_history.user_id}) ;;
  }

  join: credit_note_line_items {
    type: left_outer
    relationship: one_to_many
    sql_on: ${credit_notes.credit_note_id} = ${credit_note_line_items.credit_note_id} ;;
  }

  join: line_item_types {
    type: left_outer
    relationship: one_to_one
    sql_on: ${credit_note_line_items.line_item_type_id} = ${line_item_types.line_item_type_id} ;;
  }

  join: collectors_customer_flag_list {
    type: left_outer
    relationship: many_to_many
    sql_on: ${collectors_customer_flag_list.company_id} = ${companies.company_id} ;;
  }

  join: company_notes_rank {
    type: left_outer
    relationship: many_to_one
    sql_on: ${company_notes_rank.company_id} = ${companies.company_id} ;;
  }

  join: customers_total_ar {
    type: left_outer
    relationship: one_to_one
    sql_on: ${companies.company_id} = ${customers_total_ar.company_id} ;;
  }

  join: active_ar_customers {
    type: left_outer
    relationship: one_to_one
    sql_on: ${active_ar_customers.company_id} = ${collector_companies.company_id} ;;
  }

  join: customer_rebates {
    type: left_outer
    relationship: one_to_many
    sql_on: ${companies.company_id} = ${customer_rebates.customer_id} ;;
  }

  join: purchase_orders {
    type: left_outer
    relationship: one_to_one
    sql_on: ${orders_treasury.purchase_order_id} = ${purchase_orders.purchase_order_id} ;;
  }

  join: purchase_order_on_invoice {
    from: purchase_orders
    type: left_outer
    relationship: one_to_one
    sql_on: ${invoices.purchase_order_id} = ${purchase_order_on_invoice.purchase_order_id} ;;
  }

  join: deliveries {
    type: left_outer
    relationship: one_to_many
    sql_on: ${rentals.rental_id} = ${deliveries.rental_id} and ${rentals.drop_off_delivery_id} = ${deliveries.delivery_id} ;;
  }

  join: locations {
    type:  left_outer
    relationship: many_to_one
    sql_on:  ${deliveries.location_id} = ${locations.location_id} ;;
  }

  join: states {
    type: left_outer
    relationship: many_to_one
    sql_on: ${states.state_id} = ${locations.state_id}  ;;
  }

  join: invoices_line_item_types {
    from: line_item_types
    type: left_outer
    relationship: one_to_one
    sql_on: ${line_items.line_item_type_id} = ${invoices_line_item_types.line_item_type_id} ;;
  }
  join: last_collector_comment {
    type: left_outer
    relationship: many_to_one
    sql_on: ${last_collector_comment.company_id} = ${companies.company_id}  ;;
  }

  # aggregate_table: rollup__market_region_xwalk_market_id__market_region_xwalk_market_name {
  #   query: {
  #     dimensions: [market_region_xwalk.market_id, market_region_xwalk.market_name]
  #     measures: [invoices.Current_Total_Amount, invoices.Due_Date_Amount_31_to_60_days, invoices.Due_Date_Amount_61_to_90_days, invoices.Due_Date_Amount_91_to_120_days, invoices.Due_Date_Amount_Below_30_Days, invoices.Due_Date_Amount_over_120_days, invoices.Invoice_Total_Amount]
  #     timezone: "America/Chicago"
  #   }

  #   materialization: {
  #     persist_for: "2 hours"
  #   }
  # }

  # aggregate_table: rollup__companies_company_id__companies_company_name_with_net_terms__company_notes_rank_date_and_note_text__salesperson_user_id__users_Full_Name {
  #   query: {
  #     dimensions: [companies.company_id, companies.company_name_with_net_terms, company_notes_rank.date_and_note_text, salesperson_user_id, users.Full_Name]
  #     measures: [invoices.Current_Total_Amount, invoices.Due_Date_Amount_31_to_60_days, invoices.Due_Date_Amount_61_to_90_days, invoices.Due_Date_Amount_91_to_120_days, invoices.Due_Date_Amount_Below_30_Days, invoices.Due_Date_Amount_over_120_days, invoices.Due_Date_Total_Amount]
  #     filters: [invoices.Due_Date_Total_Amount: ">0"]
  #     timezone: "UTC"
  #   }

  #   materialization: {
  #     persist_for: "2 hours"
  #   }
  # }
  join: credit_app_master_list {
    type: left_outer
    relationship: many_to_one
    sql_on: ${credit_app_master_list.customer_id} = ${companies.company_id}  ;;
  }

  join: disputes {
    type: left_outer
    relationship: many_to_one
    sql_on: ${invoices.invoice_id} = ${disputes.invoice_id} ;;
  }

  join: dispute_reasons {
    type: left_outer
    relationship: many_to_one
    sql_on: ${disputes.dispute_reason_id} = ${dispute_reasons.dispute_reason_id} ;;
  }

  join: dispute_events {
    type: left_outer
    relationship: many_to_one
    sql_on: ${disputes.dispute_id} = ${dispute_events.dispute_id} ;;
  }

  join: dispute_credit_reasons {
    type: left_outer
    relationship: many_to_one
    sql_on: ${disputes.dispute_reason_id} = ${dispute_credit_reasons.dispute_credit_reason_id} ;;
  }

  join: billing_company_preferences {
    sql_on: ${companies.company_id} = ${billing_company_preferences.company_id} ;;
    relationship: one_to_one
    type: left_outer
  }

  join: quarterly_company_market_assignments {
    type: left_outer
    sql_on: ${companies.company_id} = ${quarterly_company_market_assignments.company_id} ;;
    relationship: one_to_one
  }

}
