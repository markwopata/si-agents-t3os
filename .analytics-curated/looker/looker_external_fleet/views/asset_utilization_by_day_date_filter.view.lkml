view: asset_utilization_by_day_date_filter {
  derived_table: {
    sql: with asset_list_own as (
          select asset_id
          from table(assetlist({{ _user_attributes['user_id'] }}::numeric))
          )
          ,own_available_dates as (
          select
              al.asset_id,
              convert_timezone('{{ _user_attributes['user_timezone'] }}',report_range:start_range)::date as start_date,
              convert_timezone('{{ _user_attributes['user_timezone'] }}',report_range:end_range)::date as end_date,
              sum(on_time) as on_time,
              sum(idle_time) as idle_time
              --,sum(miles_driven) as miles_driven
          from
              asset_list_own al
              left join es_warehouse.public.hourly_asset_usage hau on al.asset_id = hau.asset_id
          where
              report_range:start_range >= COALESCE(convert_timezone('{{ _user_attributes['user_timezone'] }}', 'UTC',{% date_start hourly_asset_usage_date_filter.date_filter %}),convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', convert_timezone('{{ _user_attributes['user_timezone'] }}',current_timestamp)::date - interval '10 days'))
              AND report_range:end_range <= COALESCE(convert_timezone('{{ _user_attributes['user_timezone'] }}', 'UTC',{% date_end hourly_asset_usage_date_filter.date_filter %}),convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', convert_timezone('{{ _user_attributes['user_timezone'] }}',current_timestamp)::date))
          group by
              al.asset_id,
              convert_timezone('{{ _user_attributes['user_timezone'] }}',report_range:start_range)::date,
              convert_timezone('{{ _user_attributes['user_timezone'] }}',report_range:end_range)::date
          )
          ,asset_list_rental as (
          select rl.asset_id, rl.start_date, rl.end_date
          from table(rental_asset_list({{ _user_attributes['user_id'] }}::numeric,
          convert_timezone('{{ _user_attributes['user_timezone'] }}', 'UTC', {% date_start hourly_asset_usage_date_filter.date_filter %}),
          convert_timezone('{{ _user_attributes['user_timezone'] }}', 'UTC', {% date_end hourly_asset_usage_date_filter.date_filter %}),
          '{{ _user_attributes['user_timezone'] }}')) rl
          join assets a on a.asset_id = rl.asset_id
          where
          a.company_id <> {{ _user_attributes['company_id'] }}
          ),
          rental_available_dates as (
          select
              alr.asset_id,
              convert_timezone('{{ _user_attributes['user_timezone'] }}',report_range:start_range)::date as rental_start_date,
              convert_timezone('{{ _user_attributes['user_timezone'] }}',report_range:end_range)::date as rental_end_date,
              sum(on_time) as on_time,
              sum(idle_time) as idle_time
              --,sum(miles_driven) as miles_driven
          from
              asset_list_rental alr
              left join es_warehouse.public.hourly_asset_usage hau on alr.asset_id = hau.asset_id and hau.report_range:start_range >= alr.start_date AND hau.report_range:end_range <= alr.end_date
          where
              report_range:start_range >= COALESCE(convert_timezone('{{ _user_attributes['user_timezone'] }}', 'UTC',{% date_start hourly_asset_usage_date_filter.date_filter %}),convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', convert_timezone('{{ _user_attributes['user_timezone'] }}',current_timestamp)::date - interval '10 days'))
              AND report_range:end_range <= COALESCE(convert_timezone('{{ _user_attributes['user_timezone'] }}', 'UTC', {% date_end hourly_asset_usage_date_filter.date_filter %}),convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', convert_timezone('{{ _user_attributes['user_timezone'] }}',current_timestamp)::date))
          group by
              alr.asset_id,
              convert_timezone('{{ _user_attributes['user_timezone'] }}',report_range:start_range)::date,
              convert_timezone('{{ _user_attributes['user_timezone'] }}',report_range:end_range)::date
          ),
          date_series as (
          select
            series::date as date
          from table
            (generate_series(
            convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_start hourly_asset_usage_date_filter.date_filter %}),
            convert_timezone('{{ _user_attributes['user_timezone'] }}', {% date_end hourly_asset_usage_date_filter.date_filter %}),
            'day')
          ))
          ,utilization_info as (
          select
              alo.asset_id,
              'own' as ownership_type,
              --ds.date,
              start_date,
              end_date,
              coalesce(sum(on_time),0) as on_time,
              sum(idle_time) as idle_time
              --,round(sum(miles_driven),1) as miles_driven
          from
              asset_list_own alo
              join own_available_dates oad on alo.asset_id = oad.asset_id
              --left join date_series ds on oad.start_date::date = ds.date
          group by
              alo.asset_id,
              --ds.date,
              start_date,
              end_date
          UNION
          select
              alr.asset_id,
              'rented' as ownership_type,
              --ds.date,
              rental_start_date as start_date,
              rental_end_date as end_date,
              coalesce(sum(on_time),0) as on_time,
              sum(idle_time) as idle_time
              --,round(sum(miles_driven),1) as miles_driven
          from
              asset_list_rental alr
              join rental_available_dates rad on alr.asset_id = rad.asset_id
              --left join date_series ds on rad.rental_start_date::date = ds.date
          group by
              alr.asset_id,
              --ds.date,
              rental_start_date,
              rental_end_date
          )
          ,available_asset_dates as (
          select
                alr.asset_id,
                ds.date
          from
                asset_list_rental alr
                join date_series ds on ds.date between alr.start_date::date and alr.end_date::date
          union
          select
                alo.asset_id,
                ds.date
          from
                asset_list_own alo
                join date_series ds on 1=1
          )
          select
              aa.date,
              aa.asset_id,
              ownership_type,
              start_date,
              end_date,
              coalesce(on_time,0) as on_time,
              idle_time
              --,miles_driven
          from
             available_asset_dates aa
             left join utilization_info ui on aa.date = ui.start_date and aa.asset_id = ui.asset_id
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

  dimension: ownership_type {
    type: string
    sql: ${TABLE}."OWNERSHIP_TYPE" ;;
  }

  dimension: date {
    type: date
    sql: ${TABLE}."DATE" ;;
  }

  dimension: start_date {
    type: date
    sql: ${TABLE}."START_DATE" ;;
  }

  dimension: end_date {
    type: date
    sql: ${TABLE}."END_DATE" ;;
  }

  dimension: on_time {
    type: number
    sql: ${TABLE}."ON_TIME" ;;
  }

  dimension: idle_time {
    type: number
    sql: ${TABLE}."IDLE_TIME" ;;
  }

  dimension: miles_driven {
    type: number
    sql: ${TABLE}."MILES_DRIVEN" ;;
  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(${asset_id},${start_date},${ownership_type}) ;;
  }

  dimension: start_range_time_formatted {
    group_label: "HTML Passed Date Format" label: "Date"
    sql: ${date} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  measure: total_on_time {
    label: "Run Time Hours"
    type: sum
    sql: coalesce(${on_time}/3600,0) ;;
    value_format_name: decimal_2
    sql_distinct_key: ${primary_key}||${on_time}||${assets.asset_id} ;;
  }

  measure: total_idle_time {
    label: "Idle Time Hours"
    type: sum
    sql: ${idle_time}/3600 ;;
    value_format_name: decimal_2
  }

  measure: equipment_run_time_hours {
    type: sum
    sql: coalesce(${on_time}/3600,0) ;;
    filters: [asset_types.name: "equipment"]
    value_format_name: decimal_2
    drill_fields: [chart_drill_opt*]
  }

  measure: trailer_run_time_hours {
    type: sum
    sql: coalesce(${on_time}/3600,0) ;;
    filters: [asset_types.name: "trailer"]
    value_format_name: decimal_2
    drill_fields: [chart_drill_opt*]
  }

  measure: vehicle_run_time_hours {
    type: sum
    sql: coalesce(${on_time}/3600,0) ;;
    filters: [asset_types.name: "vehicle"]
    value_format_name: decimal_2
    drill_fields: [chart_drill_opt*]
  }

  set: chart_drill_opt {
    fields: [
      assets.custom_name, assets.make, assets.model,
      asset_odometer_based_off_date_selection.odometer, asset_last_location.last_location, asset_last_location.last_contact_time_formatted, total_on_time, total_idle_time
    ]
  }

  set: detail {
    fields: [
      asset_id,
      ownership_type,
      start_date,
      end_date,
      on_time,
      idle_time,
      miles_driven
    ]
  }
}
