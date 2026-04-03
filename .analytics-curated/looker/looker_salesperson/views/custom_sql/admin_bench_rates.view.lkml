view: admin_bench_rates {
  derived_table: {
    sql:
    select *
    from ES_WAREHOUSE.PUBLIC.BRANCH_RENTAL_RATES
    where rate_type_id = 2
    and active = true
    ;;
  }

  dimension: branch_rental_rate_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."BRANCH_RENTAL_RATE_ID" ;;
  }

  dimension: rate_type_id {
    type: number
    sql: ${TABLE}."RATE_TYPE_ID" ;;
  }

  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }

  dimension: price_per_hour {
    type: number
    sql: ${TABLE}."PRICE_PER_HOUR" ;;
  }

  dimension: price_per_day {
    type: number
    sql: ${TABLE}."PRICE_PER_DAY" ;;
  }

  dimension: price_per_week {
    type: number
    sql: ${TABLE}."PRICE_PER_WEEK" ;;
  }

  dimension: price_per_month {
    type: number
    sql: ${TABLE}."PRICE_PER_MONTH" ;;
  }

  dimension: call_for_pricing {
    type: yesno
    sql: ${TABLE}."CALL_FOR_PRICING" ;;
  }

  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
  }
}
