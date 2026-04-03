view: speed_report {
   derived_table: {
     sql:
with asset_list as (
    select a.asset_id
    from assets a
        join table(assetlist({{ _user_attributes['user_id'] }}::numeric)) L on L.asset_id = a.asset_id
    where a.asset_type_id = 2
)
, trip_duration as (
select
  base.asset_id,
    base.speed_events,
    base.speed_secs,
    base.on_time_secs,
    base.idle_sec
  from
(
SELECT
    t.asset_id,
    da.operator_name as driver_name,
    coalesce(ROUND(sum(t.trip_time_seconds::decimal),0),2) as on_time_secs,
    coalesce(ROUND(sum(t.idle_duration::decimal),0),2) as idle_sec,
    coalesce(sum(t.speeding_incidents),0) as speed_events,
    coalesce(sum(t.speeding_duration),0) as speed_secs
FROM trips t join asset_list al on al.asset_id = t.asset_id
  left join users u on t.driver_user_id = u.user_id
  left join business_intelligence.gold.v_fact_operator_assignments da on da.asset_id = t.asset_id
            and da.assignment_time <= t.report_timestamp
            and coalesce(da.unassignment_time, current_date()) >= t.report_timestamp
where t.end_timestamp >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %})
  and t.end_timestamp < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})
    and t.trip_type_id in(1,2,5,7)
group by t.asset_id
  ) base
)
,assets_w_speed_threshold as (
  select distinct t.asset_id,
  da.operator_name as driver_name,
  duration_seconds, exceeded_threshold_value as maxSpeed, aid.start_timestamp, aid.end_timestamp
  from tracking_incidents t join asset_list al on al.asset_id = t.asset_id
      join asset_incident_thresholds ait on ait.asset_incident_threshold_id = t.asset_incident_threshold_id
      join asset_incident_threshold_durations aid on aid.start_incident_id = t.tracking_incident_id
      left join business_intelligence.gold.v_fact_operator_assignments da on da.asset_id = t.asset_id
            and da.assignment_time <= t.report_timestamp
            and coalesce(da.unassignment_time, current_date()) >= t.report_timestamp
    where
        t.tracking_incident_type_id = 32 and ait.asset_incident_threshold_field_id = 9
        and t.report_timestamp >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %})
        and t.report_timestamp <= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})
        and aid.start_timestamp >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %})
        and aid.end_timestamp <= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})

)
, assets_wo_speed_threshold as (
   select distinct t.asset_id,
  da.operator_name as driver_name,
        optional_fields:maxSpeed::float as maxSpeed,
        duration as duration_seconds,
        t.report_timestamp
      from tracking_incidents t join asset_list al on al.asset_id = t.asset_id
      left join business_intelligence.gold.v_fact_operator_assignments da on da.asset_id = t.asset_id
            and da.assignment_time <= t.report_timestamp
            and coalesce(da.unassignment_time, current_date()) >= t.report_timestamp
      where
          tracking_incident_type_id = 2
          and t.asset_id not in (select asset_id from assets_w_speed_threshold)
          and t.report_timestamp >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %})
          and t.report_timestamp <= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})
)
, max_speed as (
  select asset_id, driver_name, maxSpeed, duration_seconds
    from assets_w_speed_threshold
    union
  select asset_id, driver_name, maxSpeed, duration_seconds
    from assets_wo_speed_threshold
)
,assets_w_speed_threshold_duration as (
  select  asset_id, driver_name, duration_seconds
    from assets_w_speed_threshold
)
, assets_wo_speed_threshold_duration as (
  select asset_id, driver_name, duration_seconds
    from assets_wo_speed_threshold
)
, speed_duration as (
    select asset_id,
    driver_name,
        sum(duration_seconds) as duration_seconds,
        coalesce(count(*),0) as speed_events,
    floor(sum(duration_seconds)::decimal/ (86400))::integer as speed_day,
      floor(mod(sum(duration_seconds)::decimal, 86400) / 3600)::integer as speed_hr,
      floor(mod(sum(duration_seconds)::decimal, 3600) / 60)::integer as speed_min,
      mod(sum(duration_seconds)::decimal, 60) as speed_sec
  from assets_w_speed_threshold_duration
  group by asset_id, driver_name,
  union
    select asset_id,
        sum(duration_seconds) as duration_seconds,
        coalesce(count(*),0) as speed_events,
    floor(sum(duration_seconds)::decimal/ (86400))::integer as speed_day,
      floor(mod(sum(duration_seconds)::decimal, 86400) / 3600)::integer as speed_hr,
      floor(mod(sum(duration_seconds)::decimal, 3600) / 60)::integer as speed_min,
      mod(sum(duration_seconds)::decimal, 60) as speed_sec
  from assets_wo_speed_threshold_duration
  group by asset_id, driver_name
)
select al.asset_id,
driver_name,
  a.inventory_branch_id, s.duration_seconds,
  COALESCE(NULLIF(t.speed_events, 0), s.speed_events) as speed_events,
  round(avg(m.maxSpeed)::decimal,1) as speed_avg,
  (s.duration_seconds/(t.on_time_secs-t.idle_sec)) as driving_percentage,
case when s.speed_day > 0 then concat(s.speed_day, ' days ', s.speed_hr, ' hrs ')
     when s.speed_hr > 0 then concat(s.speed_hr, ' hrs ', s.speed_min, ' mins ', s.speed_sec, ' secs')
     else concat(s.speed_min, ' mins ', s.speed_sec, ' secs') end as speed_time,
    t.on_time_secs,t.idle_sec
FROM asset_list al join assets a on a.asset_id = al.asset_id
  join max_speed m on m.asset_id = al.asset_id
  join trip_duration t on t.asset_id = al.asset_id
  join speed_duration s on s.asset_id = al.asset_id
group by al.asset_id, driver_name, a.inventory_branch_id,
    t.speed_events, t.on_time_secs, t.idle_sec,
    s.speed_day, s.speed_hr, s.speed_min, s.speed_sec, s.speed_events, s.duration_seconds
;;
  }
  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # dimension: primary_key {
  #   primary_key: yes
  #   type: number
  #   sql: ${asset_id};;
  # }

  dimension: asset_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: driver_name {
    type: string
    sql: ${TABLE}."DRIVER_NAME" ;;
  }

  filter: date_filter {
    type: date_time
  }

  dimension: inventory_branch_id {
    type: number
    sql: ${TABLE}."INVENTORY_BRANCH_ID" ;;
  }

  dimension: speed_events {
    type: number
    sql: ${TABLE}."SPEED_EVENTS" ;;
    html:
   <font color="#0063f3"><u><a href="/embed/dashboards/35?Asset={{ assets.custom_name._value }}&Date+Filter={{_filters['speed_report.date_filter'] | url_encode }}">{{value}}</a></font></u>;;
  }

  dimension: speed_avg {
    label: "Avg Max Speed"
    type: number
    sql: ${TABLE}."SPEED_AVG";;
    html: {{value}} mph ;;
  }

  dimension: driving_percentage {
    label: " Speeding % of Drive Time"
    type: number
    sql: ${TABLE}."DRIVING_PERCENTAGE" ;;
  }

  dimension: speed_time {
    label: "Speed Duration"
    type: string
    sql: ${TABLE}."SPEED_TIME" ;;
  }

  dimension: duration_seconds {
    type: number
    sql: ${TABLE}."DURATION_SECONDS" ;;
  }

  dimension: on_time_secs {
    type: number
    sql: ${TABLE}."ON_TIME_SECS" ;;
  }

  dimension: idle_sec {
    type: number
    sql: ${TABLE}."IDLE_SEC" ;;
  }

  measure: total_on_time_seconds {
    type: sum
    sql: ${on_time_secs} ;;
  }

  measure: total_idle_seconds {
    type: sum
    sql: ${idle_sec} ;;
  }

  measure: percentage_of_drive_time_speeding {
    type: number
    sql: (${total_duration_seconds}/(${total_on_time_seconds}-${total_idle_seconds})) ;;
    value_format_name: percent_2
  # (s.duration_seconds/(t.on_time_secs-t.idle_sec))
  }

  measure: total_duration_seconds {
    type: sum
    sql: ${duration_seconds} ;;
  }

  # NOTE: old impl for total_speed_duration
  # measure: total_speed_duration {
  #   type: string
  #   sql:
  #   case
  #   when
  #     floor(${total_duration_seconds}/(60*60*24))::decimal > 0
  #     then
  #     concat(floor(${total_duration_seconds}/(60*60*24))::decimal, ' day(s) ',
  #     floor(MOD(${total_duration_seconds},(60*60*24))/(60*60))::decimal, ' hr(s) ',
  #     floor(MOD(${total_duration_seconds},(60*60))/(60))::decimal, ' min(s) and '
  #     ,MOD(${total_duration_seconds},(60))::decimal, ' sec(s). ')
  #   when
  #     floor(MOD(${total_duration_seconds},(60*60*24))/(60*60)) > 0
  #     then
  #     concat(floor(MOD(${total_duration_seconds},(60*60*24))/(60*60))::decimal, ' hr(s) ',
  #     floor(MOD(${total_duration_seconds},(60*60))/(60))::decimal, ' min(s) and '
  #     ,MOD(${total_duration_seconds},(60))::decimal, ' sec(s). ')
  #   else
  #   concat(floor(MOD(${total_duration_seconds},(60*60))/(60))::decimal, ' min(s) and '
  #   ,MOD(${total_duration_seconds},(60))::decimal, ' sec(s). ')
  #   end
  #   ;;
  # }

  measure: total_speeding_duration {
    type: number
    sql: round(${total_duration_seconds}/3600,2);;
    label: "Total Speeding Duration"
    html: {{value}} hours ;;
  }

  measure: total_speed_events {
    type: sum
    sql: ${speed_events} ;;
  }

  set: detail {
    fields: [speed_events, speed_avg, driving_percentage, speed_time]
  }

  }