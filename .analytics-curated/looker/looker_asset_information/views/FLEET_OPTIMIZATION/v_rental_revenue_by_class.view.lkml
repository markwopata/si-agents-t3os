view: v_rental_revenue_by_class {
  sql_table_name: "FLEET_OPTIMIZATION"."GOLD"."V_RENTAL_REVENUE_BY_CLASS" ;;

  parameter: max_rank {
    type: number
    allowed_value: { value: "10" label: "Top 10" }
    allowed_value: { value: "25" label: "Top 25" }
    allowed_value: { value: "50" label: "Top 50" }
    allowed_value: { value: "100" label: "Top 100" }
    default_value: "25"
  }
  dimension: rank_limit {
    type:  number
    sql:  {% parameter max_rank %} ;;
  }
  dimension: class_revenue_per_rental_day {
    type: number
    sql: ${TABLE}."CLASS_REVENUE_PER_RENTAL_DAY" ;;
  }
  dimension: days_in_period {
    type: number
    sql: ${TABLE}."DAYS_IN_PERIOD" ;;
  }
  dimension_group: end {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."END_DATE" ;;
  }
  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }
  dimension: equipment_class_key {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS_KEY" ;;
  }
  dimension: equipment_class_name {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS_NAME" ;;
  }
  dimension: rev_by_class_key {
    type: string
    sql: ${TABLE}."REV_BY_CLASS_KEY" ;;
  }
  dimension_group: start {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."START_DATE" ;;
  }
  dimension: tf_key {
    type: string
    sql: ${TABLE}."TF_KEY" ;;
  }
  dimension: total_assets_in_class {
    type: number
    sql: ${TABLE}."TOTAL_ASSETS_IN_CLASS" ;;
  }
  dimension: total_class_rental_days {
    type: number
    sql: ${TABLE}."TOTAL_CLASS_RENTAL_DAYS" ;;
  }
  dimension: total_class_revenue {
    type: number
    sql: ${TABLE}."TOTAL_CLASS_REVENUE" ;;
  }
  measure: count {
    type: count
    drill_fields: [equipment_class_name]
  }
  measure: sum_class_revenue_per_rental_day{
    type: sum
    sql: ${class_revenue_per_rental_day} ;;
  }
  measure: sum_total_assets_in_class {
    type: sum
    sql: ${total_assets_in_class} ;;
  }
  measure: sum_total_class_rental_days {
    type: sum
    sql: ${total_class_rental_days} ;;
  }
  measure: sum_totaL_class_revenue {
    type: sum
    sql: ${total_class_revenue} ;;
  }
}
