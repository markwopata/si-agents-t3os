
view: fleet_utilization_by_asset {
  derived_table: {
    sql: with daily_run_time as (
                 select
                 report_range:start_range::date as run_date,
                 asset_id,
                 sum(on_time) as on_time,
                 sum(idle_time) as idle_time,
                 sum(on_time) + sum(idle_time) as run_time
                 from es_warehouse.public.hourly_asset_usage
                 where report_range:start_range::date >= DATEADD(Day ,-91, current_date)
                 group by run_date, asset_id
                 )
                , all_assets as (
                 select distinct
                 asset_id
                 from ES_WAREHOUSE.PUBLIC.assets
                 where tracker_id is not null
                 and deleted = false
                 )
                 --- this needs to be reworked to pull inprogress trips then remove suspected trips
                , sus_trips as (
                  select
                  distinct t.asset_id,
                  case
                      when (c.name not ilike '%generator%' or c.name not ilike '%pump%') and t.start_timestamp::date < dateadd(day, -2, current_date)                    then 1
                      when (c.name ilike '%generator%' or c.name ilike '%pump%') and t.start_timestamp::date < dateadd(day, -91, current_date) then 1
                      else null
                  end as sus_trip_flag
                  from ES_WAREHOUSE.PUBLIC.trips t
                  left join ES_WAREHOUSE.PUBLIC.assets a on a.asset_id = t.asset_id
                  left join ES_WAREHOUSE.PUBLIC.categories c on a.category_id = c.category_id
                  where t.end_timestamp is null
                  and t.trip_time_seconds is null
                  and t.asset_id is not null
                  and t.trip_type_id in (1, 4)
                  )
                 , date_table as (
                  select
                  dateadd(
                  day,
                  '-' || row_number() over (order by null),
                  dateadd(day, '+1', current_date())
                  ) as run_date
                  from table (generator(rowcount => 30))
                  )
                 , date_table_2 as (
                  select *
                  from
                  date_table dt
                  cross join all_assets al
                  )
                 , rental_assigments as (
                  select
                  --r.start_date::date as rental_start_date,
                  --coalesce(r.end_date,current_date())::date as  rental_end_date,
                  ea.start_date::date as rental_start_date,
                  coalesce(ea.end_date,current_date())::date as  rental_end_date,
                  r.asset_id,
                  r.rental_id,
                  u.company_id as company_renting_id
                  from
                  ES_WAREHOUSE.PUBLIC.orders o
                  join ES_WAREHOUSE.PUBLIC.rentals r on (r.order_id = o.order_id)
                  join ES_WAREHOUSE.PUBLIC.users u on (o.user_id = u.user_id)
                  left join ES_WAREHOUSE.PUBLIC.equipment_assignments ea on (r.rental_id = ea.rental_id)
                  --left join assets a on (a.asset_id = ea.asset_id)
                  where rental_type_id in (1,2,4)
                  and rental_status_id not in (1,2,3,4,8)
                  and r.asset_id is not null
                  )

                  select
                    dt.run_date
                  , DAYNAME(dt.run_date) as day_name
                  , DAYOFWEEK(dt.run_date) as day_num
                  , dt.asset_id
                  , a.custom_name
                  --, c.parent_category_id
                  , c.name as sub_category_name
                  , c.category_id
                  , ra.rental_id
                  , ra.company_renting_id
                  , co.name as company_name
                  , a.asset_type_id
                  , coalesce(concat(a.make,' ',a.model),'No Make Model Assigned') as make_model
                  , a.company_id as company_owner_id
                  , st.sus_trip_flag
                  , coalesce(ra.company_renting_id, a.company_id) as utilization_assigned_company_id
                  , case when st.sus_trip_flag = 1 then 0 else coalesce(on_time, 0) end as on_time
                  , case when st.sus_trip_flag = 1 then 0 else coalesce(idle_time, 0) end as idle_time
                  , case when st.sus_trip_flag = 1 then 0 else coalesce(run_time, 0) end as run_time
                  , 3600 * 8 as potential_utilization
                  from
                  date_table_2 dt
                  left join daily_run_time drt on (dt.run_date = drt.run_date and dt.asset_id = drt.asset_id)
                  left join rental_assigments ra on (dt.asset_id = ra.asset_id and dt.run_date >= ra.rental_start_date and dt.run_date <=
                  ra.rental_end_date )
                  left join ES_WAREHOUSE.PUBLIC.assets a on (a.asset_id = dt.asset_id)
                  left join  ES_WAREHOUSE.PUBLIC.companies co on co.company_id = ra.company_renting_id
                  left join ES_WAREHOUSE.PUBLIC.categories c on c.category_id = a.category_id
                  left join sus_trips st on (a.asset_id = st.asset_id)
                  where coalesce(ra.company_renting_id, a.company_id) is not null
                  and a.asset_type_id in (1,2)
                  and c.name is not null ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: run_date {
    type: date
    sql: ${TABLE}."RUN_DATE" ;;
  }

  dimension: day_name {
    type: string
    sql: ${TABLE}."DAY_NAME" ;;
  }

  dimension: day_num {
    type: number
    sql: ${TABLE}."DAY_NUM" ;;
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: company_renting_id {
    type: number
    sql: ${TABLE}."COMPANY_RENTING_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: custom_name {
    type: string
    sql: ${TABLE}."CUSTOM_NAME" ;;
  }

  dimension: sub_category_name {
    type: string
    sql: ${TABLE}."SUB_CATEGORY_NAME" ;;
  }

  dimension: category_id {
    type: number
    sql: ${TABLE}."CATEGORY_ID" ;;
  }

  dimension: asset_type_id {
    type: number
    sql: ${TABLE}."ASSET_TYPE_ID" ;;
  }

  dimension: make_model {
    type: string
    sql: ${TABLE}."MAKE_MODEL" ;;
  }

  dimension: company_owner_id {
    type: number
    sql: ${TABLE}."COMPANY_OWNER_ID" ;;
  }

  dimension: sus_trip_flag {
    type: number
    sql: ${TABLE}."SUS_TRIP_FLAG" ;;
  }

  dimension: utilization_assigned_company_id {
    type: number
    sql: ${TABLE}."UTILIZATION_ASSIGNED_COMPANY_ID" ;;
  }

  dimension: on_time {
    type: number
    sql: ${TABLE}."ON_TIME" ;;
  }

  measure: on_time_sum {
    type: sum
    sql: ${on_time} ;;
  }

  dimension: idle_time {
    type: number
    sql: ${TABLE}."IDLE_TIME" ;;
  }

  measure: idle_time_sum {
    type: sum
    sql: ${idle_time} ;;
  }

  dimension: run_time {
    type: number
    sql: ${TABLE}."RUN_TIME" ;;
  }

  measure: run_time_sum {
    type: sum
    sql: ${run_time} ;;
  }

  dimension: potential_utilization {
    type: number
    sql: ${TABLE}."POTENTIAL_UTILIZATION" ;;
  }

  measure: potential_utilization_sum {
    type: sum
    sql: ${potential_utilization} ;;
  }

  measure: distinct_rental_ids {
    type: count_distinct
    sql: ${rental_id} ;;
  }

  measure: distinct_asset_ids {
    type: count_distinct
    sql: ${asset_id} ;;
  }

  measure: percent_used {
    type: number
    value_format: "0.00\%"
    sql: (${on_time_sum} / ${potential_utilization_sum}) * 100 ;;
  }

  set: detail {
    fields: [
        run_date,
        day_name,
        day_num,
  asset_id,
  rental_id,
  custom_name,
  company_renting_id,
  company_name,
  sub_category_name,
  category_id,
  asset_type_id,
  make_model,
  company_owner_id,
  sus_trip_flag,
  utilization_assigned_company_id,
  on_time,
  idle_time,
  run_time,
  potential_utilization,
  on_time_sum,
  idle_time_sum,
  run_time_sum,
  potential_utilization_sum,
  distinct_rental_ids,
  distinct_asset_ids
    ]
  }
}
