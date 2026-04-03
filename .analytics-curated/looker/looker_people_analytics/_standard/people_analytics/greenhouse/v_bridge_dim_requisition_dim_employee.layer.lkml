include: "/_base/people_analytics/greenhouse/v_bridge_dim_requisition_dim_employee.view.lkml"

view: +v_bridge_dim_requisition_dim_employee {
  label: "Bridge Dim Requisition Dim Employee"

  ######### DIMENSIONS #########

  dimension: bridge_dim_requisition_dim_employee_requisition_key {
    value_format_name: id
    description: "Requisition Key used to join the Requisition Table"
  }

  dimension: bridge_dim_requisition_dim_employee_employee_key {
    value_format_name: id
    description: "Employee Key used to join the Users Table"
  }
}
