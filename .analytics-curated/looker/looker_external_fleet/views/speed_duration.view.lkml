view: speed_duration {
  derived_table: {
    sql:
  with asset_list as (
   select a.asset_id
   from assets a join table(assetlist({{ _user_attributes['user_id'] }}::numeric)) L on L.asset_id = a.asset_id
   where a.asset_type_id = 2
)
-- speeding duration for assets with a manually set speeding threshold
  select distinct t.asset_id,
      duration_seconds as speed_duration_seconds,
      exceeded_threshold_value as maxSpeed,
      aid.start_timestamp as report_timestamp
--      aid.end_timestamp
  from tracking_incidents t join asset_list al on al.asset_id = t.asset_id
      join asset_incident_thresholds ait on ait.asset_incident_threshold_id = t.asset_incident_threshold_id
      join asset_incident_threshold_durations aid on aid.start_incident_id = t.tracking_incident_id
    where
        t.tracking_incident_type_id = 32 and ait.asset_incident_threshold_field_id = 9
        and t.report_timestamp >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %})
        and t.report_timestamp <= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})
        and aid.start_timestamp >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %})
        and aid.end_timestamp <= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})
union
-- speeding duration for assets without a set threshold and set to the auto speed limit of ~80?
   select distinct t.asset_id,
        duration as speed_duration_seconds,
        optional_fields:maxSpeed::float as maxSpeed,
        t.report_timestamp
      from tracking_incidents t join asset_list al on al.asset_id = t.asset_id
      where
          tracking_incident_type_id = 2
          and t.report_timestamp >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %})
          and t.report_timestamp <= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})
  ;;

  }

  dimension: asset_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: speed_duration_seconds {
    type: number
    sql: ${TABLE}."SPEED_DURATION_SECONDS" ;;
  }

  dimension: maxSpeed {
    type: number
    sql: ${TABLE}."MAXSPEED" ;;
  }

  dimension_group: report_timestamp {
    type: time
    sql: ${TABLE}."REPORT_TIMESTAMP" ;;
  }

  filter: date_filter {
    type: date_time
  }

  }
