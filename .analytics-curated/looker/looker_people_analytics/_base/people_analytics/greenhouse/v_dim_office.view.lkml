view: v_dim_office {
  sql_table_name: "PEOPLE_ANALYTICS"."GREENHOUSE"."V_DIM_OFFICE" ;;

  dimension: office_district_id {
    type: number
    sql: ${TABLE}."OFFICE_DISTRICT_ID" ;;
  }
  dimension: office_district_name {
    type: string
    sql: ${TABLE}."OFFICE_DISTRICT_NAME" ;;
  }
  dimension: office_external_id {
    type: string
    sql: ${TABLE}."OFFICE_EXTERNAL_ID" ;;
  }
  dimension: office_key {
    type: number
    sql: ${TABLE}."OFFICE_KEY" ;;
  }
  dimension: office_level {
    type: number
    sql: ${TABLE}."OFFICE_LEVEL" ;;
  }
  dimension: office_level_name {
    type: string
    sql: ${TABLE}."OFFICE_LEVEL_NAME" ;;
  }
  dimension: office_location_id {
    type: number
    sql: ${TABLE}."OFFICE_LOCATION_ID" ;;
  }
  dimension: office_location_name {
    type: string
    sql: ${TABLE}."OFFICE_LOCATION_NAME" ;;
  }
  dimension: office_name {
    type: string
    sql: ${TABLE}."OFFICE_NAME" ;;
  }
  dimension: office_region_id {
    type: number
    sql: ${TABLE}."OFFICE_REGION_ID" ;;
  }
  dimension: office_region_name {
    type: string
    sql: ${TABLE}."OFFICE_REGION_NAME" ;;
  }
  dimension: office_state {
    type: string
    sql: ${TABLE}."OFFICE_STATE" ;;
  }
  measure: count {
    type: count
    drill_fields: [office_level_name, office_location_name, office_name, office_region_name, office_district_name]
  }
}
