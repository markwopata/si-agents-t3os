view: overdue_inspections {
  sql_table_name: "ANALYTICS"."SERVICE"."OVERDUE_INSPECTIONS"
    ;;

  dimension: pkey {
    primary_key: yes
    type: string
    sql: CONCAT_WS('-', ${service_branch_id}, ${asset_id}, ${maintenance_group_interval_name}) ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset_id_service_link {
    type: string
    sql: ${asset_id} ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/assets/all/asset/{{value}}/service">{{rendered_value}}</a></u>;;
  }

  dimension: maintenance_group_interval_name {
    type: string
    sql: ${TABLE}."MAINTENANCE_GROUP_INTERVAL_NAME" ;;
  }

  dimension: overdue_type {
    label: "Inspection Type"
    type: string
    sql: ${TABLE}."OVERDUE_TYPE" ;;
  }

  dimension: service_branch_id {
    type: number
    sql: ${TABLE}."SERVICE_BRANCH_ID" ;;
  }

  dimension: asset_status {
    type: string
    sql: ${TABLE}."ASSET_STATUS" ;;
  }

  dimension_group: asset_status_start {
    type: time
    timeframes: [date, week, month, year]
    sql: ${TABLE}."ASSET_STATUS_START" ;;
  }

  dimension: until_next_service_usage {
    type: number
    sql: ${TABLE}."UNTIL_NEXT_INSPECTION_USAGE" ;;
  }

  dimension: until_next_service_time {
    type: number
    sql: ${TABLE}."UNTIL_NEXT_INSPECTION_TIME" ;;
  }


  # - - - - - MEASURES - - - - -

  measure: distinct_assets {
    type: count
    drill_fields: [detail*]
  }

  measure: overdue_ansi {
    type: count
    filters: [overdue_type: "ANSI"]
    drill_fields: [service_branch.market_name, count]
  }
  measure: overdue_on_rent_ANSI {
    type: count
    filters: [asset_status: "On Rent", overdue_type: "ANSI"]
    drill_fields: [service_branch.market_name, count]
  }

  measure: overdue_dot {
    type: count
    filters: [overdue_type: "DOT"]
    drill_fields: [service_branch.market_name, count]
  }

  measure: overdue_annual {
    type: count
    filters: [overdue_type: "Annual"]
    drill_fields: [service_branch.market_name, count]
  }

  measure: overdue_pm {
    type: count
    filters: [overdue_type: "PM"]
    drill_fields: [service_branch.market_name, count]
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # - - - - - SETS - - - - -
  set: detail {
    fields: [
      asset_id_service_link,
      assets_aggregate.make_model,
      assets_aggregate.class,
      service_branch.market_name,
      maintenance_group_interval_name,
      asset_status,
      asset_status_start_date,
      overdue_type,
      asset_location.location_info_date,
      asset_location.address,
      asset_location.map_link]
  }
}
