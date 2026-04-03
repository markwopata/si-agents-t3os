include: "/_base/people_analytics/greenhouse/v_dim_office.view.lkml"


view: +v_dim_office {
  label: "Dim Office"

  ################ DIMENSIONS ################

  dimension: office_key {
    value_format_name: id
    description: "Office Key used to join to the Fact Application Requisition Offer"
  }

  dimension: office_region_id {
    value_format_name: id
    description: "ID used to identify an office region"
  }

  dimension: office_district_id {
    value_format_name: id
    description: "ID used to identify an office district"
  }

  dimension: office_location_id {
    value_format_name: id
    description: "ID used to identify an office location"
  }


  dimension: district {
    type: string
    sql: substr(${TABLE}."OFFICE_DISTRICT_NAME",10,3) ;;
  }

  dimension: region {
    type: string
    sql: case when ${office_region_name} in ('Default Office Record','No Region Specified') then null
      else substr(${TABLE}."OFFICE_REGION_NAME",8,1) end;;
  }

}
