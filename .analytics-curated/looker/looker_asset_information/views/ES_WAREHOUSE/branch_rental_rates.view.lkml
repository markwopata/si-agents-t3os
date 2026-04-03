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
    value_format_name: id
  }

  dimension: call_for_pricing {
    type: yesno
    sql: ${TABLE}."CALL_FOR_PRICING" ;;
  }

  dimension: created_by_user_id {
    type: number
    sql: ${TABLE}."CREATED_BY_USER_ID" ;;
    value_format_name: id
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
    value_format_name: id
  }

  dimension: price_per_day {
    type: number
    sql: ${TABLE}."PRICE_PER_DAY" ;;
    value_format_name: usd_0
  }

  dimension: price_per_hour {
    type: number
    sql: ${TABLE}."PRICE_PER_HOUR" ;;
    value_format_name: usd_0
  }

  dimension: price_per_month {
    type: number
    sql: ${TABLE}."PRICE_PER_MONTH" ;;
    value_format_name: usd_0
  }

  dimension: price_per_week {
    type: number
    sql: ${TABLE}."PRICE_PER_WEEK" ;;
    value_format_name: usd_0
  }

  dimension: rate_type_id {
    type: number
    sql: ${TABLE}."RATE_TYPE_ID" ;;
    value_format_name: id
  }

  dimension: voided_by_user_id {
    type: number
    sql: ${TABLE}."VOIDED_BY_USER_ID" ;;
    value_format_name: id
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

  measure: count {
    type: count
    drill_fields: [branch_rental_rate_id]
  }
}
