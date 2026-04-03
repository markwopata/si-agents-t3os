connection: "es_snowflake_c_analytics"

include: "/views/ANALYTICS/looker_commission_clawback_history.view.lkml"
include: "/views/ANALYTICS/collector_mktassignments.view.lkml"
include: "/views/ANALYTICS/collector_customer_assignments.view.lkml"
include: "/views/ES_WAREHOUSE/users.view.lkml"
include: "/views/ES_WAREHOUSE/invoices.view.lkml"
include: "/views/ES_WAREHOUSE/markets.view.lkml"
include: "/views/ES_WAREHOUSE/orders.view.lkml"
include: "/views/ES_WAREHOUSE/net_terms.view.lkml"
include: "/views/ES_WAREHOUSE/companies.view.lkml"
include: "/views/ANALYTICS/pay_periods.view.lkml"
include: "/views/ANALYTICS/commissions.view.lkml"
include: "/views/ES_WAREHOUSE/credit_notes.view.lkml"
include: "/views/ES_WAREHOUSE/credit_note_allocations.view.lkml"
include: "/views/ES_WAREHOUSE/payments.view.lkml"
include: "/views/ANALYTICS/salesperson_invoice_changes.view.lkml"
include: "/views/ES_WAREHOUSE/payment_applications.view.lkml"
include: "/views/ANALYTICS/commission_transactions.view.lkml"
include: "/views/ANALYTICS/commission_statement_data.view.lkml"
include: "/views/custom_sql/view_commission_statement_tile.view.lkml"
include: "/views/custom_sql/commission_statement_access.view.lkml"
include: "/views/ANALYTICS/commissions_salesperson_data.view.lkml"
include: "/views/custom_sql/commission_guarantee_payments.view.lkml"
include: "/views/custom_sql/commission_allocations.view.lkml"
include: "/views/SWORKS/commission_override_requests.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/ES_WAREHOUSE/equipment_classes.view.lkml"
include: "/views/SWORKS/commission_override_permissions.view.lkml"

## this explore is used for payroll's dashboards. Can possibly be deleted when new commission process is finalized and new explores rebuilt. --JW 12/13/22
## commented out again after rebuilding --JW 9/20/24

# explore: commission_statement {
#   always_join: [invoices,users,companies,salesperson_invoice_changes]
#   from: commission_transactions
#   label: "Commission Transactions"
#   case_sensitive: no
#   sql_always_where:  (('collectors' = {{ _user_attributes['department'] }} OR 'developer' = {{ _user_attributes['department'] }} OR 'managers' = {{ _user_attributes['department'] }})
#                           OR  ((('salesperson' = {{ _user_attributes['department'] }} AND ${users.email_address} =  LOWER('{{ _user_attributes['email'] }}') )))
#                           OR 'god view' = {{ _user_attributes['department'] }}) ;;

#   join:  users {
#     from:  users
#     relationship:  many_to_one
#     type: inner
#     sql_on: ${commission_statement.user_id} = ${users.user_id} ;;
#   }

#   join: invoices {
#     from: invoices
#     relationship: many_to_one
#     type: inner
#     sql_on: ${commission_statement.invoice_id} = ${invoices.invoice_id} ;;
#   }

#   join: orders {
#     relationship: many_to_one
#     type: left_outer
#     sql_on: ${invoices.order_id} = ${orders.order_id} ;;
#   }

#   join: companies {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${invoices.company_id} = ${companies.company_id} ;;
#   }

#   join: payment_applications {
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${invoices.invoice_id} = ${payment_applications.invoice_id} ;;
#   }

#   join: credit_note_allocations {
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${invoices.invoice_id} = ${credit_note_allocations.invoice_id} ;;
#   }

#   join: credit_notes {
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${invoices.invoice_id} = ${credit_notes.originating_invoice_id} and ${commission_statement.dte_date} = ${credit_notes.date_created_date} ;;
#   }

#   join: salesperson_invoice_changes {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${commission_statement.invoice_id} = ${salesperson_invoice_changes.invoice_id} and
#         (${commission_statement.user_id} = ${salesperson_invoice_changes.prev_rep_id} or ${commission_statement.user_id} = ${salesperson_invoice_changes.new_rep_id});;
#   }

# }


## no longer needed --JW 9/20/24
# explore: new_commission_statement {
#   always_join: [commission_statement_data,commission_statement_access]
#   from: users
#   view_label: "Users"
#   case_sensitive: no
#   sql_always_where: ${commission_statement_data.hidden} = false and
#                     ('developer' = {{ _user_attributes['department'] }}
#                     OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'traci.marshall@equipmentshare.com'
#                     OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'christine@equipmentshare.com'
#                     OR (${commission_statement_data.email_address} =  LOWER('{{ _user_attributes['email'] }}') )
#                     OR array_contains (TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')::VARIANT, ${commission_statement_access.manager_array}))
#                     and ${company_id} = 1854 and ${deleted} = 'No' and ${employee_id} is not null;;

#   join: commission_statement_data {
#     relationship: one_to_many
#     type: left_outer
#     sql_on: ${new_commission_statement.user_id} = ${commission_statement_data.user_id} ;;
#   }

#   join: commission_statement_access {
#     relationship: many_to_one
#     type: left_outer
#     sql_on: ${commission_statement_data.user_id} = ${commission_statement_access.user_id};;
# }
# }


## as of 9/20/24, this is still needed for the tile on the salesperson dashboard --JW 9/20/24
  explore: view_commission_statement_tile {
}

## no longer needed --JW 9/20/24
#   explore: commission_guarantee_payments {
# }


## no longer needed --JW 9/20/24
#   explore:  commission_allocations {
# }


explore: commission_override_requests {
  case_sensitive: no

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${commission_override_requests.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: commission_override_permissions {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.district} = ${commission_override_permissions.district}  ;;
  }

  join: request_users {
    from: users
    view_label: "Salespersons"
    type: left_outer
    relationship:many_to_one
    sql_on: ${commission_override_requests.request_user_id} = ${request_users.user_id} ;;
  }

  join: review_users {
    from: users
    view_label: "Managers"
    type: left_outer
    relationship: many_to_one
    sql_on: coalesce(${commission_override_requests.review_user_id},${commission_override_permissions.user_id}) = ${review_users.user_id} ;;
  }

  join: equipment_classes {
    type: left_outer
    relationship: many_to_one
    sql_on: ${commission_override_requests.equipment_class_id} = ${equipment_classes.equipment_class_id} ;;
  }

  join: companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${commission_override_requests.company_id} = ${companies.company_id} ;;
  }
}
