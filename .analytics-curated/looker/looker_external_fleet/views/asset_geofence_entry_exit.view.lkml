view: asset_geofence_entry_exit {
  derived_table: {
    sql:  with owned_rented_assets as (
          select asset_id
          from table(assetlist({{ _user_attributes['user_id'] }}::numeric))
          )
          ,rental_asset_list as (
          select RL.asset_id, start_date, end_date
          from table(rental_asset_list({{ _user_attributes['user_id'] }}::numeric,
          convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start asset_geofence_time_utilization.date_filter %}),
          convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %}),
          ('{{ _user_attributes['user_timezone'] }}'))) RL
          join assets a on a.asset_id = rl.asset_id
          where
          a.company_id <> {{ _user_attributes['company_id'] }}
         )
        --, geo_duration as (
        select
          distinct
          ge.asset_id,
          g.geofence_id,
          g.name as geofence_name,
          convert_timezone('{{ _user_attributes['user_timezone'] }}', ge.encounter_start_timestamp) as geofence_entry,
          convert_timezone('{{ _user_attributes['user_timezone'] }}', ge.encounter_end_timestamp) as geofence_exit,
          {% date_start asset_geofence_time_utilization.date_filter %} as geofence_selected_start,
          {% date_end asset_geofence_time_utilization.date_filter %} as geofence_selected_end
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
        UNION
        select
          distinct
          ge.asset_id,
          g.geofence_id,
          g.name as geofence_name,
          convert_timezone('{{ _user_attributes['user_timezone'] }}',ge.encounter_start_timestamp) as geofence_entry,
          convert_timezone('{{ _user_attributes['user_timezone'] }}',ge.encounter_end_timestamp) as geofence_exit,
          {% date_start asset_geofence_time_utilization.date_filter %} as geofence_selected_start,
          {% date_end asset_geofence_time_utilization.date_filter %} as geofence_selected_end
        from
          asset_geofence_encounters ge
          join geofences g on ge.geofence_id = g.geofence_id
          join rental_asset_list o on o.asset_id = ge.asset_id and o.start_date >= ge.encounter_start_timestamp and (o.end_date <= ge.encounter_end_timestamp OR o.end_date is null)
        where
          g.company_id = {{ _user_attributes['company_id'] }}::numeric
          and  overlaps(
              ge.encounter_start_timestamp,
              coalesce(ge.encounter_end_timestamp, current_timestamp),
              convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start asset_geofence_time_utilization.date_filter %}),
              convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %})
              )


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

  dimension_group: geofence_entry {
    type: time
    sql: ${TABLE}."GEOFENCE_ENTRY" ;;
    html: {{ rendered_value | date: "%b %d, %Y %r  "  }} {{ _user_attributes['user_timezone_label'] }};;
  }

  dimension_group: geofence_report_selected_start {
    type: time
    sql: ${TABLE}."GEOFENCE_SELECTED_START" ;;
    html: {{ rendered_value | date: "%b %d, %Y %r  "  }} {{ _user_attributes['user_timezone_label'] }};;
  }

  dimension_group: geofence_exit {
    type: time
    sql: ${TABLE}."GEOFENCE_EXIT" ;;
    html: {{ rendered_value | date: "%b %d, %Y %r  "  }} {{ _user_attributes['user_timezone_label'] }};;
  }

  dimension_group: geofence_report_selected_end {
    type: time
    sql: ${TABLE}."GEOFENCE_SELECTED_END" ;;
    html: {{ rendered_value | date: "%b %d, %Y %r  "  }} {{ _user_attributes['user_timezone_label'] }};;
  }

  # dimension: geo_seconds {
  #   type: number
  #   sql: ${TABLE}."GEO_SECONDS" ;;
  #   value_format_name: decimal_2
  # }

  # dimension: geofence_time {
  #   type: number
  #   sql: ${geo_seconds}/3600 ;;
  #   value_format_name: decimal_2
  #   html: {{rendered_value}} hrs. ;;
  # }

  dimension: geo_seconds {
    type: number
    sql:
    case

    when ${geofence_entry_time} > {% date_start asset_geofence_time_utilization.date_filter %}
    and coalesce(${geofence_exit_time},{% date_end asset_geofence_time_utilization.date_filter %}) >= {% date_end asset_geofence_time_utilization.date_filter %}
    then timediff(seconds, ${geofence_entry_time} ,{% date_end asset_geofence_time_utilization.date_filter %})

    when ${geofence_entry_time} <= {% date_start asset_geofence_time_utilization.date_filter %}
    and coalesce(${geofence_exit_time},{% date_end asset_geofence_time_utilization.date_filter %}) >= {% date_end asset_geofence_time_utilization.date_filter %}
    then timediff(seconds, {% date_start asset_geofence_time_utilization.date_filter %} ,{% date_end asset_geofence_time_utilization.date_filter %})

    when ${geofence_entry_time} > {% date_start asset_geofence_time_utilization.date_filter %}
    and ${geofence_exit_time} < {% date_end asset_geofence_time_utilization.date_filter %}
    then timediff(seconds, ${geofence_entry_time} , ${geofence_exit_time})

    when ${geofence_entry_time} <= {% date_start asset_geofence_time_utilization.date_filter %}
    and ${geofence_exit_time} < {% date_end asset_geofence_time_utilization.date_filter %}
    then timediff(seconds, {% date_start asset_geofence_time_utilization.date_filter %} , ${geofence_exit_time})

    else 0
    end
    ;;
    value_format_name: decimal_2
  }

  dimension: geofence_time {
    type: number
    sql: ${geo_seconds}/3600 ;;
    value_format_name: decimal_2
    html: {{rendered_value}} hrs. ;;
  }

  filter: date_filter {
    type: date_time
  }

  set: detail {
    fields: [
      asset_id,
      geofence_id,
      geofence_name,
      geofence_entry_time,
      geofence_exit_time,
      geofence_report_selected_start_time,
      geofence_report_selected_end_time,
      geo_seconds

    ]
  }
}
