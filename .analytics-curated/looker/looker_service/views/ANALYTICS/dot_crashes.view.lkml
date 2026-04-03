view: dot_crashes {
  sql_table_name: "PARTS_INVENTORY"."DOT_CRASHES" ;;

  dimension: citation_issued {
    type: string
    sql: ${TABLE}."CITATION_ISSUED" ;;
  }
  dimension: crash_date {
    type: date
    sql: ${TABLE}."CRASH_DATE" ;;
    allow_fill: yes
  }
  dimension: crash_fatalities {
    type: number
    sql: ${TABLE}."CRASH_FATALITIES" ;;
  }
  dimension: crash_injuries {
    type: number
    sql: ${TABLE}."CRASH_INJURIES" ;;
  }
  dimension: crash_number {
    type: string
    sql: ${TABLE}."CRASH_NUMBER" ;;
  }
  dimension: crash_state {
    type: string
    sql: ${TABLE}."CRASH_STATE" ;;
  }
  dimension: crash_towaway {
    type: string
    sql: ${TABLE}."CRASH_TOWAWAY" ;;
  }
  dimension: driver_date_of_birth {
    type: date
    sql: ${TABLE}."DRIVER_DATE_OF_BIRTH" ;;
  }
  dimension: driver_first_name {
    type: string
    sql: ${TABLE}."DRIVER_FIRST_NAME" ;;
  }
  dimension: driver_last_name {
    type: string
    sql: ${TABLE}."DRIVER_LAST_NAME" ;;
  }
  dimension: driver_license_number {
    type: string
    sql: ${TABLE}."DRIVER_LICENSE_NUMBER" ;;
  }
  dimension: driver_license_state {
    type: string
    sql: ${TABLE}."DRIVER_LICENSE_STATE" ;;
  }
  dimension: hm_released {
    type: string
    sql: ${TABLE}."HM_RELEASED" ;;
  }
  dimension: light_condition {
    type: string
    sql: ${TABLE}."LIGHT_CONDITION" ;;
  }
  dimension: not_preventable_flag {
    type: string
    sql: ${TABLE}."NOT_PREVENTABLE_FLAG" ;;
  }
  dimension: road_access_control {
    type: string
    sql: ${TABLE}."ROAD_ACCESS_CONTROL" ;;
  }
  dimension: road_surface_condition {
    type: string
    sql: ${TABLE}."ROAD_SURFACE_CONDITION" ;;
  }
  dimension: roadway_trafficway {
    type: string
    sql: ${TABLE}."ROADWAY_TRAFFICWAY" ;;
  }
  dimension: severity_weight_a {
    type: number
    sql: ${TABLE}."SEVERITY_WEIGHT_A" ;;
  }
  dimension: time_severity_weight_axb {
    type: number
    sql: ${TABLE}."TIME_SEVERITY_WEIGHT_AXB" ;;
  }
  dimension: time_weight_b {
    type: number
    sql: ${TABLE}."TIME_WEIGHT_B" ;;
  }
  dimension: vehicle_license_number {
    type: string
    sql: ${TABLE}."VEHICLE_LICENSE_NUMBER" ;;
  }
  dimension: vehicle_license_state {
    type: string
    sql: ${TABLE}."VEHICLE_LICENSE_STATE" ;;
  }
  dimension: vehicle_vin {
    type: string
    sql: ${TABLE}."VEHICLE_VIN" ;;
  }
  dimension: weather_condition {
    type: string
    sql: ${TABLE}."WEATHER_CONDITION" ;;
  }
  measure: count {
    type: count_distinct
    sql: ${crash_number} ;;
    drill_fields: [crash_date, crash_number, crash_state, driver_last_name, driver_first_name, vehicle_license_number, assets_aggregate.asset_id]
  }
}
