view: category_class_comparison {
  sql_table_name: "SERVICE"."CATEGORY_CLASS_COMPARISON" ;;

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
  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }
  dimension: class {
    type: string
    sql: ${TABLE}."CLASS" ;;
  }
  dimension: exclusive_class_to_category {
    type: number
    sql: ${TABLE}."EXCLUSIVE_CLASS_TO_CATEGORY" ;;
    value_format_name: percent_2
  }
  dimension: exclusive_class_to_sub_category {
    type: number
    sql: ${TABLE}."EXCLUSIVE_CLASS_TO_SUB_CATEGORY" ;;
    value_format_name: percent_2
  }
  dimension: exclusive_make_to_category {
    type: number
    sql: ${TABLE}."EXCLUSIVE_MAKE_TO_CATEGORY" ;;
    value_format_name: percent_2
  }
  dimension: exclusive_make_to_class {
    type: number
    sql: ${TABLE}."EXCLUSIVE_MAKE_TO_CLASS" ;;
    value_format_name: percent_2
  }
  dimension: exclusive_make_to_sub_category {
    type: number
    sql: ${TABLE}."EXCLUSIVE_MAKE_TO_SUB_CATEGORY" ;;
    value_format_name: percent_2
  }
  dimension: exclusive_model_to_category {
    type: number
    sql: ${TABLE}."EXCLUSIVE_MODEL_TO_CATEGORY" ;;
    value_format_name: percent_2
  }
  dimension: exclusive_model_to_class {
    type: number
    sql: ${TABLE}."EXCLUSIVE_MODEL_TO_CLASS" ;;
    value_format_name: percent_2
  }
  dimension: exclusive_model_to_make {
    type: number
    sql: ${TABLE}."EXCLUSIVE_MODEL_TO_MAKE" ;;
    value_format_name: percent_2
  }
  dimension: exclusive_model_to_sub_category {
    type: number
    sql: ${TABLE}."EXCLUSIVE_MODEL_TO_SUB_CATEGORY" ;;
    value_format_name: percent_2
  }
  dimension: exclusive_sub_category_to_category {
    type: number
    sql: ${TABLE}."EXCLUSIVE_SUB_CATEGORY_TO_CATEGORY" ;;
    value_format_name: percent_2
  }
  dimension: exclusive_year_to_category {
    type: number
    sql: ${TABLE}."EXCLUSIVE_YEAR_TO_CATEGORY" ;;
    value_format_name: percent_2
  }
  dimension: exclusive_year_to_class {
    type: number
    sql: ${TABLE}."EXCLUSIVE_YEAR_TO_CLASS" ;;
    value_format_name: percent_2
  }
  dimension: exclusive_year_to_make {
    type: number
    sql: ${TABLE}."EXCLUSIVE_YEAR_TO_MAKE" ;;
    value_format_name: percent_2
  }
  dimension: exclusive_year_to_model {
    type: number
    sql: ${TABLE}."EXCLUSIVE_YEAR_TO_MODEL" ;;
    value_format_name: percent_2
  }
  dimension: exclusive_year_to_sub_category {
    type: number
    sql: ${TABLE}."EXCLUSIVE_YEAR_TO_SUB_CATEGORY" ;;
    value_format_name: percent_2
  }
  dimension: inclusive_class_to_category {
    type: number
    sql: ${TABLE}."INCLUSIVE_CLASS_TO_CATEGORY" ;;
    value_format_name: percent_2
  }
  dimension: inclusive_class_to_sub_category {
    type: number
    sql: ${TABLE}."INCLUSIVE_CLASS_TO_SUB_CATEGORY" ;;
    value_format_name: percent_2
  }
  dimension: inclusive_make_to_category {
    type: number
    sql: ${TABLE}."INCLUSIVE_MAKE_TO_CATEGORY" ;;
    value_format_name: percent_2
  }
  dimension: inclusive_make_to_class {
    type: number
    sql: ${TABLE}."INCLUSIVE_MAKE_TO_CLASS" ;;
    value_format_name: percent_2
  }
  dimension: inclusive_make_to_sub_category {
    type: number
    sql: ${TABLE}."INCLUSIVE_MAKE_TO_SUB_CATEGORY" ;;
    value_format_name: percent_2
  }
  dimension: inclusive_model_to_category {
    type: number
    sql: ${TABLE}."INCLUSIVE_MODEL_TO_CATEGORY" ;;
    value_format_name: percent_2
  }
  dimension: inclusive_model_to_class {
    type: number
    sql: ${TABLE}."INCLUSIVE_MODEL_TO_CLASS" ;;
    value_format_name: percent_2
  }
  dimension: inclusive_model_to_make {
    type: number
    sql: ${TABLE}."INCLUSIVE_MODEL_TO_MAKE" ;;
    value_format_name: percent_2
  }
  dimension: inclusive_model_to_sub_category {
    type: number
    sql: ${TABLE}."INCLUSIVE_MODEL_TO_SUB_CATEGORY" ;;
    value_format_name: percent_2
  }
  dimension: inclusive_sub_category_to_category {
    type: number
    sql: ${TABLE}."INCLUSIVE_SUB_CATEGORY_TO_CATEGORY" ;;
    value_format_name: percent_2
  }
  dimension: inclusive_year_to_category {
    type: number
    sql: ${TABLE}."INCLUSIVE_YEAR_TO_CATEGORY" ;;
    value_format_name: percent_2
  }
  dimension: inclusive_year_to_class {
    type: number
    sql: ${TABLE}."INCLUSIVE_YEAR_TO_CLASS" ;;
    value_format_name: percent_2
  }
  dimension: inclusive_year_to_make {
    type: number
    sql: ${TABLE}."INCLUSIVE_YEAR_TO_MAKE" ;;
    value_format_name: percent_2
  }
  dimension: inclusive_year_to_model {
    type: number
    sql: ${TABLE}."INCLUSIVE_YEAR_TO_MODEL" ;;
    value_format_name: percent_2
  }
  dimension: inclusive_year_to_sub_category {
    type: number
    sql: ${TABLE}."INCLUSIVE_YEAR_TO_SUB_CATEGORY" ;;
    value_format_name: percent_2
  }
  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }
  dimension: metric {
    type: string
    sql: ${TABLE}."METRIC" ;;
  }
  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }
  dimension: primary_key {
    type: string
    primary_key: yes
    sql: concat(${agg_window},'-',${as_of_date},'-',${problem_group},'/',${make},'/',${model},'/'${year}) ;;
  }
  dimension: problem_group {
    type: string
    sql: ${TABLE}."PROBLEM_GROUP" ;;
  }
  dimension: sub_category {
    type: string
    sql: ${TABLE}."SUB_CATEGORY" ;;
  }
  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
    value_format_name: id
  }
  parameter: x_comparison_item {
    type: string
    allowed_value: {value: "Year"}
    allowed_value: {value: "Model"}
    allowed_value: {value: "Make"}
    allowed_value: {value: "Class"}
    allowed_value: {value: "Sub Category"}
  }
  parameter: y_comparison_group {
    type: string
    allowed_value: {value: "Model"}
    allowed_value: {value: "Make"}
    allowed_value: {value: "Class"}
    allowed_value: {value: "Sub Category"}
    allowed_value: {value: "Category"}
  }
  measure: avg_exclusive_class_to_category {
    type: average
    sql: ${exclusive_class_to_category} ;;
    value_format_name: percent_2
  }
  measure: avg_exclusive_class_to_sub_category {
    type: average
    sql: ${exclusive_class_to_sub_category} ;;
    value_format_name: percent_2
  }
  measure: avg_exclusive_make_to_category {
    type: average
    sql: ${exclusive_make_to_category} ;;
    value_format_name: percent_2
  }
  measure: avg_exclusive_make_to_class {
    type: average
    sql: ${exclusive_make_to_class} ;;
    value_format_name: percent_2
  }
  measure: avg_exclusive_make_to_sub_category {
    type: average
    sql: ${exclusive_make_to_sub_category} ;;
    value_format_name: percent_2
  }
  measure: avg_exclusive_model_to_category {
    type: average
    sql: ${exclusive_model_to_category} ;;
    value_format_name: percent_2
  }
  measure: avg_exclusive_model_to_class {
    type: average
    sql: ${exclusive_model_to_class} ;;
    value_format_name: percent_2
  }
  measure: avg_exclusive_model_to_make {
    type: average
    sql: ${exclusive_model_to_make} ;;
    value_format_name: percent_2
  }
  measure: avg_exclusive_model_to_sub_category {
    type: average
    sql: ${exclusive_model_to_sub_category} ;;
    value_format_name: percent_2
  }
  measure: avg_exclusive_sub_category_to_category {
    type: average
    sql: ${exclusive_sub_category_to_category} ;;
    value_format_name: percent_2
  }
  measure: avg_exclusive_year_to_category {
    type: average
    sql: ${exclusive_year_to_category} ;;
    value_format_name: percent_2
  }
  measure: avg_exclusive_year_to_class {
    type: average
    sql: ${exclusive_year_to_class} ;;
    value_format_name: percent_2
  }
  measure: avg_exclusive_year_to_make {
    type: average
    sql: ${exclusive_year_to_make} ;;
    value_format_name: percent_2
  }
  measure: avg_exclusive_year_to_model {
    type: average
    sql: ${exclusive_year_to_model} ;;
    value_format_name: percent_2
  }
  measure: avg_exclusive_year_to_sub_category {
    type: average
    sql: ${exclusive_year_to_sub_category} ;;
    value_format_name: percent_2
  }
  measure: avg_inclusive_class_to_category {
    type: average
    sql: ${inclusive_class_to_category} ;;
    value_format_name: percent_2
  }
  measure: avg_inclusive_class_to_sub_category {
    type: average
    sql: ${inclusive_class_to_sub_category} ;;
    value_format_name: percent_2
  }
  measure: avg_inclusive_make_to_category {
    type: average
    sql: ${inclusive_make_to_category} ;;
    value_format_name: percent_2
  }
  measure: avg_inclusive_make_to_class {
    type: average
    sql: ${inclusive_make_to_class} ;;
    value_format_name: percent_2
  }
  measure: avg_inclusive_make_to_sub_category {
    type: average
    sql: ${inclusive_make_to_sub_category} ;;
    value_format_name: percent_2
  }
  measure: avg_inclusive_model_to_category {
    type: average
    sql: ${inclusive_model_to_category} ;;
    value_format_name: percent_2
  }
  measure: avg_inclusive_model_to_class {
    type: average
    sql: ${inclusive_model_to_class} ;;
    value_format_name: percent_2
  }
  measure: avg_inclusive_model_to_make {
    type: average
    sql: ${inclusive_model_to_make} ;;
    value_format_name: percent_2
  }
  measure: avg_inclusive_model_to_sub_category {
    type: average
    sql: ${inclusive_model_to_sub_category} ;;
    value_format_name: percent_2
  }
  measure: avg_inclusive_sub_category_to_category {
    type: average
    sql: ${inclusive_sub_category_to_category} ;;
    value_format_name: percent_2
  }
  measure: avg_inclusive_year_to_category {
    type: average
    sql: ${inclusive_year_to_category} ;;
    value_format_name: percent_2
  }
  measure: avg_inclusive_year_to_class {
    type: average
    sql: ${inclusive_year_to_class} ;;
    value_format_name: percent_2
  }
  measure: avg_inclusive_year_to_make {
    type: average
    sql: ${inclusive_year_to_make} ;;
    value_format_name: percent_2
  }
  measure: avg_inclusive_year_to_model {
    type: average
    sql: ${inclusive_year_to_model} ;;
    value_format_name: percent_2
  }
  measure: avg_inclusive_year_to_sub_category {
    type: average
    sql: ${inclusive_year_to_sub_category} ;;
    value_format_name: percent_2
  }
}

view: category_class_roc {
  derived_table: {
    sql:
    with percent_of_group as (
    select
    as_of,
    agg_window,
    problem_group,
    category,
    sub_category,
    class,
    make,
    model,
    year,
    exclusive_year_to_class as percentage_year_to_class
    from ${category_class_comparison.SQL_TABLE_NAME} as ccc
    where ccc.metric = 'percentage_of_assets_in_group'
    )

    ,non_work_order as (
    select distinct
    make,
    model,
    year,
    problem_group,
    true as has_work_orders
    from analytics.service.daily_work_order_info
    where problem_group is not null
    )

    select
    ccc.as_of,
    ccc.agg_window,
    ccc.metric,
    ccc.problem_group,
    ccc.category,
    ccc.sub_category,
    ccc.class,
    ccc.make,
    ccc.model,
    ccc.year,
    percentage_year_to_class,
    ifnull(nwo.has_work_orders,false) as has_work_orders,
    -- inclusive_year_to_model
    inclusive_year_to_model,
    lag(inclusive_year_to_model) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as inclusive_year_to_model_lag,
    inclusive_year_to_model - lag(inclusive_year_to_model) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as inclusive_year_to_model_difference,
    -- inclusive_year_to_make
    inclusive_year_to_make,
    lag(inclusive_year_to_make) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as inclusive_year_to_make_lag,
    inclusive_year_to_make - lag(inclusive_year_to_make) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as inclusive_year_to_make_difference,
    -- inclusive_year_to_class
    inclusive_year_to_class,
    lag(inclusive_year_to_class) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as inclusive_year_to_class_lag,
    inclusive_year_to_class - lag(inclusive_year_to_class) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as inclusive_year_to_class_difference,
    -- inclusive_year_to_sub_category
    inclusive_year_to_sub_category,
    lag(inclusive_year_to_sub_category) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as inclusive_year_to_sub_category_lag,
    inclusive_year_to_sub_category - lag(inclusive_year_to_sub_category) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as inclusive_year_to_sub_category_difference,
    -- inclusive_year_to_category
    inclusive_year_to_category,
    lag(inclusive_year_to_category) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as inclusive_year_to_category_lag,
    inclusive_year_to_category - lag(inclusive_year_to_category) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as inclusive_year_to_category_difference,
    -- inclusive_model_to_make
    inclusive_model_to_make,
    lag(inclusive_model_to_make) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as inclusive_model_to_make_lag,
    inclusive_model_to_make - lag(inclusive_model_to_make) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as inclusive_model_to_make_difference,
    -- inclusive_model_to_class
    inclusive_model_to_class,
    lag(inclusive_model_to_class) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as inclusive_model_to_class_lag,
    inclusive_model_to_class - lag(inclusive_model_to_class) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as inclusive_model_to_class_difference,
    -- inclusive_model_to_sub_category
    inclusive_model_to_sub_category,
    lag(inclusive_model_to_sub_category) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as inclusive_model_to_sub_category_lag,
    inclusive_model_to_sub_category - lag(inclusive_model_to_sub_category) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as inclusive_model_to_sub_category_difference,
    -- inclusive_model_to_category
    inclusive_model_to_category,
    lag(inclusive_model_to_category) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as inclusive_model_to_category_lag,
    inclusive_model_to_category - lag(inclusive_model_to_category) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as inclusive_model_to_category_difference,
    -- inclusive_make_to_class
    inclusive_make_to_class,
    lag(inclusive_make_to_class) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as inclusive_make_to_class_lag,
    inclusive_make_to_class - lag(inclusive_make_to_class) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as inclusive_make_to_class_difference,
    -- inclusive_make_to_sub_category
    inclusive_make_to_sub_category,
    lag(inclusive_make_to_sub_category) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as inclusive_make_to_sub_category_lag,
    inclusive_make_to_sub_category - lag(inclusive_make_to_sub_category) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as inclusive_make_to_sub_category_difference,
    -- inclusive_make_to_category
    inclusive_make_to_category,
    lag(inclusive_make_to_category) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as inclusive_make_to_category_lag,
    inclusive_make_to_category - lag(inclusive_make_to_category) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as inclusive_make_to_category_difference,
    -- inclusive_class_to_sub_category
    inclusive_class_to_sub_category,
    lag(inclusive_class_to_sub_category) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as inclusive_class_to_sub_category_lag,
    inclusive_class_to_sub_category - lag(inclusive_class_to_sub_category) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as inclusive_class_to_sub_category_difference,
    -- inclusive_class_to_category
    inclusive_class_to_category,
    lag(inclusive_class_to_category) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as inclusive_class_to_category_lag,
    inclusive_class_to_category - lag(inclusive_class_to_category) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as inclusive_class_to_category_difference,
    -- inclusive_sub_category_to_category
    inclusive_sub_category_to_category,
    lag(inclusive_sub_category_to_category) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as inclusive_sub_category_to_category_lag,
    inclusive_sub_category_to_category - lag(inclusive_sub_category_to_category) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as inclusive_sub_category_to_category_difference,
    -- exclusive_year_to_model
    exclusive_year_to_model,
    lag(exclusive_year_to_model) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as exclusive_year_to_model_lag,
    exclusive_year_to_model - lag(exclusive_year_to_model) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as exclusive_year_to_model_difference,
    -- exclusive_year_to_make
    exclusive_year_to_make,
    lag(exclusive_year_to_make) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as exclusive_year_to_make_lag,
    exclusive_year_to_make - lag(exclusive_year_to_make) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as exclusive_year_to_make_difference,
    -- exclusive_year_to_class
    exclusive_year_to_class,
    lag(exclusive_year_to_class) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as exclusive_year_to_class_lag,
    exclusive_year_to_class - lag(exclusive_year_to_class) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as exclusive_year_to_class_difference,
    -- exclusive_year_to_sub_category
    exclusive_year_to_sub_category,
    lag(exclusive_year_to_sub_category) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as exclusive_year_to_sub_category_lag,
    exclusive_year_to_sub_category - lag(exclusive_year_to_sub_category) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as exclusive_year_to_sub_category_difference,
    -- exclusive_year_to_category
    exclusive_year_to_category,
    lag(exclusive_year_to_category) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as exclusive_year_to_category_lag,
    exclusive_year_to_category - lag(exclusive_year_to_category) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as exclusive_year_to_category_difference,
    -- exclusive_model_to_make
    exclusive_model_to_make,
    lag(exclusive_model_to_make) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as exclusive_model_to_make_lag,
    exclusive_model_to_make - lag(exclusive_model_to_make) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as exclusive_model_to_make_difference,
    -- exclusive_model_to_class
    exclusive_model_to_class,
    lag(exclusive_model_to_class) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as exclusive_model_to_class_lag,
    exclusive_model_to_class - lag(exclusive_model_to_class) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as exclusive_model_to_class_difference,
    -- exclusive_model_to_sub_category
    exclusive_model_to_sub_category,
    lag(exclusive_model_to_sub_category) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as exclusive_model_to_sub_category_lag,
    exclusive_model_to_sub_category - lag(exclusive_model_to_sub_category) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as exclusive_model_to_sub_category_difference,
    -- exclusive_model_to_category
    exclusive_model_to_category,
    lag(exclusive_model_to_category) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as exclusive_model_to_category_lag,
    exclusive_model_to_category - lag(exclusive_model_to_category) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as exclusive_model_to_category_difference,
    -- exclusive_make_to_class
    exclusive_make_to_class,
    lag(exclusive_make_to_class) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as exclusive_make_to_class_lag,
    exclusive_make_to_class - lag(exclusive_make_to_class) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as exclusive_make_to_class_difference,
    -- exclusive_make_to_sub_category
    exclusive_make_to_sub_category,
    lag(exclusive_make_to_sub_category) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as exclusive_make_to_sub_category_lag,
    exclusive_make_to_sub_category - lag(exclusive_make_to_sub_category) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as exclusive_make_to_sub_category_difference,
    -- exclusive_make_to_category
    exclusive_make_to_category,
    lag(exclusive_make_to_category) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as exclusive_make_to_category_lag,
    exclusive_make_to_category - lag(exclusive_make_to_category) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as exclusive_make_to_category_difference,
    -- exclusive_class_to_sub_category
    exclusive_class_to_sub_category,
    lag(exclusive_class_to_sub_category) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as exclusive_class_to_sub_category_lag,
    exclusive_class_to_sub_category - lag(exclusive_class_to_sub_category) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as exclusive_class_to_sub_category_difference,
    -- exclusive_class_to_category
    exclusive_class_to_category,
    lag(exclusive_class_to_category) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as exclusive_class_to_category_lag,
    exclusive_class_to_category - lag(exclusive_class_to_category) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as exclusive_class_to_category_difference,
    -- exclusive_sub_category_to_category
    exclusive_sub_category_to_category,
    lag(exclusive_sub_category_to_category) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as exclusive_sub_category_to_category_lag,
    exclusive_sub_category_to_category - lag(exclusive_sub_category_to_category) over (partition by metric,agg_window,problem_group,category,sub_category,class,make,model,year order by as_of) as exclusive_sub_category_to_category_difference
    from ${category_class_comparison.SQL_TABLE_NAME} as ccc
    join percent_of_group pog
      using(as_of,
    agg_window,
    problem_group,
    category,
    sub_category,
    class,
    make,
    model,
    year)
    left join non_work_order nwo
      using(make,model,year,problem_group);;
  }
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
  dimension: metric {
    type: string
    sql: ${TABLE}."METRIC" ;;
  }
  dimension: problem_group {
    type: string
    sql: ${TABLE}."PROBLEM_GROUP" ;;
  }
  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }
  dimension: sub_category {
    type: string
    sql: ${TABLE}."SUB_CATEGORY" ;;
  }
  dimension: class {
    type: string
    sql: ${TABLE}."CLASS" ;;
  }
  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }
  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }
  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
    value_format_name: id
  }
  dimension: percentage_year_to_class {
    type: number
    sql: ${TABLE}."PERCENTAGE_YEAR_TO_CLASS" ;;
    value_format_name: percent_2
  }
  dimension: has_work_orders {
    type: yesno
    sql: ${TABLE}."HAS_WORK_ORDERS" ;;
  }
  dimension: work_order_link {
    type: string
    sql: 'Work Orders' ;;
    html: <font color="blue "><u><a href="https://equipmentshare.looker.com/dashboards/2157?Problem+Group={{ problem_group }}&Make={{ make }}&Model={{ model }}&Year={{ year }}" target="_blank">{{rendered_value}}</a></font></u> ;;
  }
  dimension: exclusive_class_to_category {
    type: number
    sql: ${TABLE}."EXCLUSIVE_CLASS_TO_CATEGORY" ;;
    value_format_name: percent_2
  }
  dimension: exclusive_class_to_sub_category {
    type: number
    sql: ${TABLE}."EXCLUSIVE_CLASS_TO_SUB_CATEGORY" ;;
    value_format_name: percent_2
  }
  dimension: exclusive_make_to_category {
    type: number
    sql: ${TABLE}."EXCLUSIVE_MAKE_TO_CATEGORY" ;;
    value_format_name: percent_2
  }
  dimension: exclusive_make_to_class {
    type: number
    sql: ${TABLE}."EXCLUSIVE_MAKE_TO_CLASS" ;;
    value_format_name: percent_2
  }
  dimension: exclusive_make_to_sub_category {
    type: number
    sql: ${TABLE}."EXCLUSIVE_MAKE_TO_SUB_CATEGORY" ;;
    value_format_name: percent_2
  }
  dimension: exclusive_model_to_category {
    type: number
    sql: ${TABLE}."EXCLUSIVE_MODEL_TO_CATEGORY" ;;
    value_format_name: percent_2
  }
  dimension: exclusive_model_to_class {
    type: number
    sql: ${TABLE}."EXCLUSIVE_MODEL_TO_CLASS" ;;
    value_format_name: percent_2
  }
  dimension: exclusive_model_to_make {
    type: number
    sql: ${TABLE}."EXCLUSIVE_MODEL_TO_MAKE" ;;
    value_format_name: percent_2
  }
  dimension: exclusive_model_to_sub_category {
    type: number
    sql: ${TABLE}."EXCLUSIVE_MODEL_TO_SUB_CATEGORY" ;;
    value_format_name: percent_2
  }
  dimension: exclusive_sub_category_to_category {
    type: number
    sql: ${TABLE}."EXCLUSIVE_SUB_CATEGORY_TO_CATEGORY" ;;
    value_format_name: percent_2
  }
  dimension: exclusive_year_to_category {
    type: number
    sql: ${TABLE}."EXCLUSIVE_YEAR_TO_CATEGORY" ;;
    value_format_name: percent_2
  }
  dimension: exclusive_year_to_class {
    type: number
    sql: ${TABLE}."EXCLUSIVE_YEAR_TO_CLASS" ;;
    value_format_name: percent_2
  }
  dimension: exclusive_year_to_make {
    type: number
    sql: ${TABLE}."EXCLUSIVE_YEAR_TO_MAKE" ;;
    value_format_name: percent_2
  }
  dimension: exclusive_year_to_model {
    type: number
    sql: ${TABLE}."EXCLUSIVE_YEAR_TO_MODEL" ;;
    value_format_name: percent_2
  }
  dimension: exclusive_year_to_sub_category {
    type: number
    sql: ${TABLE}."EXCLUSIVE_YEAR_TO_SUB_CATEGORY" ;;
    value_format_name: percent_2
  }
  dimension: inclusive_class_to_category {
    type: number
    sql: ${TABLE}."INCLUSIVE_CLASS_TO_CATEGORY" ;;
    value_format_name: percent_2
  }
  dimension: inclusive_class_to_sub_category {
    type: number
    sql: ${TABLE}."INCLUSIVE_CLASS_TO_SUB_CATEGORY" ;;
    value_format_name: percent_2
  }
  dimension: inclusive_make_to_category {
    type: number
    sql: ${TABLE}."INCLUSIVE_MAKE_TO_CATEGORY" ;;
    value_format_name: percent_2
  }
  dimension: inclusive_make_to_class {
    type: number
    sql: ${TABLE}."INCLUSIVE_MAKE_TO_CLASS" ;;
    value_format_name: percent_2
  }
  dimension: inclusive_make_to_sub_category {
    type: number
    sql: ${TABLE}."INCLUSIVE_MAKE_TO_SUB_CATEGORY" ;;
    value_format_name: percent_2
  }
  dimension: inclusive_model_to_category {
    type: number
    sql: ${TABLE}."INCLUSIVE_MODEL_TO_CATEGORY" ;;
    value_format_name: percent_2
  }
  dimension: inclusive_model_to_class {
    type: number
    sql: ${TABLE}."INCLUSIVE_MODEL_TO_CLASS" ;;
    value_format_name: percent_2
  }
  dimension: inclusive_model_to_make {
    type: number
    sql: ${TABLE}."INCLUSIVE_MODEL_TO_MAKE" ;;
    value_format_name: percent_2
  }
  dimension: inclusive_model_to_sub_category {
    type: number
    sql: ${TABLE}."INCLUSIVE_MODEL_TO_SUB_CATEGORY" ;;
    value_format_name: percent_2
  }
  dimension: inclusive_sub_category_to_category {
    type: number
    sql: ${TABLE}."INCLUSIVE_SUB_CATEGORY_TO_CATEGORY" ;;
    value_format_name: percent_2
  }
  dimension: inclusive_year_to_category {
    type: number
    sql: ${TABLE}."INCLUSIVE_YEAR_TO_CATEGORY" ;;
    value_format_name: percent_2
  }
  dimension: inclusive_year_to_class {
    type: number
    sql: ${TABLE}."INCLUSIVE_YEAR_TO_CLASS" ;;
    value_format_name: percent_2
  }
  dimension: inclusive_year_to_make {
    type: number
    sql: ${TABLE}."INCLUSIVE_YEAR_TO_MAKE" ;;
    value_format_name: percent_2
  }
  dimension: inclusive_year_to_model {
    type: number
    sql: ${TABLE}."INCLUSIVE_YEAR_TO_MODEL" ;;
    value_format_name: percent_2
  }
  dimension: inclusive_year_to_sub_category {
    type: number
    sql: ${TABLE}."INCLUSIVE_YEAR_TO_SUB_CATEGORY" ;;
    value_format_name: percent_2
  }
  dimension: exclusive_class_to_category_difference {
    type: number
    sql: ${TABLE}."EXCLUSIVE_CLASS_TO_CATEGORY_DIFFERENCE" ;;
    value_format_name: percent_2
  }
  dimension: exclusive_class_to_sub_category_difference {
    type: number
    sql: ${TABLE}."EXCLUSIVE_CLASS_TO_SUB_CATEGORY_DIFFERENCE" ;;
    value_format_name: percent_2
  }
  dimension: exclusive_make_to_category_difference {
    type: number
    sql: ${TABLE}."EXCLUSIVE_MAKE_TO_CATEGORY_DIFFERENCE" ;;
    value_format_name: percent_2
  }
  dimension: exclusive_make_to_class_difference {
    type: number
    sql: ${TABLE}."EXCLUSIVE_MAKE_TO_CLASS_DIFFERENCE" ;;
    value_format_name: percent_2
  }
  dimension: exclusive_make_to_sub_category_difference {
    type: number
    sql: ${TABLE}."EXCLUSIVE_MAKE_TO_SUB_CATEGORY_DIFFERENCE" ;;
    value_format_name: percent_2
  }
  dimension: exclusive_model_to_category_difference {
    type: number
    sql: ${TABLE}."EXCLUSIVE_MODEL_TO_CATEGORY_DIFFERENCE" ;;
    value_format_name: percent_2
  }
  dimension: exclusive_model_to_class_difference {
    type: number
    sql: ${TABLE}."EXCLUSIVE_MODEL_TO_CLASS_DIFFERENCE" ;;
    value_format_name: percent_2
  }
  dimension: exclusive_model_to_make_difference {
    type: number
    sql: ${TABLE}."EXCLUSIVE_MODEL_TO_MAKE_DIFFERENCE" ;;
    value_format_name: percent_2
  }
  dimension: exclusive_model_to_sub_category_difference {
    type: number
    sql: ${TABLE}."EXCLUSIVE_MODEL_TO_SUB_CATEGORY_DIFFERENCE" ;;
    value_format_name: percent_2
  }
  dimension: exclusive_sub_category_to_category_difference {
    type: number
    sql: ${TABLE}."EXCLUSIVE_SUB_CATEGORY_TO_CATEGORY_DIFFERENCE" ;;
    value_format_name: percent_2
  }
  dimension: exclusive_year_to_category_difference {
    type: number
    sql: ${TABLE}."EXCLUSIVE_YEAR_TO_CATEGORY_DIFFERENCE" ;;
    value_format_name: percent_2
  }
  dimension: exclusive_year_to_class_difference {
    type: number
    sql: ${TABLE}."EXCLUSIVE_YEAR_TO_CLASS_DIFFERENCE" ;;
    value_format_name: percent_2
  }
  dimension: exclusive_year_to_make_difference {
    type: number
    sql: ${TABLE}."EXCLUSIVE_YEAR_TO_MAKE_DIFFERENCE" ;;
    value_format_name: percent_2
  }
  dimension: exclusive_year_to_model_difference {
    type: number
    sql: ${TABLE}."EXCLUSIVE_YEAR_TO_MODEL_DIFFERENCE" ;;
    value_format_name: percent_2
  }
  dimension: exclusive_year_to_sub_category_difference {
    type: number
    sql: ${TABLE}."EXCLUSIVE_YEAR_TO_SUB_CATEGORY_DIFFERENCE" ;;
    value_format_name: percent_2
  }
  dimension: inclusive_class_to_category_difference {
    type: number
    sql: ${TABLE}."INCLUSIVE_CLASS_TO_CATEGORY_DIFFERENCE" ;;
    value_format_name: percent_2
  }
  dimension: inclusive_class_to_sub_category_difference {
    type: number
    sql: ${TABLE}."INCLUSIVE_CLASS_TO_SUB_CATEGORY_DIFFERENCE" ;;
    value_format_name: percent_2
  }
  dimension: inclusive_make_to_category_difference {
    type: number
    sql: ${TABLE}."INCLUSIVE_MAKE_TO_CATEGORY_DIFFERENCE" ;;
    value_format_name: percent_2
  }
  dimension: inclusive_make_to_class_difference {
    type: number
    sql: ${TABLE}."INCLUSIVE_MAKE_TO_CLASS_DIFFERENCE" ;;
    value_format_name: percent_2
  }
  dimension: inclusive_make_to_sub_category_difference {
    type: number
    sql: ${TABLE}."INCLUSIVE_MAKE_TO_SUB_CATEGORY_DIFFERENCE" ;;
    value_format_name: percent_2
  }
  dimension: inclusive_model_to_category_difference {
    type: number
    sql: ${TABLE}."INCLUSIVE_MODEL_TO_CATEGORY_DIFFERENCE" ;;
    value_format_name: percent_2
  }
  dimension: inclusive_model_to_class_difference {
    type: number
    sql: ${TABLE}."INCLUSIVE_MODEL_TO_CLASS_DIFFERENCE" ;;
    value_format_name: percent_2
  }
  dimension: inclusive_model_to_make_difference {
    type: number
    sql: ${TABLE}."INCLUSIVE_MODEL_TO_MAKE_DIFFERENCE" ;;
    value_format_name: percent_2
  }
  dimension: inclusive_model_to_sub_category_difference {
    type: number
    sql: ${TABLE}."INCLUSIVE_MODEL_TO_SUB_CATEGORY_DIFFERENCE" ;;
    value_format_name: percent_2
  }
  dimension: inclusive_sub_category_to_category_difference {
    type: number
    sql: ${TABLE}."INCLUSIVE_SUB_CATEGORY_TO_CATEGORY_DIFFERENCE" ;;
    value_format_name: percent_2
  }
  dimension: inclusive_year_to_category_difference {
    type: number
    sql: ${TABLE}."INCLUSIVE_YEAR_TO_CATEGORY_DIFFERENCE" ;;
    value_format_name: percent_2
  }
  dimension: inclusive_year_to_class_difference {
    type: number
    sql: ${TABLE}."INCLUSIVE_YEAR_TO_CLASS_DIFFERENCE" ;;
    value_format_name: percent_2
  }
  dimension: inclusive_year_to_make_difference {
    type: number
    sql: ${TABLE}."INCLUSIVE_YEAR_TO_MAKE_DIFFERENCE" ;;
    value_format_name: percent_2
  }
  dimension: inclusive_year_to_model_difference {
    type: number
    sql: ${TABLE}."INCLUSIVE_YEAR_TO_MODEL_DIFFERENCE" ;;
    value_format_name: percent_2
  }
  dimension: inclusive_year_to_sub_category_difference {
    type: number
    sql: ${TABLE}."INCLUSIVE_YEAR_TO_SUB_CATEGORY_DIFFERENCE" ;;
    value_format_name: percent_2
  }
  measure: inclusive_year_to_model_avg {
    type: average
    sql: ${inclusive_year_to_model_difference} ;;
    value_format_name: decimal_2
  }
  measure: inclusive_year_to_make_avg {
    type: average
    sql: ${inclusive_year_to_make_difference} ;;
    value_format_name: decimal_2
  }
  measure: inclusive_year_to_class_avg {
    type: average
    sql: ${inclusive_year_to_class_difference} ;;
    value_format_name: decimal_2
  }
  measure: inclusive_year_to_sub_category_avg {
    type: average
    sql: ${inclusive_year_to_sub_category_difference} ;;
    value_format_name: decimal_2
  }
  measure: inclusive_year_to_category_avg {
    type: average
    sql: ${inclusive_year_to_category_difference} ;;
    value_format_name: decimal_2
  }
  measure: inclusive_model_to_make_avg {
    type: average
    sql: ${inclusive_model_to_make_difference} ;;
    value_format_name: decimal_2
  }
  measure: inclusive_model_to_class_avg {
    type: average
    sql: ${inclusive_model_to_class_difference} ;;
    value_format_name: decimal_2
  }
  measure: inclusive_model_to_sub_category_avg {
    type: average
    sql: ${inclusive_model_to_sub_category_difference} ;;
    value_format_name: decimal_2
  }
  measure: inclusive_model_to_category_avg {
    type: average
    sql: ${inclusive_model_to_category_difference} ;;
    value_format_name: decimal_2
  }
  measure: inclusive_make_to_class_avg {
    type: average
    sql: ${inclusive_make_to_class_difference} ;;
    value_format_name: decimal_2
  }
  measure: inclusive_make_to_sub_category_avg {
    type: average
    sql: ${inclusive_make_to_sub_category_difference} ;;
    value_format_name: decimal_2
  }
  measure: inclusive_make_to_category_avg {
    type: average
    sql: ${inclusive_make_to_category_difference} ;;
    value_format_name: decimal_2
  }
  measure: inclusive_class_to_sub_category_avg {
    type: average
    sql: ${inclusive_class_to_sub_category_difference} ;;
    value_format_name: decimal_2
  }
  measure: inclusive_class_to_category_avg {
    type: average
    sql: ${inclusive_class_to_category_difference} ;;
    value_format_name: decimal_2
  }
  measure: inclusive_sub_category_to_category_avg {
    type: average
    sql: ${inclusive_sub_category_to_category_difference} ;;
    value_format_name: decimal_2
  }
  measure: exclusive_year_to_model_avg {
    type: average
    sql: ${exclusive_year_to_model_difference} ;;
    value_format_name: decimal_2
  }
  measure: exclusive_year_to_make_avg {
    type: average
    sql: ${exclusive_year_to_make_difference} ;;
    value_format_name: decimal_2
  }
  measure: exclusive_year_to_class_avg {
    type: average
    sql: ${exclusive_year_to_class_difference} ;;
    value_format_name: decimal_2
    drill_fields: [metric,as_of_date,exclusive_year_to_class_avg]
  }
  measure: exclusive_year_to_sub_category_avg {
    type: average
    sql: ${exclusive_year_to_sub_category_difference} ;;
    value_format_name: decimal_2
  }
  measure: exclusive_year_to_category_avg {
    type: average
    sql: ${exclusive_year_to_category_difference} ;;
    value_format_name: decimal_2
  }
  measure: exclusive_model_to_make_avg {
    type: average
    sql: ${exclusive_model_to_make_difference} ;;
    value_format_name: decimal_2
  }
  measure: exclusive_model_to_class_avg {
    type: average
    sql: ${exclusive_model_to_class_difference} ;;
    value_format_name: decimal_2
  }
  measure: exclusive_model_to_sub_category_avg {
    type: average
    sql: ${exclusive_model_to_sub_category_difference} ;;
    value_format_name: decimal_2
  }
  measure: exclusive_model_to_category_avg {
    type: average
    sql: ${exclusive_model_to_category_difference} ;;
    value_format_name: decimal_2
  }
  measure: exclusive_make_to_class_avg {
    type: average
    sql: ${exclusive_make_to_class_difference} ;;
    value_format_name: decimal_2
  }
  measure: exclusive_make_to_sub_category_avg {
    type: average
    sql: ${exclusive_make_to_sub_category_difference} ;;
    value_format_name: decimal_2
  }
  measure: exclusive_make_to_category_avg {
    type: average
    sql: ${exclusive_make_to_category_difference} ;;
    value_format_name: decimal_2
  }
  measure: exclusive_class_to_sub_category_avg {
    type: average
    sql: ${exclusive_class_to_sub_category_difference} ;;
    value_format_name: decimal_2
  }
  measure: exclusive_class_to_category_avg {
    type: average
    sql: ${exclusive_class_to_category_difference} ;;
    value_format_name: decimal_2
  }
  measure: exclusive_sub_category_to_category_avg {
    type: average
    sql: ${exclusive_sub_category_to_category_difference} ;;
    value_format_name: decimal_2
  }
}
