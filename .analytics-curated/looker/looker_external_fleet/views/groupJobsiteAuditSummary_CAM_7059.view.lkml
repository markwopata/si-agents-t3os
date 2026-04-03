view: groupjobsiteauditsummary_cam_7059 {
  derived_table: {
    sql:
    with geofences_all as ( -- Get all the geofences for this company
        select geofence_id, name as CAMcode, location_id
        from geofences
        where company_id = 7059
            and (deleted = false or deleted is null)
    )
    , exit_time as ( --selects last exit time in each geofence
    select distinct geofence_id,
                exit_time,
                pos
                from (
        select
            ge.geofence_id,
                ge.encounter_end_timestamp as exit_time,
                rank() over (partition by ge.geofence_id order by ge.encounter_end_timestamp desc) as pos
        from asset_geofence_encounters ge join geofences_all aa on aa.geofence_id = ge.geofence_id
            join table(assetlist(10339)) L on L.asset_id = ge.asset_id
        where
            ge.encounter_start_timestamp between dateadd(hour, -15, current_timestamp) and dateadd(hour, 9, current_timestamp)
    ) a where pos < 2
    )
    , entry_time as ( --selects first entry time in each geofence
    select distinct geofence_id,
                entry_time
                from (
        select
            ge.geofence_id,
                ge.encounter_start_timestamp as entry_time,
                rank() over (partition by ge.geofence_id order by ge.encounter_start_timestamp) as pos
        from asset_geofence_encounters ge join geofences_all aa on aa.geofence_id = ge.geofence_id
            join table(assetlist(10339)) L on L.asset_id = ge.asset_id
       where
            ge.encounter_start_timestamp between dateadd(hour, -15, current_timestamp) and dateadd(hour, 9, current_timestamp)
    ) a where pos < 2
    )
    ,geo_checkin as ( -- Get all the checkins, which means an asset entered a geofence to start work
      select
        geofence_id,
        asset_id,
        floor(sum(geo_seconds)::decimal/ (86400))::integer as geo_day,
        floor(mod(sum(geo_seconds)::decimal, 86400) / 3600)::integer as geo_hr,
        floor(mod(sum(geo_seconds)::decimal, 3600) / 60)::integer as geo_min,
        mod(sum(geo_seconds)::decimal, 60) as geo_sec
      from(
        select distinct
            ge.geofence_id,
            ge.asset_id,
            TIMESTAMPDIFF(SECONDS, ge.encounter_start_timestamp,coalesce(ge.encounter_end_timestamp, dateadd(hour, 9, current_timestamp))) as geo_seconds
        from asset_geofence_encounters ge join geofences_all aa on aa.geofence_id = ge.geofence_id
            join table(assetlist(10339)) L on L.asset_id = ge.asset_id
        where
            ge.encounter_start_timestamp between dateadd(hour, -15, current_timestamp) and dateadd(hour, 9, current_timestamp)
     ) gc
     group by geofence_id, asset_id
    )
    select
        og.organization_id,
        o.name as area_manager,
        ga.geofence_id,
        ga.CAMcode,
        coalesce(listagg(distinct a.custom_name, ', '), ' ') as subcontractors,
        convert_timezone('PST8PDT', e.entry_time) as entry_time,
        convert_timezone('PST8PDT', ex.exit_time) as exit_time,
        case when gc.geofence_id is null then 'No' else 'Yes' end as check_in,
        case when geo_day > 0 then concat(geo_day, ' days ', geo_hr, ' hrs ')
             when geo_hr > 0 then concat(geo_hr, ' hrs ', geo_min, ' mins ', geo_sec, ' secs')
             else concat(geo_min, ' mins ', geo_sec, ' secs') end as geo_duration,
        street_1 as street,
        city,
        st.abbreviation as state,
        zip_code as zipcode
    from geofences_all ga
        left join geo_checkin gc on ga.geofence_id = gc.geofence_id
        left join organization_geofence_xref og on ga.geofence_id = og.geofence_id
        left join organizations o on o.organization_id = og.organization_id
        left join assets a on gc.asset_id = a.asset_id
        left join locations l on ga.location_id = l.location_id
        left join states st on l.state_id=st.state_id
        left join entry_time e on e.geofence_id = ga.geofence_id
        left join exit_time ex on ex.geofence_id = ga.geofence_id
    group by og.organization_id, o.name, ga.geofence_id, ga.CAMcode, gc.geofence_id, e.entry_time, ex.exit_time, geo_day, geo_hr, geo_min, geo_sec, st.abbreviation, l.zip_code, street_1, city
    ;;
  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: CONCAT(${organization_id}},${geofence_id}) ;;
  }

  dimension: organization_id {
    type: number
    sql: ${TABLE}."ORGANIZATION_ID" ;;
  }

  dimension: area_manager {
    label: "Area Manager"
    type: string
    sql: ${TABLE}."AREA_MANAGER" ;;
  }

  dimension: geofence_id {
    type: number
    sql: ${TABLE}."GEOFENCE_ID" ;;
  }

  dimension: CAMcode {
    label: "CAMCode"
    type: string
    sql: ${TABLE}."CAMCODE" ;;
  }

  dimension: subcontractors {
    type: string
    sql: ${TABLE}."SUBCONTRACTORS" ;;
  }

  dimension: entry_time {
    label: "First Entry Time"
    type: date_time
    sql: ${TABLE}."ENTRY_TIME" ;;
    html: {{ value | date: "%I:%M %p"  }};;
  }

  dimension: exit_time {
    label: "Last Exit Time"
    type: date_time
    sql: ${TABLE}."EXIT_TIME" ;;
    html: {{ value | date: "%I:%M %p"  }};;
  }

  dimension: check_in {
    label: "Geofence Visited (Y or N)"
    type: string
    sql: ${TABLE}."CHECK_IN" ;;
  }

  dimension: geo_duration {
    label: "Total Time Visited (HH:MM)"
    type: string
    sql: ${TABLE}."GEO_DURATION" ;;
  }

  dimension: street {
    type: string
    sql: ${TABLE}."STREET" ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}."CITY" ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  dimension: zipcode {
    type: string
    sql: ${TABLE}."ZIPCODE" ;;
  }

}
