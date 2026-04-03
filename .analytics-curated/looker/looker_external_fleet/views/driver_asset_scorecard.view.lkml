view: driver_asset_scorecard {

  derived_table: {
    sql:
    with asset_groups as (
    select distinct a.custom_name, a.asset_id, a.driver_name
      from assets a
            join table(assetlist({{ _user_attributes['user_id'] }}::numeric)) L on L.asset_id = a.asset_id
      where a.asset_type_id = 2
    )
    , speed_events as (
    select sp.trip_id,
      sum(sp.speed_duration_secs) as speed_duration_secs,
      count(sp.speed_events) as speed_events
    from (
      select t.asset_id, tr.trip_id,
        duration_seconds as speed_duration_secs,
        start_incident_id as speed_events
      from tracking_incidents t join asset_groups ag on ag.asset_id = t.asset_id
        join asset_incident_thresholds ait on ait.asset_incident_threshold_id = t.asset_incident_threshold_id
        join asset_incident_threshold_durations aid on aid.start_incident_id = t.tracking_incident_id
        join tracking_events te on te.tracking_event_id = t.tracking_event_id
        join trips tr on tr.trip_id = t.trip_id
      where
        t.tracking_incident_type_id = 32 and ait.asset_incident_threshold_field_id = 9
        and t.report_timestamp >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %})
        and t.report_timestamp < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})
        and aid.start_timestamp >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %})
        and aid.end_timestamp < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})
    union
       select t.asset_id, tr.trip_id,
        duration as speed_duration_secs,
        tracking_incident_id as speed_events
       from tracking_incidents t join asset_groups ag on ag.asset_id = t.asset_id
          join trips tr on tr.trip_id = t.trip_id
        where
          tracking_incident_type_id = 2
          and t.report_timestamp >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %})
            and t.report_timestamp < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})
    ) sp
    group by trip_id
    )
    , base as (
    select {% if scorecard_by._parameter_value == "'Asset'" %} t.asset_id, concat(a.custom_name, ' - ', coalesce(a.driver_name, 'No Driver Assigned')) as name
           {% else %}
           coalesce(concat(u.first_name, ' ', u.last_name), 'Unassigned Driver') as name
           {%  endif %},
      round(sum(t.trip_distance_miles), 0) as miles_driven,
      round(sum(t.trip_time_seconds)::decimal/3600, 2) as on_time_hrs,
      coalesce(sum(t.impact_incidents),0) as impact,
      coalesce(sum(t.idle_incidents),0) as idle,
      count(sp.speed_events) as speed,
      coalesce(sum(t.aggressive_incidents),0) as aggressive,
      coalesce(round(sum(t.idle_duration)::decimal/3600,2),0.00) as idle_hrs,
      coalesce(round(sum(sp.speed_duration_secs)::decimal/3600,2),0.00) as speed_hrs,
      case when coalesce(sum(t.aggressive_incidents),0) > 0 then
          case when round(100 - (sum(t.aggressive_incidents)::decimal * 0.125),2) < 0 then 0 else round(100 - (sum(t.aggressive_incidents) * 0.125),2) end
            else 100 end as aggressive_score,
        case when coalesce(sum(t.impact_incidents),0) = 0 then 100
         when coalesce(sum(t.impact_incidents),0) = 1 then 80
         else 50 end as impact_score,
      case when coalesce(sum(t.idle_duration),0) > 0 then 100 - round(((sum(t.idle_duration)::numeric / sum(t.trip_time_seconds)::numeric) * 100),2)
         else 100 end as idle_score,
      case when coalesce(sum(sp.speed_duration_secs),0) > 0 then round(100 - (sum(sp.speed_duration_secs)::numeric / sum(t.trip_time_seconds)::numeric) * 100,2)
        else 100 end as speed_score
    from trips t left join users u on t.driver_user_id = u.user_id
      join asset_groups a on t.asset_id = a.asset_id
      left join speed_events sp on sp.trip_id = t.trip_id
    where t.start_timestamp >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %})
    and t.start_timestamp < convert_timezone('UTC','{{ _user_attributes['user_timezone'] }}', {% date_end date_filter %})
      and t.end_timestamp is not null
      and t.trip_type_id in(1,2,5,7)
    group by {% if scorecard_by._parameter_value == "'Asset'" %} t.asset_id, concat(a.custom_name, ' - ', coalesce(a.driver_name, 'No Driver Assigned'))
             {% else %}
             coalesce(concat(u.first_name, ' ', u.last_name), 'Unassigned Driver')
             {%  endif %}
    )
    select b.*,
      case when b.aggressive_score >= 95 then 'A'
         when b.aggressive_score >= 90 then 'B'
         when b.aggressive_score >= 85 then 'C'
         when b.aggressive_score >= 80 then 'D'
         when b.aggressive_score >= 0 then 'F'
         else '' end as aggressive_grade,
     -- case when b.impact_score >= 95 then 'A'
      --   when b.impact_score >= 90 then 'B'
     --    when b.impact_score >= 85 then 'C'
     --    when b.impact_score >= 80 then 'D'
     --    when b.impact_score >= 0 then 'F'
     --    else '' end as impact_grade,
      case when b.idle_score >= 95 then 'A'
         when b.idle_score >= 90 then 'B'
         when b.idle_score >= 85 then 'C'
         when b.idle_score >= 80 then 'D'
         when b.idle_score >= 0 then 'F'
         else '' end as idle_grade,
      case when b.speed_score >= 95 then 'A'
         when b.speed_score >= 90 then 'B'
         when b.speed_score >= 85 then 'C'
         when b.speed_score >= 80 then 'D'
         when b.speed_score >= 0 then 'F'
         else '' end as speed_grade,
      case when (b.aggressive_score + b.idle_score + b.speed_score) / 3 < 0 then 0
        else (b.aggressive_score  + b.idle_score + b.speed_score) / 3
        end as total_score,
      case when (b.aggressive_score  + b.idle_score + b.speed_score) / 3 >= 95 then 'A'
         when (b.aggressive_score  + b.idle_score + b.speed_score) / 3 >= 90 then 'B'
         when (b.aggressive_score  + b.idle_score + b.speed_score) / 3 >= 85 then 'C'
         when (b.aggressive_score  + b.idle_score + b.speed_score) / 3 >= 80 then 'D'
         when (b.aggressive_score  + b.idle_score + b.speed_score) / 3 >= 0 then 'F'
         when (b.aggressive_score  + b.idle_score + b.speed_score) / 3 < 0 then 'F'
         else '' end as total_grade
       --  case when (b.aggressive_score + b.impact_score + b.idle_score + b.speed_score) / 4 < 0 then 0
       -- else (b.aggressive_score + b.impact_score + b.idle_score + b.speed_score) / 4
      --  end as total_score,
    --  case when (b.aggressive_score + b.impact_score + b.idle_score + b.speed_score) / 4 >= 95 then 'A'
     --    when (b.aggressive_score + b.impact_score + b.idle_score + b.speed_score) / 4 >= 90 then 'B'
     --    when (b.aggressive_score + b.impact_score + b.idle_score + b.speed_score) / 4 >= 85 then 'C'
     --    when (b.aggressive_score + b.impact_score + b.idle_score + b.speed_score) / 4 >= 80 then 'D'
     --    when (b.aggressive_score + b.impact_score + b.idle_score + b.speed_score) / 4 >= 0 then 'F'
     --    when (b.aggressive_score + b.impact_score + b.idle_score + b.speed_score) / 4 < 0 then 'F'
      --   else '' end as total_grade
    from base b
    order by name
    ;;

    }

  filter: date_filter {
    type: date_time
  }

  filter: groups_filter {
    type: string
  }

  # dimension: asset_id {
  #   primary_key: yes
  #   sql: ${TABLE}."ASSET_ID" ;;
  # }

  dimension: name {
    label: "Asset/Driver"
    primary_key: yes
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: custom_name {
    type: string
    sql:  ${TABLE}."CUSTOM_NAME" ;;
  }

  dimension: driver {
    type: string
    sql: ${TABLE}."DRIVER" ;;
  }

  dimension: miles_driven {
    type: number
    sql: ${TABLE}."MILES_DRIVEN" ;;
  }

  dimension: time_driven_hours {
    type: number
    sql: ${TABLE}."ON_TIME_HRS" ;;
  }

  dimension: impact_count {
    type: number
    sql: ${TABLE}."IMPACT" ;;
  }

  dimension: speed_count {
    type: number
    sql: ${TABLE}."SPEED" ;;
  }

  dimension: agressive_incidents {
    type: number
    sql: ${TABLE}."AGGRESSIVE" ;;
  }

  dimension: idle_hours {
    type: number
    sql: ${TABLE}."IDLE_HRS" ;;
  }

  dimension: speed_hours {
    type: number
    sql: ${TABLE}."SPEED_HRS" ;;
  }

  dimension: aggressive_score {
    type: number
    sql: ${TABLE}."AGGRESSIVE_SCORE" ;;
  }

  dimension: impact_score {
    type: number
    sql: ${TABLE}."IMPACT_SCORE" ;;
  }

  dimension: idle_score {
    type: number
    sql: ${TABLE}."IDLE_SCORE" ;;
  }

  dimension: speed_score {
    type: number
    sql: ${TABLE}."SPEED_SCORE" ;;
  }

  dimension: aggressive_grade {
    type: string
    sql: ${TABLE}."AGGRESSIVE_GRADE" ;;
  }

 # dimension: impact_grade {
 #   type: string
 #   sql: ${TABLE}."IMPACT_GRADE" ;;
 # }

  dimension: idle_grade {
    type: string
    sql: ${TABLE}."IDLE_GRADE" ;;
  }

  dimension: speed_grade {
    type: string
    sql: ${TABLE}."SPEED_GRADE" ;;
  }

  dimension: total_score {
    type:  number
    sql: ${TABLE}."TOTAL_SCORE" ;;
  }

  dimension: total_grade {
    type: string
    sql: ${TABLE}."TOTAL_GRADE" ;;
  }

  parameter: scorecard_by {
    type: string
    allowed_value: { value: "Asset"}
    allowed_value: { value: "Driver"}
  }

  dimension: dynamic_by_asset_or_driver_selection {
    label_from_parameter: scorecard_by
    sql:{% if scorecard_by._parameter_value == "'Asset'" %}
      concat(${custom_name},${name})
    {% elsif scorecard_by._parameter_value == "'Driver'" %}
      coalesce(concat(u.first_name, ' ', u.last_name), 'Unassigned Driver')
    {% else %}
      NULL
    {% endif %} ;;
    }

  }
