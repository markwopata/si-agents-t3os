include: "/_standard/people_analytics/looker/vehicle_tracking_employee_detail.layer.lkml"
include: "/_standard/analytics/payroll/company_directory.layer.lkml"

explore: vehicle_tracking_employee_detail {
  label: "Vehicle Tracking Employee Detail"

  join: company_directory {
    type: left_outer
    relationship: one_to_one
    sql_on: ${vehicle_tracking_employee_detail.employee_id} = ${company_directory.employee_id} ;;
  }
}
