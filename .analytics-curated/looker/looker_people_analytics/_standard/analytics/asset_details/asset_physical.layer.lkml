include: "/_base/analytics/asset_details/asset_physical.view.lkml"


view: +asset_physical {

  ############### DIMENSIONS ###############
  dimension: asset_id {
    value_format_name: id
  }
  dimension: rental_branch_id {
    value_format_name: id
  }
  dimension: rental_branch_company_id {
    value_format_name: id
  }
  dimension: service_branch_id {
    value_format_name: id
  }
  dimension:service_branch_company_id {
    value_format_name: id
  }
  dimension: inventory_branch_id {
    value_format_name: id
  }
  dimension: inventory_branch_company_id {
    value_format_name: id
  }
  dimension: asset_type_id {
    value_format_name: id
  }
  dimension: company_id {
    value_format_name: id
  }
  dimension: tracker_id {
    value_format_name: id
  }
  dimension: business_segment_id {
    value_format_name: id
  }
  dimension: sub_category_id {
    value_format_name: id
  }
  dimension: parent_category_id {
    value_format_name: id
  }

  ############### DATES ###############
  dimension_group: date_created {
    type: time
    timeframes: [raw,time,date,week,month,quarter,year]
    sql: ${date_created} ;;
  }
  dimension_group: table_update {
    type: time
    timeframes: [raw,time,date,week,month,quarter,year]
    sql: ${table_update} ;;
  }
}
