view: performance_reviews {
  sql_table_name: "LOOKER"."PERFORMANCE_REVIEWS" ;;

  dimension: cost_center {
    type: string
    sql: ${TABLE}."COST_CENTER" ;;
  }
  dimension: default_cost_center_full_path {
    type: string
    sql: ${TABLE}."DEFAULT_COST_CENTER_FULL_PATH" ;;
  }
  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }
  dimension: division {
    type: string
    sql: ${TABLE}."DIVISION" ;;
  }
  dimension_group: effective {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."EFFECTIVE_DATE" ;;
  }
  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }
  dimension_group: end {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."END_DATE" ;;
  }
  dimension: location {
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }
  dimension: manager_rating {
    type: string
    sql: ${TABLE}."MANAGER_RATING" ;;
  }
  dimension: overall_calculated_manager_rating {
    type: number
    sql: ${TABLE}."OVERALL_CALCULATED_MANAGER_RATING" ;;
  }
  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }
  dimension: review_template {
    type: string
    sql: ${TABLE}."REVIEW_TEMPLATE" ;;
  }
  dimension_group: start {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."START_DATE" ;;
  }
  dimension: title {
    type: string
    sql: ${TABLE}."TITLE" ;;
  }
  dimension: worker {
    type: string
    sql: ${TABLE}."WORKER" ;;
  }
  measure: count {
    type: count
  }
}
