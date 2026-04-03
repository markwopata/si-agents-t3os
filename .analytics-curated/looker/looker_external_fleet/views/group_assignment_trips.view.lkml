view: group_assignment_trips {
  derived_table: {
    sql:
    with group_trips as (
    select sao.asset_id,
        sao.organization_id,
        o.name as group_name,
        sao.date_start as group_start,
        case when sao.date_end = '9999-12-31'::timestamp_tz(9) then null else sao.date_end end as group_end,
        case when sao.date_end = '9999-12-31'::timestamp_tz(9) then datediff(day,sao.date_start,current_timestamp) else datediff(day,sao.date_start,sao.date_end) end duration_days,
        coalesce(sum(t.trip_time_seconds),0) as trip_seconds,
        coalesce(sum(t.idle_duration),0) as idle_seconds,
        floor(sum(trip_time_seconds)::decimal/ (86400))::integer as trip_day,
        floor(mod(sum(trip_time_seconds)::decimal, 86400) / 3600)::integer as trip_hr,
        floor(mod(sum(trip_time_seconds)::decimal, 3600) / 60)::integer as trip_min,
        mod(sum(trip_time_seconds)::decimal, 60) as trip_sec,
        floor(sum(idle_duration)::decimal/ (86400))::integer as idle_day,
        floor(mod(sum(idle_duration)::decimal, 86400) / 3600)::integer as idle_hr,
        floor(mod(sum(idle_duration)::decimal, 3600) / 60)::integer as idle_min,
        mod(sum(idle_duration)::decimal, 60) as idle_sec,
        datediff(day,
                case when sao.date_start <= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}) then convert_timezone('{{ _user_attributes['user_timezone'] }}', 'UTC', {% date_start date_filter %}) else sao.date_start end,
                case when sao.date_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}) then convert_timezone('{{ _user_attributes['user_timezone'] }}', 'UTC', {% date_end date_filter %}) else sao.date_end end
                ) as days_in_group
    from scd.scd_asset_organization sao
        join public.organizations o on o.organization_id = sao.organization_id
        join public.assets a on a.asset_id = sao.asset_id
        left join trips t on t.asset_id = sao.asset_id and t.start_timestamp between convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}) and convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})
    where o.company_id = '{{ _user_attributes['company_id'] }}'::integer
        and overlaps (date_start, date_end, convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}), convert_timezone('{{ _user_attributes['user_timezone'] }}', 'UTC', {% date_end date_filter %}))
    group by sao.asset_id, sao.organization_id, o.name, sao.date_end, sao.date_start
    )
    , current_groups_list as (
    select asset_id,
        listagg(distinct group_name, ', ') within group (order by group_name) as current_groups
    from group_trips
    group by asset_id
    )
    select gt.asset_id,
        gt.organization_id,
        gt.group_name,
        gt.group_start,
        gt.group_end,
        gt.duration_days,
        gt.trip_seconds,
        gt.idle_seconds,
        case when trip_day > 0 then concat(trip_day, ' days ', trip_hr, ' hrs ', trip_min, ' mins ')
             when trip_hr > 0 then concat(trip_hr, ' hrs ', trip_min, ' mins ', trip_sec, ' secs')
             else concat(trip_min, ' mins ', trip_sec, ' secs') end as trip_time,
        case when idle_day > 0 then concat(idle_day, ' days ', idle_hr, ' hrs ', idle_min, ' mins ')
             when idle_hr > 0 then concat(idle_hr, ' hrs ', idle_min, ' mins ', idle_sec, ' secs')
             else concat(idle_min, ' mins ', idle_sec, ' secs') end as idle_time,
        cgl.current_groups,
        gt.days_in_group
    from group_trips gt left join current_groups_list cgl on gt.asset_id = cgl.asset_id
    ;;

    }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: CONCAT(${asset_id},${organization_id},${group_start}) ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: organization_id {
    type: number
    sql: ${TABLE}."ORGANIZATION_ID" ;;
  }

  dimension: group_name {
    type: string
    sql: ${TABLE}."GROUP_NAME" ;;
  }

  dimension: group_start {
    label: "Date Start"
    type: date_time
    sql: ${TABLE}."GROUP_START" ;;
    html: {{ rendered_value | date: "%b %d, %Y %r"  }} {{ _user_attributes['user_timezone_label'] }};;
  }

  dimension: group_end {
    label: "Date End"
    type: date_time
    sql: ${TABLE}."GROUP_END" ;;
    html: {{ rendered_value | date: "%b %d, %Y %r"  }} {{ _user_attributes['user_timezone_label'] }};;
  }

  dimension: duration_days {
    label: "Total Days in Group"
    type: number
    sql: ${TABLE}."DURATION_DAYS" ;;
  }

  dimension: trip_seconds {
    type: number
    sql: ${TABLE}."TRIP_SECONDS" ;;
  }

  dimension: idle_seconds {
    type: number
    sql: ${TABLE}."IDLE_SECONDS" ;;
  }

  dimension: trip_time {
    label: "Run Time"
    type: string
    sql: ${TABLE}."TRIP_TIME" ;;
  }

  dimension: idle_time {
    type: string
    sql: ${TABLE}."IDLE_TIME" ;;
  }

  dimension: current_groups {
    type: string
    sql: ${TABLE}."CURRENT_GROUPS" ;;
  }

  dimension: days_in_group {
    type: number
    sql: ${TABLE}."DAYS_IN_GROUP" ;;
  }

  # dimension: last_location {
  #   type: string
  #   sql: ${TABLE}."LAST_LOCATION" ;;
  # }

  filter: date_filter {
  type: date_time
  }

  measure: days_in_group_measure {
    label: "Total Days in Group"
    type: sum
    sql: ${duration_days} ;;
    description: "Total overall days an asset was in the group. This metric is only based on the date range if a start/end date falls within the duration selected."
  }

  measure: days_in_group_during_selected_range {
    label: "Days in Group During Selected Range"
    type: sum
    sql: ${days_in_group} ;;
    description: "Total days an asset was in the group based off the selected date range"
  }

  measure: ttl_trip_time {
    type: sum
    sql: ${trip_seconds} /3600 ;;
    value_format_name: decimal_2
  }

  measure: ttl_idle_time {
    type: sum
    sql: ${idle_seconds} /3600;;
    value_format_name: decimal_2
  }

  dimension: group_filter {
    type: string
    sql: ${group_name} ;;
    suggest_dimension: group_name
  }

    }
