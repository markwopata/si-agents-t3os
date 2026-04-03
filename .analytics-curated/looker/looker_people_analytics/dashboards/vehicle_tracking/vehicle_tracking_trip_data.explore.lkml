include: "/_standard/people_analytics/looker/vehicle_tracking_trip_data.layer.lkml"
include: "/_standard/analytics/payroll/company_directory.layer.lkml"

explore: vehicle_tracking_trip_data {
  label: "Vehicle Tracking Trip Data"

  join: company_directory {
    type: left_outer
    relationship: one_to_one
    sql_on: ${vehicle_tracking_trip_data.employee_id} = ${company_directory.employee_id} ;;
  }
}
