view: active_branch_rental_rates_pivot {
 derived_table: {
  sql: WITH columns     AS (
                          SELECT branch_id,
                                 equipment_class_id,
                                 rate_type_id,
                                 SUM(price_per_hour)  AS pivotcol1,
                                 SUM(price_per_day)   AS pivotcol2,
                                 SUM(price_per_week)  AS pivotcol3,
                                 SUM(price_per_month) AS pivotcol4
                            FROM es_warehouse.public.branch_rental_rates
                           WHERE active = 'Y'
                           GROUP BY branch_id, equipment_class_id, rate_type_id),
       agg_columns AS (
                          SELECT branch_id,
                                 equipment_class_id,
                                 OBJECT_AGG(rate_type_id, pivotcol1) AS hour_price,
                                 OBJECT_AGG(rate_type_id, pivotcol2) AS day_price,
                                 OBJECT_AGG(rate_type_id, pivotcol3) AS week_price,
                                 OBJECT_AGG(rate_type_id, pivotcol4) AS month_price
                            FROM columns
                           GROUP BY branch_id, equipment_class_id)
SELECT ac.branch_id,
       ac.equipment_class_id,
       ec.name as equipment_class_name,
       ac.hour_price:"1"::integer  AS online_hour_rate,
       ac.day_price:"1"::integer   AS online_day_rate,
       ac.week_price:"1"::integer  AS online_week_rate,
       ac.month_price:"1"::integer AS online_month_rate,
       ac.hour_price:"2"::integer  AS benchmark_hour_rate,
       ac.day_price:"2"::integer   AS benchmark_day_rate,
       ac.week_price:"2"::integer  AS benchmark_week_rate,
       ac.month_price:"2"::integer AS benchmark_month_rate,
       ac.hour_price:"3"::integer  AS floor_hour_rate,
       ac.day_price:"3"::integer   AS floor_day_rate,
       ac.week_price:"3"::integer  AS floor_week_rate,
       ac.month_price:"3"::integer AS floor_month_rate
  FROM agg_columns ac
  left join es_warehouse.public.equipment_classes ec on ac.equipment_class_id = ec.equipment_class_id
 ORDER BY branch_id, equipment_class_id
;;
}

dimension: branch_id {
  type: number
  sql: ${TABLE}."BRANCH_ID" ;;
  value_format_name: id
}

dimension: equipment_class_id {
  type: number
  sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  value_format_name: id
}

dimension: equipment_class_name {
  type: number
  sql: ${TABLE}."EQUIPMENT_CLASS_NAME" ;;
}

dimension: online_hour_rate {
  type: number
  sql: ${TABLE}."ONLINE_HOUR_RATE" ;;
  value_format_name: usd
}

dimension: online_day_rate {
  type: number
  sql: ${TABLE}."ONLINE_DAY_RATE" ;;
  value_format_name: usd
}

dimension: online_week_rate {
  type: number
  sql: ${TABLE}."ONLINE_WEEK_RATE" ;;
  value_format_name: usd
}

dimension: online_month_rate {
  type: number
  sql: ${TABLE}."ONLINE_MONTH_RATE" ;;
  value_format_name: usd
}

dimension: benchmark_hour_rate {
  type: number
  sql: ${TABLE}."BENCHMARK_HOUR_RATE" ;;
  value_format_name: usd
}

dimension: benchmark_day_rate {
  type: number
  sql: ${TABLE}."BENCHMARK_DAY_RATE" ;;
  value_format_name: usd
}

dimension: benchmark_week_rate {
  type: number
  sql: ${TABLE}."BENCHMARK_WEEK_RATE" ;;
  value_format_name: usd
}

dimension: benchmark_month_rate {
  type: number
  sql: ${TABLE}."BENCHMARK_MONTH_RATE" ;;
  value_format_name: usd
}

dimension: floor_hour_rate {
  type: number
  sql: ${TABLE}."FLOOR_HOUR_RATE" ;;
  value_format_name: usd
}

dimension: floor_day_rate {
  type: number
  sql: ${TABLE}."FLOOR_DAY_RATE" ;;
  value_format_name: usd
}

dimension: floor_week_rate {
  type: number
  sql: ${TABLE}."FLOOR_WEEK_RATE" ;;
  value_format_name: usd
}

dimension: floor_month_rate {
  type: number
  sql: ${TABLE}."FLOOR_MONTH_RATE" ;;
  value_format_name: usd
}

}
