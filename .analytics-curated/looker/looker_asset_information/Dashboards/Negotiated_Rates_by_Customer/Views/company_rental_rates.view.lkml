#
# The purpose of this view is to incomporate company rates to compare company rates to benchmark rates for rentals
# for the Negotiated Rates by Customer dashboard..
# This dashboard is intended to be a place to monitor rates that are below benchmark rates for a given branch.
#
# Britt Shanklin | Built 2022-07-11

view: company_rental_rates {
 sql_table_name: "ES_WAREHOUSE"."PUBLIC"."COMPANY_RENTAL_RATES" ;;

  dimension: company_rental_rate_id {
    type: number
    primary_key: yes
    sql: ${TABLE}."COMPANY_RENTAL_RATE_ID" ;;
  }

  dimension: company_id  {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
   }

  dimension: voided {
    type: yesno
    sql: ${TABLE}."VOIDED" ;;
  }

  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }

  dimension: rental_rate_type_id {
    type: number
    sql: ${TABLE}."RENTAL_RATE_TYPE_ID" ;;
  }

  dimension: price_per_hour {
    type: number
    sql: ${TABLE}."PRICE_PER_HOUR" ;;
    value_format_name: usd_0
  }

  dimension: price_per_day {
    type: number
    sql: ${TABLE}."PRICE_PER_DAY" ;;
    value_format_name: usd_0
  }

  dimension: price_per_week {
    type: number
    sql: ${TABLE}."PRICE_PER_WEEK" ;;
    value_format_name: usd_0
  }

  dimension: price_per_month {
    type: number
    sql: ${TABLE}."PRICE_PER_MONTH" ;;
    value_format_name: usd_0
  }

  dimension: percent_discount {
    type: number
    sql: ${TABLE}."PERCENT_DISCOUNT" ;;
    value_format_name: percent_0
  }

  dimension: rate_type_id {
    type: number
    sql: ${TABLE}."RATE_TYPE_ID" ;;
  }

  dimension: created_date {
    type: date
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: end_date {
    type: date
    sql: ${TABLE}."END_DATE" ;;
  }

  measure: company_rates {
    type: string
    sql: CONCAT('$', ${price_per_day}, ' / $', ${price_per_week}, ' / $', ${price_per_month}) ;;
  }

  measure: date_rate_diff {
    type: number
    sql: ${price_per_day} - ${branch_rental_rates.price_per_day} ;;
    value_format_name: usd_0
  }

  measure: week_rate_diff {
    type: number
    sql: ${price_per_week} - ${branch_rental_rates.price_per_week} ;;
    value_format_name: usd_0
  }

  measure: month_rate_diff {
    type: number
    sql: ${price_per_month} - ${branch_rental_rates.price_per_month} ;;
    value_format_name: usd_0
  }

  measure: rates_difference {
    type: string
    sql: CONCAT('$', ${date_rate_diff}, ' / $', ${week_rate_diff}, ' / $', ${month_rate_diff}) ;;
  }

}
