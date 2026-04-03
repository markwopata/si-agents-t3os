include: "/_base/people_analytics/greenhouse/v_dim_department.view.lkml"


view: +v_dim_department {
  label: "Dim Department"

  ################ DIMENSIONS ################

  dimension: department_key {
    value_format_name: id
    description: "Department Key used to join to the Fact Application Requisition Offer table"
  }

  dimension: department_id {
    value_format_name: id
    description: "ID used to identify a department"
  }

  dimension: department_parent_id {
    value_format_name: id
    description: "ID used to identify the parent of a department"
  }
}
