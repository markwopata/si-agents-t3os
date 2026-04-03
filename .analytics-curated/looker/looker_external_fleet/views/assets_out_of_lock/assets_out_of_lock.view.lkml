view: assets_out_of_lock {
  derived_table: {
    sql:  WITH current_ool as
(
select
distinct a.asset_id
--askv.name,
--askv.value
from asset_status_key_values askv
join assets a on askv.asset_id = a.asset_id
where askv.name = 'out_of_lock' and askv.value is not null
and a.company_id = 1854
and a.asset_type_id = 2

)


     select distinct a.asset_id,a.name,a.dot_number,a.description,a.duration_seconds,a.location_lat as start_location_lat ,a.location_lon as start_location_lon,a.date_started,b.date_ended,b.location_lat as end_location_lat,b.location_lon as end_location_lon FROM
     (
     select distinct ut.asset_id,a.name,a.description,uts.start_incident_id,te_s.location_lat,te_s.location_lon,te_s.city,uts.UNHEALTHY_TRACKER_TRAIT_LOG_ID ,uts.duration_seconds,uts.date_started,cd.dot_number
     from unhealthy_tracker_trait_logs ut-- te_s.location_lat,
     JOIN assets a on a.asset_id=ut.asset_id and a.tracker_id=ut.tracker_id  and ut.date_started >= dateadd(year, -1, current_date) and UNHEALTHY_TRACKER_TRAIT_TYPE_ID = 2 and a.company_id=1854 and a.asset_type_id=2   --and ut.asset_id in (select * from current_ool)
       join company_dot_numbers cd on cd.dot_number_id = a.dot_number_id
    join      (
     select OPTIONAL_FIELDS:duration_seconds as duration_seconds,OPTIONAL_FIELDS:start_incident_id as start_incident_id,UNHEALTHY_TRACKER_TRAIT_LOG_ID ,asset_id,tracker_id,ut.date_started
     from unhealthy_tracker_trait_logs ut --where UNHEALTHY_TRACKER_TRAIT_TYPE_ID = 2  and  ut.date_started >= dateadd(year, -1, current_date) --and ut.asset_id in (select * from current_ool)
     ) uts
     on uts.UNHEALTHY_TRACKER_TRAIT_LOG_ID  = ut.UNHEALTHY_TRACKER_TRAIT_LOG_ID
     join tracking_incidents tis  on tis.TRACKING_INCIDENT_ID = uts.START_INCIDENT_ID
     join tracking_events te_s on te_s.tracking_event_id=tis.tracking_event_id and  te_s.REPORT_TIMESTAMP >= dateadd(year, -1, current_date)-- and st_dwithin (st_makepoint(-122.1858115,47.4529257), st_makepoint(te_s.location_lon,te_s.location_lat ), 500*1.609)
     )a

     JOIN
     (
     select distinct ut.asset_id, ute.end_incident_id,te_e.location_lat,te_e.location_lon,ute.UNHEALTHY_TRACKER_TRAIT_LOG_ID,ute.date_ended,cd.dot_number
     from unhealthy_tracker_trait_logs ut-- te_s.location_lat,
     JOIN assets a on a.asset_id=ut.asset_id and a.tracker_id=ut.tracker_id and  ut.date_started >= dateadd(year, -1, current_date) and UNHEALTHY_TRACKER_TRAIT_TYPE_ID = 2 and a.company_id=1854 and a.asset_type_id=2   --and ut.asset_id in (select * from current_ool)
       join company_dot_numbers cd on cd.dot_number_id = a.dot_number_id
     join  (
     select OPTIONAL_FIELDS:end_incident_id as end_incident_id,UNHEALTHY_TRACKER_TRAIT_LOG_ID,asset_id,tracker_id,ut.date_ended
     from unhealthy_tracker_trait_logs ut --where UNHEALTHY_TRACKER_TRAIT_TYPE_ID = 2  and  ut.date_started >= dateadd(year, -1, current_date) --and ut.asset_id in (select * from current_ool)
     ) ute
     on ute.UNHEALTHY_TRACKER_TRAIT_LOG_ID = ut.UNHEALTHY_TRACKER_TRAIT_LOG_ID
    join tracking_incidents tie  on tie.TRACKING_INCIDENT_ID = ute.END_INCIDENT_ID-- and tie.asset_id=ute.asset_id
    join tracking_events te_e on te_e.tracking_event_id=tie.tracking_event_id and  te_e.REPORT_TIMESTAMP >= dateadd(year, -1, current_date)-- and st_dwithin (st_makepoint(-122.1858115,47.4529257), st_makepoint( te_e.location_lon,te_e.location_lat ),500*1.609)
     )b on a.asset_id=b.asset_id and a.UNHEALTHY_TRACKER_TRAIT_LOG_ID = b.UNHEALTHY_TRACKER_TRAIT_LOG_ID
      ;;
  }

  measure: count {
    type: count
    #drill_fields: [detail*]
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: duration_seconds {
    type: string
    sql: ${TABLE}."DURATION_SECONDS" ;;
  }

  dimension: start_location_lat {
    type: number
    sql: ${TABLE}."START_LOCATION_LAT" ;;
  }

  dimension: start_location_lon {
    type: number
    sql: ${TABLE}."START_LOCATION_LON" ;;
  }

  dimension_group: date_started {
    type: time
    sql: ${TABLE}."DATE_STARTED" ;;
  }

  dimension_group: date_ended {
    type: time
    sql: ${TABLE}."DATE_ENDED" ;;
  }

  dimension: end_location_lon {
    type: number
    sql: ${TABLE}."END_LOCATION_LON" ;;
  }

  dimension: end_location_lat {
    type: number
    sql: ${TABLE}."END_LOCATION_LAT" ;;
  }

  dimension: mapping_event_start {
    label: "OOL Location Start"
    type: location
    sql_latitude:${start_location_lat} ;;
    sql_longitude:${start_location_lon} ;;
    html: {{rendered_value}}
    <br />
    <p>
    </p>
    <p>Asset:
    <br />{{ asset_id._value }}
    </p>
    ;;
    }

    dimension: mapping_event_End {
      label: "OOL Location End"
      type: location
      sql_latitude:${end_location_lat} ;;
      sql_longitude:${end_location_lon} ;;
      html: {{rendered_value}}
            <br />
            <p>
            </p>
            <p>Asset:
            <br />{{ asset_id._value }}
            </p>
            ;;

  }



}
