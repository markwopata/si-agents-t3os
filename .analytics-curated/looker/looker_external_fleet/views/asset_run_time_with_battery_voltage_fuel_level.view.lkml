view: asset_run_time_with_battery_voltage_fuel_level {
  derived_table: {
    sql:
      {% if daily_or_hourly_selection._parameter_value == "'Daily'" %}
      with date_series as (
      select
        series::date as day
      from table
        (generate_series(
        convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %})::timestamp_tz,
        convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})::timestamp_tz,
        'day')
      )),
      asset_list_own as (
      select asset_id
      from table(assetlist({{ _user_attributes['user_id'] }}::numeric))
      )
      ,own_run_time as (
      select
          al.asset_id,
          convert_timezone('{{ _user_attributes['user_timezone'] }}',report_range:start_range)::date as start_date,
          convert_timezone('{{ _user_attributes['user_timezone'] }}',report_range:end_range)::date as end_date,
          sum(on_time) as on_time
      from
          asset_list_own al
          left join es_warehouse.public.hourly_asset_usage hau on al.asset_id = hau.asset_id
      where
          report_range:start_range >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %})
          AND report_range:end_range <= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})
          --and al.asset_id in (35952,45992,35957)
      group by
          al.asset_id,
          convert_timezone('{{ _user_attributes['user_timezone'] }}',report_range:start_range)::date,
          convert_timezone('{{ _user_attributes['user_timezone'] }}',report_range:end_range)::date
      )
      ,asset_list_rental as (
      select rl.asset_id, rl.start_date, rl.end_date
      from table(rental_asset_list({{ _user_attributes['user_id'] }}::numeric,
      convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}),
      convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}),
      '{{ _user_attributes['user_timezone'] }}')) rl
      join assets a on a.asset_id = rl.asset_id
          where
          a.company_id <> {{ _user_attributes['company_id'] }}
      )
      ,rental_run_time as (
      select
          alr.asset_id,
          convert_timezone('{{ _user_attributes['user_timezone'] }}',report_range:start_range)::date as rental_start_date,
          convert_timezone('{{ _user_attributes['user_timezone'] }}',report_range:end_range)::date as rental_end_date,
          sum(on_time) as on_time
      from
          asset_list_rental alr
          left join es_warehouse.public.hourly_asset_usage hau on alr.asset_id = hau.asset_id and hau.report_range:start_range >= alr.start_date AND hau.report_range:end_range <= alr.end_date
      where
          report_range:start_range >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %})
          AND report_range:end_range <= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})
      group by
          alr.asset_id,
          convert_timezone('{{ _user_attributes['user_timezone'] }}',report_range:start_range)::date,
          convert_timezone('{{ _user_attributes['user_timezone'] }}',report_range:end_range)::date
      )
      {% if run_time_with._parameter_value == "'Battery Voltage'" and daily_or_hourly_selection._parameter_value == "'Daily'" %}
      , battery_voltage_levels as (
      select
        al.asset_id,
        convert_timezone('{{ _user_attributes['user_timezone'] }}',report_timestamp)::date as report_date,
        coalesce(round(avg(battery_voltage),2),0) as daily_average_battery_voltage
      from
          asset_list_own al
          inner join asset_engine_statuses aes on al.asset_id = aes.asset_id
          inner join assets a on a.asset_id = al.asset_id
      where
          report_timestamp >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %})
          AND report_timestamp <= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})
          AND {% if show_battery_voltage_when_engine_is._parameter_value == "'Active'" %}
              (aes.engine_active = TRUE)
              {% elsif show_battery_voltage_when_engine_is._parameter_value == "'Not Active'" %}
              (aes.engine_active = FALSE)
              {% else %}
              (aes.engine_active = TRUE OR aes.engine_active = FALSE OR aes.engine_active is null)
              {% endif %}
      group by
          al.asset_id,
          convert_timezone('{{ _user_attributes['user_timezone'] }}',report_timestamp)::date
      UNION
      select
          al.asset_id,
          convert_timezone('{{ _user_attributes['user_timezone'] }}',report_timestamp)::date as report_date,
          coalesce(round(avg(battery_voltage),2),0) as daily_average_battery_voltage
      from
          asset_list_rental al
          inner join asset_engine_statuses aes on al.asset_id = aes.asset_id
          inner join assets a on a.asset_id = al.asset_id
      where
          report_timestamp >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %})
          AND report_timestamp <= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})
          and {% if show_battery_voltage_when_engine_is._parameter_value == "'Active'" %}
              (aes.engine_active = TRUE)
              {% elsif show_battery_voltage_when_engine_is._parameter_value == "'Not Active'" %}
              (aes.engine_active = FALSE)
              {% else %}
              (aes.engine_active = TRUE OR aes.engine_active = FALSE OR aes.engine_active is null)
              {% endif %}
      group by
          al.asset_id,
          convert_timezone('{{ _user_attributes['user_timezone'] }}',report_timestamp)::date
      )
      {% else %}
      , battery_voltage_levels as (
      select
        NULL as asset_id,
        NULL as report_date,
        NULL as daily_average_battery_voltage
      )
      {%  endif %}
      {% if run_time_with._parameter_value == "'Fuel Level'" and daily_or_hourly_selection._parameter_value == "'Daily'" %}
      , daily_avg_fuel_level as (
      select
        al.asset_id,
        convert_timezone('{{ _user_attributes['user_timezone'] }}',report_timestamp)::date as report_date,
        coalesce(round(avg(fuel_level),2),0) as daily_avg_fuel_level
      from
          asset_list_own al
          inner join asset_engine_statuses aes on al.asset_id = aes.asset_id
          inner join assets a on a.asset_id = al.asset_id
      where
          report_timestamp >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %})
          AND report_timestamp <= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})
      group by
          al.asset_id,
          convert_timezone('{{ _user_attributes['user_timezone'] }}',report_timestamp)::date
      UNION
      select
          al.asset_id,
          convert_timezone('{{ _user_attributes['user_timezone'] }}',report_timestamp)::date as report_date,
          coalesce(round(avg(fuel_level),2),0) as daily_avg_fuel_level
      from
          asset_list_rental al
          inner join asset_engine_statuses aes on al.asset_id = aes.asset_id
          inner join assets a on a.asset_id = al.asset_id
      where
          report_timestamp >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %})
          AND report_timestamp <= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})
      group by
          al.asset_id,
          convert_timezone('{{ _user_attributes['user_timezone'] }}',report_timestamp)::date
      )
      {% else %}
      , daily_avg_fuel_level as (
      select
        NULL as asset_id,
        NULL as report_date,
        NULL as daily_avg_fuel_level
      )
      {%  endif %}
      , asset_id_list as (
      select
        alo.asset_id
      from
        asset_list_own alo
        left join own_run_time ort on alo.asset_id = ort.asset_id
      union
      select
        alr.asset_id
      from
        asset_list_rental alr
        left join rental_run_time rrt on rrt.asset_id = alr.asset_id
      )
      , asset_run_time as (
      select
        asset_id,
        start_date,
        on_time
      from
        own_run_time
      union
      select
        asset_id,
        rental_start_date,
        on_time
      from
        rental_run_time
      )
      , asset_total_run_time as (
      select
        asset_id,
        round((sum(on_time)/3600),2) as total_duration_run_time
      from
        asset_run_time
      group by
        asset_id
      )
      select
          'Daily' as selection,
          al.asset_id,
          a.custom_name,
          to_timestamp(ds.day) as day,
          round(coalesce(art.on_time/3600,0),2) as run_time_hrs,
          coalesce(bl.daily_average_battery_voltage,0) as daily_average_battery_voltage,
          coalesce(fl.daily_avg_fuel_level,0) as daily_fuel_level,
          coalesce(atrt.total_duration_run_time,0) as total_duration_run_time
      from
          asset_id_list al
          left join date_series ds on 1=1
          left join asset_run_time art on art.asset_id = al.asset_id and art.start_date = ds.day
          left join battery_voltage_levels bl on bl.asset_id = al.asset_id and bl.report_date = ds.day
          left join daily_avg_fuel_level fl on fl.asset_id = al.asset_id and fl.report_date = ds.day
          join assets a on al.asset_id = a.asset_id and a.deleted = FALSE and a.asset_type_id in (1,2)
          left join asset_total_run_time atrt on atrt.asset_id = a.asset_id
      {% elsif daily_or_hourly_selection._parameter_value == "'Hourly'" %}
      with date_series as (
      select
        series as day
      from table
        (generate_series(
        convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %})::timestamp_tz,
        convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})::timestamp_tz,
        'hour')
      ))
      ,asset_list_own as (
      select asset_id
      from table(assetlist({{ _user_attributes['user_id'] }}::numeric))
      )
      ,own_run_time as (
      select
          al.asset_id,
          TO_CHAR(DATE_TRUNC('hour', convert_timezone('{{ _user_attributes['user_timezone'] }}',report_range:start_range)), 'YYYY-MM-DD HH24') as start_date,
          TO_CHAR(DATE_TRUNC('hour', convert_timezone('{{ _user_attributes['user_timezone'] }}',report_range:end_range)), 'YYYY-MM-DD HH24') as end_date,
          sum(on_time) as on_time
      from
          asset_list_own al
          left join es_warehouse.public.hourly_asset_usage hau on al.asset_id = hau.asset_id
      where
          report_range:start_range >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %})
          AND report_range:end_range <= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})
          --and al.asset_id in (35952,45992,35957)
      group by
          al.asset_id,
          TO_CHAR(DATE_TRUNC('hour', convert_timezone('{{ _user_attributes['user_timezone'] }}',report_range:start_range)), 'YYYY-MM-DD HH24'),
          TO_CHAR(DATE_TRUNC('hour', convert_timezone('{{ _user_attributes['user_timezone'] }}',report_range:end_range)), 'YYYY-MM-DD HH24')
      )
      ,asset_list_rental as (
      select asset_id, start_date, end_date
      from table(rental_asset_list({{ _user_attributes['user_id'] }}::numeric,
      convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}),
      convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}),
      '{{ _user_attributes['user_timezone'] }}'))
      )
      ,rental_run_time as (
      select
          alr.asset_id,
          TO_CHAR(DATE_TRUNC('hour', convert_timezone('{{ _user_attributes['user_timezone'] }}',report_range:start_range)), 'YYYY-MM-DD HH24') as rental_start_date,
          TO_CHAR(DATE_TRUNC('hour', convert_timezone('{{ _user_attributes['user_timezone'] }}',report_range:end_range)), 'YYYY-MM-DD HH24') as rental_end_date,
          sum(on_time) as on_time
      from
          asset_list_rental alr
          left join es_warehouse.public.hourly_asset_usage hau on alr.asset_id = hau.asset_id and hau.report_range:start_range >= alr.start_date AND hau.report_range:end_range <= alr.end_date
      where
          report_range:start_range >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %})
          AND report_range:end_range <= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})
      group by
          alr.asset_id,
          TO_CHAR(DATE_TRUNC('hour', convert_timezone('{{ _user_attributes['user_timezone'] }}',report_range:start_range)), 'YYYY-MM-DD HH24'),
          TO_CHAR(DATE_TRUNC('hour', convert_timezone('{{ _user_attributes['user_timezone'] }}',report_range:end_range)), 'YYYY-MM-DD HH24')
      )
      {% if run_time_with._parameter_value == "'Battery Voltage'" and daily_or_hourly_selection._parameter_value == "'Hourly'" %}
      , battery_voltage_levels as (
      select
        al.asset_id,
        TO_CHAR(DATE_TRUNC('hour', convert_timezone('{{ _user_attributes['user_timezone'] }}',report_timestamp) ), 'YYYY-MM-DD HH24') as report_date,
        coalesce(round(avg(battery_voltage),2),0) as daily_average_battery_voltage
      from
          asset_list_own al
          inner join asset_engine_statuses aes on al.asset_id = aes.asset_id
          inner join assets a on a.asset_id = al.asset_id
      where
          report_timestamp >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %})
          AND report_timestamp <= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})
          and {% if show_battery_voltage_when_engine_is._parameter_value == "'Active'" %}
              (aes.engine_active = TRUE)
              {% elsif show_battery_voltage_when_engine_is._parameter_value == "'Not Active'" %}
              (aes.engine_active = FALSE)
              {% else %}
              (aes.engine_active = TRUE OR aes.engine_active = FALSE OR aes.engine_active is null)
              {% endif %}
      group by
          al.asset_id,
          TO_CHAR(DATE_TRUNC('hour', convert_timezone('{{ _user_attributes['user_timezone'] }}',report_timestamp) ), 'YYYY-MM-DD HH24')
      UNION
      select
          al.asset_id,
          TO_CHAR(DATE_TRUNC('hour', convert_timezone('{{ _user_attributes['user_timezone'] }}',report_timestamp) ), 'YYYY-MM-DD HH24') as report_date,
          coalesce(round(avg(battery_voltage),2),0) as daily_average_battery_voltage
      from
          asset_list_rental al
          inner join asset_engine_statuses aes on al.asset_id = aes.asset_id
          inner join assets a on a.asset_id = al.asset_id
      where
          report_timestamp >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %})
          AND report_timestamp <= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})
          AND {% if show_battery_voltage_when_engine_is._parameter_value == "'Active'" %}
              (aes.engine_active = TRUE)
              {% elsif show_battery_voltage_when_engine_is._parameter_value == "'Not Active'" %}
              (aes.engine_active = FALSE)
              {% else %}
              (aes.engine_active = TRUE OR aes.engine_active = FALSE OR aes.engine_active is null)
              {% endif %}
      group by
          al.asset_id,
          TO_CHAR(DATE_TRUNC('hour', convert_timezone('{{ _user_attributes['user_timezone'] }}',report_timestamp) ), 'YYYY-MM-DD HH24')
      )
      {% else %}
      , battery_voltage_levels as (
      select
        NULL as asset_id,
        NULL as report_date,
        NULL as daily_average_battery_voltage
      )
      {%  endif %}
      {% if run_time_with._parameter_value == "'Fuel Level'" and daily_or_hourly_selection._parameter_value == "'Hourly'" %}
      , daily_avg_fuel_level as (
      select
        al.asset_id,
        TO_CHAR(DATE_TRUNC('hour', convert_timezone('{{ _user_attributes['user_timezone'] }}',report_timestamp) ), 'YYYY-MM-DD HH24') as report_date,
        coalesce(round(avg(fuel_level),2),0) as daily_avg_fuel_level
      from
          asset_list_own al
          inner join asset_engine_statuses aes on al.asset_id = aes.asset_id
          inner join assets a on a.asset_id = al.asset_id
      where
          report_timestamp >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %})
          AND report_timestamp <= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})
      group by
          al.asset_id,
          TO_CHAR(DATE_TRUNC('hour', convert_timezone('{{ _user_attributes['user_timezone'] }}',report_timestamp) ), 'YYYY-MM-DD HH24')
      UNION
      select
          al.asset_id,
          TO_CHAR(DATE_TRUNC('hour', convert_timezone('{{ _user_attributes['user_timezone'] }}',report_timestamp) ), 'YYYY-MM-DD HH24') as report_date,
          coalesce(round(avg(fuel_level),2),0) as daily_avg_fuel_level
      from
          asset_list_rental al
          inner join asset_engine_statuses aes on al.asset_id = aes.asset_id
          inner join assets a on a.asset_id = al.asset_id
      where
          report_timestamp >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %})
          AND report_timestamp <= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})
      group by
          al.asset_id,
          TO_CHAR(DATE_TRUNC('hour', convert_timezone('{{ _user_attributes['user_timezone'] }}',report_timestamp) ), 'YYYY-MM-DD HH24')
      )
      {% else %}
      , daily_avg_fuel_level as (
      select
        NULL as asset_id,
        NULL as report_date,
        NULL as daily_avg_fuel_level
      )
      {%  endif %}
      , asset_id_list as (
      select
        alo.asset_id
      from
        asset_list_own alo
        left join own_run_time ort on alo.asset_id = ort.asset_id
      union
      select
        alr.asset_id
      from
        asset_list_rental alr
        left join rental_run_time rrt on rrt.asset_id = alr.asset_id
      )
      , asset_run_time as (
      select
        asset_id,
        start_date,
        on_time
      from
        own_run_time
      union
      select
        asset_id,
        rental_start_date,
        on_time
      from
        rental_run_time
      )
      , asset_total_run_time as (
      select
        asset_id,
        round((sum(on_time)/3600),2) as total_duration_run_time
      from
        asset_run_time
      group by
        asset_id
      )
      select
          'Hourly' as selection,
          al.asset_id,
          a.custom_name,
          ds.day,
          round(coalesce(art.on_time/3600,0),2) as run_time_hrs,
          coalesce(bl.daily_average_battery_voltage,0) as daily_average_battery_voltage,
          coalesce(fl.daily_avg_fuel_level,0) as daily_fuel_level,
          coalesce(atrt.total_duration_run_time,0) as total_duration_run_time
      from
          asset_id_list al
          left join date_series ds on 1=1
          left join asset_run_time art on art.asset_id = al.asset_id and art.start_date = ds.day
          left join battery_voltage_levels bl on bl.asset_id = al.asset_id and bl.report_date = ds.day
          left join daily_avg_fuel_level fl on fl.asset_id = al.asset_id and fl.report_date = ds.day
          join assets a on al.asset_id = a.asset_id and a.deleted = FALSE and a.asset_type_id in (1,2)
          left join asset_total_run_time atrt on atrt.asset_id = a.asset_id
      {% else %}
      {%  endif %}
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(${asset_id},${day_raw}) ;;
  }

  dimension: selection {
    type: string
    sql: ${TABLE}."SELECTION" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: custom_name {
    type: string
    sql: ${TABLE}."CUSTOM_NAME" ;;
  }

  dimension_group: day {
    type: time
    sql: ${TABLE}."DAY" ;;
  }

  dimension: run_time_hrs {
    type: number
    sql: ${TABLE}."RUN_TIME_HRS" ;;
  }

  dimension: daily_average_battery_voltage {
    type: number
    sql: ${TABLE}."DAILY_AVERAGE_BATTERY_VOLTAGE" ;;
  }

  dimension: daily_fuel_level {
    type: number
    sql: ${TABLE}."DAILY_FUEL_LEVEL" ;;
  }

  dimension: total_duration_run_time {
    type: number
    sql: ${TABLE}."TOTAL_DURATION_RUN_TIME" ;;
  }

  filter: date_filter {
    type: date_time
  }

  parameter: daily_or_hourly_selection {
    type: string
    allowed_value: { value: "Daily"}
    allowed_value: { value: "Hourly"}
  }

  dimension: dynamic_daily_or_hourly_selection {
    label_from_parameter: daily_or_hourly_selection
    sql:{% if daily_or_hourly_selection._parameter_value == "'Daily'" %}
      ${selection}
    {% elsif daily_or_hourly_selection._parameter_value == "'Hourly'" %}
      ${selection}
    {% else %}
      NULL
    {% endif %} ;;
  }

  parameter: show_battery_voltage {
    type: string
    allowed_value: { value: "Yes"}
    allowed_value: { value: "No"}
  }

  dimension: dynamic_show_battery_voltage {
    label_from_parameter: show_battery_voltage
    sql:{% if show_battery_voltage._parameter_value == "'Yes'" %}
      ${selection}
    {% elsif show_battery_voltage._parameter_value == "'No'" %}
      ${selection}
    {% else %}
      NULL
    {% endif %} ;;
  }

  parameter: show_fuel_level {
    type: string
    allowed_value: { value: "Yes"}
    allowed_value: { value: "No"}
  }

  dimension: dynamic_show_fuel_level {
    label_from_parameter: show_fuel_level
    sql:{% if show_fuel_level._parameter_value == "'Yes'" %}
      ${selection}
    {% elsif show_fuel_level._parameter_value == "'No'" %}
      ${selection}
    {% else %}
      NULL
    {% endif %} ;;
  }

  dimension: dynamic_timeframe {
    label: "Date"
    type: string
    sql:
    CASE
    WHEN {% parameter daily_or_hourly_selection %} = 'Daily' THEN ${day_date}
    WHEN {% parameter daily_or_hourly_selection %} = 'Hourly' THEN ${day_time}
    END ;;
    html: {% if daily_or_hourly_selection._parameter_value == "'Daily'" %}
    {{ rendered_value | date: "%b %d, %Y" }}
    {% else %}
    <p>{{rendered_value | date: "%b %d, %Y %r"}} </p>
    {% endif %} ;;
  }

  parameter: show_battery_voltage_when_engine_is {
    type: string
    allowed_value: { value: "Active"}
    allowed_value: { value: "Not Active"}
    allowed_value: { value: "Active/Not Active"}
  }

  parameter: run_time_with {
    type: string
    allowed_value: { value: "Battery Voltage"}
    allowed_value: { value: "Fuel Level"}
  }

  measure: dynamic_run_time_with {
    type: number
    label_from_parameter: run_time_with
    sql:{% if run_time_with._parameter_value == "'Battery Voltage'" %}
      ${average_battery_voltage}
    {% elsif run_time_with._parameter_value == "'Fuel Level'" %}
      ${average_fuel_level}
    {% else %}
      NULL
    {% endif %} ;;
    html: {% if run_time_with._parameter_value == "'Battery Voltage'" %}
    {{ rendered_value }} V
    {% else %}
    {{rendered_value }} %
    {% endif %} ;;
  }

  measure: total_run_time {
    type: sum
    sql: ${run_time_hrs} ;;
    value_format_name: decimal_1
    html: {{rendered_value}} hrs. ;;
  }

  measure: average_battery_voltage {
    type: average
    sql: ${daily_average_battery_voltage} ;;
    value_format_name: decimal_1
  }

  measure: average_fuel_level {
    type: average
    sql: ${daily_fuel_level} ;;
    value_format_name: decimal_1
  }

  dimension: asset_with_run_time {
    type: string
    sql: concat(${custom_name},' (',${total_duration_run_time},' hrs)') ;;
  }

  set: detail {
    fields: [asset_id, day_time, run_time_hrs, daily_average_battery_voltage, daily_fuel_level]
  }
}
