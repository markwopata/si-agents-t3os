view: v_branch_rates_current_active {
  sql_table_name: "FLEET_OPTIMIZATION"."GOLD"."V_BRANCH_RATES_CURRENT_ACTIVE" ;;

  dimension: benchmark_price_per_day {
    group_label: "Benchmark Price"
    type: number
    sql: ${TABLE}."BENCHMARK_PRICE_PER_DAY" ;;
    value_format_name: usd_0
  }
  dimension: benchmark_price_per_hour {
    group_label: "Benchmark Price"
    type: number
    sql: ${TABLE}."BENCHMARK_PRICE_PER_HOUR" ;;
    value_format_name: usd_0
  }
  dimension: benchmark_price_per_month {
    group_label: "Benchmark Price"
    type: number
    sql: ${TABLE}."BENCHMARK_PRICE_PER_MONTH" ;;
    value_format_name: usd_0
  }
  dimension: benchmark_price_per_week {
    group_label: "Benchmark Price"
    type: number
    sql: ${TABLE}."BENCHMARK_PRICE_PER_WEEK" ;;
    value_format_name: usd_0
  }
  dimension: benchmark_rate_id {
    type: string
    sql: ${TABLE}."BENCHMARK_RATE_ID" ;;
  }
  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
  }
  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }
  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }
  dimension_group: effective_end_ts {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."EFFECTIVE_END_TS" ;;
  }
  dimension_group: effective_start_ts {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."EFFECTIVE_START_TS" ;;
  }
  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }
  dimension: floor_price_per_day {
    group_label: "Floor Price"
    type: number
    sql: ${TABLE}."FLOOR_PRICE_PER_DAY" ;;
    value_format_name: usd_0
  }
  dimension: floor_price_per_hour {
    group_label: "Floor Price"
    type: number
    sql: ${TABLE}."FLOOR_PRICE_PER_HOUR" ;;
    value_format_name: usd_0
  }
  dimension: floor_price_per_month {
    group_label: "Floor Price"
    type: number
    sql: ${TABLE}."FLOOR_PRICE_PER_MONTH" ;;
    value_format_name: usd_0
  }
  dimension: floor_price_per_week {
    group_label: "Floor Price"
    type: number
    sql: ${TABLE}."FLOOR_PRICE_PER_WEEK" ;;
    value_format_name: usd_0
  }
  dimension: floor_rate_id {
    type: string
    sql: ${TABLE}."FLOOR_RATE_ID" ;;
  }
  dimension: location_id {
    type: number
    sql: ${TABLE}."LOCATION_ID" ;;
  }
  dimension: mart_rate_key {
    type: string
    sql: ${TABLE}."MART_RATE_KEY" ;;
  }
  dimension: online_price_per_day {
    group_label: "Book Price"
    type: number
    sql: ${TABLE}."ONLINE_PRICE_PER_DAY" ;;
    value_format_name: usd_0
  }
  dimension: online_price_per_hour {
    group_label: "Book Price"
    type: number
    sql: ${TABLE}."ONLINE_PRICE_PER_HOUR" ;;
    value_format_name: usd_0
  }
  dimension: online_price_per_month {
    group_label: "Book Price"
    type: number
    sql: ${TABLE}."ONLINE_PRICE_PER_MONTH" ;;
    value_format_name: usd_0
  }
  dimension: online_price_per_week {
    group_label: "Book Price"
    type: number
    sql: ${TABLE}."ONLINE_PRICE_PER_WEEK" ;;
    value_format_name: usd_0
  }
  dimension: online_rate_id {
    type: string
    sql: ${TABLE}."ONLINE_RATE_ID" ;;
  }
  dimension: rate_category {
    type: string
    sql: ${TABLE}."RATE_CATEGORY" ;;
  }
  dimension: rate_scope {
    type: string
    sql: ${TABLE}."RATE_SCOPE" ;;
  }
  dimension: rate_source {
    type: string
    sql: ${TABLE}."RATE_SOURCE" ;;
  }
  dimension: rate_source_record_id {
    type: number
    sql: ${TABLE}."RATE_SOURCE_RECORD_ID" ;;
  }
  dimension: region {
    type: number
    sql: ${TABLE}."REGION" ;;
  }
  dimension: state_abbreviation {
    type: string
    sql: ${TABLE}."STATE_ABBREVIATION" ;;
  }
  measure: count {
    type: count
  }
  # dimension: online_rates_combined {
  #   group_label: "Combined Rates"
  #   label: "Online Rates (Day/Week/4-Week)"
  #   type: string
  #   sql: concat(coalesce(${online_price_per_day},' '),' / ',coalesce(${online_price_per_week},' '),' / ',coalesce(${online_price_per_month},' ')) ;;
  #   html: {{online_price_per_day._rendered_value}} / {{online_price_per_week._rendered_value}} / {{online_price_per_month._rendered_value}} ;;
  # }
  dimension: online_rates_combined {
    group_label: "Combined Rates"
    label: "Book Rates (Day/Week/4-Week)"
    type: string
    sql: concat(${online_price_per_day},' / ',${online_price_per_week},' / ',${online_price_per_month}) ;;
    html: {{online_price_per_day._rendered_value}} / {{online_price_per_week._rendered_value}} / {{online_price_per_month._rendered_value}} ;;
  }
  dimension: benchmark_rates_combined {
    group_label: "Combined Rates"
    label: "Benchmark Rates (Day/Week/4-Week)"
    type: string
    sql: concat(${benchmark_price_per_day},' / ',${benchmark_price_per_week},' / ',${benchmark_price_per_month}) ;;
    html: {{benchmark_price_per_day._rendered_value}} / {{benchmark_price_per_week._rendered_value}} / {{benchmark_price_per_month._rendered_value}} ;;
  }
  dimension: floor_rates_combined {
    group_label: "Combined Rates"
    label: "Floor Rates (Day/Week/4-Week)"
    type: string
    sql: concat(${floor_price_per_day},' / ',${floor_price_per_week},' / ',${floor_price_per_month}) ;;
    html: {{floor_price_per_day._rendered_value}} / {{floor_price_per_week._rendered_value}} / {{floor_price_per_month._rendered_value}} ;;
  }
}
