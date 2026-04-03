view: speed_report_incident_log {
  derived_table: {
    sql:
with
    asset_list_own as (
    select distinct ai.asset_id from BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__ASSET_INFO ai
    left join es_warehouse.public.organization_asset_xref ox on  ox.asset_id = ai.asset_id
    left join es_warehouse.public.organizations o on  o.organization_id = ox.organization_id
        where (ai.company_id in (select company_id from es_warehouse.public.users where user_id = {{ _user_attributes['user_id'] }}::numeric)
        or o.company_id = {{ _user_attributes['company_id'] }}::numeric)
    )
    ,asset_list_rental as (
    select cv.asset_id,start_date,end_date from BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__COMPANY_VALUES cv
    join business_intelligence.triage.stg_t3__asset_info ai on ai.asset_id = cv.asset_id
    left join es_warehouse.public.organization_asset_xref ox on  ox.asset_id = ai.asset_id
    left join es_warehouse.public.organizations o on  o.organization_id = ox.organization_id
        where time_overlaps(
         start_date,
         end_date,
         convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}),
         convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}),
         true
         )
        and rental_company_id =  {{ _user_attributes['company_id'] }}::numeric
    )
    ,owned_and_rental_assets as ( --Code to combine rental and owned asset ids together
    select
      asset_id
      , 'Owned' as ownership
    from
      asset_list_own
    UNION
    select
      asset_id
      , 'Rented' as ownership
    from
      asset_list_rental

    ) , tracking_incidents_triage as (
        select
        a.asset_id,
        a.custom_name,
        a.inventory_branch_id,
        a.make,
        a.model,
        a.branch,
        a.license_plate_number,
        a.license_plate_state,
        t.tracking_incident_id,
        t.tracking_event_id,
        t.trip_id,
        t.asset_incident_threshold_id,
        t.tracking_incident_name,
        t.duration,
        t.date_time,
        COALESCE(t.driver_name_new, 'Unassigned Driver') as driver_name,
        t.posted_speed_limit,
        t.maxspeed,
        t.start_address as address,
        t.speed_location_lon,
        t.speed_location_lat,
        ait.asset_incident_threshold_field_id,
        ait.exceeded_value_range,
        aid.duration_seconds,
        aid.exceeded_threshold_value,
        aid.start_timestamp,
        aid.end_timestamp
        from business_intelligence.triage.stg_t3__asset_info a
        join owned_and_rental_assets L on L.asset_id = a.asset_id
        join business_intelligence.triage.stg_t3__tracking_incidents_triage t on L.asset_id = t.asset_id
        left join asset_incident_thresholds ait on ait.asset_incident_threshold_id = t.asset_incident_threshold_id
        left join asset_incident_threshold_durations aid on aid.start_incident_id = t.tracking_incident_id and aid.asset_id = t.asset_id
              where t.date_time >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start speed_report_incident_log.date_filter %})
              and t.date_time <= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end speed_report_incident_log.date_filter %})
              and a.asset_type = 'Vehicle'

    ) , assets_w_speed_or_local_threshold as (
            select distinct
            asset_id,
            make,
            model,
            license_plate_number,
            license_plate_state,
            branch,
            tracking_incident_id ,
            tracking_event_id,
            trip_id,
            inventory_branch_id,
            duration_seconds,
            round(exceeded_threshold_value,0) as maxSpeed,
            case
              when asset_incident_threshold_field_id = 9 and tracking_incident_name = 'Over Speed Limit'
              then coalesce(exceeded_value_range:lower_bound, exceeded_value_range, 'NONE')
              else posted_speed_limit
            end as speed_threshold,
            start_timestamp,
            end_timestamp,
            case
              when asset_incident_threshold_field_id = 9 and tracking_incident_name = 'Over Speed Limit'
              then 'Threshold'
              else concat('Posted Speed', ' (>', to_char(exceeded_value_range:lower_bound), ' MPH Over)')
            end as speeding_type,
            driver_name,
            custom_name,
            address,
            speed_location_lon,
            speed_location_lat
              from  tracking_incidents_triage t
              where (asset_incident_threshold_field_id = 17
              or (tracking_incident_name = 'Over Speed Limit'and asset_incident_threshold_field_id = 9))
                and start_timestamp >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start speed_report_incident_log.date_filter %})
                and end_timestamp   <= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end speed_report_incident_log.date_filter %})

    ), assets_wo_speed_threshold as (
            select distinct
            t.asset_id,
            t.make,
            t.model,
            t.license_plate_number,
            t.license_plate_state,
            t.branch,
            t.tracking_incident_id ,
            t.tracking_event_id,
            t.trip_id,
            t.inventory_branch_id,
            t.duration as duration_seconds,
            round(t.maxSpeed::float,0) as maxSpeed,
            -- Default means >= 79mph; all default alerts are at this threshold.
            79 as speed_threshold,
            t.date_time as start_timestamp,
            -- Originally, we marked end_timestamp as NULL for all Default events.
            -- We now impute an end_timestamp for Default alerts: end_time = start_time + duration_seconds
            DATEADD(secs, duration, t.date_time) as end_timestamp,
            'Default' as speeding_type,
            t.driver_name,
            t.custom_name,
            t.address,
            t.speed_location_lon,
            t.speed_location_lat
              from tracking_incidents_triage t
              where tracking_incident_name = 'Over Speed'
              and t.asset_id not in (select asset_id from assets_w_speed_or_local_threshold)
    ), all_assets as ( -- Combines all incidents from both tables
                select * from assets_w_speed_or_local_threshold
                              union (select * from assets_wo_speed_threshold)
    ), trip_duration as (
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
                coalesce(ROUND(sum(t.trip_time_seconds::decimal),0),2) as on_time_secs,
                coalesce(ROUND(sum(t.idle_duration::decimal),0),2) as idle_sec,
                coalesce(sum(t.speeding_incidents),0) as speed_events,
                coalesce(sum(t.speeding_duration),0) as speed_secs
            FROM trips t join (select distinct asset_id from owned_and_rental_assets) al on al.asset_id = t.asset_id
            where t.end_timestamp >= convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_start speed_report_incident_log.date_filter %})
              and t.end_timestamp < convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end speed_report_incident_log.date_filter %})
              and t.trip_type_id in (1,2,5,7)
            group by t.asset_id
              ) base
    )
    select al.asset_id,
           al.make,
           al.model,
           al.license_plate_number,
           al.license_plate_state,
           al.branch,
           tracking_incident_id ,
           al.trip_id,
           al.inventory_branch_id,
           al.duration_seconds,
           coalesce(count(distinct al.start_timestamp), 0) as speed_events,
           al.maxSpeed as maxSpeed,
           al.speed_threshold as speed_threshold,
           round(avg(al.maxSpeed)::decimal,1) as speed_avg,
           case when (t.on_time_secs - t.idle_sec) = 0 then 0 else
             (al.duration_seconds / (t.on_time_secs - t.idle_sec))
           end speed_percentage,
           convert_timezone('{{ _user_attributes['user_timezone'] }}', al.start_timestamp) as start_timestamp,
           convert_timezone('{{ _user_attributes['user_timezone'] }}', al.end_timestamp) as end_timestamp,
           al.speeding_type,
           t.on_time_secs,
           t.idle_sec,
           al.address,
           al.speed_location_lon,
           al.speed_location_lat,
           al.driver_name,
           al.custom_name
      from all_assets al
          join trip_duration t on t.asset_id = al.asset_id
      group by al.inventory_branch_id, al.asset_id, al.make, al.model, al.license_plate_number, al.license_plate_state, al.branch, tracking_incident_id , al.trip_id, speed_events, duration_seconds,
               maxSpeed, al.start_timestamp, al.end_timestamp,
               t.on_time_secs, t.idle_sec, speeding_type, speed_threshold,address,
              speed_location_lon, speed_location_lat, al.driver_name, al.custom_name
  ;;
  }

  dimension: dummy_for_pie_chart {
    label: "% Events by Alert Type"
    type: string
    sql: ' ' ;;
  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(${asset_id}, ${start_timestamp_time}, ${end_timestamp_time}, ${speed_threshold});;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: tracking_incident_id {
    type: number
    sql: ${TABLE}."TRACKING_INCIDENT_ID" ;;
  }

  dimension: duration_seconds {
    type: number
    sql: ${TABLE}."DURATION_SECONDS" ;;
  }

  dimension: inventory_branch_id {
    type: number
    sql: ${TABLE}."INVENTORY_BRANCH_ID" ;;
  }

  dimension: maxspeed {
    type: number
    label: "Max Speed"
    sql: ${TABLE}."MAXSPEED" ;;
    html: {{rendered_value}} mph ;;
  }

  dimension: speed_location_lon {
    type: number
    sql: ${TABLE}."SPEED_LOCATION_LON" ;;
  }

  dimension: speed_location_lat {
    type: number
    sql: ${TABLE}."SPEED_LOCATION_LAT" ;;
  }

  dimension: mapping_event {
    type: location
    sql_latitude:${speed_location_lat} ;;
    sql_longitude:${speed_location_lon} ;;
    label: "Speeding Location"
    html: <font color="#0063f3"<u><a href='https://www.google.com/maps/place/{{value}}' target='_blank'>{{value}}</a>;;
  }

  dimension: speed_threshold {
    type: string
    sql: ${TABLE}."SPEED_THRESHOLD" ;;
    html: {{rendered_value}} mph ;;
  }

  dimension: speeding_type {
    type: string
    sql: ${TABLE}."SPEEDING_TYPE" ;;
  }

  dimension: address {
    type: string
    sql: ${TABLE}."ADDRESS" ;;
  }

  dimension:  speed_day {
    type: number
    sql: floor(sum(${TABLE}."DURATION_SECONDS")::decimal / (86400))::integer;;
    label: "Days Speeding"
  }

  dimension:  speed_hr {
    type: number
    sql: floor(mod(sum(${TABLE}."DURATION_SECONDS")::decimal, 86400) / 3600)::integer;;
    label: "Hours Speeding"
  }

  dimension:  speed_min {
    type: number
    sql: floor(mod(sum(${TABLE}."DURATION_SECONDS")::decimal, 3600) / 60)::integer;;
    label: "Minutes Speeding"
  }

  dimension: speed_sec {
    type: number
    sql: mod(sum(${TABLE}."DURATION_SECONDS")::decimal, 60) ;;
    label: "Seconds Speeding"
  }

  measure: speed_time {
    label: "Speed Duration"
    description: "NOTE: If speeding alerts have overlapping or duplicate thresholds, Speed Duration and % of Drive Time Speeding may appear inflated. To improve this, remove any duplicate alerts in the Alerts section of Fleet."
    type: string
    sql:
    case
    when ${speed_day} > 0
         then concat(${speed_day}, ' days ', ${speed_hr}, ' hrs')
    when ${speed_hr} > 0
         then concat(${speed_hr}, ' hrs ', ${speed_min}, ' mins ', ${speed_sec}, ' secs')
    else
         concat(${speed_min}, ' mins ', ${speed_sec}, ' secs') end
    ;;
  }

  measure: speed_avg {
    label: "Avg Max Speed"
    type: number
    sql: round(avg(${maxspeed})::decimal, 1) ;;
    html: {{value}} mph ;;
  }

  dimension: speed_percentage {
    label: "Speeding % of Drive Time"
    type: number
    sql: ${TABLE}."SPEED_PERCENTAGE" ;;
  }

  dimension: excess_speed {
    type: string
    description: "Maximum # of miles per hour over the threshold/speed limit during the selected event."
    sql: case when (${maxspeed} - ${speed_threshold}) > 0
              then to_varchar(${maxspeed} - ${speed_threshold})
              -- avoids misleading '0 mph over' reading when speed is <1 mph over threshold,
              -- as speed values are rounded/truncated to the nearest integer in this report
              else '<1'
         end ;;
    html: {{rendered_value}} mph over;;
    order_by_field: excess_speed_numeric
  }

  dimension: excess_speed_numeric {
    type: number
    description: "Custom sort order for Excess Speed"
    sql: ${maxspeed} - ${speed_threshold} ;;
  }

  dimension: excess_speed_bin {
    label: "Excess Speed Range"
    sql: case when ${excess_speed_numeric} <= 5 then '0-5 MPH Over'
              when ${excess_speed_numeric} >  5 and ${excess_speed_numeric} <= 10 then '06-10 MPH Over'
              when ${excess_speed_numeric} > 10 and ${excess_speed_numeric} <= 20 then '11-20 MPH Over'
              when ${excess_speed_numeric} > 20 and ${excess_speed_numeric} <= 30 then '21-30 MPH Over'
              when ${excess_speed_numeric} > 30                                   then '31+ MPH Over'
         end ;;
  }

  dimension: idle_sec {
    type: number
    sql: ${TABLE}."IDLE_SEC" ;;
  }

  dimension: on_time_secs {
    type: number
    sql: ${TABLE}."ON_TIME_SECS" ;;
  }

  dimension_group: start_timestamp {
    label: "Start Time"
    type: time
    sql: ${TABLE}."START_TIMESTAMP" ;;
    html: {{ rendered_value | date: "%b %d, %Y %r"  }} {{ _user_attributes['user_timezone_label'] }};;
  }

  dimension_group: end_timestamp {
    label: "End Time"
    type: time
    sql: ${TABLE}."END_TIMESTAMP" ;;
    html: {{ rendered_value | date: "%b %d, %Y %r"  }} {{ _user_attributes['user_timezone_label'] }};;
  }

  dimension: driver_name {
    label: "Driver"
    type: string
    suggest_persist_for: "0 seconds"
    sql: ${TABLE}."DRIVER_NAME"
      ;;
  }

  dimension: custom_name {
    label: "Asset"
    type: string
    sql: TRIM(${TABLE}."CUSTOM_NAME") ;;
  }

  dimension: branch {
    type: string
    sql: TRIM(${TABLE}."BRANCH") ;;
  }

  dimension: make {
    type: string
    sql: TRIM(${TABLE}."MAKE") ;;
  }

  dimension: model {
    type: string
    sql: TRIM(${TABLE}."MODEL") ;;
  }

  dimension: license_plate_number {
    type: string
    sql: TRIM(${TABLE}."LICENSE_PLATE_NUMBER") ;;
  }

  dimension: license_plate_state {
    type: string
    sql: TRIM(${TABLE}."LICENSE_PLATE_STATE") ;;
  }

  dimension: make_and_model  {
    type: string
    sql: concat(coalesce(${make}, ''), ' ', coalesce(${model}, '')) ;;
  }

  dimension: asset_make_model {
    type: string
    sql: concat(${custom_name},' ',coalesce(${make},' '),' ',coalesce(${model},' ')) ;;
  }

  dimension: asset_linked_to_track_w_speeding_date {
    label: "Speeding Asset with Link"
    type: string
    sql: ${asset_make_model};;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id._filterable_value }}/history?selectedDate={{ speed_report_incident_log.start_timestamp_date._filterable_value}}" target="_blank">{{value}}</a></font></u>;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: count_all_events {
    label: "Total Speeding Events"
    type: count
  }

  measure: count_assets {
    label: "# of Assets"
    type: count_distinct
    sql: ${asset_id} ;;
  }

  measure: count_branches {
    label: "# of Branches"
    type: count_distinct
    sql: ${branch} ;;  # `markets.view.lkml.name` == Branch Name
  }

  measure: is_filtered_by_asset {
    type: yesno
    # Note: yes, this is gross. We have 3 conditions here to reflect 'up to 3' assets being selected in the dashboard filter for `asset`;
    #       this approach is not easily extensible to work with filters over large numbers of assets, but should work as a stopgap
    #.      for the typical use case here.
    sql: (${count_assets} = 1) or (${count_assets} = 2) or (${count_assets} = 3) ;;
  }

  measure: is_filtered_by_branch {
    type: yesno
    # Note: Only allowing 1 branch.
    sql: (${count_branches} = 1) ;;
  }

  measure: dynamic_percent_speeding_total {
    label: "Speeding % of Drive Time (Filter-Aware)"
    type: number
    sql:  case when (${is_filtered_by_asset} or ${is_filtered_by_branch})
               then ${total_percent_speeding_normalized}
               else ${total_percentage_of_drive_time_speeding}
          end ;;
  }

  measure: total_duration_seconds {
    type: sum
    sql: ${speed_report_incident_log.duration_seconds} ;;
  }

  measure: total_idle_seconds {
    type: sum
    sql: ${speed_report_incident_log.idle_sec} ;;
  }

  measure: total_on_time_seconds {
    type: sum
    sql: ${speed_report_incident_log.on_time_secs} ;;
  }

  measure: total_percentage_of_drive_time_speeding {
    type: number
    sql:
    case
    when (${speed_report_incident_log.total_on_time_seconds} - ${speed_report_incident_log.total_idle_seconds}) = 0
      then 0 else
    (${speed_report_incident_log.total_duration_seconds}
    / (${speed_report_incident_log.total_on_time_seconds}
       - ${speed_report_incident_log.total_idle_seconds}
      )
    ) end ;;
    # value_format_name: percent_2
    }

    measure: total_percent_speeding_normalized {
      type: number
      label: "Speeding % of Drive Time (Total)"
      description: "NOTE: If speeding alerts have overlapping or duplicate thresholds, Speed Duration and % of Drive Time Speeding may appear inflated. To improve this, remove any duplicate alerts in the Alerts section of Fleet."
      sql: ${total_percentage_of_drive_time_speeding} * ${count_all_events} ;;
    }

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
      sql: round(sum(${speed_report_incident_log.duration_seconds})/3600,2) ;;
      html: {{value}} hours ;;
    }

    measure: total_speeding_duration_formatted {
      label: "Total Speeding Duration (w/ # Events)"
      type: number
      sql: round(sum(${speed_report_incident_log.duration_seconds})/3600,2) ;;
      html: {{value}} hours | {{count_all_events._rendered_value}} events ;;
    }

    measure: count_posted_speed {
      type: count
      label: "Posted Speed"
      filters: [speeding_type: "Posted Speed"]
    }

    measure: count_threshold {
      type: count
      label: "Threshold"
      filters: [speeding_type: "Threshold"]
    }

    measure: count_default {
      type: count
      label: "Default"
      filters: [speeding_type: "Default"]
    }

    set: detail {
      fields: [asset_id, duration_seconds, maxspeed, start_timestamp_time, end_timestamp_time, speed_location_lon, speed_location_lat]
    }

    filter: date_filter {
      type: date
      # type: date_time
    }

    # parameter: driver_by {
    #   type: string
    #   allowed_value: { value: "Driver Assignment"}
    #   allowed_value: { value: "Legacy Assignment"}
    # }


  }
