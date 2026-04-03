view: location_hierarchy {
  sql_table_name: "GREENHOUSE"."LOCATION_HIERARCHY" ;;

  dimension: district_id {
    type: number
    sql: ${TABLE}."DISTRICT_ID" ;;
  }
  dimension: district_name {
    type: string
    sql: ${TABLE}."DISTRICT_NAME" ;;
  }
  dimension: location_id {
    type: number
    sql: ${TABLE}."LOCATION_ID" ;;
  }
  dimension: location_name {
    type: string
    sql: ${TABLE}."LOCATION_NAME" ;;
  }
  dimension: location_parent_id {
    type: number
    sql: ${TABLE}."LOCATION_PARENT_ID" ;;
  }
  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }
  dimension: state {
    type: string
    map_layer_name: us_states
    sql: ${TABLE}."STATE" ;;
  }
  dimension: region_id {
    type: number
    sql: ${TABLE}."REGION_ID" ;;
  }
  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }
  measure: count {
    type: count
    drill_fields: [location_name, district_name, region_name, name]
  }
}
