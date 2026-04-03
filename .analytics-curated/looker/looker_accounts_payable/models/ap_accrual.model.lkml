connection: "es_snowflake"

include: "/views/**/*.view.lkml"                # include all views in the views/ folder in this project
# include: "/**/*.view.lkml"                 # include all views in this project
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard


explore: ap_accrual_2014_subledger_total {
  join: dim_date {
    relationship: many_to_one
    sql_on: ${ap_accrual_2014_subledger_total.entry_date} = ${dim_date.date_date} ;;
  }
}

explore: ap_accrual_ledger_vs_subledger {
  join: dim_date {
    relationship: many_to_one
    sql_on: ${ap_accrual_ledger_vs_subledger.entry_date} = ${dim_date.date_date} ;;
  }
}

explore: ap_accrual_2014_balance {
  join: dim_date {
    relationship: many_to_one
    sql_on: ${ap_accrual_2014_balance.period_start_date} = ${dim_date.date_date} ;;
  }
}

explore: ap_accrual_receipt_to_conversion {
  join: dim_date {
    relationship: many_to_one
    sql_on: ${ap_accrual_receipt_to_conversion.entry_date} = ${dim_date.date_date} ;;
  }
}

explore: ap_accrual_bill_to_receipt {
  join: dim_date {
    relationship: many_to_one
    sql_on: ${ap_accrual_bill_to_receipt.post_date} = ${dim_date.date_date} ;;
  }
}

explore: ap_accrual_invoice_to_receipt {
  join: dim_date {
    relationship: many_to_one
    sql_on: ${ap_accrual_invoice_to_receipt.entry_date} = ${dim_date.date_date} ;;
  }

  join: ap_accrual_journal_numbers {
    view_label: "Variance Journal Numbers"
    relationship: many_to_one
    sql_on: ${ap_accrual_invoice_to_receipt.journal_number} = ${ap_accrual_journal_numbers.journal_number} ;;
  }
}
