connection: "es_snowflake_analytics"

include: "/Dashboards/Budget/Views/*.view.lkml"

explore: budget {
  persist_for: "2 minutes"
  from: fact_transactions
  view_label: "Transactions"
  always_join: [dim_department]
  cancel_grouping_fields: [budget.post_date]
  sql_always_where:
  ARRAY_CONTAINS('{{_user_attributes['email']}}'::VARIANT, dim_department.allowed_emails)
  --OR {{_user_attributes['department']}} = 'developer' --removed 2024-05-16 Per Gina to remove access of all developers from dashboard
  AND ${budget.is_published}
  --{tag: corporate budget}
  ;;

  join: dim_date {
    view_label: "Date"
    type: full_outer
    relationship: many_to_one
    sql_on: ${budget.post_date} = ${dim_date.date}  ;;
  }

  join: dim_department {
    view_label: "Departments"
    type: inner
    relationship: many_to_one
    sql_on: ${budget.fk_department} = ${dim_department.pk_department} ;;
  }

  join: dim_expense_line {
    view_label: "Expense Lines"
    type: inner
    relationship: many_to_one
    sql_on: ${budget.fk_expense_line} = ${dim_expense_line.pk_expense_line} ;;
  }

  join: dim_budget_unit {
    view_label: "Budget Units"
    type: inner
    relationship: many_to_one
    sql_on: ${budget.fk_budget_unit} = ${dim_budget_unit.pk_budget_unit} ;;
  }

  join: sage_corporate_actuals_sv {
    view_label: "Troubleshooting Only | Fact Source - Sage"
    type: inner
    relationship: one_to_one
    sql_on:
    ${budget.sk_glentry_recordno} = ${sage_corporate_actuals_sv.glentry_recordno}
    AND ${budget.sk_glbatch_recordno} = ${sage_corporate_actuals_sv.glbatch_recordno}
    ;;
  }
}

explore: budget_employees {
  from: company_directory
  sql_always_where: (${budget_employees.date_hired} <= CURRENT_DATE())
  --{tag: corporate budget}
  ;;

  join: dim_department {
    type: inner
    relationship: many_to_one
    sql_on: ${budget_employees.default_cost_centers_full_path} = ${dim_department.ukg_cost_center} ;;
  }
}
