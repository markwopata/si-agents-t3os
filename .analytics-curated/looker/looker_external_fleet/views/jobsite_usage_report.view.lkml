view: jobsite_usage_report {
  derived_table: {
    sql: with asset_list_own as (
      select asset_id
      from table(assetlist({{ _user_attributes['user_id'] }}::numeric))
      )
      ,own_geofence as (
      select
          al.asset_id,
          convert_timezone('{{ _user_attributes['user_timezone'] }}',report_range:start_range)::date as start_date,
          convert_timezone('{{ _user_attributes['user_timezone'] }}',report_range:end_range)::date as end_date,
          hagu.geofence_id,
          g.name as geofence_name,
          sum(hours) as run_time_on_site
      from
          asset_list_own al
          left join es_warehouse.public.hourly_asset_geofence_usage hagu on al.asset_id = hagu.asset_id
          left join geofences g on g.geofence_id = hagu.geofence_id
      where
          report_range:start_range >= COALESCE(convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %}),convert_timezone('{{ _user_attributes['user_timezone'] }}', current_timestamp)::date::timestamp_ntz - interval '10 days')
          AND report_range:end_range <= COALESCE(convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %}),convert_timezone('{{ _user_attributes['user_timezone'] }}', current_timestamp)::date::timestamp_ntz)
          AND g.company_id = {{ _user_attributes['company_id'] }}
      group by
          al.asset_id,
          convert_timezone('{{ _user_attributes['user_timezone'] }}',report_range:start_range)::date,
          convert_timezone('{{ _user_attributes['user_timezone'] }}',report_range:end_range)::date,
          hagu.geofence_id,
          g.name
      )
      ,asset_list_rental as (
      select rl.asset_id, rl.start_date, rl.end_date
      from table(rental_asset_list({{ _user_attributes['user_id'] }}::numeric,
      convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}),
      convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}),
      'America/Chicago')) rl
      join assets a on a.asset_id = rl.asset_id
          where
          a.company_id <> {{ _user_attributes['company_id'] }}
      ),
      rental_geofence as (
      select
          alr.asset_id,
          convert_timezone('{{ _user_attributes['user_timezone'] }}',report_range:start_range)::date as rental_start_date,
          convert_timezone('{{ _user_attributes['user_timezone'] }}',report_range:end_range)::date as rental_end_date,
          hagu.geofence_id,
          g.name as geofence_name,
          sum(hours) as run_time_on_site
      from
          asset_list_rental alr
          left join es_warehouse.public.hourly_asset_geofence_usage hagu on alr.asset_id = hagu.asset_id and hagu.report_range:start_range >= alr.start_date AND hagu.report_range:end_range <= alr.end_date
          left join geofences g on g.geofence_id = hagu.geofence_id
      where
          report_range:start_range >= COALESCE(convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %}),convert_timezone('{{ _user_attributes['user_timezone'] }}', current_timestamp)::date::timestamp_ntz - interval '10 days')
          AND report_range:end_range <= COALESCE(convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %}),convert_timezone('{{ _user_attributes['user_timezone'] }}', current_timestamp)::date::timestamp_ntz)
          AND g.company_id = {{ _user_attributes['company_id'] }}
      group by
          alr.asset_id,
          convert_timezone('{{ _user_attributes['user_timezone'] }}',report_range:start_range)::date,
          convert_timezone('{{ _user_attributes['user_timezone'] }}',report_range:end_range)::date,
          hagu.geofence_id,
          g.name
      ),
      date_series as (
      select
        series::date as date
      from table
        (generate_series(
        convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %})::timestamp_tz,
        convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})::timestamp_tz,
        'day')
      ))
      ,utilization_info as (
      select
          alo.asset_id,
          'own' as ownership_type,
          geofence_id,
          geofence_name,
          start_date,
          end_date,
          coalesce(sum(run_time_on_site),0) as run_time_on_site
      from
          asset_list_own alo
          join own_geofence og on alo.asset_id = og.asset_id
      group by
          alo.asset_id,
          geofence_id,
          geofence_name,
          start_date,
          end_date
      UNION
      select
          alr.asset_id,
          'rented' as ownership_type,
          geofence_id,
          geofence_name,
          rental_start_date as start_date,
          rental_end_date as end_date,
          coalesce(sum(run_time_on_site),0) as run_time_on_site
      from
          asset_list_rental alr
          join rental_geofence rg on alr.asset_id = rg.asset_id
      group by
          alr.asset_id,
          geofence_id,
          geofence_name,
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
       , phases as (
        select
          o.job_id
        , r.asset_id
        , r.start_date
        , r.end_date
        , j.name as phase_job_name
        , j.job_id as phase_job_id
        , jp.job_id as job_id
        , jp.name as job_name
        from
        es_warehouse.public.orders o
        left join es_warehouse.public.rentals r on (r.order_id = o.order_id)
        join es_warehouse.public.jobs j on (j.job_id = o.job_id) and j.parent_job_id is not null
        left join es_warehouse.public.jobs jp on (j.parent_job_id = jp.job_id)
        where
         r.asset_id is not null
        and r.deleted = false
        and o.deleted = false
        )
        , job_name_list as (
        select
          o.job_id
        , r.asset_id
        , r.start_date
        , r.end_date
        , NULL as phase_job_name
        , NULL as phase_job_id
        , j.job_id
        , j.name as job_name

        from
        es_warehouse.public.orders o
        left join es_warehouse.public.rentals r on (r.order_id = o.order_id)
        join es_warehouse.public.jobs j on (j.job_id = o.job_id) and j.parent_job_id is null
        where
         r.asset_id is not null
        and r.deleted = false
        and o.deleted = false
        )
        , jobs_list as (

        Select * from phases
        UNION
        Select * from job_name_list
        )
      select
          aa.date,
          aa.asset_id,
          ownership_type,
          geofence_id,
          geofence_name,
          coalesce(run_time_on_site,0) as run_time_on_site,
          jl.job_name,
          jl.phase_job_name
      from
         available_asset_dates aa
         left join utilization_info ui on aa.date = ui.start_date and aa.asset_id = ui.asset_id
         left join jobs_list jl on jl.asset_id = aa.asset_id and jl.start_date <= aa.date and jl.end_date >= aa.date
        where
            {% condition job_name_filter %} jl.job_name {% endcondition %}
        AND {% condition phase_job_name_filter %} jl.phase_job_name {% endcondition %}
        AND
          geofence_id is not null
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: date {
    type: date
    sql: ${TABLE}."DATE" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(${date},${asset_id},${geofence_name}) ;;
  }

  dimension: ownership_type {
    type: string
    sql: ${TABLE}."OWNERSHIP_TYPE" ;;
  }

  dimension: geofence_id {
    type: number
    sql: ${TABLE}."GEOFENCE_ID" ;;
  }

  dimension: geofence_name {
    type: string
    sql: ${TABLE}."GEOFENCE_NAME" ;;
  }

  dimension: run_time_on_site {
    type: number
    sql: ${TABLE}."RUN_TIME_ON_SITE" ;;
    value_format_name: decimal_2
    html: <a href="#drillmenu" target="_self">{{rendered_value}} hrs.</a>;;
  }

  measure: total_run_time_on_site {
    type: sum
    sql: ${run_time_on_site} ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
    html: <a href="#drillmenu" target="_self">{{rendered_value}} hrs.</a>;;
  }

  measure: total_run_time_on_site_kpi {
    type: sum
    sql: ${run_time_on_site} ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  filter: date_filter {
    type: date_time
  }

  dimension: ownership {
    type: string
    sql: case when ${ownership_type} = 'own' then 'Owned' else 'Rental' end ;;
  }

  measure: days_on_site {
    type: count_distinct
    sql: ${date} ;;
    drill_fields: [detail*]
  }

  dimension: date_time_formatted {
    group_label: "HTML Passed Date Format" label: "Date"
    sql: ${date} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  measure: total_run_time_on_site_rental_equipment {
    type: sum
    sql: ${run_time_on_site} ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
    html: <a href="#drillmenu" target="_self">{{rendered_value}} hrs.</a>;;
    filters: [ownership_type: "rented",
      asset_types.asset_type: "Equipment"]
  }

  measure: total_run_time_on_site_rental_vehicles {
    type: sum
    sql: ${run_time_on_site} ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
    html: <a href="#drillmenu" target="_self">{{rendered_value}} hrs.</a>;;
    filters: [ownership_type: "rented",
      asset_types.asset_type: "Vehicle"]
  }

  measure: equipment_run_time {
    type: sum
    sql: ${run_time_on_site} ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
    html: <a href="#drillmenu" target="_self">{{rendered_value}} hrs.</a>;;
    filters: [asset_types.asset_type: "Equipment"]
  }

  measure: vehcile_run_time {
    type: sum
    sql: ${run_time_on_site} ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
    html: <a href="#drillmenu" target="_self">{{rendered_value}} hrs.</a>;;
    filters: [asset_types.asset_type: "Vehicle"]
  }

  measure: count_distinct_owned_assets {
    type: count_distinct
    sql: ${asset_id} ;;
    filters: [ownership: "Owned"]
  }

  measure: count_distinct_rental_assets {
    type: count_distinct
    sql: ${asset_id} ;;
    filters: [ownership: "Rental"]
  }

  dimension: job_name {
    type: string
    sql: ${TABLE}."JOB_NAME" ;;
  }

  dimension: phase_job_name {
    type: string
    sql: ${TABLE}."PHASE_JOB_NAME" ;;
  }

  filter: job_name_filter {
    suggest_explore: jobsite_usage_report
    suggest_dimension: jobsite_usage_report.job_name
  }

  filter: phase_job_name_filter {
    suggest_explore: jobsite_usage_report
    suggest_dimension: jobsite_usage_report.phase_job_name
  }

  set: detail {
    fields: [
      date_time_formatted,
      assets.custom_name,
      assets.make_and_model,
      ownership,
      geofence_name,
      run_time_on_site
    ]
  }
}
