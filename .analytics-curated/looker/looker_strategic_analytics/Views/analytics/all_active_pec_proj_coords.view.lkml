view: all_active_pec_proj_coords {
  sql_table_name: "ANALYTICS"."MEGA_PROJECTS"."ALL_ACTIVE_PEC_PROJ_COORDS" ;;

  dimension: project_id {
    type: string
    sql: ${TABLE}."PROJECT_ID" ;;
  }

  dimension: owner_id {
    type: string
    sql: ${TABLE}."OWNER_ID" ;;
  }

  dimension: owner_name {
    type: string
    sql: ${TABLE}."OWNER_NAME" ;;
  }

  dimension: proj_name {
    type: string
    sql: ${TABLE}."PROJ_NAME" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  dimension: est_proj_value {
    type: number
    sql: ${TABLE}."EST_PROJ_VALUE" ;;
    value_format_name: usd
  }

  dimension: latitude {
    type: number
    sql: ${TABLE}."LATITUDE" ;;
  }

  dimension: longitude {
    type: number
    sql: ${TABLE}."LONGITUDE" ;;
  }

  dimension: activity_status {
    type: string
    sql: ${TABLE}."ACTIVITY_STATUS" ;;
  }

  dimension: pecweb_url {
    type: string
    sql: ${TABLE}."PECWEB_URL" ;;
  }

  dimension: ind_desc {
    type: string
    sql: ${TABLE}."IND_DESC" ;;
  }

  dimension: plant_city {
    type: string
    sql: ${TABLE}."PLANT_CITY" ;;
  }

  dimension: activity_desc {
    type: string
    sql: ${TABLE}."ACTIVITY_DESC" ;;
  }

  dimension: plant_zip {
    type: string
    sql: ${TABLE}."PLANT_ZIP" ;;
  }

  dimension: plant_st {
    type: string
    sql: ${TABLE}."PLANT_ST" ;;
  }

  dimension: project_type {
    type: string
    sql: ${TABLE}."PROJECT_TYPE" ;;
  }

  dimension: plant_name {
    type: string
    sql: ${TABLE}."PLANT_NAME" ;;
  }

  dimension: plant_addr {
    type: string
    sql: ${TABLE}."PLANT_ADDR" ;;
  }

  dimension_group: kickoff_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."KICKOFF_DATE" ;;
  }

  dimension_group: est_completion_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."EST_COMPLETION_DATE" ;;
  }

  dimension_group: publish_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."PUBLISH_DATE" ;;
  }

  set: detail_drill {
    fields: [project_id, proj_name, owner_name, plant_city, plant_st, est_proj_value, kickoff_date_date]
  }

  measure: count {
    type: count
    drill_fields: [detail_drill*]
  }

  measure: total_est_proj_value {
    type: sum
    sql: ${est_proj_value} ;;
    value_format_name: usd
  }
}
