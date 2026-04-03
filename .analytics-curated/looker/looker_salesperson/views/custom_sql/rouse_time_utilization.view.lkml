view: rouse_time_utilization {
  derived_table: {
    sql:
with market_time_utilization_6mo as (


WITH month_window AS (
  SELECT
    DATEADD(year, -1, DATE_TRUNC('month', CURRENT_DATE)) AS start_month,
    DATEADD(month, 6, DATEADD(year, -1, DATE_TRUNC('month', CURRENT_DATE))) AS end_month
),

per_month AS (
  SELECT
    TRY_CAST(RIGHT(cat_class, CHARINDEX('-', REVERSE(cat_class)) - 1) AS NUMBER) AS equipment_class_id,
    rr.district,
    DATE_TRUNC('month', br."MONTH") AS m,
    COALESCE(ROUND(AVG(util_benchmark), 4), 0) AS market_time_utilization
  FROM inbound.rouse.benchmark_rates br
  JOIN rate_achievement.rate_regions rr
    ON TRY_CAST(br.location AS NUMBER) = rr.market_id
  CROSS JOIN month_window w
  WHERE br.location <> 'RouseBlank'
    AND br.cat_class <> 'RouseBlank'
    AND br."MONTH" >= w.start_month
    AND br."MONTH" <  w.end_month
  GROUP BY 1,2,3
)

SELECT
  equipment_class_id,
  district,
  LISTAGG(
    TO_CHAR(m, 'MON-YY') || ': ' || TO_CHAR(market_time_utilization * 100, 'FM999.00') || '%',
    ' | '
  ) WITHIN GROUP (ORDER BY m) AS market_time_utilization_6mo
FROM per_month
GROUP BY 1,2
ORDER BY 2,1)


select
try_cast(right(cat_class, charindex('-', reverse(cat_class)) - 1) as number) as EQUIPMENT_CLASS_ID,
rr.district,
market_time_utilization_6mo,
round(avg(monthly_standard_avg)) as market_benchmark,
round(avg(br.MONTHLY_STANDARD_BQ)) as market_bq,
COALESCE(round(avg(UTIL_BENCHMARK),4),0) as market_time_utilization
from INBOUND.rouse.benchmark_rates br
join RATE_ACHIEVEMENT.RATE_REGIONS rr on try_cast(br.location as number) = rr.MARKET_ID
left join market_time_utilization_6mo rtu on rtu.equipment_class_id = try_cast(right(cat_class, charindex('-', reverse(cat_class)) - 1) as number)
and rtu.district = rr.district
WHERE location <> 'RouseBlank'
  and CAT_CLASS <> 'RouseBlank'
and datediff(months, month, current_date) < 3
group by 1,2,3
    ;;
  }

  dimension: equipment_class_id {
    type: number
    value_format: "0"
    sql: ${TABLE}.equipment_class_id ;;
  }

  dimension: district {
    type: number
    value_format: "0"
    sql: ${TABLE}.district ;;
  }

  dimension: equipment_class_district_pk {
    primary_key: yes
    type: string
    sql: CONCAT(${equipment_class_id}, '-', ${district}) ;;
  }

  dimension: market_benchmark {
    type: number
    value_format: "$#,##0"
    sql: ${TABLE}.market_benchmark ;;
  }

  dimension: market_bq {
    type: number
    value_format: "$#,##0"
    sql: ${TABLE}.market_bq ;;
  }

  dimension: market_time_utilization {
    type: number
    value_format: "0%"
    sql: ${TABLE}.market_time_utilization ;;
  }

  dimension: market_time_ute_25_pct_above_es {
    type: string
    sql: CASE WHEN ${time_utilization_district.time_ut} + 0.25 < ${market_time_utilization} THEN 'Yes' else 'No' end  ;;
  }

  dimension: market_time_utilization_6mo {
    type: string
    sql: ${TABLE}.market_time_utilization_6mo  ;;
  }

  measure: suggested_dealrate {
    type: number
    value_format: "$#,##0"
    sql: (CASE WHEN (avg(${rouse_time_utilization.market_bq})-avg(${floor_rates_by_district.floor_rate}))/avg(${floor_rates_by_district.floor_rate}) < -0.10
          THEN avg(${rouse_time_utilization.market_bq}) ELSE avg(${floor_rates_by_district.floor_rate}) * 0.9 END);;
  }

  measure: monthly_revenue_opportunity_based_on_market_utilization {
    type: number
    value_format: "$#,##0"
    sql: (CASE WHEN (avg(${rouse_time_utilization.market_bq})-avg(${floor_rates_by_district.floor_rate}))/avg(${floor_rates_by_district.floor_rate}) < -0.10
    THEN avg(${rouse_time_utilization.market_bq}) ELSE avg(${floor_rates_by_district.floor_rate}) * 0.9 END)
    * (AVG(${rouse_time_utilization.market_time_utilization}) - avg(${time_utilization_district.time_ut}))* COUNT(DISTINCT ${suggested_discount_rates.asset_id})  ;;
  }

  measure: market_benchmark_average {
    type: average
    value_format: "$#,##0"
    sql: ${TABLE}.market_benchmark ;;
  }

  measure: market_bq_average {
    type: average
    value_format: "$#,##0"
    sql: ${TABLE}.market_bq ;;
  }

  measure: market_time_utilization_average {
    type: average
    value_format: "0.00%"
    sql: ${TABLE}.market_time_utilization ;;
  }


}
