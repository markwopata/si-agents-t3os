view: branch_rental_rates {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."BRANCH_RENTAL_RATES"
    ;;
  drill_fields: [branch_rental_rate_id]

  dimension: branch_rental_rate_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."BRANCH_RENTAL_RATE_ID" ;;
  }

  dimension_group: _es_update_timestamp {
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
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: active {
    type: yesno
    sql: ${TABLE}."ACTIVE" ;;
  }

  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: call_for_pricing {
    type: yesno
    sql: ${TABLE}."CALL_FOR_PRICING" ;;
  }

  dimension: created_by_user_id {
    type: number
    sql: ${TABLE}."CREATED_BY_USER_ID" ;;
  }

  dimension_group: date_created {
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
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension_group: date_voided {
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
    sql: ${TABLE}."DATE_VOIDED" ;;
  }

  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }

  dimension: price_per_day {
    type: number
    sql: ${TABLE}."PRICE_PER_DAY" ;;
  }

  dimension: price_per_hour {
    type: number
    sql: ${TABLE}."PRICE_PER_HOUR" ;;
  }

  dimension: price_per_month {
    type: number
    sql: ${TABLE}."PRICE_PER_MONTH" ;;
  }

  dimension: price_per_week {
    type: number
    sql: ${TABLE}."PRICE_PER_WEEK" ;;
  }

  dimension: rate_type_id {
    type: number
    sql: ${TABLE}."RATE_TYPE_ID" ;;
  }

  dimension: rate_type_name {
    type: string
    sql:
    CASE
    WHEN ${rate_type_id} = 1 THEN 'Online'
    WHEN ${rate_type_id} = 2 THEN 'Benchmark'
    WHEN ${rate_type_id} = 3 THEN 'Floor'
    END
    ;;
  }

  dimension: voided_by_user_id {
    type: number
    sql: ${TABLE}."VOIDED_BY_USER_ID" ;;
  }

  # - - - - - MEASURES - - - - -

  measure: count {
    type: count
    drill_fields: [branch_rental_rate_id]
  }

  measure: rates {
    description: "Concats the rates but only works if you have each rate selected"
    type: string
    sql: concat(${price_per_hour}, ' / ', ${price_per_day}, ' / ', ${price_per_week}, ' / ', ${price_per_month}) ;;
  }

  measure: per_hour {
    type: median
    sql: ${price_per_hour} ;;
  }
  measure: per_day {
    type: median
    sql: ${price_per_day} ;;
  }
  measure: per_week {
    type: median
    sql: ${price_per_week} ;;
  }
  measure: per_month {
    type: median
    sql: ${price_per_month} ;;
  }

# the measures are used in the multi-location rate calculator
  measure: floor_rates {
    type: string
    sql:
       (select concat('$',ceil(sum(brr2.price_per_day)),' / $',ceil(sum(brr2.price_per_week)),' / $',ceil(sum(brr2.price_per_month)))
       from es_warehouse.public.branch_rental_rates brr2
      where brr2.branch_id = ${branch_id}
      and brr2.equipment_class_id = ${equipment_class_id}
      and brr2.rate_type_id = 3
      and brr2.active=true);;
  }
  measure: benchmark_rates {
    type: string
    sql:
       (select concat('$',ceil(sum(brr2.price_per_day)),' / $',ceil(sum(brr2.price_per_week)),' / $',ceil(sum(brr2.price_per_month)))
       from es_warehouse.public.branch_rental_rates brr2
      where brr2.branch_id = ${branch_id}
      and brr2.equipment_class_id = ${equipment_class_id}
      and brr2.rate_type_id = 2
      and brr2.active=true);;
  }

  measure: online_rates {
    type: string
    sql:
       (select concat('$',ceil(sum(brr2.price_per_day)),' / $',ceil(sum(brr2.price_per_week)),' / $',ceil(sum(brr2.price_per_month)))
       from es_warehouse.public.branch_rental_rates brr2
      where brr2.branch_id = ${branch_id}
      and brr2.equipment_class_id = ${equipment_class_id}
      and brr2.rate_type_id = 1
      and brr2.active=true);;
  }
}
