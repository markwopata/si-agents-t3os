# The name of this view in Looker is "Rateachievement Points"
view: rateachievement_points {
  # The sql_table_name parameter indicates the underlying database table
  # to be used for all fields in this view.
  sql_table_name: "PUBLIC"."RATEACHIEVEMENT_POINTS"
    ;;
  # No primary key is defined for this view. In order to join this view in an Explore,
  # define primary_key: yes on a dimension that has no repeated values.

  # Here's what a typical dimension looks like in LookML.
  # A dimension is a groupable field that can be used to filter query results.
  # This dimension will be called "Amount" in Explore.

  # dimension: amount {
  #   type: number
  #   sql: ${TABLE}."AMOUNT" ;;
  # }

  # A measure is a field that uses a SQL aggregate function. Here are defined sum and average
  # measures for this dimension, but you can also add measures of many different aggregates.
  # Click on the type parameter to see all the options in the Quick Help panel on the right.

  # measure: total_amount {
  #   type: sum
  #   sql: ${amount} ;;
  # }

  # measure: average_amount {
  #   type: average
  #   sql: ${amount} ;;
  # }

  # dimension: asset_id {
  #   type: number
  #   sql: ${TABLE}."ASSET_ID" ;;
  # }

  # dimension: broad_equipment_class {
  #   type: string
  #   sql: ${TABLE}."BROAD_EQUIPMENT_CLASS" ;;
  # }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  # Dates and timestamps can be represented in Looker using a dimension group of type: time.
  # Looker converts dates and timestamps to the specified timeframes within the dimension group.

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

  # dimension: day_benchmark {
  #   type: number
  #   sql: ${TABLE}."DAY_BENCHMARK" ;;
  # }

  # dimension: day_book {
  #   type: number
  #   sql: ${TABLE}."DAY_BOOK" ;;
  # }

  # dimension: day_discount {
  #   type: number
  #   sql: ${TABLE}."DAY_DISCOUNT" ;;
  # }

  # dimension: day_online {
  #   type: number
  #   sql: ${TABLE}."DAY_ONLINE" ;;
  # }

  # dimension: day_points {
  #   type: number
  #   sql: ${TABLE}."DAY_POINTS" ;;
  # }

  # dimension: day_volume {
  #   type: number
  #   sql: ${TABLE}."DAY_VOLUME" ;;
  # }

  # dimension_group: end {
  #   type: time
  #   timeframes: [
  #     raw,
  #     date,
  #     week,
  #     month,
  #     quarter,
  #     year
  #   ]
  #   convert_tz: no
  #   datatype: date
  #   sql: ${TABLE}."END_DATE" ;;
  # }

  # dimension: equipment_category {
  #   type: string
  #   sql: ${TABLE}."EQUIPMENT_CATEGORY" ;;
  # }

  # dimension: final_equipment_class {
  #   type: string
  #   sql: ${TABLE}."FINAL_EQUIPMENT_CLASS" ;;
  # }

  # dimension: final_market {
  #   type: string
  #   sql: ${TABLE}."FINAL_MARKET" ;;
  # }

  # dimension: final_region {
  #   type: string
  #   sql: ${TABLE}."FINAL_REGION" ;;
  # }

  # dimension: hit_day_target {
  #   type: string
  #   sql: ${TABLE}."HIT_DAY_TARGET" ;;
  # }

  # dimension: hit_month_target {
  #   type: string
  #   sql: ${TABLE}."HIT_MONTH_TARGET" ;;
  # }

  # dimension: hit_revenue_target {
  #   type: string
  #   sql: ${TABLE}."HIT_REVENUE_TARGET" ;;
  # }

  # dimension: hit_week_target {
  #   type: string
  #   sql: ${TABLE}."HIT_WEEK_TARGET" ;;
  # }

  # dimension: industrial_vol {
  #   type: number
  #   sql: ${TABLE}."INDUSTRIAL_VOL" ;;
  # }

  dimension: invoice_id {
    type: number
    #primary_key: yes
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  # dimension: invoice_length {
  #   type: number
  #   sql: ${TABLE}."INVOICE_LENGTH" ;;
  # }

  # dimension: invoice_volume {
  #   type: string
  #   sql: ${TABLE}."INVOICE_VOLUME" ;;
  # }

  # dimension: market_id {
  #   type: number
  #   sql: ${TABLE}."MARKET_ID" ;;
  # }

  # dimension: market_name {
  #   type: string
  #   sql: ${TABLE}."MARKET_NAME" ;;
  # }

  # dimension: midwest_vol {
  #   type: number
  #   sql: ${TABLE}."MIDWEST_VOL" ;;
  # }

  # dimension: model_name {
  #   type: string
  #   sql: ${TABLE}."MODEL_NAME" ;;
  # }

  # dimension: month_benchmark {
  #   type: number
  #   sql: ${TABLE}."MONTH_BENCHMARK" ;;
  # }

  # dimension: month_book {
  #   type: number
  #   sql: ${TABLE}."MONTH_BOOK" ;;
  # }

  # dimension: month_discount {
  #   type: number
  #   sql: ${TABLE}."MONTH_DISCOUNT" ;;
  # }

  # dimension: month_online {
  #   type: number
  #   sql: ${TABLE}."MONTH_ONLINE" ;;
  # }

  # dimension: month_points {
  #   type: number
  #   sql: ${TABLE}."MONTH_POINTS" ;;
  # }

  # dimension: month_volume {
  #   type: number
  #   sql: ${TABLE}."MONTH_VOLUME" ;;
  # }

  # dimension: mtn_west_vol {
  #   type: number
  #   sql: ${TABLE}."MTN_WEST_VOL" ;;
  # }

  # dimension: new_class_id {
  #   type: string
  #   sql: ${TABLE}."NEW_CLASS_ID" ;;
  # }

  # dimension: northeast_vol {
  #   type: number
  #   sql: ${TABLE}."NORTHEAST_VOL" ;;
  # }

  # dimension: online_amount {
  #   type: number
  #   sql: ${TABLE}."ONLINE_AMOUNT" ;;
  # }

  # dimension: pacific_vol {
  #   type: number
  #   sql: ${TABLE}."PACIFIC_VOL" ;;
  # }

  dimension: percent_discount {
    type: number
    sql: ${TABLE}."PERCENT_DISCOUNT" ;;
  }

  # dimension: purchase_price {
  #   type: number
  #   sql: ${TABLE}."PURCHASE_PRICE" ;;
  # }

  # dimension: rate_region {
  #   type: string
  #   sql: ${TABLE}."RATE_REGION" ;;
  # }

  # dimension: region_index {
  #   type: number
  #   sql: ${TABLE}."REGION_INDEX" ;;
  # }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  # dimension: rental_year_quarter {
  #   type: string
  #   sql: ${TABLE}."RENTAL_YEAR_QUARTER" ;;
  # }

  # dimension: salesperson {
  #   type: string
  #   sql: ${TABLE}."SALESPERSON" ;;
  # }

  # dimension: salesperson_user_id {
  #   type: number
  #   sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  # }

  # dimension: southeast_vol {
  #   type: number
  #   sql: ${TABLE}."SOUTHEAST_VOL" ;;
  # }

  # dimension: southwest_vol {
  #   type: number
  #   sql: ${TABLE}."SOUTHWEST_VOL" ;;
  # }

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

  # dimension: true_price_per_day {
  #   type: number
  #   sql: ${TABLE}."TRUE_PRICE_PER_DAY" ;;
  # }

  # dimension: true_price_per_month {
  #   type: number
  #   sql: ${TABLE}."TRUE_PRICE_PER_MONTH" ;;
  # }

  # dimension: true_price_per_week {
  #   type: number
  #   sql: ${TABLE}."TRUE_PRICE_PER_WEEK" ;;
  # }

  # dimension: week_benchmark {
  #   type: number
  #   sql: ${TABLE}."WEEK_BENCHMARK" ;;
  # }

  # dimension: week_book {
  #   type: number
  #   sql: ${TABLE}."WEEK_BOOK" ;;
  # }

  # dimension: week_discount {
  #   type: number
  #   sql: ${TABLE}."WEEK_DISCOUNT" ;;
  # }

  # dimension: week_online {
  #   type: number
  #   sql: ${TABLE}."WEEK_ONLINE" ;;
  # }

  # dimension: week_points {
  #   type: number
  #   sql: ${TABLE}."WEEK_POINTS" ;;
  # }

  # dimension: week_volume {
  #   type: number
  #   sql: ${TABLE}."WEEK_VOLUME" ;;
  # }

  # measure: count {
  #   type: count
  #   drill_fields: [model_name, market_name, company_name]
  # }
  measure: avg_percent_discount {
    type: average
    sql: ${percent_discount} ;;
    value_format: "0.00%"
  }
  dimension: invoice_rental_id {
    primary_key: yes
    type: string
    sql: CONCAT(${invoice_id},${rental_id}) ;;
  }

}
