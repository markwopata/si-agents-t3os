include: "/_standard/analytics/commission/commission_details.layer.lkml"
include: "/_standard/people_analytics/test/gl_commission_test.layer.lkml"
include: "/_standard/analytics/commission/employee_commission_info.layer.lkml"
include: "/_base/analytics/commission/commission_types.view.lkml"
include: "/_standard/es_warehouse/public/users.layer.lkml"

# view: +commission_details {
#   label: "Prior Commission"

# }


explore: gl_commission_test {
  view_label: "Payroll GL Commission Report"
  label: "Commission Accruals"

  join: current_commission {
    from: commission_details
    view_label: "Current Commissions"
    type: left_outer
    relationship: one_to_many
    sql_on: (${gl_commission_test.intaact_code} = ${current_commission.branch_id}-- and ${gl_commission_test.cost_center_fixed} ilike '%Equipment Rental')
    and ${gl_commission_test.employee_id} = curren
    and date_trunc('month',${gl_commission_test.pay_date_date}::date) = ${current_commission.commission_month_raw};;
    }
  join: prior_commission {
    from: commission_details
    view_label: "Prior Commissions"
    type: left_outer
    relationship: one_to_many
    sql_on: (${gl_commission_test.intaact_code} = ${prior_commission.branch_id} and ${gl_commission_test.cost_center_fixed} ilike '%Equipment Rental')
    and dateadd('month',-1,date_trunc('month',${gl_commission_test.pay_date_date}::date)) = ${prior_commission.commission_month_raw};;
  }
  join: employee_commission_info {
    type: left_outer
    relationship: many_to_many
    sql_on:  ;;
  }
  join: users {}
}
# and ${gl_commission_test.pay_date_month} = ${commission_details.billing_approved_month}
