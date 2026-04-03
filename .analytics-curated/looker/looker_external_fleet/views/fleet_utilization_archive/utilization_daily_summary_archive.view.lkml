view: utilization_daily_summary_archive {
 derived_table: {
  sql:
    with last_check as (
          select
          asset_id
          , max(last_checkin_timestamp_end_date) as last_check
          , max(hours) as hours_max
          , max(odometer) as odo_max
          from
          BUSINESS_INTELLIGENCE.TRIAGE.stg_t3__by_day_utilization_historical bdu
          where
          (bdu.owner_company_id = {{ _user_attributes['company_id'] }}
           or bdu.rental_company_id = {{ _user_attributes['company_id'] }})
          AND bdu.date >= {% date_start date_filter %}::date
          AND bdu.date <= {% date_end date_filter %}::date
          AND {% condition job_name_filter %} bdu.job_name {% endcondition %}
          AND {% condition phase_job_name_filter %} bdu.phase_job_name {% endcondition %}
          AND {% condition custom_name_filter %} bdu.custom_name {% endcondition %}
          AND {% condition asset_class_filter %} bdu.asset_class {% endcondition %}
          AND {% condition category_filter %} bdu.category {% endcondition %}
          AND {% condition branch_filter %} bdu.branch {% endcondition %}
          AND {% condition asset_type_filter %} bdu.asset_type {% endcondition %}
          AND {% condition tracker_grouping_filter %} bdu.tracker_grouping {% endcondition %}
          group by asset_id
          )
          , last_address as (
          select
          bdu.asset_id
          , bdu.address
          , bdu.geofences
          from
          BUSINESS_INTELLIGENCE.TRIAGE.stg_t3__by_day_utilization_historical bdu
          join last_check lc on lc.asset_id = bdu.asset_id and lc.last_check = bdu.last_checkin_timestamp_end_date
          where
          (bdu.owner_company_id = {{ _user_attributes['company_id'] }}
           or bdu.rental_company_id = {{ _user_attributes['company_id'] }})
          AND bdu.date >= {% date_start date_filter %}::date
          AND bdu.date <= {% date_end date_filter %}::date
          AND {% condition job_name_filter %} bdu.job_name {% endcondition %}
          AND {% condition phase_job_name_filter %} bdu.phase_job_name {% endcondition %}
          AND {% condition custom_name_filter %} bdu.custom_name {% endcondition %}
          AND {% condition asset_class_filter %} bdu.asset_class {% endcondition %}
          AND {% condition category_filter %} bdu.category {% endcondition %}
          AND {% condition branch_filter %} bdu.branch {% endcondition %}
          AND {% condition asset_type_filter %} bdu.asset_type {% endcondition %}
          AND {% condition tracker_grouping_filter %} bdu.tracker_grouping {% endcondition %}
          )

     , pre as (
          select distinct
            bdu.*
          --, o.name as group_name
          , bdu.date as day
          ---, 95 as TOTAL_AVAILABLE_ASSETS
          , CONVERT_TIMEZONE('UTC', '{{ _user_attributes['user_timezone'] }}',lc.last_check::datetime) as last_checkin_timestamp
          , lc.hours_max
          , lc.odo_max
          , bdu.geofences as geofence
          , la.geofences as geofence_max
          , la.address as address_max
          , case
          when bdu.owner_company_id = {{ _user_attributes['company_id'] }} then 'Owned'
          when bdu.rental_company_id = {{ _user_attributes['company_id'] }} then 'Rented'
          else NULL
          end as rented_vs_owned
          , case
          when bdu.owner_company_id = {{ _user_attributes['company_id'] }} then owned_asset_count
          when bdu.rental_company_id = {{ _user_attributes['company_id'] }} then rental_asset_count
          else 0
          end as TOTAL_AVAILABLE_ASSETS
          ,
          {% if show_in_progress_trips._parameter_value == "'No'" %}
          case
          when '{{ _user_attributes['user_timezone'] }}' = 'UTC' then NULLIF(on_time_utc / 60 / 60,0)
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Chicago' then NULLIF(on_time_cst/ 60 / 60,0)
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Denver' then NULLIF(on_time_mnt/ 60 / 60,0)
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Los_Angeles' then NULLIF(on_time_wst/ 60 / 60,0)
          --- else is Eastern Standard Time
          else NULLIF(on_time_est/ 60 / 60,0)
          {% else %}
          case
          when '{{ _user_attributes['user_timezone'] }}' = 'UTC' then COALESCE(on_time_utc/ 60 / 60,0) + COALESCE(in_progress_on_time_utc/ 60 / 60,0)
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Chicago' then COALESCE(on_time_cst/ 60 / 60,0) + COALESCE(in_progress_on_time_cst/ 60 / 60,0)
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Denver' then COALESCE(on_time_mnt/ 60 / 60,0) + COALESCE(in_progress_on_time_mnt/ 60 / 60,0)
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Los_Angeles' then COALESCE(on_time_wst/ 60 / 60,0) + COALESCE(in_progress_on_time_wst/ 60 / 60,0)
          --- else is Eastern Standard Time
          else COALESCE(on_time_est/ 60 / 60,0) + COALESCE(in_progress_on_time_est/ 60 / 60,0)
        {% endif %}
          end as total_on_time
          ,
          from
          BUSINESS_INTELLIGENCE.TRIAGE.stg_t3__by_day_utilization_historical bdu
          left join last_check lc on lc.asset_id = bdu.asset_id
          left join last_address la on la.asset_id = bdu.asset_id
          left join es_warehouse.public.organization_asset_xref oax on bdu.asset_id = oax.asset_id
          left join es_warehouse.public.organizations o on oax.organization_id = o.organization_id
          where
          (bdu.owner_company_id = {{ _user_attributes['company_id'] }}
           or bdu.rental_company_id = {{ _user_attributes['company_id'] }})
          --and o.company_id = {{ _user_attributes['company_id'] }}

          AND bdu.date >= {% date_start date_filter %}::date
          AND bdu.date <= {% date_end date_filter %}::date

          AND {% condition job_name_filter %} bdu.job_name {% endcondition %}
          AND {% condition phase_job_name_filter %} bdu.phase_job_name {% endcondition %}
          AND {% condition custom_name_filter %} bdu.custom_name {% endcondition %}
          AND {% condition asset_class_filter %} bdu.asset_class {% endcondition %}
          AND {% condition groups_filter %} o.name {% endcondition %}
          AND {% condition ownership_filter %} rented_vs_owned {% endcondition %}
          AND {% condition category_filter %} bdu.category {% endcondition %}
          AND {% condition branch_filter %} bdu.branch {% endcondition %}
          AND {% condition asset_type_filter %} bdu.asset_type {% endcondition %}
          AND {% condition tracker_grouping_filter %} bdu.tracker_grouping {% endcondition %}
          AND
           {% if show_assets_no_contact_over_72_hrs._parameter_value == "'Yes'" %}
            1 = 1
           {% else %}
           bdu.contact_in_72_Hours = 'Yes'
           {% endif %}
           AND
           {% if show_weekends._parameter_value == "'Yes'" %}
            1 = 1
           {% else %}
           bdu.weekend_flag = '0'
           {% endif %}
      )
       ,days_for_calculation as (
      select
        {% if show_weekends._parameter_value == "'Yes'" %}
        0
        {% else %}
        sum(weekend_flag)
        {% endif %} as total_weekend_days,

        (datediff(day,min(pre.day),max(pre.day)) -
        {% if show_weekends._parameter_value == "'Yes'" %}
        0
        {% else %}
        sum(weekend_flag)
        {% endif %}
        ) +1 as date_filter_difference
        from
        pre
      --group by weekend_flag
          )
      select
          pre.day
        , pre.day_name
        , pre.rented_vs_owned
        --, total_weekend_days
        , COALESCE(sum(weekend_flag) / count(day), 0 ) as total_weekend_days
        --, COALESCE(NULLIF(sum(coalesce(round(pre.total_on_time,2),0)),0) / NULLIF(count(distinct pre.total_on_time),0),0) as total_on_time
        , sum(round(pre.total_on_time,2)) as total_on_time
        , count(distinct pre.asset_id) as total_available_assets
        , date_filter_difference
      from pre
      left join days_for_calculation dfc on 1=1
      group by
        pre.day
        , pre.day_name
        , pre.rented_vs_owned
        , total_weekend_days
        , date_filter_difference
    ;;
  }

measure: count {
  type: count
  drill_fields: [detail*]
}

dimension: primary_key {
  primary_key: yes
  type: string
  sql: concat(day,${total_on_time},${total_available_assets}) ;;
}

filter: date_filter {
  type: date_time
}

dimension: day {
  type: date
  sql: ${TABLE}."DAY" ;;
}

dimension: day_name {
  type: string
  sql: ${TABLE}."DAY_NAME" ;;
}

dimension: total_weekend_days {
  type: number
  sql: ${TABLE}."TOTAL_WEEKEND_DAYS" ;;
}

dimension: total_on_time {
  type: number
  sql: ${TABLE}."TOTAL_ON_TIME" ;;
}

dimension: total_available_assets {
  type: number
  sql: ${TABLE}."TOTAL_AVAILABLE_ASSETS" ;;
}

dimension: date_filter_difference {
  type: number
  sql: ${TABLE}."DATE_FILTER_DIFFERENCE" ;;
}

dimension: start_range_time_formatted {
  type: date
  group_label: "HTML Passed Date Format" label: "Date"
  sql: ${day} ;;
  html: {{ rendered_value | date: "%b %d, %Y"  }};;
}

measure: total_date_filter_difference {
  type: max
  sql: ${date_filter_difference} ;;
}

measure: total_selected_weekend_days {
  type: max
  sql: ${total_weekend_days} ;;
}

measure: total_selected_on_time {
  label: "Total On Time"
  type: sum
  sql: coalesce(round(${total_on_time},2),0) ;;
}

measure: total_selected_available_assets {
  label: "Total Available Assets"
  type: sum
  sql: ${total_available_assets};;
}

dimension: day_name_rank {
  type: number
  sql:
      case
        when ${day_name} = 'Mon' then 1
        when ${day_name} = 'Tue' then 2
        when ${day_name} = 'Wed' then 3
        when ${day_name} = 'Thu' then 4
        when ${day_name} = 'Fri' then 5
        when ${day_name} = 'Sat' then 6
        when ${day_name} = 'Sun' then 7
      end
      ;;
}

parameter: show_weekends {
  type: string
  allowed_value: { value: "Yes"}
  allowed_value: { value: "No"}
}

parameter: show_out_of_lock_assets {
  type: string
  allowed_value: { value: "Yes"}
  allowed_value: { value: "No"}
}

parameter: show_assets_no_contact_over_72_hrs {
  type: string
  allowed_value: { value: "Yes"}
  allowed_value: { value: "No"}
}

parameter: show_in_progress_trips {
  type: string
  allowed_value: { value: "Yes"}
  allowed_value: { value: "No"}
}

parameter: utilization_hours {
  type: string
  allowed_value: { value: "1 Hour"}
  allowed_value: { value: "2 Hours"}
  allowed_value: { value: "3 Hours"}
  allowed_value: { value: "4 Hours"}
  allowed_value: { value: "5 Hours"}
  allowed_value: { value: "6 Hours"}
  allowed_value: { value: "7 Hours"}
  allowed_value: { value: "8 Hours"}
  allowed_value: { value: "10 Hours"}
  allowed_value: { value: "12 Hours"}
  allowed_value: { value: "24 Hours"}
}

measure: dynamic_average_utilization_percentage_by_day {
  # label_from_parameter: hourly_asset_usage_date_filter.utilization_hours
  label: "Utilization %"
  sql:
    coalesce(
    {% if utilization_hours._parameter_value == "'8 Hours'" %}
      ${daily_utilization_kpi_eight_hours}
    {% elsif utilization_hours._parameter_value == "'10 Hours'" %}
      ${daily_utilization_kpi_ten_hours}
    {% elsif utilization_hours._parameter_value == "'12 Hours'" %}
      ${daily_utilization_kpi_twelve_hours}
    {% elsif utilization_hours._parameter_value == "'24 Hours'" %}
      ${daily_utilization_kpi_twenty_four_hours}
    {% elsif utilization_hours._parameter_value == "'1 Hour'" %}
      ${daily_utilization_kpi_one_hours}
    {% elsif utilization_hours._parameter_value == "'2 Hours'" %}
      ${daily_utilization_kpi_two_hours}
    {% elsif utilization_hours._parameter_value == "'3 Hours'" %}
      ${daily_utilization_kpi_three_hours}
    {% elsif utilization_hours._parameter_value == "'4 Hours'" %}
      ${daily_utilization_kpi_four_hours}
    {% elsif utilization_hours._parameter_value == "'5 Hours'" %}
      ${daily_utilization_kpi_five_hours}
    {% elsif utilization_hours._parameter_value == "'6 Hours'" %}
      ${daily_utilization_kpi_six_hours}
    {% elsif utilization_hours._parameter_value == "'7 Hours'" %}
      ${daily_utilization_kpi_seven_hours}
    {% else %}
      NULL
    {% endif %},0) ;;
  html: {{rendered_value}}
          <br />Available Assets <br />{{ total_selected_available_assets._rendered_value }}
          <br />Total Run Time <br />{{total_selected_on_time._rendered_value}} hrs.;;
  type: number
  value_format_name: percent_1
}

measure: daily_utilization_kpi_eight_hours {
  type: number
  sql:
    ((${total_selected_on_time})/(8))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    ;;
  value_format_name: percent_1
}

measure: daily_utilization_kpi_ten_hours {
  type: number
  sql:
    ((${total_selected_on_time})/(10))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    ;;
  value_format_name: percent_1
}

measure: daily_utilization_kpi_twelve_hours {
  type: number
  sql:
    ((${total_selected_on_time})/(12))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    ;;
  value_format_name: percent_1
}

measure: daily_utilization_kpi_twenty_four_hours {
  type: number
  sql:
    ((${total_selected_on_time})/(24))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    ;;
  value_format_name: percent_1
}

measure: daily_utilization_kpi_one_hours {
  type: number
  sql:
    ((${total_selected_on_time})/(1))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    ;;
  value_format_name: percent_1
}

measure: daily_utilization_kpi_two_hours {
  type: number
  sql:
    ((${total_selected_on_time})/(2))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    ;;
  value_format_name: percent_1
}

measure: daily_utilization_kpi_three_hours {
  type: number
  sql:
    ((${total_selected_on_time})/(3))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    ;;
  value_format_name: percent_1
}

measure: daily_utilization_kpi_four_hours {
  type: number
  sql:
    ((${total_selected_on_time})/(4))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    ;;
  value_format_name: percent_1
}

measure: daily_utilization_kpi_five_hours {
  type: number
  sql:
    ((${total_selected_on_time})/(5))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    ;;
  value_format_name: percent_1
}

measure: daily_utilization_kpi_six_hours {
  type: number
  sql:
    ((${total_selected_on_time})/(6))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    ;;
  value_format_name: percent_1
}

measure: daily_utilization_kpi_seven_hours {
  type: number
  sql:
    ((${total_selected_on_time})/(7))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    ;;
  value_format_name: percent_1
}

measure: average_utilization_kpi_eight_hours {
  type: number
  sql:
    case
    when ${total_date_filter_difference} >= 5 then
    ((${total_selected_on_time})/((8*5/7)*${total_date_filter_difference}))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    when (${total_date_filter_difference} = 1 AND ${total_selected_weekend_days} = 1) OR (${total_date_filter_difference} = 2 AND ${total_selected_weekend_days} = 2) then
    ((${total_selected_on_time})/((8)*${total_date_filter_difference}))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    when ${total_date_filter_difference} < 5 AND ${total_selected_weekend_days} >= 1 then
    ((${total_selected_on_time})/((8)*(${total_date_filter_difference}-${total_selected_weekend_days})))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    when ${total_date_filter_difference} < 5 AND ${total_selected_weekend_days} = 0 then
    ((${total_selected_on_time})/((8)*${total_date_filter_difference}))/(case when (${total_selected_available_assets}) = 0 then null else (${total_selected_available_assets}) end)
    end
    ;;
  value_format_name: percent_1
  # value_format_name: decimal_1
  # html: {{rendered_value}}% ;;
}

measure: average_utilization_daily_rate {
  # label_from_parameter: hourly_asset_usage_date_filter.utilization_hours
  label: "Average Daily Utilization %"
  sql:
    coalesce(
    {% if utilization_hours._parameter_value == "'8 Hours'" %}
      ${daily_utilization_kpi_eight_hours}
    {% elsif utilization_hours._parameter_value == "'10 Hours'" %}
      ${daily_utilization_kpi_ten_hours}
    {% elsif utilization_hours._parameter_value == "'12 Hours'" %}
      ${daily_utilization_kpi_twelve_hours}
    {% elsif utilization_hours._parameter_value == "'24 Hours'" %}
      ${daily_utilization_kpi_twenty_four_hours}
    {% elsif utilization_hours._parameter_value == "'1 Hour'" %}
      ${daily_utilization_kpi_one_hours}
    {% elsif utilization_hours._parameter_value == "'2 Hours'" %}
      ${daily_utilization_kpi_two_hours}
    {% elsif utilization_hours._parameter_value == "'3 Hours'" %}
      ${daily_utilization_kpi_three_hours}
    {% elsif utilization_hours._parameter_value == "'4 Hours'" %}
      ${daily_utilization_kpi_four_hours}
    {% elsif utilization_hours._parameter_value == "'5 Hours'" %}
      ${daily_utilization_kpi_five_hours}
    {% elsif utilization_hours._parameter_value == "'6 Hours'" %}
      ${daily_utilization_kpi_six_hours}
    {% elsif utilization_hours._parameter_value == "'7 Hours'" %}
      ${daily_utilization_kpi_seven_hours}
    {% else %}
      NULL
    {% endif %},0) ;;
  type: number
  value_format_name: percent_1
}

filter: custom_name_filter {
  suggest_explore: asset_utilization_by_day
  suggest_dimension: asset_utilization_by_day.asset
}

filter: groups_filter {
  suggest_explore: asset_utilization_by_day
  suggest_dimension: asset_utilization_by_day.group_name
}

filter: ownership_filter {
  suggest_explore: asset_utilization_by_day
  suggest_dimension: asset_utilization_by_day.ownership
}

filter: asset_class_filter {
  suggest_explore: asset_utilization_by_day
  suggest_dimension: asset_utilization_by_day.asset_class
}

filter: branch_filter {
  suggest_explore: asset_utilization_by_day
  suggest_dimension: asset_utilization_by_day.branch
}

filter: category_filter {
  suggest_explore: asset_utilization_by_day
  suggest_dimension: asset_utilization_by_day.category
}

filter: asset_type_filter {
  suggest_explore: asset_utilization_by_day
  suggest_dimension: asset_utilization_by_day.asset_type
}

filter: tracker_grouping_filter {
  suggest_explore: asset_utilization_by_day
  suggest_dimension: asset_utilization_by_day.tracker_grouping
}

filter: job_name_filter {
  suggest_explore: job_list
  suggest_dimension: job_list.job_name
}

filter: phase_job_name_filter {
  suggest_explore: job_list
  suggest_dimension: job_list.phase_job_name
}

set: detail {
  fields: [day, day_name, total_on_time, total_available_assets, date_filter_difference]
}
}
