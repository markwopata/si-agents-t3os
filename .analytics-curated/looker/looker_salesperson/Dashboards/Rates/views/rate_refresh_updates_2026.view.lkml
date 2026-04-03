view: rate_refresh_updates_2026 {
  derived_table: {
    sql:
     with all_rates as (select rr.*, ro.price_per_month as override_floor, ro1.price_per_month as override_bench
                   from RATE_ACHIEVEMENT.rate_refresh as rr
                   left join analytics.rate_achievement.rate_refresh_overrides as ro
                   on ro.region_id = rr.region and ro.equipment_class_id = rr.equipment_class_id and ro.approval_status = 'approved' and ro.rate_type_id = 3 and ro.date_voided is null
                   left join analytics.rate_achievement.rate_refresh_overrides as ro1
                   on ro1.region_id = rr.region and ro1.equipment_class_id = rr.equipment_class_id and ro1.approval_status = 'approved' and ro1.rate_type_id = 2 and ro1.date_voided is null),

     bench as (select distinct REGION,
                               ar.EQUIPMENT_CLASS_ID,
                               round(coalesce(override_bench, PROPOSED_BENCH)) as bench_month,
                               round(coalesce(override_bench, PROPOSED_BENCH)/coalesce(ro.week_month, 2.5))  as bench_week,
                                round(coalesce(override_bench, PROPOSED_BENCH)/coalesce(ro.week_month, 2.5)/coalesce(ro.day_week, 2.5))   as bench_day
               from all_rates ar
               left join analytics.rate_achievement.rate_splits_overrides as ro
               on ro.equipment_class_id = ar.equipment_class_id and ro.active = true

               ),
     floor as (select distinct REGION,
                               ar.EQUIPMENT_CLASS_ID,
                               round(coalesce(override_floor, PROPOSED_FLOOR)) as floor_month,
                               round(coalesce(override_floor, PROPOSED_FLOOR)/coalesce(ro.week_month, 2.5))  as floor_week,
                               round(coalesce(override_floor, PROPOSED_FLOOR)/coalesce(ro.week_month, 2.5)/coalesce(ro.day_week, 2.5))   as floor_day
               from all_rates ar
              left join analytics.rate_achievement.rate_splits_overrides as ro
               on ro.equipment_class_id = ar.equipment_class_id and ro.active = true
               )
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
from RATE_ACHIEVEMENT.RATE_REFRESH re
         join bench b on re.EQUIPMENT_CLASS_ID = b.EQUIPMENT_CLASS_ID and re.REGION = b.REGION
         join floor f on re.EQUIPMENT_CLASS_ID = f.EQUIPMENT_CLASS_ID and re.REGION = f.REGION

where not (CURRENT_BENCH=bench_month
   and CURRENT_FLOOR=floor_month)
order by REGION_NAME, floor_percent_change desc

;;
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
    value_format_name: usd_0
  }

  dimension: current_floor {
    type: number
    sql: ${TABLE}."CURRENT_FLOOR" ;;
    value_format_name: usd_0
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
    value_format_name: percent_1
  }

  dimension: floor_percent_change {
    type: number
    sql: ${TABLE}."FLOOR_PERCENT_CHANGE" ;;
    value_format_name: percent_1
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
