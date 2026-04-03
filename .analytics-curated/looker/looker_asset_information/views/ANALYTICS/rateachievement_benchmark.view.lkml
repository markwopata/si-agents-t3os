view: rateachievement_benchmark {
  sql_table_name: "PUBLIC"."RATEACHIEVEMENT_BENCHMARK"
    ;;

  dimension: day_benchmark {
    type: number
    sql: coalesce(${TABLE}."DAY_BENCHMARK",0) ;;
  }

  dimension: divison {
    type: string
    sql: ${TABLE}."DIVISON" ;;
  }

  dimension: equipment_category {
    type: string
    sql: ${TABLE}."EQUIPMENT_CATEGORY" ;;
  }

  dimension: equipment_class {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS" ;;
  }

  dimension: equipment_class_id {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: month_benchmark {
    type: number
    sql: coalesce(${TABLE}."MONTH_BENCHMARK",0) ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: region_index {
    type: number
    sql: ${TABLE}."REGION_INDEX" ;;
  }

  dimension: week_benchmark {
    type: number
    sql: coalesce(${TABLE}."WEEK_BENCHMARK",0) ;;
  }

  dimension: year_quarter {
    type: string
    sql: ${TABLE}."YEAR_QUARTER" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
