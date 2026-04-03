view: asset_geofence_idle_time {
  derived_table: {
    sql: with owned_rented_assets as (
          select asset_id
          from table(assetlist({{ _user_attributes['user_id'] }}::numeric))
          union
          select RL.asset_id
          from table(rental_asset_list({{ _user_attributes['user_id'] }}::numeric,
          convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start asset_geofence_time_utilization.date_filter %}),
          convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %}),
          ('{{ _user_attributes['user_timezone'] }}'))) RL
          join assets a on a.asset_id = rl.asset_id
          where
          a.company_id <> {{ _user_attributes['company_id'] }}
         )
        , geo_duration as (
        select
          distinct
          ge.asset_id,
          g.geofence_id,
          ge.encounter_start_timestamp as entry,
          convert_timezone('{{ _user_attributes['user_timezone'] }}',ge.encounter_end_timestamp) as exit,
          ge.start_odometer,
          ge.end_odometer,
          case when ge.encounter_start_timestamp  < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start asset_geofence_time_utilization.date_filter %}) and (ge.encounter_end_timestamp is null or ge.encounter_end_timestamp > convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %})) then TIMESTAMPDIFF(seconds,{% date_start asset_geofence_time_utilization.date_filter %}, {% date_end asset_geofence_time_utilization.date_filter %})
               when ge.encounter_start_timestamp  < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start asset_geofence_time_utilization.date_filter %}) and ge.encounter_end_timestamp between convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start asset_geofence_time_utilization.date_filter %}) and convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %}) then TIMESTAMPDIFF(seconds, convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start asset_geofence_time_utilization.date_filter %}), ge.encounter_end_timestamp)
               when ge.encounter_start_timestamp >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start asset_geofence_time_utilization.date_filter %}) and ge.encounter_end_timestamp <=  convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %}) then TIMESTAMPDIFF(seconds, ge.encounter_start_timestamp, ge.encounter_end_timestamp)
               when ge.encounter_start_timestamp between convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start asset_geofence_time_utilization.date_filter %}) and convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %}) then
                  case when ge.encounter_end_timestamp is null then TIMESTAMPDIFF(seconds, ge.encounter_start_timestamp, {% date_end asset_geofence_time_utilization.date_filter %})
                     when ge.encounter_end_timestamp >  {% date_end asset_geofence_time_utilization.date_filter %} then TIMESTAMPDIFF(seconds, ge.encounter_start_timestamp, {% date_end asset_geofence_time_utilization.date_filter %})
                   end
                   else TIMESTAMPDIFF(seconds, ge.encounter_start_timestamp, ge.encounter_end_timestamp)
              end as geo_seconds
        from
          asset_geofence_encounters ge
          join geofences g on ge.geofence_id = g.geofence_id
          join owned_rented_assets o on o.asset_id = ge.asset_id
        where
          g.company_id = {{ _user_attributes['company_id'] }}::numeric
          and  overlaps(
              ge.encounter_start_timestamp,
              coalesce(ge.encounter_end_timestamp, current_timestamp),
              convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start asset_geofence_time_utilization.date_filter %}),
              convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %})
              )
        )
        , trip_data as (
        select
          DISTINCT t.trip_id,
          t.asset_id,
          convert_timezone('{{ _user_attributes['user_timezone'] }}',t.start_timestamp) as trip_start,
          convert_timezone('{{ _user_attributes['user_timezone'] }}',coalesce(t.end_timestamp, current_timestamp)) as trip_end
        from
          trips t
          join geo_duration g on g.asset_id=t.asset_id
        where
          overlaps(
            t.start_timestamp,
            coalesce(t.end_timestamp, current_timestamp),
            convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start asset_geofence_time_utilization.date_filter %}),
            convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %}))
          and case when convert_timezone('{{ _user_attributes['user_timezone'] }}',t.end_timestamp) = convert_timezone('{{ _user_attributes['user_timezone'] }}',current_timestamp) then current_timestamp::date else convert_timezone('{{ _user_attributes['user_timezone'] }}',t.end_timestamp) end  >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start asset_geofence_time_utilization.date_filter %}) --start_date
          and convert_timezone('{{ _user_attributes['user_timezone'] }}',t.start_timestamp) <= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %})
          and TIMESTAMPDIFF(seconds, t.start_timestamp, coalesce(t.end_timestamp, current_timestamp)) <= 604800
        )
        , geo_trip_join as (
        select
          distinct gd.asset_id,
          gd.geofence_id,
          gd.entry,
          gd.exit,
          gd.geo_seconds,
          td.trip_start,
          td.trip_end,
          case when convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start asset_geofence_time_utilization.date_filter %}) < entry and convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %}) > coalesce(exit,current_timestamp) then
          case when (trip_start <= entry and trip_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %}) and exit is null) then TIMESTAMPDIFF(seconds, entry, {% date_end asset_geofence_time_utilization.date_filter %})
             when (trip_start <= entry and (trip_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %}::timestamp_ntz) or trip_end >= coalesce(exit,current_timestamp))) then TIMESTAMPDIFF(seconds, entry, coalesce(exit,current_timestamp))
             when (trip_start <= entry and trip_end < coalesce(exit,convert_timezone('{{ _user_attributes['user_timezone'] }}',current_timestamp)) and trip_end < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %})) then TIMESTAMPDIFF(seconds, entry, trip_end)
             when (trip_start > entry and trip_end > coalesce(exit,current_timestamp)) then TIMESTAMPDIFF(seconds, trip_start, coalesce(exit,current_timestamp))
             when (trip_start > entry and trip_end < coalesce(exit,current_timestamp)) then TIMESTAMPDIFF(seconds, trip_start, trip_end)
          end
           when convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start asset_geofence_time_utilization.date_filter %}) > entry and (convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %}) > coalesce(exit,current_timestamp)) then
            case when (trip_start <= entry and trip_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %}) and exit is null) then TIMESTAMPDIFF(seconds, {% date_start asset_geofence_time_utilization.date_filter %}, {% date_end asset_geofence_time_utilization.date_filter %})
               when (trip_start <= entry and (trip_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %}) or trip_end >= exit)) then TIMESTAMPDIFF(seconds, {% date_start asset_geofence_time_utilization.date_filter %}, exit)
               when (trip_start < entry and trip_end < coalesce(exit,current_timestamp) and trip_end < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %})) then TIMESTAMPDIFF(seconds, convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start asset_geofence_time_utilization.date_filter %}), trip_end)
               when (trip_start > entry and trip_end > coalesce(exit,current_timestamp)) then TIMESTAMPDIFF(seconds, trip_start, coalesce(exit,current_timestamp))
               when (trip_start > entry and trip_end < coalesce(exit,current_timestamp)) then TIMESTAMPDIFF(seconds, trip_start, trip_end)
            end
           when convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start asset_geofence_time_utilization.date_filter %}) <= entry and (convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %}) <= coalesce(exit,current_timestamp)) then
            case when (trip_start <= entry and trip_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %}) and exit is null) then TIMESTAMPDIFF(seconds, entry, {% date_end asset_geofence_time_utilization.date_filter %})
               when (trip_start <= entry and trip_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %})) then TIMESTAMPDIFF(seconds, entry, {% date_end asset_geofence_time_utilization.date_filter %})
               when (trip_start <= entry and trip_end < coalesce(exit,current_timestamp) and trip_end < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %})) then TIMESTAMPDIFF(seconds, entry, trip_end)
               when (trip_start > entry and trip_end < coalesce(exit,convert_timezone('{{ _user_attributes['user_timezone'] }}',current_timestamp))) then TIMESTAMPDIFF(seconds,trip_start, trip_end)
               when (trip_start > entry and trip_end > coalesce(exit,current_timestamp)) then TIMESTAMPDIFF(seconds,trip_start, coalesce(exit, convert_timezone('{{ _user_attributes['user_timezone'] }}',current_timestamp)))
            end
           when convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start asset_geofence_time_utilization.date_filter %}) > entry and (convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %}) <= coalesce(exit,current_timestamp)) then
            case when (trip_start <= entry and trip_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %}) and exit is null) then TIMESTAMPDIFF(seconds, {% date_start date_filter %}, {% date_end asset_geofence_time_utilization.date_filter %})
               when (trip_start <= entry and trip_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %})) then TIMESTAMPDIFF(seconds, {% date_start date_filter %}, {% date_end asset_geofence_time_utilization.date_filter %})
               when (trip_start <= entry and trip_end < coalesce(exit,current_timestamp) and trip_end < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %})) then TIMESTAMPDIFF(seconds, {% date_start asset_geofence_time_utilization.date_filter %}, trip_end)
               when (trip_start > entry and trip_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %}::timestamp_ntz) and trip_end > exit) then TIMESTAMPDIFF(seconds,trip_start, {% date_end asset_geofence_time_utilization.date_filter %}::timestamp_ntz)
               when (trip_start > entry and trip_end < coalesce(exit,current_timestamp) and trip_start >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start asset_geofence_time_utilization.date_filter %}) and trip_end <= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %})) then TIMESTAMPDIFF(seconds,trip_start, trip_end)
               when (trip_start > entry and trip_end < coalesce(exit,current_timestamp) and trip_end > convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %})) then TIMESTAMPDIFF(seconds,trip_start, {% date_end asset_geofence_time_utilization.date_filter %})
               when (trip_start > entry and trip_end < coalesce(exit,current_timestamp)) then TIMESTAMPDIFF(seconds,{% date_start date_filter %}, trip_end)
            end
      end as geo_trip_seconds --ends up being run time in geofence
        from
          geo_duration gd
          left join trip_data td on gd.asset_id = td.asset_id
          and overlaps(
          td.trip_start,
          td.trip_end,
          gd.entry,
          coalesce(gd.exit,current_timestamp)
          )
      --  where
      --    gd.asset_id = 130803
      --    and geofence_id in (46268,87946,84287)
        )
        , geofence_time as (
        select
          distinct asset_id,
          geofence_id,
          entry,
          exit,
          (geo_seconds/3600) as time_in_geofence,
          sum(geo_trip_seconds/3600) as run_time_in_geofence
        from
          geo_trip_join
          --where geofence_id in (84287)
        group by
          asset_id,
          geofence_id,
          entry,
          exit,
          geo_seconds
        )
        , idle_data as (
        select
             distinct
             i.asset_id,
             start_timestamp as idle_start,
             end_timestamp as idle_end,
             duration_seconds as idle_seconds
--             , g.entry_hours,
--             g.exit_hours
          from
             asset_idles i
            join geo_duration g on g.asset_id=i.asset_id
            join owned_rented_assets al on al.asset_id = i.asset_id
          where
            case when i.end_timestamp = current_timestamp then current_date else i.end_timestamp end >= convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_start asset_geofence_time_utilization.date_filter %}) --start_date
            and i.start_timestamp <= convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end asset_geofence_time_utilization.date_filter %}::timestamp_ntz)
            and OVERLAPS(
              i.start_timestamp,
              coalesce(i.end_timestamp, current_timestamp),
              convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_start asset_geofence_time_utilization.date_filter %}),
              convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end asset_geofence_time_utilization.date_filter %}::timestamp_ntz)
        )
        )
        select distinct
          gt.asset_id,
          gt.geofence_id,
          g.name as geofence_name,
          id.idle_start,
          id.idle_end,
          --id.idle_seconds,
          case when convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_start asset_geofence_time_utilization.date_filter %}) < entry and convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end asset_geofence_time_utilization.date_filter %}) > coalesce(exit,current_timestamp) then
            case when (idle_start <= entry and idle_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end asset_geofence_time_utilization.date_filter %}) and exit is null) then TIMESTAMPDIFF(seconds, entry, convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end asset_geofence_time_utilization.date_filter %}))
               when (idle_start <= entry and idle_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end asset_geofence_time_utilization.date_filter %}::timestamp_ntz)) or idle_end >= coalesce(exit,current_timestamp) then TIMESTAMPDIFF(seconds, entry, coalesce(exit,current_timestamp))
               when (idle_start <= entry and idle_end < coalesce(exit,convert_timezone('{{ _user_attributes['user_timezone'] }}',current_timestamp)) and idle_end < convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end asset_geofence_time_utilization.date_filter %})) then TIMESTAMPDIFF(seconds, entry, idle_end)
               when (idle_start > entry and idle_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end asset_geofence_time_utilization.date_filter %}) and exit is null) then TIMESTAMPDIFF(seconds, idle_start, convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end asset_geofence_time_utilization.date_filter %}))
               when (idle_start > entry and idle_end > coalesce(exit,current_timestamp)) then TIMESTAMPDIFF(seconds, idle_start, exit)
               when (idle_start > entry and idle_end < coalesce(exit,current_timestamp) and idle_end < convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end asset_geofence_time_utilization.date_filter %})) then TIMESTAMPDIFF(seconds,idle_start, idle_end)
            end
             when convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_start asset_geofence_time_utilization.date_filter %}) > entry and convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end asset_geofence_time_utilization.date_filter %}) > coalesce(exit,current_timestamp) then
              case when (idle_start <= entry and idle_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end asset_geofence_time_utilization.date_filter %}) and exit is null) then TIMESTAMPDIFF(seconds,convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_start asset_geofence_time_utilization.date_filter %}), convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end asset_geofence_time_utilization.date_filter %}))
                 when (idle_start <= entry and idle_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end asset_geofence_time_utilization.date_filter %})) or idle_end >= coalesce(exit,current_timestamp) then TIMESTAMPDIFF(seconds, convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_start asset_geofence_time_utilization.date_filter %}), coalesce(exit,current_timestamp))
                 when (idle_start <= entry and idle_end < coalesce(exit,convert_timezone('{{ _user_attributes['user_timezone'] }}',current_timestamp)) and idle_end < convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end asset_geofence_time_utilization.date_filter %})) then TIMESTAMPDIFF(seconds,convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_start asset_geofence_time_utilization.date_filter %}), idle_end)
                 when (idle_start > entry and idle_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end asset_geofence_time_utilization.date_filter %}::timestamp_ntz) and exit is null) then TIMESTAMPDIFF(seconds, idle_start, convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end asset_geofence_time_utilization.date_filter %}::timestamp_ntz))
                 when (idle_start > entry and idle_end > coalesce(exit,current_timestamp)) then TIMESTAMPDIFF(seconds, idle_start, exit)
                 when (idle_start > entry and idle_end < coalesce(exit,current_timestamp) and idle_end < convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end asset_geofence_time_utilization.date_filter %})) then TIMESTAMPDIFF(seconds, idle_start, idle_end)
              end
             when convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_start asset_geofence_time_utilization.date_filter %}) <= entry and convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end asset_geofence_time_utilization.date_filter %}) <= coalesce(exit,current_timestamp) then
              case when (idle_start <= entry and idle_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end asset_geofence_time_utilization.date_filter %}) and exit is null) then TIMESTAMPDIFF(seconds, entry, convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end asset_geofence_time_utilization.date_filter %}))
                 when (idle_start <= entry and idle_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end asset_geofence_time_utilization.date_filter %}::timestamp_ntz)) then TIMESTAMPDIFF(seconds, entry, convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end date_filter %}))
                 when (idle_start <= entry and idle_end < coalesce(exit,current_timestamp) and idle_end < convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end asset_geofence_time_utilization.date_filter %})) then TIMESTAMPDIFF(seconds, entry, idle_end)
                 when (idle_start > entry and idle_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end asset_geofence_time_utilization.date_filter %}) and exit is null) then TIMESTAMPDIFF(seconds, idle_start, convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end asset_geofence_time_utilization.date_filter %}))
                 when (idle_start > entry and idle_end > coalesce(exit,current_timestamp)) then TIMESTAMPDIFF(seconds, idle_start, convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end asset_geofence_time_utilization.date_filter %}::timestamp_ntz))
                 when (idle_start > entry and idle_end < coalesce(exit,current_timestamp) and idle_end < convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end asset_geofence_time_utilization.date_filter %})) then TIMESTAMPDIFF(seconds, idle_start, idle_end)
              end
             when convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_start asset_geofence_time_utilization.date_filter %}) > entry and (convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end asset_geofence_time_utilization.date_filter %}) <= coalesce(exit,current_timestamp)) then
              case when (idle_start <= entry and idle_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end asset_geofence_time_utilization.date_filter %}) and exit is null) then TIMESTAMPDIFF(seconds, convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_start asset_geofence_time_utilization.date_filter %}), convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end date_filter %}))
                 when (idle_start <= entry and idle_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end asset_geofence_time_utilization.date_filter %})) THEN TIMESTAMPDIFF(seconds, convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_start asset_geofence_time_utilization.date_filter %}),  convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end asset_geofence_time_utilization.date_filter %}))
                 when (idle_start <= entry and idle_end < coalesce(exit,current_timestamp) and idle_end < convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end asset_geofence_time_utilization.date_filter %}::timestamp_ntz)) then TIMESTAMPDIFF(seconds, idle_start, idle_end)
                 when (idle_start > entry and idle_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end asset_geofence_time_utilization.date_filter %}) and exit is null) then TIMESTAMPDIFF(seconds, idle_start, convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end asset_geofence_time_utilization.date_filter %}))
                 when (idle_start > entry and idle_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end asset_geofence_time_utilization.date_filter %}) and idle_end > coalesce(exit,current_timestamp)) then TIMESTAMPDIFF(seconds, idle_start, convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end asset_geofence_time_utilization.date_filter %}))
                 when (idle_start > entry and idle_end < coalesce(exit,convert_timezone('{{ _user_attributes['user_timezone'] }}',current_timestamp)) and idle_end < convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end asset_geofence_time_utilization.date_filter %})) then TIMESTAMPDIFF(seconds, idle_start, idle_end)
              end
            end as geofence_idle_seconds
        from
          geofence_time gt
          inner join idle_data id on gt.asset_id = id.asset_id
              and overlaps(
                idle_start,
                idle_end,
                entry,
                coalesce(exit,current_timestamp)
              )
          inner join geofences g on gt.geofence_id = g.geofence_id
 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: geofence_id {
    type: number
    sql: ${TABLE}."GEOFENCE_ID" ;;
  }

  dimension_group: idle_start {
    type: time
    sql: ${TABLE}."IDLE_START" ;;
    html: {{ rendered_value | date: "%b %d, %Y %r  "  }} {{ _user_attributes['user_timezone_label'] }};;
  }

  dimension_group: idle_end {
    type: time
    sql: ${TABLE}."IDLE_END" ;;
    html: {{ rendered_value | date: "%b %d, %Y %r  "  }} {{ _user_attributes['user_timezone_label'] }};;
  }

  dimension: geofence_idle_seconds {
    type: number
    sql: ${TABLE}."GEOFENCE_IDLE_SECONDS" ;;
    value_format_name: decimal_2
  }

  dimension: geofence_name {
    type: string
    sql: ${TABLE}."GEOFENCE_NAME" ;;
  }

  dimension: geofence_idle_time {
    type: number
    sql: ${geofence_idle_seconds}/3600 ;;
    value_format_name: decimal_2
    html: {{rendered_value}} hrs. ;;
  }

  filter: date_filter {
    type: date_time
  }

  set: detail {
    fields: [asset_id, geofence_id, idle_start_time, idle_end_time, geofence_idle_seconds]
  }
}
