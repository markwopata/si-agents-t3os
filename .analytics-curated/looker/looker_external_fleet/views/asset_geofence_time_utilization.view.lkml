view: asset_geofence_time_utilization {
  derived_table: {
    sql: with owned_assets as (
          select asset_id
          from table(assetlist({{ _user_attributes['user_id'] }}::numeric))
          )
          , rented_assets as (
          select rl.asset_id, start_date::date as start_date, end_date::date as end_date
          from table(rental_asset_list({{ _user_attributes['user_id'] }}::numeric,
          convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %}),
          convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %}),
          ('{{ _user_attributes['user_timezone'] }}'))) rl
          join assets a on a.asset_id = rl.asset_id
          where
          a.company_id <> {{ _user_attributes['company_id'] }}
         )
        , geo_duration as (
        select
          distinct
          ge.asset_id,
          g.geofence_id,
          convert_timezone('{{ _user_attributes['user_timezone'] }}',ge.encounter_start_timestamp) as entry,
          convert_timezone('{{ _user_attributes['user_timezone'] }}',ge.encounter_end_timestamp) as exit,

           case
              when ge.start_odometer <= IFNULL(ge.end_odometer,ge.start_odometer) then ge.start_odometer
              when ge.start_odometer > IFNULL(ge.end_odometer,ge.start_odometer) then ge.end_odometer
              end as start_odometer,
          case
              when IFNULL(ge.end_odometer,ge.start_odometer) >= ge.start_odometer then IFNULL(ge.end_odometer,ge.start_odometer)
              when IFNULL(ge.end_odometer,ge.start_odometer) < ge.start_odometer then ge.start_odometer
              end as end_odometer,

          case when ge.encounter_start_timestamp  < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %}) and (ge.encounter_end_timestamp is null or convert_timezone('{{ _user_attributes['user_timezone'] }}',ge.encounter_end_timestamp) > convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %})) then TIMESTAMPDIFF(seconds,{% date_start date_filter %}, {% date_end date_filter %})
               when ge.encounter_start_timestamp  < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %}) and convert_timezone('{{ _user_attributes['user_timezone'] }}',ge.encounter_end_timestamp) between convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %}) and convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %}) then TIMESTAMPDIFF(seconds, {% date_start date_filter %}, ge.encounter_end_timestamp)
               when ge.encounter_start_timestamp >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %}) and convert_timezone('{{ _user_attributes['user_timezone'] }}',ge.encounter_end_timestamp) <=  convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %}) then TIMESTAMPDIFF(seconds, ge.encounter_start_timestamp, ge.encounter_end_timestamp)
               when ge.encounter_start_timestamp between convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %}) and convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %}) then
                  case when ge.encounter_end_timestamp is null then TIMESTAMPDIFF(seconds, ge.encounter_start_timestamp, {% date_end date_filter %})
                     when convert_timezone('{{ _user_attributes['user_timezone'] }}',ge.encounter_end_timestamp) >  {% date_end date_filter %} then TIMESTAMPDIFF(seconds, ge.encounter_start_timestamp, {% date_end date_filter %})
                   end
                   else TIMESTAMPDIFF(seconds, ge.encounter_start_timestamp, ge.encounter_end_timestamp)
              end as geo_seconds
        from
          owned_assets o
          left join asset_geofence_encounters ge on o.asset_id = ge.asset_id
          join geofences g on ge.geofence_id = g.geofence_id
        where
          g.company_id = {{ _user_attributes['company_id'] }}::numeric
          and ge.encounter_start_timestamp < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %})
          and coalesce(ge.encounter_end_timestamp, current_timestamp) > convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %})

        union
        select
          distinct
          ge.asset_id,
          g.geofence_id,
          convert_timezone('{{ _user_attributes['user_timezone'] }}',ge.encounter_start_timestamp) as entry,
          convert_timezone('{{ _user_attributes['user_timezone'] }}',ge.encounter_end_timestamp) as exit,

          case
              when ge.start_odometer <= IFNULL(ge.end_odometer,ge.start_odometer) then ge.start_odometer
              when ge.start_odometer > IFNULL(ge.end_odometer,ge.start_odometer) then ge.end_odometer
              end as start_odometer,
          case
              when IFNULL(ge.end_odometer,ge.start_odometer) >= ge.start_odometer then IFNULL(ge.end_odometer,ge.start_odometer)
              when IFNULL(ge.end_odometer,ge.start_odometer) < ge.start_odometer then ge.start_odometer
              end as end_odometer,

          case when ge.encounter_start_timestamp  < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %}) and (ge.encounter_end_timestamp is null or convert_timezone('{{ _user_attributes['user_timezone'] }}',ge.encounter_end_timestamp) > convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %})) then TIMESTAMPDIFF(seconds,{% date_start date_filter %}, {% date_end date_filter %})
               when ge.encounter_start_timestamp  < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %}) and convert_timezone('{{ _user_attributes['user_timezone'] }}',ge.encounter_end_timestamp) between convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %}) and convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %}) then TIMESTAMPDIFF(seconds, {% date_start date_filter %}, ge.encounter_end_timestamp)
               when ge.encounter_start_timestamp >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %}) and convert_timezone('{{ _user_attributes['user_timezone'] }}',ge.encounter_end_timestamp) <=  convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %}) then TIMESTAMPDIFF(seconds, ge.encounter_start_timestamp, ge.encounter_end_timestamp)
               when ge.encounter_start_timestamp between convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %}) and convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %}) then
                  case when ge.encounter_end_timestamp is null then TIMESTAMPDIFF(seconds, ge.encounter_start_timestamp, {% date_end date_filter %})
                     when convert_timezone('{{ _user_attributes['user_timezone'] }}',ge.encounter_end_timestamp) >  {% date_end date_filter %} then TIMESTAMPDIFF(seconds, ge.encounter_start_timestamp, {% date_end date_filter %})
                   end
                   else TIMESTAMPDIFF(seconds, ge.encounter_start_timestamp, ge.encounter_end_timestamp)
              end as geo_seconds
        from
          rented_assets o
          left join asset_geofence_encounters ge on o.asset_id = ge.asset_id
          AND ge.encounter_end_timestamp
          between convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %})
          AND coalesce(convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %}),current_timestamp)

          join geofences g on ge.geofence_id = g.geofence_id
        where
          g.company_id = {{ _user_attributes['company_id'] }}::numeric
          and ge.encounter_start_timestamp < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %})
          and coalesce(ge.encounter_end_timestamp, current_timestamp) > convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %})

        )
        , owned_trip_data as (
        select
          DISTINCT
          t.trip_id,
          t.asset_id,
          case when convert_timezone('{{ _user_attributes['user_timezone'] }}',t.start_timestamp) < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %}) then convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %}) else convert_timezone('{{ _user_attributes['user_timezone'] }}',t.start_timestamp) end as trip_start,
          convert_timezone('{{ _user_attributes['user_timezone'] }}',coalesce(t.end_timestamp, current_timestamp)) as trip_end
        from
          owned_assets o
          join trips t on o.asset_id=t.asset_id
        where
          convert_timezone('{{ _user_attributes['user_timezone'] }}', t.start_timestamp) < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %})
          and convert_timezone('{{ _user_attributes['user_timezone'] }}', coalesce(t.end_timestamp, current_timestamp)) > convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %})
          and TIMESTAMPDIFF(seconds, t.start_timestamp, coalesce(t.end_timestamp, current_timestamp)) <= 604800
          and t.trip_type_id in (1, 2, 5, 7)

        )
        , rental_trip_data as (
        select
          DISTINCT
          t.trip_id,
          t.asset_id,
          case when convert_timezone('{{ _user_attributes['user_timezone'] }}',t.start_timestamp) < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %}) then convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %}) else convert_timezone('{{ _user_attributes['user_timezone'] }}',t.start_timestamp) end as trip_start,
          convert_timezone('{{ _user_attributes['user_timezone'] }}',coalesce(t.end_timestamp, current_timestamp)) as trip_end
        from
          rented_assets r
          join trips t on r.asset_id=t.asset_id AND r.start_date::date <= t.start_timestamp::date AND r.end_date::date >= coalesce(t.end_timestamp, current_timestamp)
        where
          convert_timezone('{{ _user_attributes['user_timezone'] }}', t.start_timestamp) < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %})
          and convert_timezone('{{ _user_attributes['user_timezone'] }}', coalesce(t.end_timestamp, current_timestamp)) > convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %})
          and TIMESTAMPDIFF(seconds, t.start_timestamp, coalesce(t.end_timestamp, current_timestamp)) <= 604800
          and t.trip_type_id in (1, 2, 5, 7)

        )
        , geo_trip_join as (
        select
          distinct gd.asset_id,
          gd.geofence_id,
          gd.entry,
          gd.exit,
          gd.geo_seconds,
          gd.start_odometer,
          gd.end_odometer,
          gd.end_odometer - gd.start_odometer as miles_driven,
          td.trip_start,
          td.trip_end,
          case when convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %}) < entry and convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %}) > coalesce(exit,current_timestamp) then
          case when (trip_start <= entry and trip_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %}) and exit is null) then TIMESTAMPDIFF(seconds, entry, {% date_end date_filter %})
             when (trip_start <= entry and (trip_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %}) or trip_end >= coalesce(exit,current_timestamp))) then TIMESTAMPDIFF(seconds, entry, coalesce(exit,current_timestamp))
             when (trip_start <= entry and trip_end < coalesce(exit,convert_timezone('{{ _user_attributes['user_timezone'] }}',current_timestamp)) and trip_end < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %})) then TIMESTAMPDIFF(seconds, entry, trip_end)
             when (trip_start > entry and trip_end > coalesce(exit,current_timestamp)) then TIMESTAMPDIFF(seconds, trip_start, coalesce(exit,current_timestamp))
             when (trip_start > entry and trip_end < coalesce(exit,current_timestamp)) then TIMESTAMPDIFF(seconds, trip_start, trip_end)
          end
           when convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %}) > entry and (convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %}) > coalesce(exit,current_timestamp)) then
            case when (trip_start <= entry and trip_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %}) and exit is null) then TIMESTAMPDIFF(seconds, {% date_start date_filter %}, {% date_end date_filter %})
               when (trip_start <= entry and (trip_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %}) or trip_end >= exit)) then TIMESTAMPDIFF(seconds, {% date_start date_filter %}, exit)
               when (trip_start < entry and trip_end < coalesce(exit,current_timestamp) and trip_end < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %})) then TIMESTAMPDIFF(seconds, convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %}), trip_end)
               when (trip_start > entry and trip_end > coalesce(exit,current_timestamp)) then TIMESTAMPDIFF(seconds, trip_start, coalesce(exit,current_timestamp))
               when (trip_start > entry and trip_end < coalesce(exit,current_timestamp)) then TIMESTAMPDIFF(seconds, trip_start, trip_end)
            end
           when convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %}) <= entry and (convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %}) <= coalesce(exit,current_timestamp)) then
            case when (trip_start <= entry and trip_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %}) and exit is null) then TIMESTAMPDIFF(seconds, entry, {% date_end date_filter %})
               when (trip_start <= entry and trip_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %})) then TIMESTAMPDIFF(seconds, entry, {% date_end date_filter %})
               when (trip_start <= entry and trip_end < coalesce(exit,current_timestamp) and trip_end < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %})) then TIMESTAMPDIFF(seconds, entry, trip_end)
               when (trip_start > entry and trip_end < coalesce(exit,convert_timezone('{{ _user_attributes['user_timezone'] }}',current_timestamp))) then TIMESTAMPDIFF(seconds,trip_start, trip_end)
               when (trip_start > entry and trip_end > coalesce(exit,current_timestamp)) then TIMESTAMPDIFF(seconds,trip_start, coalesce(exit, convert_timezone('{{ _user_attributes['user_timezone'] }}',current_timestamp)))
            end
           when convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %}) > entry and (convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %}) <= coalesce(exit,current_timestamp)) then
            case when (trip_start <= entry and trip_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %}) and exit is null) then TIMESTAMPDIFF(seconds, {% date_start date_filter %}, {% date_end date_filter %})
               when (trip_start <= entry and trip_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %})) then TIMESTAMPDIFF(seconds, {% date_start date_filter %}, {% date_end date_filter %})
               when (trip_start <= entry and trip_end < coalesce(exit,current_timestamp) and trip_end < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %})) then TIMESTAMPDIFF(seconds, {% date_start date_filter %}, trip_end)
               when (trip_start > entry and trip_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %}) and trip_end > exit) then TIMESTAMPDIFF(seconds,trip_start, {% date_end date_filter %})
               when (trip_start > entry and trip_end < coalesce(exit,current_timestamp) and trip_start >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %}) and trip_end <= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %})) then TIMESTAMPDIFF(seconds,trip_start, trip_end)
               when (trip_start > entry and trip_end < coalesce(exit,current_timestamp) and trip_end > convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %})) then TIMESTAMPDIFF(seconds,trip_start, {% date_end date_filter %})
               when (trip_start > entry and trip_end < coalesce(exit,current_timestamp)) then TIMESTAMPDIFF(seconds,{% date_start date_filter %}, trip_end)
            end
      end as geo_trip_seconds --ends up being run time in geofence
        from
         geo_duration gd
         left join owned_trip_data td on gd.asset_id = td.asset_id
         and td.trip_start < coalesce(gd.exit, current_timestamp)
         and td.trip_end > gd.entry

      UNION
      select
          distinct gd.asset_id,
          gd.geofence_id,
          gd.entry,
          gd.exit,
          gd.geo_seconds,
          gd.start_odometer,
          gd.end_odometer,
          gd.end_odometer - gd.start_odometer as miles_driven,
          td.trip_start,
          td.trip_end,
          case when convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %}) < entry and convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %}) > coalesce(exit,current_timestamp) then
          case when (trip_start <= entry and trip_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %}) and exit is null) then TIMESTAMPDIFF(seconds, entry, {% date_end date_filter %})
             when (trip_start <= entry and (trip_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %}) or trip_end >= coalesce(exit,current_timestamp))) then TIMESTAMPDIFF(seconds, entry, coalesce(exit,current_timestamp))
             when (trip_start <= entry and trip_end < coalesce(exit,convert_timezone('{{ _user_attributes['user_timezone'] }}',current_timestamp)) and trip_end < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %})) then TIMESTAMPDIFF(seconds, entry, trip_end)
             when (trip_start > entry and trip_end > coalesce(exit,current_timestamp)) then TIMESTAMPDIFF(seconds, trip_start, coalesce(exit,current_timestamp))
             when (trip_start > entry and trip_end < coalesce(exit,current_timestamp)) then TIMESTAMPDIFF(seconds, trip_start, trip_end)
          end
           when convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %}) > entry and (convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %}) > coalesce(exit,current_timestamp)) then
            case when (trip_start <= entry and trip_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %}) and exit is null) then TIMESTAMPDIFF(seconds, {% date_start date_filter %}, {% date_end date_filter %})
               when (trip_start <= entry and (trip_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %}) or trip_end >= exit)) then TIMESTAMPDIFF(seconds, {% date_start date_filter %}, exit)
               when (trip_start < entry and trip_end < coalesce(exit,current_timestamp) and trip_end < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %})) then TIMESTAMPDIFF(seconds, convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %}), trip_end)
               when (trip_start > entry and trip_end > coalesce(exit,current_timestamp)) then TIMESTAMPDIFF(seconds, trip_start, coalesce(exit,current_timestamp))
               when (trip_start > entry and trip_end < coalesce(exit,current_timestamp)) then TIMESTAMPDIFF(seconds, trip_start, trip_end)
            end
           when convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %}) <= entry and (convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %}) <= coalesce(exit,current_timestamp)) then
            case when (trip_start <= entry and trip_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %}) and exit is null) then TIMESTAMPDIFF(seconds, entry, {% date_end date_filter %})
               when (trip_start <= entry and trip_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %})) then TIMESTAMPDIFF(seconds, entry, {% date_end date_filter %})
               when (trip_start <= entry and trip_end < coalesce(exit,current_timestamp) and trip_end < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %})) then TIMESTAMPDIFF(seconds, entry, trip_end)
               when (trip_start > entry and trip_end < coalesce(exit,convert_timezone('{{ _user_attributes['user_timezone'] }}',current_timestamp))) then TIMESTAMPDIFF(seconds,trip_start, trip_end)
               when (trip_start > entry and trip_end > coalesce(exit,current_timestamp)) then TIMESTAMPDIFF(seconds,trip_start, coalesce(exit, convert_timezone('{{ _user_attributes['user_timezone'] }}',current_timestamp)))
            end
           when convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %}) > entry and (convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %}) <= coalesce(exit,current_timestamp)) then
            case when (trip_start <= entry and trip_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %}) and exit is null) then TIMESTAMPDIFF(seconds, {% date_start date_filter %}, {% date_end date_filter %})
               when (trip_start <= entry and trip_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %})) then TIMESTAMPDIFF(seconds, {% date_start date_filter %}, {% date_end date_filter %})
               when (trip_start <= entry and trip_end < coalesce(exit,current_timestamp) and trip_end < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %})) then TIMESTAMPDIFF(seconds, {% date_start date_filter %}, trip_end)
               when (trip_start > entry and trip_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %}) and trip_end > exit) then TIMESTAMPDIFF(seconds,trip_start, {% date_end date_filter %})
               when (trip_start > entry and trip_end < coalesce(exit,current_timestamp) and trip_start >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %}) and trip_end <= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %})) then TIMESTAMPDIFF(seconds,trip_start, trip_end)
               when (trip_start > entry and trip_end < coalesce(exit,current_timestamp) and trip_end > convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %})) then TIMESTAMPDIFF(seconds,trip_start, {% date_end date_filter %})
               when (trip_start > entry and trip_end < coalesce(exit,current_timestamp)) then TIMESTAMPDIFF(seconds,{% date_start date_filter %}, trip_end)
            end
      end as geo_trip_seconds --ends up being run time in geofence
        from
          geo_duration gd
          left join rental_trip_data td on gd.asset_id = td.asset_id
          and td.trip_start < coalesce(gd.exit, current_timestamp)
          and td.trip_end > gd.entry

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
        group by
          asset_id,
          geofence_id,
          entry,
          exit,
          geo_seconds
        )
        , miles_driven_data as (
        select
        gd.asset_id,
        gd.geofence_id,
        sum(gd.end_odometer - gd.start_odometer) as miles_driven_in_geofence
        from geo_duration gd
        group by
        gd.asset_id,
        gd.geofence_id
        )
        , date_series as (
        select
          series::date as day
        from table
          (generate_series(
          {% date_start date_filter %}::timestamp_tz,
          {% date_end date_filter %}::timestamp_tz,
          'day')
        )
        )
        , idle_data as (
          select
             distinct
             i.asset_id,
             start_timestamp as idle_start,
             end_timestamp as idle_end,
             duration_seconds as idle_seconds
          from
            owned_assets oa
            join asset_idles i on oa.asset_id = i.asset_id
            join geo_duration g on g.asset_id=i.asset_id
          where
            i.start_timestamp < convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end date_filter %})
            and coalesce(i.end_timestamp, current_timestamp) > convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_start date_filter %})
        UNION
        select
             distinct
             i.asset_id,
             start_timestamp as idle_start,
             end_timestamp as idle_end,
             duration_seconds as idle_seconds
          from
            rented_assets ra
            join asset_idles i on ra.asset_id = i.asset_id AND ra.start_date::date <= i.start_timestamp::date AND ra.end_date::date >= coalesce(i.end_timestamp, current_timestamp)
            join geo_duration g on g.asset_id = i.asset_id
          where
            i.start_timestamp < convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end date_filter %})
            and coalesce(i.end_timestamp, current_timestamp) > convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_start date_filter %})
        )
        , geo_idles_join as (
        select distinct
          gt.asset_id,
          gt.geofence_id,
          gt.entry,
          gt.exit,
          time_in_geofence,
          gt.run_time_in_geofence,
          id.idle_start,
          id.idle_end,
          id.idle_seconds,
          case when convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_start date_filter %}) < entry and convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end date_filter %}) > coalesce(exit,current_timestamp) then
            case when (idle_start <= entry and idle_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end date_filter %}) and exit is null) then TIMESTAMPDIFF(seconds, entry, convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end date_filter %}))
               when (idle_start <= entry and idle_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end date_filter %})) or idle_end >= coalesce(exit,current_timestamp) then TIMESTAMPDIFF(seconds, idle_start, coalesce(idle_end,current_timestamp))
               when (idle_start <= entry and idle_end < coalesce(exit,convert_timezone('{{ _user_attributes['user_timezone'] }}',current_timestamp)) and idle_end < convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end date_filter %})) then TIMESTAMPDIFF(seconds, entry, idle_end)
               when (idle_start > entry and idle_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end date_filter %}) and exit is null) then TIMESTAMPDIFF(seconds, idle_start, convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end date_filter %}))
               when (idle_start > entry and idle_end > coalesce(exit,current_timestamp)) then TIMESTAMPDIFF(seconds, idle_start, exit)
               when (idle_start > entry and idle_end < coalesce(exit,current_timestamp) and idle_end < convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end date_filter %})) then TIMESTAMPDIFF(seconds,idle_start, idle_end)
            end
             when convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_start date_filter %}) > entry and convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end date_filter %}) > coalesce(exit,current_timestamp) then
              case when (idle_start <= entry and idle_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end date_filter %}) and exit is null) then TIMESTAMPDIFF(seconds,convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_start date_filter %}), convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end date_filter %}))
                 when (idle_start <= entry and idle_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end date_filter %})) or idle_end >= coalesce(exit,current_timestamp) then TIMESTAMPDIFF(seconds, convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_start date_filter %}), coalesce(exit,current_timestamp))
                 when (idle_start <= entry and idle_end < coalesce(exit,convert_timezone('{{ _user_attributes['user_timezone'] }}',current_timestamp)) and idle_end < convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end date_filter %})) then TIMESTAMPDIFF(seconds,convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_start date_filter %}), idle_end)
                 when (idle_start > entry and idle_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end date_filter %}) and exit is null) then TIMESTAMPDIFF(seconds, idle_start, convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end date_filter %}))
                 when (idle_start > entry and idle_end > coalesce(exit,current_timestamp)) then TIMESTAMPDIFF(seconds, idle_start, exit)
                 when (idle_start > entry and idle_end < coalesce(exit,current_timestamp) and idle_end < convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end date_filter %})) then TIMESTAMPDIFF(seconds, idle_start, idle_end)
              end
             when convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_start date_filter %}) <= entry and convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end date_filter %}) <= coalesce(exit,current_timestamp) then
              case when (idle_start <= entry and idle_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end date_filter %}) and exit is null) then TIMESTAMPDIFF(seconds, entry, convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end date_filter %}))
                 when (idle_start <= entry and idle_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end date_filter %})) then TIMESTAMPDIFF(seconds, entry, convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end date_filter %}))
                 when (idle_start <= entry and idle_end < coalesce(exit,current_timestamp) and idle_end < convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end date_filter %})) then TIMESTAMPDIFF(seconds, entry, idle_end)
                 when (idle_start > entry and idle_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end date_filter %}) and exit is null) then TIMESTAMPDIFF(seconds, idle_start, convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end date_filter %}))
                 when (idle_start > entry and idle_end > coalesce(exit,current_timestamp)) then TIMESTAMPDIFF(seconds, idle_start, convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end date_filter %}))
                 when (idle_start > entry and idle_end < coalesce(exit,current_timestamp) and idle_end < convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end date_filter %})) then TIMESTAMPDIFF(seconds, idle_start, idle_end)
              end
             when convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_start date_filter %}) > entry and (convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end date_filter %}) <= coalesce(exit,current_timestamp)) then
              case when (idle_start <= entry and idle_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end date_filter %}) and exit is null) then TIMESTAMPDIFF(seconds, convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_start date_filter %}), convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end date_filter %}))
                 when (idle_start <= entry and idle_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end date_filter %})) THEN TIMESTAMPDIFF(seconds, convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_start date_filter %}),  convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end date_filter %}))
                 when (idle_start <= entry and idle_end < coalesce(exit,current_timestamp) and idle_end < convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end date_filter %})) then TIMESTAMPDIFF(seconds, idle_start, idle_end)
                 when (idle_start > entry and idle_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end date_filter %}) and exit is null) then TIMESTAMPDIFF(seconds, idle_start, convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end date_filter %}))
                 when (idle_start > entry and idle_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end date_filter %}) and idle_end > coalesce(exit,current_timestamp)) then TIMESTAMPDIFF(seconds, idle_start, convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end date_filter %}))
                 when (idle_start > entry and idle_end < coalesce(exit,convert_timezone('{{ _user_attributes['user_timezone'] }}',current_timestamp)) and idle_end < convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end date_filter %})) then TIMESTAMPDIFF(seconds, idle_start, idle_end)
              end
            end as geo_idle_seconds
        from
          geofence_time gt
          left join idle_data id on gt.asset_id = id.asset_id
              and idle_start < coalesce(exit, current_timestamp)
              and coalesce(idle_end, current_timestamp) > entry

        )
        , summarize_idle_time as (
        select
          asset_id,
          geofence_id,
          coalesce(sum(geo_idle_seconds/3600), 0) as geofence_idle_hrs
        from
          geo_idles_join
        group by
          asset_id,
          geofence_id
        )
        ,total_run_time as (
        select
            al.asset_id,
            sum(on_time)/3600 as total_on_time
        from
            owned_assets al
            inner join es_warehouse.public.hourly_asset_usage hau on al.asset_id = hau.asset_id
        where
            report_range:start_range >= COALESCE(convert_timezone('UTC', {% date_start date_filter %}),convert_timezone('{{ _user_attributes['user_timezone'] }}', 'UTC', current_date - interval '10 days'))
            AND report_range:end_range <= COALESCE(convert_timezone('UTC', {% date_end date_filter %}),convert_timezone('{{ _user_attributes['user_timezone'] }}', 'UTC', current_date))
        group by
            al.asset_id
        UNION
        select
            alr.asset_id,
            sum(on_time)/3600 as total_on_time
        from
            rented_assets alr
            inner join es_warehouse.public.hourly_asset_usage hau on alr.asset_id = hau.asset_id and hau.report_range:start_range >= alr.start_date AND hau.report_range:end_range <= alr.end_date
        where
            report_range:start_range >= COALESCE(convert_timezone('UTC', {% date_start date_filter %}),convert_timezone('{{ _user_attributes['user_timezone'] }}', 'UTC', current_date - interval '10 days'))
            AND report_range:end_range <= COALESCE(convert_timezone('UTC', {% date_end date_filter %}),convert_timezone('{{ _user_attributes['user_timezone'] }}', 'UTC', current_date))
        group by
            alr.asset_id
        )
        , geo_timeframes as (
        select
        distinct
          day,
          asset_id,
          geofence_id,
          case when entry < {% date_start date_filter %} then {% date_start date_filter %}::datetime else entry::datetime end as modified_start,
          case when exit > {% date_end date_filter %} then {% date_end date_filter %}::datetime
              when exit is null then {% date_end date_filter %}::datetime
          else exit::datetime end
          as modified_end
        from
          date_series ds
          inner join geo_duration gd on ds.day BETWEEN gd.entry::date AND coalesce(gd.exit::date, case when {% date_end date_filter %}::date >= current_date then current_timestamp::date else {% date_end date_filter %}::date end)::date

        )
        , geo_run as (

         select
          asset_id,
          geofence_id,
          sum(time_in_geofence) as time_in_geofence,
          sum(run_time_in_geofence) as run_time_in_geofence
        from
          geofence_time
        group by
          asset_id,
          geofence_id
        )
        select
          gtf.asset_id,
          gtf.geofence_id,
          min(gtf.modified_start)::datetime as first_geofence_entry_time,
          max(gtf.modified_end)::datetime as last_geofence_exit_time,
          gtime.time_in_geofence,
          coalesce(gtime.run_time_in_geofence,0) as run_time_in_geofence,
          coalesce(md.miles_driven_in_geofence,0) as miles_driven_in_geofence,
          count(distinct(day)) as distinct_days_in_geofence,
          it.geofence_idle_hrs,
          trt.total_on_time,
          datediff(day,{% date_start date_filter %},{% date_end date_filter %})+1 as datediff
        from
          geo_timeframes gtf
          left join geo_run gtime on gtime.asset_id = gtf.asset_id and gtime.geofence_id = gtf.geofence_id
          left join summarize_idle_time it on it.asset_id = gtime.asset_id and it.geofence_id = gtime.geofence_id
          left join miles_driven_data md on md.asset_id = gtime.asset_id and md.geofence_id = gtime.geofence_id
          left join total_run_time trt on trt.asset_id = gtf.asset_id
        group by
          gtf.asset_id,
          gtf.geofence_id,
          gtime.time_in_geofence,
          gtime.run_time_in_geofence,
          md.miles_driven_in_geofence,
          it.geofence_idle_hrs,
          trt.total_on_time
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: first_geofence_entry_time {
    type: date_time
    sql: ${TABLE}."FIRST_GEOFENCE_ENTRY_TIME" ;;
    html: {{ rendered_value | date: "%b %d, %Y %r  "  }} {{ _user_attributes['user_timezone_label'] }};;
  }

  dimension: last_geofence_exit_time {
    type: date_time
    sql: coalesce(${TABLE}."LAST_GEOFENCE_EXIT_TIME", ${date_fill}) ;;
    html: {{ rendered_value | date: "%b %d, %Y %r  "  }} {{ _user_attributes['user_timezone_label'] }};;
  }

  dimension: date_fill {
    type: date_time
    sql: case when {% date_end asset_geofence_time_utilization.date_filter %} <= current_date()
        then {% date_end asset_geofence_time_utilization.date_filter %}
        else current_date()
        end;;
  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(${asset_id},${geofence_id},${time_in_geofence}) ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: geofence_id {
    type: number
    sql: ${TABLE}."GEOFENCE_ID" ;;
  }

  dimension: time_in_geofence {
    type: number
    sql: ${TABLE}."TIME_IN_GEOFENCE" ;;
    value_format_name: decimal_2
  }

  dimension: run_time_in_geofence {
    type: number
    sql: ${TABLE}."RUN_TIME_IN_GEOFENCE" ;;
    value_format_name: decimal_2
  }

  dimension: miles_driven_in_geofence {
    type: number
    sql: ${TABLE}."MILES_DRIVEN_IN_GEOFENCE" ;;
    value_format_name: decimal_2
  }

  dimension: geofence_idle_hrs {
    type: number
    sql: ${TABLE}."GEOFENCE_IDLE_HRS" ;;
    value_format_name: decimal_2
  }

  dimension: total_on_time {
    type: number
    sql: ${TABLE}."TOTAL_ON_TIME" ;;
    value_format_name: decimal_2
  }

  dimension: distinct_days_in_geofence {
    type: number
    sql: ${TABLE}."DISTINCT_DAYS_IN_GEOFENCE" ;;
  }

  dimension: datediff {
    type: number
    sql: ${TABLE}."DATEDIFF" ;;
  }

  filter: date_filter {
    type: date_time
  }

  measure: summarize_days_in_geofence {
    type: sum
    sql: ${distinct_days_in_geofence} ;;
  }

  measure: summarize_date_filter_diff {
    type: sum
    sql: ${datediff} ;;
  }

  measure: days_not_in_geofence {
    type: number
    sql: ${datediff} - (case when ${distinct_days_in_geofence} > ${datediff} then ${datediff} else ${distinct_days_in_geofence} end )  ;;
  }

  measure: total_days_in_geofence {
    type: number
    sql: case when ${distinct_days_in_geofence} > ${datediff} then ${datediff} else ${distinct_days_in_geofence} end ;;
  }

  measure: total_hours_in_geofence {
    type: sum
    sql: ${time_in_geofence} ;;
    value_format_name: decimal_2
    html: <a href="#drillmenu" target="_self">{{rendered_value}} hrs.
    <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a>;;
    drill_fields: [entry_exit_detail*]
  }

  measure: total_hours_in_geofence_for_bar_chart {
    type: sum
    sql: ${time_in_geofence} ;;
    value_format_name: decimal_2
    drill_fields: [entry_exit_detail*]
    html: {{rendered_value}} hrs. ;;
  }

  measure: total_run_time_in_geofence {
    type: sum
    sql: ${run_time_in_geofence} ;;
    value_format_name: decimal_2
    html: <a href="#drillmenu" target="_self">{{rendered_value}} hrs.
    <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a>
    ;;
    drill_fields: [geo_run_detail*]
    description: "Total run time in a geofence during selected range. NOTE: Halued trips are excluded"
  }

  measure: total_miles_driven_in_geofence {
    type: sum
    sql: ${miles_driven_in_geofence} ;;
    value_format_name: decimal_2
    html: <a href="#drillmenu" target="_self">{{rendered_value}} miles
          <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a>
          ;;
    drill_fields: [miles_driven_detail*]
    description: "Total miles_driven in a geofence during selected range. NOTE: Halued trips are excluded"
  }

  measure: total_run_time_in_geofence_for_bar_chart {
    type: sum
    sql: ${run_time_in_geofence} ;;
    value_format_name: decimal_2
    drill_fields: [geo_run_detail*]
    html: {{rendered_value}} hrs. ;;
  }

  measure: total_miles_driven_in_geofence_for_bar_chart {
    type: sum
    sql: ${miles_driven_in_geofence} ;;
    value_format_name: decimal_2
    drill_fields: [miles_driven_detail*]
    html: {{rendered_value}} miles ;;
  }

  measure: total_idle_time_in_geofence {
    type: max
    sql: ${geofence_idle_hrs} ;;
    value_format_name: decimal_2
    html: <a href="#drillmenu" target="_self">{{rendered_value}} hrs.
    <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a>
    ;;
    drill_fields: [idle_detail*]
  }

  measure: total_selected_date_run_time {
    type: max
    sql: coalesce(${total_on_time},0) ;;
    value_format_name: decimal_2
    description: "Includes total time and doesn't look at the geofence. NOTE: This number can be slighly lower at times vs total run time in geofence due to the ETL process."
    html: {{rendered_value}} hrs. ;;
  }

  set: detail {
    fields: [asset_id, geofence_id, time_in_geofence, run_time_in_geofence, total_miles_driven_in_geofence, distinct_days_in_geofence]
  }

  set: idle_detail {
    fields: [
      assets.custom_name,
      asset_geofence_idle_time.geofence_name,
      asset_geofence_idle_time.idle_start_time,
      asset_geofence_idle_time.idle_end_time,
      asset_geofence_idle_time.geofence_idle_time
      ]
  }

  set: entry_exit_detail {
    fields: [
      assets.custom_name,
      asset_geofence_entry_exit.geofence_name,
      asset_geofence_entry_exit.geofence_name,
      asset_geofence_entry_exit.geofence_entry_time,
      asset_geofence_entry_exit.geofence_exit_time,
      asset_geofence_entry_exit.geofence_report_selected_start_time,
      asset_geofence_entry_exit.geofence_report_selected_end_time,
      asset_geofence_entry_exit.geofence_time
      ]
  }

  set: geo_run_detail {
    fields: [
      assets.custom_name,
      asset_geofence_trip_time.geofence_name,
      asset_geofence_trip_time.trip_start_time,
      asset_geofence_trip_time.trip_end_time
      ]
  }

  set: miles_driven_detail {
    fields: [
      assets.custom_name,
      asset_geo_fence_miles_driven_detail.geofence_name,
      asset_geo_fence_miles_driven_detail.geofence_entry_time,
      asset_geo_fence_miles_driven_detail.geofence_exit_time,
      asset_geo_fence_miles_driven_detail.start_odometer,
      asset_geo_fence_miles_driven_detail.end_odometer,
      asset_geo_fence_miles_driven_detail.miles_driven_detail
      ]
  }

}
