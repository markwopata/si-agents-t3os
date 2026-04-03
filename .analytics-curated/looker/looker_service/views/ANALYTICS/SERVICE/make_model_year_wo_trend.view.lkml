view: make_model_year_wo_trend {
  sql_table_name: "SERVICE"."MAKE_MODEL_YEAR_WO_TREND" ;;

  dimension: agg_window {
    type: string
    sql: ${TABLE}."AGG_WINDOW" ;;
  }
  dimension_group: as_of {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."AS_OF" ;;
  }
  dimension: average_cost_per_asset_in_period {
    type: number
    sql: ${TABLE}."AVERAGE_COST_PER_ASSET_IN_PERIOD" ;;
  }
  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }
  dimension: class {
    type: string
    sql: ${TABLE}."CLASS" ;;
  }
  dimension: cost_per_asset_in_period {
    type: number
    sql: ${TABLE}."COST_PER_ASSET_IN_PERIOD" ;;
  }
  dimension: cost_per_work_order_in_period {
    type: number
    sql: ${TABLE}."COST_PER_WORK_ORDER_IN_PERIOD" ;;
  }
  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }
  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }
  dimension: number_of_assets_in_period {
    type: number
    sql: ${TABLE}."NUMBER_OF_ASSETS_IN_PERIOD" ;;
  }
  dimension: number_of_assets_with_work_orders_in_period {
    type: number
    sql: ${TABLE}."NUMBER_OF_ASSETS_WITH_WORK_ORDERS_IN_PERIOD" ;;
  }
  dimension: number_of_work_orders_in_period {
    type: number
    sql: ${TABLE}."NUMBER_OF_WORK_ORDERS_IN_PERIOD" ;;
  }
  dimension: problem_group {
    type: string
    sql: ${TABLE}."PROBLEM_GROUP" ;;
  }
  dimension: sub_category {
    type: string
    sql: ${TABLE}."SUB_CATEGORY" ;;
  }
  dimension: total_cost_in_period {
    type: number
    sql: ${TABLE}."TOTAL_COST_IN_PERIOD" ;;
  }
  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }
  measure: count {
    type: count
  }
}
