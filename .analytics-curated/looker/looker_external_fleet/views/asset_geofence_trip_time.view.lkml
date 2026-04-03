view: asset_geofence_trip_time {
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
          g.name as geofence_name,
          convert_timezone('{{ _user_attributes['user_timezone'] }}',ge.encounter_start_timestamp) as entry,
          convert_timezone('{{ _user_attributes['user_timezone'] }}',ge.encounter_end_timestamp) as exit,
          ge.start_odometer,
          ge.end_odometer,
          case when ge.encounter_start_timestamp  < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start asset_geofence_time_utilization.date_filter %}) and (ge.encounter_end_timestamp is null or ge.encounter_end_timestamp > convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %})) then TIMESTAMPDIFF(seconds,{% date_start date_filter %}, {% date_end asset_geofence_time_utilization.date_filter %})
               when ge.encounter_start_timestamp  < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start asset_geofence_time_utilization.date_filter %}) and ge.encounter_end_timestamp between convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start asset_geofence_time_utilization.date_filter %}) and convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %}) then TIMESTAMPDIFF(seconds, {% date_start asset_geofence_time_utilization.date_filter %}, ge.encounter_end_timestamp)
               when ge.encounter_start_timestamp >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start asset_geofence_time_utilization.date_filter %}) and ge.encounter_end_timestamp <=  convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %}) then TIMESTAMPDIFF(seconds, ge.encounter_start_timestamp, ge.encounter_end_timestamp)
               when ge.encounter_start_timestamp between convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start asset_geofence_time_utilization.date_filter %}) and convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %}) then
                  case when ge.encounter_end_timestamp is null then TIMESTAMPDIFF(seconds, ge.encounter_start_timestamp, {% date_end asset_geofence_time_utilization.date_filter %})
                     when convert_timezone('{{ _user_attributes['user_timezone'] }}',ge.encounter_end_timestamp) >  {% date_end asset_geofence_time_utilization.date_filter %} then TIMESTAMPDIFF(seconds, ge.encounter_start_timestamp, {% date_end asset_geofence_time_utilization.date_filter %})
                   end
                   else TIMESTAMPDIFF(seconds, ge.encounter_start_timestamp, ge.encounter_end_timestamp)
              end as geo_seconds
        from
          asset_geofence_encounters ge
          join geofences g on ge.geofence_id = g.geofence_id
          join owned_rented_assets o on o.asset_id = ge.asset_id
        where
          g.company_id = {{ _user_attributes['company_id'] }}::numeric
          and ge.encounter_start_timestamp < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %})
          and (
                ge.encounter_end_timestamp > convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start asset_geofence_time_utilization.date_filter %})
                or ge.encounter_end_timestamp is null
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
            t.start_timestamp < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %})
            and (
                  t.end_timestamp > convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start asset_geofence_time_utilization.date_filter %})
                  or t.end_timestamp is null
                )
            and t.trip_type_id in (1,2,5,7)
            and coalesce(t.end_timestamp, current_timestamp) <= dateadd(second, 604800, t.start_timestamp)


        )

        select
          distinct gd.asset_id,
          gd.geofence_id,
          gd.geofence_name,
          td.trip_start,
          td.trip_end,
          case when convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start asset_geofence_time_utilization.date_filter %}) < entry and convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %}) > coalesce(exit,current_timestamp) then
          case when (trip_start <= entry and trip_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %}) and exit is null) then TIMESTAMPDIFF(seconds, entry, {% date_end asset_geofence_time_utilization.date_filter %})
             when (trip_start <= entry and (trip_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %}::timestamp_ntz) or trip_end >= coalesce(exit,current_timestamp))) then TIMESTAMPDIFF(seconds, entry, coalesce(exit,current_timestamp))
             when (trip_start <= entry and trip_end < coalesce(exit,current_timestamp) and trip_end < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %})) then TIMESTAMPDIFF(seconds, entry, trip_end)
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
               when (trip_start > entry and trip_end < coalesce(exit,current_timestamp)) then TIMESTAMPDIFF(seconds,trip_start, trip_end)
               when (trip_start > entry and trip_end > coalesce(exit,current_timestamp)) then TIMESTAMPDIFF(seconds,trip_start, coalesce(exit, convert_timezone('{{ _user_attributes['user_timezone'] }}',current_timestamp)))
            end
           when convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start asset_geofence_time_utilization.date_filter %}) > entry and (convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %}) <= coalesce(exit,current_timestamp)) then
            case when (trip_start <= entry and trip_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %}) and exit is null) then TIMESTAMPDIFF(seconds, {% date_start date_filter %}, {% date_end asset_geofence_time_utilization.date_filter %})
               when (trip_start <= entry and trip_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %})) then TIMESTAMPDIFF(seconds, {% date_start date_filter %}, {% date_end asset_geofence_time_utilization.date_filter %})
               when (trip_start <= entry and trip_end < coalesce(exit,current_timestamp) and trip_end < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %})) then TIMESTAMPDIFF(seconds, {% date_start asset_geofence_time_utilization.date_filter %}, trip_end)
               when (trip_start > entry and trip_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %}) and trip_end > exit) then TIMESTAMPDIFF(seconds,trip_start, {% date_end asset_geofence_time_utilization.date_filter %})
               when (trip_start > entry and trip_end < coalesce(exit,current_timestamp) and trip_start >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start asset_geofence_time_utilization.date_filter %}) and trip_end <= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %})) then TIMESTAMPDIFF(seconds,trip_start, trip_end)
               when (trip_start > entry and trip_end < coalesce(exit,current_timestamp) and trip_end > convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %}::timestamp_ntz)) then TIMESTAMPDIFF(seconds,trip_start, {% date_end asset_geofence_time_utilization.date_filter %}::timestamp_ntz)
               when (trip_start > entry and trip_end < coalesce(exit,current_timestamp)) then TIMESTAMPDIFF(seconds,{% date_start date_filter %}, trip_end)
            end
      end as geo_trip_seconds --ends up being run time in geofence
        from
          geo_duration gd
          join trip_data td on gd.asset_id = td.asset_id
         and td.trip_start < coalesce(gd.exit, current_timestamp)
         and td.trip_end > gd.entry

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

  dimension: geofence_name {
    type: string
    sql: ${TABLE}."GEOFENCE_NAME" ;;
  }

  dimension_group: trip_start {
    type: time
    sql: ${TABLE}."TRIP_START" ;;
    html: {{ rendered_value | date: "%b %d, %Y %r  "  }} {{ _user_attributes['user_timezone_label'] }};;
  }

  dimension_group: trip_end {
    type: time
    sql: ${TABLE}."TRIP_END" ;;
    html: {{ rendered_value | date: "%b %d, %Y %r  "  }} {{ _user_attributes['user_timezone_label'] }};;
  }

  dimension: geo_trip_seconds {
    type: number
    sql: coalesce(${TABLE}."GEO_TRIP_SECONDS",0) ;;
  }

  dimension: geofence_trip_duration {
    type: number
    sql: ${geo_trip_seconds}/3600 ;;
    value_format_name: decimal_2
    html: {{rendered_value}} hrs. ;;
  }

  dimension: trip_length {
    type: string
    sql:to_char(${geo_trip_seconds}::timestamp,'HH24:MI:SS') ;;
  }

  filter: date_filter {
    type: date_time
  }

  set: detail {
    fields: [
      asset_id,
      geofence_id,
      geofence_name,
      trip_start_time,
      trip_end_time,
      geo_trip_seconds
    ]
  }
}
