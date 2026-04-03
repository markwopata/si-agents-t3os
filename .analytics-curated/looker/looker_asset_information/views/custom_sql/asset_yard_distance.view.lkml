view: asset_yard_distance {
  sql_table_name: "ANALYTICS"."PUBLIC"."ASSET_YARD_DISTANCE"
    ;;

  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: tracker_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."TRACKER_ID" ;;
  }

  dimension: asset_status {
    type: string
    sql: ${TABLE}."ASSET_STATUS" ;;
  }

  dimension: inventory_branch {
    type: string
    sql: ${TABLE}."INVENTORY_BRANCH" ;;
  }

  dimension: inventory_branch_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."INVENTORY_BRANCH_ID" ;;
  }

  dimension: inventory_branch_company {
    type: string
    sql: ${TABLE}."INVENTORY_BRANCH_COMPANY" ;;
  }

  dimension: inventory_branch_company_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."INVENTORY_BRANCH_COMPANY_ID" ;;
  }

  dimension: inventory_branch_distance_mi {
    type: number
    sql: ${TABLE}."INVENTORY_BRANCH_DISTANCE_MI" ;;
  }

  dimension: rental_branch {
    type: string
    sql: ${TABLE}."RENTAL_BRANCH" ;;
  }

  dimension: rental_branch_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."RENTAL_BRANCH_ID" ;;
  }

  dimension: rental_branch_company {
    type: string
    sql: ${TABLE}."RENTAL_BRANCH_COMPANY" ;;
  }

  dimension: rental_branch_company_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."RENTAL_BRANCH_COMPANY_ID" ;;
  }

  dimension: rental_branch_distance_mi {
    type: number
    sql: ${TABLE}."RENTAL_BRANCH_DISTANCE_MI" ;;
  }

  dimension: service_branch {
    type: string
    sql: ${TABLE}."SERVICE_BRANCH" ;;
  }

  dimension: service_branch_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."SERVICE_BRANCH_ID" ;;
  }

  dimension: service_branch_company {
    type: string
    sql: ${TABLE}."SERVICE_BRANCH_COMPANY" ;;
  }

  dimension: service_branch_company_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."SERVICE_BRANCH_COMPANY_ID" ;;
  }

  dimension: service_branch_distance_mi {
    type: number
    sql: ${TABLE}."SERVICE_BRANCH_DISTANCE_MI" ;;
  }

  dimension: asset_latitude {
    type: number
    sql: ${TABLE}."ASSET_LATITUDE" ;;
  }

  dimension: asset_longitude {
    type: number
    sql: ${TABLE}."ASSET_LONGITUDE" ;;
  }

  dimension_group: tracker {
    type: time
    convert_tz: yes
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."TRACKER_TIME" AS TIMESTAMP_NTZ) ;;
  }

  dimension: map_link {
    type: string
    sql: COALESCE(CONCAT_WS(',', ${asset_latitude}, ${asset_longitude}), 'No coordinates available') ;;
    html:
    {% if tracker_id._value == null %}
    No Tracker
    {% elsif map_link._value == "No coordinates available" %}
    No coordinates from tracker
    {% else %}
    <u><font color="blue"><a href="https://maps.google.com/maps?q={{rendered_value}}">MAP</a></u>
    {% endif %};;
  }

  # - - - - - MEASURES - - - - -

  measure: count {
    type: count
    drill_fields: []
  }

  measure: on_rent_at_yard {
    type: count
    filters: [rental_branch_distance_mi: "< 1", asset_status: "On Rent"]
    drill_fields: [exception_details*]
  }

  measure: not_on_rent_or_at_yard {
    type: count
    filters: [rental_branch_distance_mi: "> 1", asset_status: "-On Rent"]
    drill_fields: [exception_details*]
  }

  measure: assets_missing_tracker {
    type: count
    filters: [tracker_id: "NULL"]
    drill_fields: [exception_details*]
  }

  measure: assets_tracker_but_no_coordinates {
    type: count
    filters: [asset_latitude: "NULL", tracker_id: ">0"]
    drill_fields: [exception_details*]
  }

  # - - - - - SETS - - - - -
  set: exception_details {
    fields: [
      asset_id,
      asset_status,
      rental_branch,
      rental_branch_distance_mi,
      service_branch,
      service_branch_distance_mi,
      inventory_branch,
      inventory_branch_distance_mi,
      map_link]
  }
}
