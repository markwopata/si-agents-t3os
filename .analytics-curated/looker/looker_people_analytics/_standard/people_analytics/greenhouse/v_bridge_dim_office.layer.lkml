include: "/_base/people_analytics/greenhouse/v_bridge_dim_office.view.lkml"


view: +v_bridge_dim_office {
  label: "Bridge Dim Office"

  ################ DIMENSIONS ################

  dimension: bridge_dim_office_requisition_key {
    value_format_name: id
    description: "Requisition Key used to join the Requisition Table"
  }

  dimension: bridge_dim_office_id_full_path {
    value_format_name: id
  }

  dimension: bridge_dim_office_key {
    value_format_name: id
    description: "Office Key used to join the Office Table"
  }
}
