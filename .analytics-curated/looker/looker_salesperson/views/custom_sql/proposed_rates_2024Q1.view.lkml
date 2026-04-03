view: proposed_rates_2024q1 {
  derived_table: {
    sql: select pr.EQUIPMENT_CLASS_ID,
       ec.NAME as equipment_class,
       c.NAME as category,
       bs.NAME as business_segment,
       pr.REGION,
       rr.REGION_NAME,
       rr.DISTRICT,
       rr.MARKET_ID,
       rr.MARKET_NAME,
       coalesce(rob.PRICE_PER_MONTH, pr.BENCH_MONTH) as month_bench,
       round(month_bench / rss.WEEK_MONTH)           as week_bench,
       round(week_bench / rss.DAY_WEEK)              as day_bench,
       round(bench_day / 3)                          as hour_bench,
       coalesce(rof.PRICE_PER_MONTH, pr.FLOOR_MONTH) as month_floor,
       round(month_floor / rss.WEEK_MONTH)           as week_floor,
       round(week_floor / rss.DAY_WEEK)              as day_floor,
       round(day_floor / 3)                          as hour_floor,
       round(month_bench * 1.3)                      as month_online,
       round(week_bench * 1.3)                       as week_online,
       round(day_bench * 1.3)                        as day_online,
       round(hour_bench * 1.3)                       as hour_online,
       concat('$', day_floor, ' / $', week_floor, ' / $', month_floor) as floor_rates,
       concat('$', day_bench, ' / $', week_bench, ' / $', month_bench) as benchmark_rates,
       concat('$', day_online, ' / $', week_online, ' / $', month_online) as online_rates
from RATE_ACHIEVEMENT.PROPOSED_RATES pr
         join RATE_ACHIEVEMENT.RATE_SPLITS_STAGING rss on pr.EQUIPMENT_CLASS_ID = rss.EQUIPMENT_CLASS_ID
         join RATE_ACHIEVEMENT.RATE_REGIONS rr on pr.REGION = rr.REGION
         join ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES ec on pr.EQUIPMENT_CLASS_ID = ec.EQUIPMENT_CLASS_ID
                                                              and ec.NAME not like '%ucket%'
         join ES_WAREHOUSE.PUBLIC.CATEGORIES c on ec.CATEGORY_ID = c.CATEGORY_ID
         join ES_WAREHOUSE.PUBLIC.BUSINESS_SEGMENTS bs on ec.BUSINESS_SEGMENT_ID = bs.BUSINESS_SEGMENT_ID
         left join RATE_ACHIEVEMENT.RATE_OVERRIDES rof
                   on (pr.EQUIPMENT_CLASS_ID = rof.EQUIPMENT_CLASS_ID and pr.REGION = rof.RATE_REGION_ID and
                       rof.RATE_TYPE_ID = 3 and rof.ACTIVE)
         left join RATE_ACHIEVEMENT.RATE_OVERRIDES rob
                   on (pr.EQUIPMENT_CLASS_ID = rob.EQUIPMENT_CLASS_ID and pr.REGION = rob.RATE_REGION_ID and
                       rob.RATE_TYPE_ID = 2 and rob.ACTIVE)
where bs.BUSINESS_SEGMENT_ID <> 3
                   ;;
  }

  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }

  dimension: equipment_class {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS" ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: business_segment {
    type: string
    sql: ${TABLE}."BUSINESS_SEGMENT" ;;
  }

  dimension: region {
    type: number
    sql: ${TABLE}."REGION" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: floor_rates {
    type: string
    sql: ${TABLE}."FLOOR_RATES" ;;
  }

  dimension: benchmark_rates {
    type: string
    sql: ${TABLE}."BENCHMARK_RATES" ;;
  }

  dimension: online_rates {
    type: string
    sql: ${TABLE}."ONLINE_RATES" ;;
  }
}
