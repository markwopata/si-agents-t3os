view: rate_refresh_updates {
  derived_table: {
    sql:
with all_rates as (select rr.REGION, brr.*
                   from ES_WAREHOUSE.PUBLIC.BRANCH_RENTAL_RATES brr
                       join RATE_ACHIEVEMENT.RATE_REGIONS rr on brr.BRANCH_ID = rr.MARKET_ID
                            join RATE_ACHIEVEMENT.RATE_REFRESH_2025Q2 re
                                 on brr.EQUIPMENT_CLASS_ID = re.EQUIPMENT_CLASS_ID and rr.REGION = re.REGION
                                 where brr.ACTIVE and brr.RATE_TYPE_ID in (2, 3)),
     bench as (select distinct REGION,
                               EQUIPMENT_CLASS_ID,
                               round(mode(PRICE_PER_MONTH)) as bench_month,
                               round(mode(PRICE_PER_WEEK))  as bench_week,
                               round(mode(PRICE_PER_DAY))   as bench_day
               from all_rates
               where RATE_TYPE_ID = 2
               group by 1, 2),
     floor as (select distinct REGION,
                               EQUIPMENT_CLASS_ID,
                               round(mode(PRICE_PER_MONTH)) as floor_month,
                               round(mode(PRICE_PER_WEEK))  as floor_week,
                               round(mode(PRICE_PER_DAY))   as floor_day
               from all_rates
               where RATE_TYPE_ID = 3
               group by 1, 2)
select re.REGION,
       re.REGION_NAME,
       re.EQUIPMENT_CLASS_ID,
       re.EQUIPMENT_CLASS,
       re.CURRENT_BENCH,
       re.CURRENT_FLOOR,
       re.PROPOSED_FLOOR,
       re.PROPOSED_BENCH,
       b.bench_month,
       b.bench_week,
       b.bench_day,
       f.floor_month,
       f.floor_week,
       f.floor_day,
       (bench_month - re.CURRENT_BENCH) / re.CURRENT_BENCH             as bench_percent_change,
       (floor_month - re.CURRENT_FLOOR) / re.CURRENT_FLOOR             as floor_percent_change,
       concat('$', bench_month, ' / $', bench_week, ' / $', bench_day) as formatted_bench,
       concat('$', floor_month, ' / $', floor_week, ' / $', floor_day) as formatted_floor
from RATE_ACHIEVEMENT.RATE_REFRESH_2025Q2 re
         join bench b on re.EQUIPMENT_CLASS_ID = b.EQUIPMENT_CLASS_ID and re.REGION = b.REGION
         join floor f on re.EQUIPMENT_CLASS_ID = f.EQUIPMENT_CLASS_ID and re.REGION = f.REGION
         left join RATE_ACHIEVEMENT.RATE_SPLITS_STAGING rss on re.EQUIPMENT_CLASS_ID = rss.EQUIPMENT_CLASS_ID
where CURRENT_BENCH <> bench_month
   or CURRENT_FLOOR <> floor_month
order by REGION_NAME, floor_percent_change desc;;
  }

  dimension: region {
    type: number
    sql: ${TABLE}."REGION" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }

  dimension: equipment_class {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS" ;;
  }

  dimension: current_bench {
    type: number
    sql: ${TABLE}."CURRENT_BENCH" ;;
  }

  dimension: current_floor {
    type: number
    sql: ${TABLE}."CURRENT_FLOOR" ;;
  }

  dimension: bench_month {
    type: number
    sql: ${TABLE}."BENCH_MONTH" ;;
  }

  dimension: bench_week {
    type: number
    sql: ${TABLE}."BENCH_WEEK" ;;
  }

  dimension: bench_day {
    type: number
    sql: ${TABLE}."BENCH_DAY" ;;
  }

  dimension: floor_month {
    type: number
    sql: ${TABLE}."FLOOR_MONTH" ;;
  }

  dimension: floor_week {
    type: number
    sql: ${TABLE}."FLOOR_WEEK" ;;
  }

  dimension: floor_day {
    type: number
    sql: ${TABLE}."FLOOR_DAY" ;;
  }

  dimension: bench_percent_change {
    type: number
    sql: ${TABLE}."BENCH_PERCENT_CHANGE" ;;
  }

  dimension: floor_percent_change {
    type: number
    sql: ${TABLE}."FLOOR_PERCENT_CHANGE" ;;
  }

  dimension: formatted_bench {
    type: string
    sql: ${TABLE}."FORMATTED_BENCH" ;;
  }

  dimension: formatted_floor {
    type: string
    sql: ${TABLE}."FORMATTED_FLOOR" ;;
  }
}
