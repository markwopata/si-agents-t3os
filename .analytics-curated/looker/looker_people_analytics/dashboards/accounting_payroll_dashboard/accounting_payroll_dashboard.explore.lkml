include: "/_standard/people_analytics/looker/accounting_payroll_dashboard.layer.lkml"

view: +accounting_payroll_dashboard {

  dimension: pay_category_grouped {
    type: string
    sql: CASE WHEN ${pay_category} in ('FLSA Contract Overtime (1.5x)','FLSA Overtime (1.5x)') THEN 'FLSA Overtime (1.5x)'
    WHEN ${pay_category} in ('Parts commission','Rental Guarantee Guarantee','Rental Sales Commissions','Retail Sales Commission','Sales Guarantee Guarantee','T3 commission') THEN 'Commissions & Guarantees'
    ELSE ${pay_category} END;;
  }

}

explore: accounting_payroll_dashboard {
  label: "Account Payroll"
}
