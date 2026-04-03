connection: "es_snowflake_analytics"

include: "/views/custom_sql/monthly_payment_breakout.view.lkml"                # include all views in the views/ folder in this project
include: "/views/custom_sql/sage_cpltd.view.lkml"
include: "/views/custom_sql/debt_table_cpltd.view.lkml"
include: "/views/custom_sql/amortization_schedules.view.lkml"
include: "/views/custom_sql/amortization_schedules_hist.view.lkml"
include: "/views/custom_sql/loan_to_assets.view.lkml"
include: "/views/custom_sql/sage_total_debt.view.lkml"
include: "/views/custom_sql/debt_table_total_debt.view.lkml"
include: "/views/custom_sql/sage_loan_balances.view.lkml"
include: "/views/custom_sql/debt_table_loan_balances.view.lkml"
include: "/views/ANALYTICS/phoenix_id_types.view.lkml"
include: "/views/ANALYTICS/gl_detail.view.lkml"
include: "/views/custom_sql/dt_to_sage_bal_compare.view.lkml"
include: "/views/custom_sql/dt_to_sage_compare_updated.view.lkml"
include: "/views/custom_sql/operating_leased_assets.view.lkml"

explore: gl_detail {
  case_sensitive: no
}
explore: phoenix_id_types {
  case_sensitive: no
}
explore: monthly_payment_breakout {
  case_sensitive: no
}
explore: sage_cpltd {
  case_sensitive: no
}
explore: debt_table_cpltd {
  case_sensitive: no
}
explore: amortization_schedules {
  case_sensitive: no
}
explore: amortization_schedules_hist {
  case_sensitive: no
}
explore: loan_to_assets {
  case_sensitive: no
}
explore: sage_total_debt {
  case_sensitive: no
}

# Commented out due to low usage on 2026-03-30
# explore: debt_table_total_debt {
#   case_sensitive: no
# }
explore: sage_loan_balances {
  case_sensitive: no
}
explore: debt_table_loan_balances {
  case_sensitive: no
}
explore: dt_to_sage_bal_compare {
  case_sensitive: no
}
explore: dt_to_sage_compare_updated {
  case_sensitive: no
}

explore: operating_leased_assets {
  case_sensitive: no
}
