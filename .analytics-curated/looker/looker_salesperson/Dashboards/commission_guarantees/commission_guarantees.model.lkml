connection: "es_snowflake_analytics"

include: "/Dashboards/commission_guarantees/views/current_commission_guarantees.view.lkml"
include: "/views/custom_sql/commission_statement_access.view.lkml"
include: "/views/ES_WAREHOUSE/line_items.view.lkml"
include: "/views/custom_sql/line_items_dates_combined.view.lkml"
include: "/views/custom_sql/salesperson_to_market.view.lkml"
include: "/views/ES_WAREHOUSE/users.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/custom_sql/approved_invoice_salespersons_flat.view.lkml"
include: "/views/ANALYTICS/pay_periods.view.lkml"


# Commented out due to low usage on 2026-03-26
# explore: current_commission_guarantees {
#   always_join: [commission_statement_access]
#   case_sensitive: no
#   sql_always_where: 'developer' = {{ _user_attributes['department'] }}
#                       OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'kelsey.mosley@equipmentshare.com'
# --                      OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'christine@equipmentshare.com'
#                       OR array_contains (TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')::VARIANT, ${commission_statement_access.manager_array});;
#
#
#   join: commission_statement_access {
#     relationship: many_to_one
#     type: left_outer
#     sql_on: ${current_commission_guarantees.salesperson_user_id} = ${commission_statement_access.user_id};;
#   }
#
#   join: approved_invoice_salespersons_flat {
#     relationship: one_to_many
#     type: left_outer
#     sql_on: ${current_commission_guarantees.salesperson_user_id} = ${approved_invoice_salespersons_flat.salesperson_id} ;;
#   }
#
#   join: primary_rep_line_items {
#     from: line_items
#     relationship: many_to_many
#     type: left_outer
#     sql_on: ${approved_invoice_salespersons_flat.invoice_id} = ${primary_rep_line_items.invoice_id} and ${approved_invoice_salespersons_flat.salesperson_type} = 1 ;;
#   }
#
#   join: secondary_rep_line_items {
#     from: line_items
#     relationship: many_to_many
#     type: left_outer
#     sql_on: ${approved_invoice_salespersons_flat.invoice_id} = ${secondary_rep_line_items.invoice_id} and ${approved_invoice_salespersons_flat.salesperson_type} = 2 ;;
#   }
#
#   join: salesperson_to_market {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${current_commission_guarantees.salesperson_user_id} = ${salesperson_to_market.salesperson_user_id} ;;
#   }
#
#   join: users {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${current_commission_guarantees.salesperson_user_id} = ${users.user_id} ;;
#   }
#
#   join: market_region_xwalk {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${salesperson_to_market.final_market} = ${market_region_xwalk.market_id} ;;
#   }
#
#  join: last_guarantee_paycheck {
#     from: pay_periods
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${current_commission_guarantees.payroll_guarantee_end_date_month} = ${last_guarantee_paycheck.paycheck_date_month} AND ${last_guarantee_paycheck.comm_check_date} = 'TRUE';;
#  }
#
#   join: first_commission_paycheck {
#     from: pay_periods
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${current_commission_guarantees.payroll_commission_start_date_month} = ${first_commission_paycheck.paycheck_date_month} AND ${first_commission_paycheck.comm_check_date} = 'TRUE';;
#   }
#
# }
