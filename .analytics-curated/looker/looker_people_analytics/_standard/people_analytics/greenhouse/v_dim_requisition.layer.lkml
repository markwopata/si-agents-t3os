include: "/_base/people_analytics/greenhouse/v_dim_requisition.view.lkml"


view: +v_dim_requisition {
  label: "Dim Requisition"

  ################ DIMENSIONS ################

  dimension: requisition_key {
    value_format_name: id
    description: "Requisition Key used to join Fact Application Requisition Offer table"
  }

  dimension: requisition_number_id {
    value_format_name: id
    description: "ID used to identify a Requisition, Job ID"
  }

  dimension: requisition_id {
    value_format_name: id
    description: "The field used to actually identify different requisitions"
  }

  dimension: greenhouse_link {
    type: string
    html:
      <font color="blue "><u><a href = "https://app.greenhouse.io/sdash/{{ requisition_key | url_encode }}" target="_blank">Greenhouse Link</a></font></u>;;
    sql: 'Link' ;;
  }


  ################ MEASURES ################

  measure: unique_requisition_ids {
    type: count_distinct
    sql: ${requisition_id} ;;
    description: "Total number of distinct requisitions"
  }

  measure: unique_backfill_requisition_ids {
    type: count_distinct
    sql: ${requisition_id} ;;
    filters: [requisition_custom_hire_type: "Backfill"]
    description: "Total number of distinct backfill requisitions"
  }

  measure: unique_new_headcount_requisition_ids {
    type: count_distinct
    sql: ${requisition_id} ;;
    filters: [requisition_custom_hire_type: "New Headcount"]
    description: "Total number of distinct new headcount requisitions"
  }
}
