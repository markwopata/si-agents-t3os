include: "/_base/people_analytics/looker/corporate_open_reqs.view.lkml"

view: +corporate_open_reqs {

  ############### DIMENSIONS ###############
  dimension: open_req_ids {
    value_format_name: id
    description: "Open Requisition IDs which labels a unique job in Greenhouse"
  }

  ############### MEASURES ###############
  measure: unique_open_req_ids {
    type: count_distinct
    sql: ${open_req_ids};;
    description: "Unique Count of Open Requisition IDs"
  }
}
