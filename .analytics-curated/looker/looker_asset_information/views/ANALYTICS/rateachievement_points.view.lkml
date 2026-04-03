view: rateachievement_points {
  sql_table_name: "PUBLIC"."RATEACHIEVEMENT_POINTS"
    ;;

  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."NEW_CLASS_ID" ;;
  }

  dimension: broad_equipment_class {
    type: string
    sql: ${TABLE}."BROAD_EQUIPMENT_CLASS" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;

    link: {
      label: "View Company Invoices"
      url: "https://equipmentshare.looker.com/looks/22?f[users.Full_Name_with_ID]={{ _filters['users.Full_Name_with_ID'] | url_encode }}&f[rateachievement_points.company_id]={{ value | url_encode }}&f[market_region_xwalk.market_name]={{_filters['market_region_xwalk.market_name']  | url_encode }}&f[market_region_xwalk.region_name]={{_filters['market_region_xwalk.region_name']  | url_encode }}&f[market_region_xwalk.district]={{_filters['market_region_xwalk.district']  | url_encode }}&toggle=det"
    }
  }

  dimension: company_name {
    type: string
    sql: TRIM(${TABLE}."COMPANY_NAME") ;;

    link: {
      label: "View Company Invoices"
      url: "https://equipmentshare.looker.com/looks/22?f[users.Full_Name_with_ID]={{ _filters['users.Full_Name_with_ID'] | url_encode }}&f[rateachievement_points.company_name]={{ company_name._filterable_value | url_encode }}&f[market_region_xwalk.market_name]={{_filters['market_region_xwalk.market_name']  | url_encode }}&f[market_region_xwalk.region_name]={{_filters['market_region_xwalk.region_name']  | url_encode }}&f[market_region_xwalk.district]={{_filters['market_region_xwalk.district']  | url_encode }}&toggle=det"
    }

    link: {
      label: "View Customer Information Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/28?Company%20Name={{ company_name._filterable_value | url_encode }}&Company%20ID="
    }
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

  dimension: day_benchmark {
    type: number
    sql: ${TABLE}."DAY_BENCHMARK" ;;
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
    sql: TRIM(${TABLE}."EQUIPMENT_CATEGORY") ;;
  }

  dimension: equipment_class {
    type: string
    sql: TRIM(${TABLE}."FINAL_EQUIPMENT_CLASS") ;;
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

  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: invoice_rental_id {
    primary_key: yes
    type: string
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
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  # dimension: market_name {
  #   type: string
  #   sql: ${TABLE}."MARKET_NAME" ;;
  # }

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

  dimension: month_points {
    type: number
    sql: ${TABLE}."MONTH_POINTS" ;;
  }

  dimension: month_volume {
    type: number
    sql: ${TABLE}."MONTH_VOLUME" ;;
  }

  dimension: new_class_id {
    type: string
    sql: ${TABLE}."NEW_CLASS_ID" ;;
  }

  dimension: oil__gas_vol {
    type: number
    sql: ${TABLE}."OIL_GAS_VOL" ;;
  }

  dimension: pacific__mtn_west_vol {
    type: number
    sql: ${TABLE}."PACIFIC_MTN_WEST_VOL" ;;
  }

  dimension: purchase_price {
    type: number
    sql: ${TABLE}."PURCHASE_PRICE" ;;
  }

  dimension: rate_region {
    type: string
    sql: ${TABLE}."RATE_REGION" ;;
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

  dimension: week_points {
    type: number
    sql: ${TABLE}."WEEK_POINTS" ;;
  }

  dimension: week_volume {
    type: number
    sql: ${TABLE}."WEEK_VOLUME" ;;
  }


  measure: total_inv_amt {
    type: sum
    #sql: ${true_price_per_day}+${true_price_per_week}+${true_price_per_month} ;;
    sql: ${amount};;
    value_format: "0"
  }

  measure: total_day_benchmarks {
    type: sum
    sql:
           CASE WHEN ${day_volume} > 0
       THEN ${day_benchmark}
       ELSE 0
       END;;
  }

  measure: total_week_benchmarks {
    type: sum
    sql:
           CASE WHEN ${week_volume} > 0
       THEN ${week_benchmark}
       ELSE 0
       END;;
  }

  measure: total_month_benchmarks {
    type: sum
    sql:
           CASE WHEN ${month_volume} > 0
       THEN ${month_benchmark}
       ELSE 0
       END;;
  }

  measure: total_benchmarks {
    type: number
    sql: ${total_day_benchmarks}+${total_week_benchmarks}+${total_month_benchmarks} ;;
    value_format: "0"
  }

  measure: total_points {
    type: sum
    sql: ${day_points}+${week_points}+${month_points} ;;
    value_format: "0"
  }

  measure: perc_of_day_bench {
    type: percent_of_total
    sql: ${day_points}/${day_benchmark} ;;
    value_format: "0.00"
  }

  measure: perc_of_week_bench {
    type: percent_of_total
    sql: ${week_points}/${week_benchmark} ;;
    value_format: "0.00"
  }

  measure: perc_of_month_bench {
    type: percent_of_total
    sql: ${month_points}/${month_benchmark} ;;
    value_format: "0.00"
  }

  measure: count {
    type: count
    drill_fields: [invoice_id,date_created_date,company_name,equipment_class,total_points]
  }

  measure: count_of_assets {
    type: count_distinct
    sql: ${asset_id} ;;
    drill_fields: [invoice_id,asset_id,date_created_date,company_name,equipment_class,total_points]
  }

  dimension: invoice_id_with_link {
    type: string
    sql: ${invoice_id} ;;
    html: <font color="blue "><u><a href="https://admin.equipmentshare.com/#/home/invoices?query={{ rateachievement_points.invoice_id._value }}" target="_blank">{{ rateachievement_points.invoice_id._value }}</a></font></u> ;;
  }

  dimension: company_name_trim {
    type: string
    sql: TRIM(${company_name}) ;;
  }

  dimension: month_date_created {
    type: date
    sql: date_trunc('month',${date_created_date}) ;;
  }

  dimension: is_main_market {
    type: yesno
    sql: ${market_region_xwalk.market_name} = ${final_market} ;;
  }

  measure: final_market_distinct_count {
    type: count_distinct
    sql: ${final_market} ;;
    description: "Used to toggle final market name on salesperson dashboard"
  }
}
