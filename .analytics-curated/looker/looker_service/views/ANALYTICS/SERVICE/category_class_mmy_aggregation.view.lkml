view: category_class_mmy_aggregation {
  sql_table_name: "SERVICE"."CATEGORY_CLASS_MMY_AGGREGATION" ;;

  dimension: agg_window {
    type: string
    sql: ${TABLE}."AGG_WINDOW" ;;
  }
  dimension: agg_window_order {
    type: number
    sql: ${TABLE}."AGG_WINDOW_ORDER" ;;
  }
  dimension_group: as_of {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."AS_OF" ;;
  }
  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }
  dimension: category_cost_per_asset_in_period {
    type: number
    sql: ${TABLE}."CATEGORY_COST_PER_ASSET_IN_PERIOD" ;;
  }
  dimension: category_cost_per_work_order_in_period {
    type: number
    sql: ${TABLE}."CATEGORY_COST_PER_WORK_ORDER_IN_PERIOD" ;;
  }
  dimension: category_total_assets_in_period {
    type: number
    sql: ${TABLE}."CATEGORY_TOTAL_ASSETS_IN_PERIOD" ;;
  }
  dimension: category_total_assets_with_work_orders_in_period {
    type: number
    sql: ${TABLE}."CATEGORY_TOTAL_ASSETS_WITH_WORK_ORDERS_IN_PERIOD" ;;
  }
  dimension: category_total_cost {
    type: number
    sql: ${TABLE}."CATEGORY_TOTAL_COST" ;;
  }
  dimension: category_total_work_orders_in_period {
    type: number
    sql: ${TABLE}."CATEGORY_TOTAL_WORK_ORDERS_IN_PERIOD" ;;
  }
  dimension: class {
    type: string
    sql: ${TABLE}."CLASS" ;;
  }
  dimension: class_cost_per_asset_in_period {
    type: number
    sql: ${TABLE}."CLASS_COST_PER_ASSET_IN_PERIOD" ;;
  }
  dimension: class_cost_per_work_order_in_period {
    type: number
    sql: ${TABLE}."CLASS_COST_PER_WORK_ORDER_IN_PERIOD" ;;
  }
  dimension: class_total_assets_in_period {
    type: number
    sql: ${TABLE}."CLASS_TOTAL_ASSETS_IN_PERIOD" ;;
  }
  dimension: class_total_assets_with_work_orders_in_period {
    type: number
    sql: ${TABLE}."CLASS_TOTAL_ASSETS_WITH_WORK_ORDERS_IN_PERIOD" ;;
  }
  dimension: class_total_cost {
    type: number
    sql: ${TABLE}."CLASS_TOTAL_COST" ;;
  }
  dimension: class_total_work_orders_in_period {
    type: number
    sql: ${TABLE}."CLASS_TOTAL_WORK_ORDERS_IN_PERIOD" ;;
  }
  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }
  dimension: make_cost_per_asset_in_period {
    type: number
    sql: ${TABLE}."MAKE_COST_PER_ASSET_IN_PERIOD" ;;
  }
  dimension: make_cost_per_work_order_in_period {
    type: number
    sql: ${TABLE}."MAKE_COST_PER_WORK_ORDER_IN_PERIOD" ;;
  }
  dimension: make_total_assets_in_period {
    type: number
    sql: ${TABLE}."MAKE_TOTAL_ASSETS_IN_PERIOD" ;;
  }
  dimension: make_total_assets_with_work_orders_in_period {
    type: number
    sql: ${TABLE}."MAKE_TOTAL_ASSETS_WITH_WORK_ORDERS_IN_PERIOD" ;;
  }
  dimension: make_total_cost {
    type: number
    sql: ${TABLE}."MAKE_TOTAL_COST" ;;
  }
  dimension: make_total_work_orders_in_period {
    type: number
    sql: ${TABLE}."MAKE_TOTAL_WORK_ORDERS_IN_PERIOD" ;;
  }
  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }
  dimension: model_cost_per_asset_in_period {
    type: number
    sql: ${TABLE}."MODEL_COST_PER_ASSET_IN_PERIOD" ;;
  }
  dimension: model_cost_per_work_order_in_period {
    type: number
    sql: ${TABLE}."MODEL_COST_PER_WORK_ORDER_IN_PERIOD" ;;
  }
  dimension: model_total_assets_in_period {
    type: number
    sql: ${TABLE}."MODEL_TOTAL_ASSETS_IN_PERIOD" ;;
  }
  dimension: model_total_assets_with_work_orders_in_period {
    type: number
    sql: ${TABLE}."MODEL_TOTAL_ASSETS_WITH_WORK_ORDERS_IN_PERIOD" ;;
  }
  dimension: model_total_cost {
    type: number
    sql: ${TABLE}."MODEL_TOTAL_COST" ;;
  }
  dimension: model_total_work_orders_in_period {
    type: number
    sql: ${TABLE}."MODEL_TOTAL_WORK_ORDERS_IN_PERIOD" ;;
  }
  dimension: problem_group {
    type: string
    sql: ${TABLE}."PROBLEM_GROUP" ;;
  }
  dimension: sub_category {
    type: string
    sql: ${TABLE}."SUB_CATEGORY" ;;
  }
  dimension: sub_category_cost_per_asset_in_period {
    type: number
    sql: ${TABLE}."SUB_CATEGORY_COST_PER_ASSET_IN_PERIOD" ;;
  }
  dimension: sub_category_cost_per_work_order_in_period {
    type: number
    sql: ${TABLE}."SUB_CATEGORY_COST_PER_WORK_ORDER_IN_PERIOD" ;;
  }
  dimension: sub_category_total_assets_in_period {
    type: number
    sql: ${TABLE}."SUB_CATEGORY_TOTAL_ASSETS_IN_PERIOD" ;;
  }
  dimension: sub_category_total_assets_with_work_orders_in_period {
    type: number
    sql: ${TABLE}."SUB_CATEGORY_TOTAL_ASSETS_WITH_WORK_ORDERS_IN_PERIOD" ;;
  }
  dimension: sub_category_total_cost {
    type: number
    sql: ${TABLE}."SUB_CATEGORY_TOTAL_COST" ;;
  }
  dimension: sub_category_total_work_orders_in_period {
    type: number
    sql: ${TABLE}."SUB_CATEGORY_TOTAL_WORK_ORDERS_IN_PERIOD" ;;
  }
  dimension: primary_key {
    type: string
    primary_key: yes
    sql: concat(${agg_window},'-',${as_of_date},'-',${problem_group},'/',${make},'/',${model},'/'${year}) ;;
  }
  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }
  dimension: year_cost_per_asset_in_period {
    type: number
    sql: ${TABLE}."YEAR_COST_PER_ASSET_IN_PERIOD" ;;
  }
  dimension: year_cost_per_work_order_in_period {
    type: number
    sql: ${TABLE}."YEAR_COST_PER_WORK_ORDER_IN_PERIOD" ;;
  }
  dimension: year_total_assets_in_period {
    type: number
    sql: ${TABLE}."YEAR_TOTAL_ASSETS_IN_PERIOD" ;;
  }
  dimension: year_total_assets_with_work_orders_in_period {
    type: number
    sql: ${TABLE}."YEAR_TOTAL_ASSETS_WITH_WORK_ORDERS_IN_PERIOD" ;;
  }
  dimension: year_total_cost {
    type: number
    sql: ${TABLE}."YEAR_TOTAL_COST" ;;
  }
  dimension: year_total_work_orders_in_period {
    type: number
    sql: ${TABLE}."YEAR_TOTAL_WORK_ORDERS_IN_PERIOD" ;;
  }
  measure: count {
    type: count
  }
}
