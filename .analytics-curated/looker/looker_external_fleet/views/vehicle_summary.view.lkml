view: vehicle_summary {
  derived_table: {
    sql:
   with asset_groups as (
    select
      alo.asset_id,
      group_name as groups
    from
      (
    select distinct asset_id from BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__ASSET_INFO where company_id in (select company_id from users where user_id = {{ _user_attributes['user_id'] }}::numeric)
      )  alo
      join assets a on a.asset_id = alo.asset_id and a.asset_type_id = 2
      left join (select oax.asset_id, listagg(o.name,', ') as group_name from organization_asset_xref oax join organizations o on oax.organization_id = o.organization_id where {% condition groups_filter %} o.name {% endcondition %} group by oax.asset_id) org on org.asset_id = alo.asset_id
      left join company_dot_numbers d on a.dot_number_id = d.dot_number_id
    where
      {% condition custom_name_filter %} a.custom_name {% endcondition %}
      AND {% condition groups_filter %} org.group_name {% endcondition %}
      AND a.asset_type_id = 2
      AND
      {% if view_only_dot_assets._parameter_value == "'Yes'" %}
      d.dot_number is not null
      {% elsif view_only_dot_assets._parameter_value == "'No'" %}
      1=1
      {% else %}
      1=1
      {% endif %}
    )
    , speed_duration_w_thresholds as (
      select sp.asset_id, sum(sp.duration_seconds) as speed_duration_seconds
      from (
      select distinct t.asset_id,
          duration_seconds
      from tracking_incidents t
          join asset_groups al on al.asset_id = t.asset_id
          join asset_incident_thresholds ait on ait.asset_incident_threshold_id = t.asset_incident_threshold_id
          join asset_incident_threshold_durations aid on aid.start_incident_id = t.tracking_incident_id
      where
          t.tracking_incident_type_id = 32 and ait.asset_incident_threshold_field_id = 9
          and t.report_timestamp >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %})
          and t.report_timestamp <= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %})
          and aid.start_timestamp >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %})
          and aid.end_timestamp <= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %})
        ) sp
      group by sp.asset_id
        )
     , base as (
      select b.asset_id, custom_name, make_model, driver_name, dot_number, on_time_secs, trip_distance_miles,
      aggressive, idle_secs,
          case when b.speed_secs = 0 and sp.speed_duration_seconds > 0 then sp.speed_duration_seconds else b.speed_secs end as speed_secs,
          groups
      from (
    select
      t.asset_id,
      a.custom_name,
      concat(a.make, ' - ', a.model) as make_model,
      --case  when t.driver_user_id is null and a.driver_name is null then 'No Driver Assigned'
      --      when t.driver_user_id is not null then concat_ws(' ', u.first_name, u.last_name)
      --      when t.driver_user_id is null and a.driver_name is not null then a.driver_name
      --      when t.driver_user_id is not null or a.driver_name is not null then coalesce(a.driver_name, concat_ws(' ', u.first_name, u.last_name)) end as driver_name,
      coalesce(da.operator_name,'Unassigned') as driver_name,
      d.dot_number,
      sum(t.trip_time_seconds) as on_time_secs,
      sum(t.trip_distance_miles) as trip_distance_miles,
      coalesce(sum(t.aggressive_incidents),0) as aggressive,
      coalesce(sum(t.idle_duration),0) as idle_secs,
      coalesce(sum(t.speeding_duration),0) as speed_secs,
      ag.groups
    from
      asset_groups ag
      join trips t on t.asset_id = ag.asset_id
      --left join users u on t.driver_user_id = u.user_id
      join assets a on t.asset_id = a.asset_id
      left join company_dot_numbers d on a.dot_number_id = d.dot_number_id
      left join business_intelligence.gold.v_fact_operator_assignments da on da.asset_id = ag.asset_id
      AND coalesce(t.end_timestamp,current_timestamp) >= da.assignment_time
      AND coalesce(t.end_timestamp,current_timestamp) <= coalesce(da.unassignment_time,current_timestamp)
    where t.trip_type_id <> 3
      and convert_timezone('{{ _user_attributes['user_timezone'] }}',t.start_timestamp)::date >= {% date_start date_filter %}::date
      and convert_timezone('{{ _user_attributes['user_timezone'] }}',t.start_timestamp)::date < {% date_end date_filter %}::date
      --and t.end_timestamp is not null
    group by t.asset_id, a.custom_name, concat(a.make, ' - ', a.model), ag.groups, d.dot_number, --t.driver_user_id,
    da.operator_name
        ) b left join speed_duration_w_thresholds sp on sp.asset_id = b.asset_id
    )
    , time_conversion as (
    select asset_id,
        custom_name,
        make_model,
        driver_name,
        dot_number,
        on_time_secs,
        trip_distance_miles,
        idle_secs,
        speed_secs,
        case  when on_time_secs/ 86400 >= 1 then concat(floor(on_time_secs/ 3600), ' hours')
              when on_time_secs/ 86400 < 1 then concat(floor(on_time_secs/ 3600), ' hours ', floor(mod(on_time_secs, 3600) / 60), ' mins')
              else concat(floor(mod(on_time_secs, 3600)) / 60, ' mins ', mod( mod(on_time_secs, 3600) , 60), ' secs')
              end as drive_time,
        case  when idle_secs/ 86400 >= 1 then concat(floor(idle_secs/ 3600), ' hours')
              when idle_secs/ 86400 < 1 then concat(floor(idle_secs/ 3600), ' hours ', floor(mod(idle_secs, 3600) / 60), ' mins')
              else concat(floor(mod(idle_secs, 3600)) / 60, ' mins ', mod( mod(idle_secs, 3600), 60), ' secs')
              end as idle_time,
        case  when speed_secs/ 86400 >= 1 then concat(floor(speed_secs/ 3600), ' hours')
              when speed_secs/ 86400 < 1 then concat(floor(speed_secs/ 3600), ' hours ', floor(mod(speed_secs, 3600) / 60), ' mins')
              else concat(floor(mod(speed_secs, 3600)) / 60, ' mins ', mod( mod(speed_secs, 3600) , 60), ' secs')
              end as speed_time,
        --impact,
        aggressive,
        groups
    from base b
    )
    , asset_odometer as (
    select
      ag.asset_id,
      ao.odometer,
      ROW_NUMBER() OVER(partition by ag.asset_id ORDER BY ao.date_end desc) odometer_ranking
    from
      asset_groups ag
      left join scd.scd_asset_odometer ao on ag.asset_id = ao.asset_id AND (case when convert_timezone('UTC', {% date_end date_filter %})::date >= current_date then current_flag = 1 when date_end::date = '9999-12-31' and date_start <= convert_timezone('UTC', {% date_start date_filter %}) then current_flag = 1 else convert_timezone('UTC', {% date_end date_filter %})::date BETWEEN date_start::date AND date_end::date end)
    )
    , odometer as (
    select
        t.*,
        ai.license_plate_number,
        ai.license_plate_state,
        round(o.odometer, 0) as odometer
    from
        time_conversion t
        left join asset_odometer o on t.asset_id = o.asset_id
        left join business_intelligence.triage.stg_t3__asset_info ai on t.asset_id = ai.asset_id
    where
        odometer_ranking = 1
    )
    , asset_hours as (
    select
      ag.asset_id,
      ah.hours,
      ROW_NUMBER() OVER(partition by ag.asset_id ORDER BY ah.date_end desc) hour_ranking
    from
      asset_groups ag
      left join scd.scd_asset_hours ah on ag.asset_id = ah.asset_id AND (case when convert_timezone('UTC', {% date_end date_filter %})::date >= current_date then current_flag = 1 when date_end::date = '9999-12-31' and date_start <= convert_timezone('UTC', {% date_start date_filter %}) then current_flag = 1 else convert_timezone('UTC', {% date_end date_filter %})::date BETWEEN date_start::date AND date_end::date end)
    )
    select distinct
        od.*,
        round(hours, 0) as hours
    from
        odometer od
        left join asset_hours a on od.asset_id = a.asset_id
    where
        hour_ranking = 1
    ;;

    }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(${asset_id});;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: custom_name {
    label: "Asset"
    type: string
    sql: ${TABLE}."CUSTOM_NAME" ;;
  }

  dimension: make_model {
    label: "Make & Model"
    type: string
    sql: ${TABLE}."MAKE_MODEL" ;;
  }

  dimension: driver_name {
    label: "Driver"
    type: string
    sql: ${TABLE}."DRIVER_NAME" ;;
  }

  dimension: dot_number {
    type: string
    sql: ${TABLE}."DOT_NUMBER";;
  }

  dimension: trip_distance_miles {
    type: number
    sql: ${TABLE}."TRIP_DISTANCE_MILES";;
    value_format_name: decimal_2
  }

  dimension: on_time_secs {
    type: number
    sql: ${TABLE}."ON_TIME_SECS";;
  }

  dimension: idle_secs {
    type: number
    sql: ${TABLE}."IDLE_SECS" ;;
  }

  dimension: speed_secs {
    type: string
    sql: ${TABLE}."SPEED_SECS";;
  }

  dimension: drive_time {
    type: string
    sql: ${TABLE}."DRIVE_TIME" ;;
  }

  dimension: idle_time {
    type: string
    sql: ${TABLE}."IDLE_TIME" ;;
  }

  dimension: speed_time {
    type: string
    sql: ${TABLE}."SPEED_TIME" ;;
  }

  # dimension: impact {
  #   label: "Total Impacts"
  #   type: number
  #   sql: ${TABLE}."IMPACT" ;;
  # }

  dimension: aggressive {
    label: "Aggressive Incidents"
    type: number
    sql: ${TABLE}."AGGRESSIVE" ;;
  }

  dimension: odometer_now {
    label: "Odometer"
    type: number
    sql: ${TABLE}."ODOMETER" ;;
  }

  dimension: hours_now {
    label: "Vehicle Hours"
    type: number
    sql: ${TABLE}."HOURS" ;;
  }

  dimension: groups {
    type: string
    sql: ${TABLE}."GROUPS" ;;
  }

  dimension: license_plate_number {
    type: string
    sql: ${TABLE}."LICENSE_PLATE_NUMBER" ;;
  }

  dimension: license_plate_state {
    type: string
    sql: ${TABLE}."LICENSE_PLATE_STATE" ;;
  }

  filter: date_filter {
    type: date_time
  }

  filter: custom_name_filter {
    #no suggestions needed as we use other views to populate the data based on the date range
  }

  filter: groups_filter {
    #no suggestions needed as we use other views to populate the data based on the date range
  }

  measure: ttl_asset_drive_time_hrs {
    label: "Asset Drive Time (Hours)"
    type: sum
    sql: ${on_time_secs}/3600 ;;
    value_format_name: decimal_2
  }

  measure: ttl_asset_idle_time_hrs {
    label: "Asset Idle Time (Hours)"
    type: sum
    sql: ${idle_secs}/3600 ;;
    value_format_name: decimal_2
  }

  parameter: view_only_dot_assets {
    type: string
    allowed_value: { value: "Yes"}
    allowed_value: { value: "No"}
  }

  # parameter: driver_by {
  #   type: string
  #   allowed_value: { value: "Driver Assignment"}
  #   allowed_value: { value: "Legacy Assignment"}
  # }

  }