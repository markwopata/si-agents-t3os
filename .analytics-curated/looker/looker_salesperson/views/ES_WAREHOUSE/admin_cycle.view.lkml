view: admin_cycle {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."ADMIN_CYCLE"
    ;;

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: current_cycle {
    type: number
    sql: ${TABLE}."CURRENT_CYCLE" ;;
  }

  dimension: current_rental_days {
    type: number
    sql: ${TABLE}."CURRENT_RENTAL_DAYS" ;;
  }

  dimension: cycles_next_seven_days {
    type: yesno
    sql: ${TABLE}."CYCLES_NEXT_SEVEN_DAYS" ;;
  }

  dimension: days_left {
    type: number
    sql: ${TABLE}."DAYS_LEFT" ;;
  }

  dimension_group: end {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."END_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: end_this_rental_cycle {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."END_THIS_RENTAL_CYCLE" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: last_cycle_inv {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."LAST_CYCLE_INV_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: net_select {
    type: string
    sql: CASE WHEN ${TABLE}."NET_SELECT" = '1' then 'cash' else 'credit' end;;
  }

  dimension: net_terms_id {
    type: number
    sql: ${TABLE}."NET_TERMS_ID" ;;
  }

  dimension_group: next_cycle_inv {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."NEXT_CYCLE_INV_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: price_per_day {
    type: number
    sql: ${TABLE}."PRICE_PER_DAY" ;;
    value_format: "$#,##0"
  }

  dimension: price_per_month {
    type: number
    sql: ${TABLE}."PRICE_PER_MONTH" ;;
    value_format: "$#,##0"
  }

  dimension: price_per_week {
    type: number
    sql: ${TABLE}."PRICE_PER_WEEK" ;;
    value_format: "$#,##0"
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension_group: start {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."START_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: start_this_rental_cycle {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."START_THIS_RENTAL_CYCLE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: total_days_on_rent {
    type: number
    sql: ${TABLE}."TOTAL_DAYS_ON_RENT" ;;
  }

  dimension: days_for_invoice {
    type: number
    sql: CASE WHEN ${end_this_rental_cycle_date} > ${end_date} THEN DATEDIFF(day,${start_this_rental_cycle_date},${end_date})
    ELSE DATEDIFF(day,${start_this_rental_cycle_date},${end_this_rental_cycle_date}) END ;;
  }

  dimension: days_tot {
    type: number
    sql: ${days_for_invoice} * ${price_per_day} ;;
  }

  dimension: week_plus_days_tot {
    type: number
    sql: (FLOOR(${days_for_invoice}/7)::int * ${price_per_week}) + (${days_for_invoice} % 7 * ${price_per_day}) ;;
  }

  dimension: roundup_weeks  {
    type: number
    sql: CEIL(${days_for_invoice}/7,0)::int * ${price_per_week} ;;
  }

  dimension: next_invoice_date_buckets {
    type: number
    sql: CASE
         WHEN ${next_cycle_inv_date} >= current_date() and ${next_cycle_inv_date} <= dateadd(day,7,current_date()) then 1
         WHEN ${next_cycle_inv_date} > dateadd(day,7,current_date()) and ${next_cycle_inv_date} <= dateadd(day,14,current_date()) then 2
         WHEN ${next_cycle_inv_date} > dateadd(day,14,current_date()) and ${next_cycle_inv_date} <= dateadd(day,21,current_date()) then 3
         WHEN ${next_cycle_inv_date} > dateadd(day,21,current_date()) and ${next_cycle_inv_date} <= dateadd(day,29,current_date()) then 4
          ELSE NULL
          END;;
  }

  measure: rental_projection {
    type: number
    sql: COALESCE(LEAST(${days_tot}, ${week_plus_days_tot}, ${roundup_weeks}, ${price_per_month}),0) ;;
    value_format: "$#,##0"
  }

  measure: cycling_this_week {
    type: count
    filters: [cycles_next_seven_days: "True"]
  }

   measure: count {
    type: count
    drill_fields: [company_name]
  }
}
