view: rateachievement_points {
  sql_table_name: "ANALYTICS"."PUBLIC"."RATEACHIEVEMENT_POINTS" ;;

  parameter:  report_period {
    label: "Period"
    type: string
    full_suggestions: yes
    suggest_explore: plexi_periods
    suggest_dimension: plexi_periods.display
  }

  parameter: report_month {
    label: "Month"
    type: number
    #default_value: "8"
    allowed_value: {
      label: "January"
      value: "1"
    }
    allowed_value: {
      label: "February"
      value: "2"
    }
    allowed_value: {
      label: "March"
      value: "3"
    }
    allowed_value: {
      label: "April"
      value: "4"
    }
    allowed_value: {
      label: "May"
      value: "5"
    }
    allowed_value: {
      label: "June"
      value: "6"
    }
    allowed_value: {
      label: "July"
      value: "7"
    }
    allowed_value: {
      label: "August"
      value: "8"
    }
    allowed_value: {
      label: "September"
      value: "9"
    }
    allowed_value: {
      label: "October"
      value: "10"
    }
    allowed_value: {
      label: "November"
      value: "11"
    }
    allowed_value: {
      label: "December"
      value: "12"
    }
  }

  parameter: report_year {
    label: "Year"
    type: number
    allowed_value: {value: "2021"}
    allowed_value: {value: "2022"}
  }


  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: broad_equipment_class {
    type: string
    sql: ${TABLE}."BROAD_EQUIPMENT_CLASS" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension_group: date_created {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: date_created {
    label: "Date Created"
    type: date
    convert_tz: no
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: day_benchmark {
    type: number
    sql: ${TABLE}."DAY_BENCHMARK" ;;
  }

  dimension: day_discount {
    type: number
    sql: ${TABLE}."DAY_DISCOUNT" ;;
  }

  dimension: day_floor {
    type: number
    sql: ${TABLE}."DAY_FLOOR" ;;
  }

  dimension: day_online {
    type: number
    sql: ${TABLE}."DAY_ONLINE" ;;
  }

  dimension: day_points {
    type: number
    sql: ${TABLE}."DAY_POINTS" ;;
  }

  dimension: day_volume {
    type: number
    sql: ${TABLE}."DAY_VOLUME" ;;
  }

  dimension_group: end {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."END_DATE" ;;
  }

  dimension: equipment_category {
    type: string
    sql: ${TABLE}."EQUIPMENT_CATEGORY" ;;
  }

  dimension: final_equipment_class {
    type: string
    sql: ${TABLE}."FINAL_EQUIPMENT_CLASS" ;;
  }

  dimension: final_market {
    type: string
    sql: ${TABLE}."FINAL_MARKET" ;;
  }

  dimension: final_region {
    type: string
    sql: ${TABLE}."FINAL_REGION" ;;
  }

  dimension: hit_day_target {
    type: string
    sql: ${TABLE}."HIT_DAY_TARGET" ;;
  }

  dimension: hit_month_target {
    type: string
    sql: ${TABLE}."HIT_MONTH_TARGET" ;;
  }

  dimension: hit_revenue_target {
    type: string
    sql: ${TABLE}."HIT_REVENUE_TARGET" ;;
  }

  dimension: hit_week_target {
    type: string
    sql: ${TABLE}."HIT_WEEK_TARGET" ;;
  }

  dimension: hour_benchmark {
    type: number
    sql: ${TABLE}."HOUR_BENCHMARK" ;;
  }

  dimension: hour_floor {
    type: number
    sql: ${TABLE}."HOUR_FLOOR" ;;
  }

  dimension: hour_online {
    type: number
    sql: ${TABLE}."HOUR_ONLINE" ;;
  }

  dimension: industrial_vol {
    type: number
    sql: ${TABLE}."INDUSTRIAL_VOL" ;;
  }

  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: invoice_rental_id {
    type: string
    primary_key: yes
    sql: CONCAT(${invoice_id},'-',${rental_id}) ;;
  }

  dimension: invoice_length {
    type: number
    sql: ${TABLE}."INVOICE_LENGTH" ;;
  }

  dimension: invoice_volume {
    type: string
    sql: ${TABLE}."INVOICE_VOLUME" ;;
  }

  dimension: market_id {
    label: "Market ID"
    #primary_key: yes
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    label: "Market Name"
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: midwest_vol {
    type: number
    sql: ${TABLE}."MIDWEST_VOL" ;;
  }

  dimension: model_name {
    type: string
    sql: ${TABLE}."MODEL_NAME" ;;
  }

  dimension: month_benchmark {
    type: number
    sql: ${TABLE}."MONTH_BENCHMARK" ;;
  }

  dimension: month_discount {
    type: number
    sql: ${TABLE}."MONTH_DISCOUNT" ;;
  }

  dimension: month_floor {
    type: number
    sql: ${TABLE}."MONTH_FLOOR" ;;
  }

  dimension: month_online {
    type: number
    sql: ${TABLE}."MONTH_ONLINE" ;;
  }

  dimension: month_points {
    type: number
    sql: ${TABLE}."MONTH_POINTS" ;;
  }

  dimension: month_volume {
    type: number
    sql: ${TABLE}."MONTH_VOLUME" ;;
  }

  dimension: mtn_west_vol {
    type: number
    sql: ${TABLE}."MTN_WEST_VOL" ;;
  }

  dimension: new_class_id {
    type: string
    sql: ${TABLE}."NEW_CLASS_ID" ;;
  }

  dimension: northeast_vol {
    type: number
    sql: ${TABLE}."NORTHEAST_VOL" ;;
  }

  dimension: online_amount {
    type: number
    sql: ${TABLE}."ONLINE_AMOUNT" ;;
  }

  dimension: pacific_vol {
    type: number
    sql: ${TABLE}."PACIFIC_VOL" ;;
  }

  dimension: percent_discount {
    type: number
    sql: ${TABLE}."PERCENT_DISCOUNT" ;;
  }

  measure: percent_discount_average {
    label: "Average Discount"
    type: average
    sql: ${percent_discount} ;;
  }

  dimension: purchase_price {
    type: number
    sql: ${TABLE}."PURCHASE_PRICE" ;;
  }

  dimension: rate_region {
    type: string
    sql: ${TABLE}."RATE_REGION" ;;
  }

  dimension: rate_tier {
    type: number
    sql: ${TABLE}."RATE_TIER" ;;
  }

  dimension: region_index {
    type: number
    sql: ${TABLE}."REGION_INDEX" ;;
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: rental_year_quarter {
    type: string
    sql: ${TABLE}."RENTAL_YEAR_QUARTER" ;;
  }

  dimension: salesperson {
    type: string
    sql: ${TABLE}."SALESPERSON" ;;
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: southeast_vol {
    type: number
    sql: ${TABLE}."SOUTHEAST_VOL" ;;
  }

  dimension: southwest_vol {
    type: number
    sql: ${TABLE}."SOUTHWEST_VOL" ;;
  }

  dimension_group: start {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."START_DATE" ;;
  }

  dimension: true_price_per_day {
    type: number
    sql: ${TABLE}."TRUE_PRICE_PER_DAY" ;;
  }

  dimension: true_price_per_month {
    type: number
    sql: ${TABLE}."TRUE_PRICE_PER_MONTH" ;;
  }

  dimension: true_price_per_week {
    type: number
    sql: ${TABLE}."TRUE_PRICE_PER_WEEK" ;;
  }

  dimension: week_benchmark {
    type: number
    sql: ${TABLE}."WEEK_BENCHMARK" ;;
  }

  dimension: week_discount {
    type: number
    sql: ${TABLE}."WEEK_DISCOUNT" ;;
  }

  dimension: week_floor {
    type: number
    sql: ${TABLE}."WEEK_FLOOR" ;;
  }

  dimension: week_online {
    type: number
    sql: ${TABLE}."WEEK_ONLINE" ;;
  }

  dimension: week_points {
    type: number
    sql: ${TABLE}."WEEK_POINTS" ;;
  }

  dimension: week_volume {
    type: number
    sql: ${TABLE}."WEEK_VOLUME" ;;
  }

  measure: count {
    type: count
    drill_fields: [model_name, market_name, company_name]
  }

  set: detail {
    fields: [
      date_created,
      market_id,
      market_name,
      invoice_id,
      rental_id,
      percent_discount_average
    ]
  }
}
