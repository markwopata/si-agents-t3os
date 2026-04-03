view: asset_utilization_by_day_archive {
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
          , day_used_check as (
          select distinct
            concat(bdu.asset_id,bdu.date) as day_used_check
          , count(concat(bdu.asset_id,bdu.date)) as day_used_check_count
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
          GROUP BY concat(asset_id,date)
          )

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
          , {% if show_in_progress_trips._parameter_value == "'No'" %}
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
          end as on_time
          , case
          when '{{ _user_attributes['user_timezone'] }}' = 'UTC' then NULLIF(run_time_utc/ 60 / 60,0)
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Chicago' then NULLIF(run_time_cst/ 60 / 60,0)
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Denver' then NULLIF(run_time_mnt/ 60 / 60,0)
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Los_Angeles' then NULLIF(run_time_wst/ 60 / 60,0)
          --- else is Eastern Standard Time
          else NULLIF(run_time_est/ 60 / 60,0)
          end as run_time
          , case
          when '{{ _user_attributes['user_timezone'] }}' = 'UTC' then NULLIF(idle_time_utc/ 60 / 60,0)
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Chicago' then NULLIF(idle_time_cst/ 60 / 60,0)
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Denver' then NULLIF(idle_time_mnt/ 60 / 60,0)
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Los_Angeles' then NULLIF(idle_time_wst/ 60 / 60,0)
          --- else is Eastern Standard Time
          else NULLIF(idle_time_est/ 60 / 60,0)
          end as idle_time
          , case
          when '{{ _user_attributes['user_timezone'] }}' = 'UTC' then miles_driven_utc
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Chicago' then miles_driven_cst
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Denver' then miles_driven_mnt
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Los_Angeles' then miles_driven_wst
          --- else is Eastern Standard Time
          else miles_driven_est
          end as miles_driven
          , case
          when on_time > 0 then 1
          else 0
          end as day_used_calced
          , duc.day_used_check_count
          --, CEIL(day_used_calced / duc.day_used_check_count) as day_used_mod
          , day_used_calced / duc.day_used_check_count as day_used_mod
          , case
          when day_used_calced / duc.day_used_check_count = 0 and duc.day_used_check_count = 1 then 1
          when day_used_calced > 0 then day_used / duc.day_used_check_count
          else CEIL(day_used / duc.day_used_check_count)
          end as possible_utilization_days_calced
          from
          BUSINESS_INTELLIGENCE.TRIAGE.stg_t3__by_day_utilization_historical bdu
          left join last_check lc on lc.asset_id = bdu.asset_id
          left join last_address la on la.asset_id = bdu.asset_id
          left join es_warehouse.public.organization_asset_xref oax on bdu.asset_id = oax.asset_id
          left join es_warehouse.public.organizations o on oax.organization_id = o.organization_id
          left join day_used_check duc on duc.day_used_check = concat(bdu.asset_id,bdu.date)

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
       ;;
  }

dimension: primary_key {
  primary_key: yes
  type: string
  sql: concat(${day},${asset_id}) ;;
}

measure: count {
  type: count
  drill_fields: [run_time_detail*]
}

dimension: day {
  type: date
  sql: ${TABLE}."DAY" ;;
}

dimension: day_name {
  type: string
  sql: ${TABLE}."DAY_NAME" ;;
}

dimension: asset_id {
  type: number
  sql: ${TABLE}."ASSET_ID" ;;
}

dimension: asset {
  type: string
  sql: ${TABLE}."ASSET" ;;
}

dimension: job_id {
  type: number
  sql: ${TABLE}."JOB_ID" ;;
}

dimension: job_name {
  type: string
  sql: ${TABLE}."JOB_NAME" ;;
}

dimension: phase_job_id {
  type: number
  sql: ${TABLE}."PHASE_JOB_ID" ;;
}

dimension: phase_job_name {
  type: string
  sql: ${TABLE}."PHASE_JOB_NAME" ;;
}

# dimension: group_name {
#   type: string
#   sql: ${TABLE}."GROUP_NAME" ;;
# }

dimension: asset_class {
  label: "Class"
  type: string
  sql: ${TABLE}."ASSET_CLASS" ;;
}

dimension: category {
  type: string
  sql: ${TABLE}."CATEGORY" ;;
}

dimension: branch {
  type: string
  sql: ${TABLE}."BRANCH" ;;
}

dimension: make {
  type: string
  sql: ${TABLE}."MAKE" ;;
}

dimension: model {
  type: string
  sql: ${TABLE}."MODEL" ;;
}

dimension: serial_number_vin {
  type: string
  sql: ${TABLE}."SERIAL_NUMBER_VIN" ;;
}

dimension: asset_type {
  type: string
  sql: ${TABLE}."ASSET_TYPE" ;;
}

dimension: ownership {
  type: string
  sql: ${TABLE}."OWNERSHIP" ;;
}

dimension: tracker_grouping {
  type: string
  sql: ${TABLE}."tracker_grouping" ;;
}

dimension: driver_name {
  type: string
  sql: ${TABLE}."DRIVER_NAME" ;;
}

dimension: driver_vehicle_type{
  label: "Driver"
  type: string
  sql: CASE WHEN ${asset_type} = 'Vehicle' --vehicle asset type
         THEN COALESCE(${driver_name},'')
         ELSE ''
         END;;
}

dimension: possible_utilization_days {
  type: number
  sql: ${TABLE}."POSSIBLE_UTILIZATION_DAYS" ;;
}

# dimension: rental_status {
#   type: string
#   sql: ${TABLE}."RENTAL_STATUS" ;;
# }

dimension: used_unused_designation {
  type: string
  sql: ${TABLE}."USED_UNUSED_DESIGNATION" ;;
}

dimension: day_used {
  type: number
  sql: ${TABLE}."DAY_USED" ;;
}

# dimension: weekend_flag {
#   type: number
#   sql: ${TABLE}."WEEKEND_FLAG" ;;
# }

dimension: run_time {
  type: number
  sql: ${TABLE}."RUN_TIME" ;;
}

dimension: idle_time {
  type: number
  sql: ${TABLE}."IDLE_TIME" ;;
}

dimension: miles_driven {
  type: number
  sql: ${TABLE}."MILES_DRIVEN" ;;
}

dimension: on_time {
  type: number
  sql: ${TABLE}."ON_TIME" ;;
}

dimension: odometer {
  type: number
  sql: ${TABLE}."ODOMETER" ;;
  html: {{rendered_value}} mi. ;;
  value_format_name: decimal_1
}

dimension: hours {
  type: number
  sql: ${TABLE}."HOURS" ;;
  html: {{rendered_value}} hrs. ;;
  value_format_name: decimal_1
}

dimension_group: last_checkin_timestamp {
  type: time
  sql: ${TABLE}."LAST_CHECKIN_TIMESTAMP" ;;
}

dimension: address {
  label: "Last Address"
  type: string
  sql: ${TABLE}."ADDRESS" ;;
  html: <font color="blue "><u><a href="https://app.estrack.com/#/assets/all/asset/{{ assets.asset_id._value }}/history?selectedDate={{ current_date._value}}" target="_blank">{{value}}</a></font></u> ;;
}

dimension: geofence {
  label: "Last Geofence"
  type: string
  sql: ${TABLE}."GEOFENCE" ;;
  html: <font color="blue "><u><a href="https://app.estrack.com/#/assets/all/asset/{{ assets.asset_id._value }}/history?selectedDate={{ current_date._value}}" target="_blank">{{value}}</a></font></u> ;;
}

dimension_group: last_checkin_timestamp_end_date {
  group_label: "End Date"
  type: time
  sql: ${TABLE}."LAST_CHECKIN_TIMESTAMP_END_DATE" ;;
}

dimension: address_end_date {
  group_label: "End Date"
  label: "Last Address"
  type: string
  sql: ${TABLE}."ADDRESS" ;;
  html: <font color="blue "><u><a href="https://app.estrack.com/#/assets/all/asset/{{ assets.asset_id._value }}/history?selectedDate={{ current_date._value}}" target="_blank">{{value}}</a></font></u> ;;
}

dimension: geofence_end_date {
  group_label: "End Date"
  label: "Last Geofence"
  type: string
  sql: ${TABLE}."GEOFENCE" ;;
  html: <font color="blue "><u><a href="https://app.estrack.com/#/assets/all/asset/{{ assets.asset_id._value }}/history?selectedDate={{ current_date._value}}" target="_blank">{{value}}</a></font></u> ;;
}

  dimension: address_end_date_max {
    group_label: "End Date Max"
    label: "Last Address"
    type: string
    sql: ${TABLE}."ADDRESS_MAX" ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/assets/all/asset/{{ assets.asset_id._value }}/history?selectedDate={{ current_date._value}}" target="_blank">{{value}}</a></font></u> ;;
  }

  dimension: geofence_end_date_max {
    group_label: "End Date Max"
    label: "Last Geofence"
    type: string
    sql: ${TABLE}."GEOFENCE_MAX" ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/assets/all/asset/{{ assets.asset_id._value }}/history?selectedDate={{ current_date._value}}" target="_blank">{{value}}</a></font></u> ;;
  }

dimension: location_address {
  label: "Location"
  type: string
  sql: ${address} ;;
  html: <font color="blue "><u><a href="https://app.estrack.com/#/assets/all/asset/{{ assets.asset_id._value }}/history?selectedDate={{ current_date._value}}" target="_blank">{{value}}</a></font></u> ;;
}

dimension: location_address_end_date {
  group_label: "End Date"
  label: "Location"
  type: string
  sql: coalesce(${address_end_date},${geofence_end_date}) ;;
  html: <font color="blue "><u><a href="https://app.estrack.com/#/assets/all/asset/{{ assets.asset_id._value }}/history?selectedDate={{ current_date._value}}" target="_blank">{{value}}</a></font></u> ;;
}

  dimension: location_address_end_date_max {
    group_label: "End Date Max"
    label: "Location"
    type: string
    sql: coalesce(${address_end_date_max},${geofence_end_date_max}) ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/assets/all/asset/{{ assets.asset_id._value }}/history?selectedDate={{ current_date._value}}" target="_blank">{{value}}</a></font></u> ;;
  }

parameter: show_last_location_options {
  type: string
  allowed_value: { value: "Default"}
  allowed_value: { value: "Geofence"}
  allowed_value: { value: "Address"}
}

dimension: dynamic_last_location {
  label_from_parameter: show_last_location_options
  sql:{% if show_last_location_options._parameter_value == "'Default'" %}
      ${location_address}
    {% elsif show_last_location_options._parameter_value == "'Geofence'" %}
      ${geofence}
    {% elsif show_last_location_options._parameter_value == "'Address'" %}
      ${address}
    {% else %}
      NULL
    {% endif %} ;;
}

dimension: dynamic_last_location_end_date {
  label_from_parameter: show_last_location_options
  sql:{% if show_last_location_options._parameter_value == "'Default'" %}
      ${location_address_end_date}
    {% elsif show_last_location_options._parameter_value == "'Geofence'" %}
      ${geofence_end_date}
    {% elsif show_last_location_options._parameter_value == "'Address'" %}
      ${address_end_date}
    {% else %}
      NULL
    {% endif %} ;;

}

  dimension: dynamic_last_location_end_date_max {
    label_from_parameter: show_last_location_options
    sql:{% if show_last_location_options._parameter_value == "'Default'" %}
      ${location_address_end_date_max}
    {% elsif show_last_location_options._parameter_value == "'Geofence'" %}
      ${geofence_end_date_max}
    {% elsif show_last_location_options._parameter_value == "'Address'" %}
      ${address_end_date_max}
    {% else %}
      NULL
    {% endif %} ;;
    }

dimension: current_date {
  type: date
  sql: current_date() ;;
}


dimension: day_formatted {
  type: date
  group_label: "HTML Passed Date Format" label: "Date"
  sql: ${day} ;;
  html: {{ rendered_value | date: "%b %d, %Y"  }};;
}

dimension: date_format_concat {
  type: string
  sql: to_varchar(${day}::date, 'mon dd, yyyy') ;;
}

dimension_group: last_checkin_timestamp_raw {
  type: time
  sql: ${TABLE}."LAST_CHECKIN_TIMESTAMP" ;;
}

dimension: last_checkin_timestamp_formatted {
  group_label: "HTML Format"
  label: "Last Check In"
  type: date_time
  sql: convert_timezone(('{{ _user_attributes['user_timezone'] }}'),${last_checkin_timestamp_raw}) ;;
  html: {{ rendered_value | date: "%b %d, %Y %r  "  }} {{ _user_attributes['user_timezone_label'] }};;
  skip_drill_filter: yes
}

dimension: last_checkin_timestamp_formatted_end_date {
  group_label: "End Date"
  label: "Last Check In"
  type: date_time
  sql: convert_timezone(('{{ _user_attributes['user_timezone'] }}'),${last_checkin_timestamp_end_date_raw}) ;;
  html: {{ rendered_value | date: "%b %d, %Y %r  "  }} {{ _user_attributes['user_timezone_label'] }};;
  skip_drill_filter: yes
}

dimension: date_with_name {
  type: string
  sql: concat(${date_format_concat}, ' ', '(', ${day_name}, ')') ;;
}

dimension: asset_custom_name_to_asset_info {
  group_label: "Link to T3"
  label: "Asset"
  type: string
  sql: ${asset};;
  html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id._filterable_value }}/status" target="_blank">{{value}}</a></font></u>;;
}

measure: dummy {
  hidden: yes
  type: number
  sql: 0 ;;
  drill_fields: [asset_details*]
}

dimension: view_asset_details {
  type: string
  sql: ${asset} ;;
  # fleet_utilization_asset_details_drilldown
  html: <a href="#drillmenu" target="_self"><font color="#0063f3">View Asset Detail <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
  # drill_fields: [asset_details*]
  link: {
    label: "View Asset Details"
    icon_url: "https://imgur.com/ZCNurvk.png"
    url: "{% assign vis= '{\"show_view_names\":false,
    \"show_row_numbers\":true,
    \"transpose\":false,
    \"truncate_text\":true,
    \"hide_totals\":false,
    \"hide_row_totals\":false,
    \"size_to_fit\":true,
    \"table_theme\":\"white\",
    \"limit_displayed_rows\":false,
    \"enable_conditional_formatting\":false,
    \"header_text_alignment\":\"left\",
    \"header_font_size\":12,
    \"rows_font_size\":12,
    \"conditional_formatting_include_totals\":false,
    \"conditional_formatting_include_nulls\":false,
    \"type\":\"looker_grid\",
    \"defaults_version\":1,
    \"series_types\":{}}' %}

    {% assign dynamic_fields= '[]' %}

    {{dummy._link}}&f&vis={{vis | encode_uri}}&dynamic_fields={{dynamic_fields | encode_uri}}"
  }
}

set: asset_details {
  fields: [asset_custom_name_to_asset_info, make_and_model, category, asset_class, fleet_utilization_asset_details_drilldown.hours, fleet_utilization_asset_details_drilldown.odometer,
    fleet_utilization_asset_details_drilldown.location_geofence, fleet_utilization_asset_details_drilldown.location_address, fleet_utilization_asset_details_drilldown.last_location_timestamp_formatted,
    fleet_utilization_asset_details_drilldown.last_checkin_timestamp_formatted]
}

measure: total_utilization_days {
  type: sum
  sql: ${possible_utilization_days} ;;
}

measure: dummy_run_time {
  hidden: yes
  type: number
  sql: 0 ;;
  drill_fields: [run_time_detail*]
}

measure: dummy_idle_time {
  hidden: yes
  type: number
  sql: 0 ;;
  drill_fields: [idle_time_detail*]
}

measure: dummy_miles_driven {
  hidden: yes
  type: number
  sql: 0 ;;
  drill_fields: [miles_driven_detail*]
}

measure: dummy_on_time {
  hidden: yes
  type: number
  sql: 0 ;;
  drill_fields: [on_time_detail*]
}

measure: hours_end {
  label: "Hours"
  type: max
  sql: ${hours} ;;
  html: <a href="#drillmenu" target="_self">{{rendered_value}} hrs.</a> ;;
  # drill_fields: [detail*]
  value_format_name: decimal_1
}

measure: odometer_end {
  label: "Odometer"
  type: max
  sql: ${odometer} ;;
  html: <a href="#drillmenu" target="_self">{{rendered_value}} mi.</a> ;;
  # drill_fields: [detail*]
  value_format_name: decimal_1
}

measure: last_location_end {
  label: "Last Location Test"
  required_fields: [dynamic_last_location]
  type: string
  sql: ${dynamic_last_location} ;;
  html: <a href="#drillmenu" target="_self">{{rendered_value}}</a> ;;
  # drill_fields: [detail*]
  value_format_name: decimal_2
}

measure: total_run_time_no_icon {
  type: sum
  sql: ${run_time} ;;
  html: <a href="#drillmenu" target="_self">{{rendered_value}} hrs.</a> ;;
  # drill_fields: [detail*]
  value_format_name: decimal_2
}

measure: total_run_time {
  type: sum
  sql: ${run_time} ;;
  html: <a href="#drillmenu" target="_self">{{rendered_value}} hrs.
    <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a> ;;
  # drill_fields: [detail*]
  link: {
    label: "View Run Time for Asset"
    icon_url: "https://imgur.com/ZCNurvk.png"
    url: "{% assign vis= '{\"x_axis_gridlines\":false,
    \"y_axis_gridlines\":true,
    \"show_view_names\":false,
    \"show_y_axis_labels\":true,
    \"show_y_axis_ticks\":true,
    \"y_axis_tick_density\":\"default\",
    \"y_axis_tick_density_custom\":5,
    \"show_x_axis_label\":true,
    \"show_x_axis_ticks\":true,
    \"y_axis_scale_mode\":\"linear\",
    \"x_axis_reversed\":false,
    \"y_axis_reversed\":false,
    \"plot_size_by_field\":false,
    \"trellis\":\"\",
    \"stacking\":\"\",
    \"limit_displayed_rows\":false,
    \"legend_position\":\"center\",
    \"point_style\":\"none\",
    \"show_value_labels\":false,
    \"label_density\":25,
    \"x_axis_scale\":\"auto\",
    \"y_axis_combined\":true,
    \"ordering\":\"none\",
    \"show_null_labels\":false,
    \"show_totals_labels\":false,
    \"show_silhouette\":false,
    \"totals_color\":\"#808080\",
    \"type\":\"looker_column\",
    \"defaults_version\":1}' %}

    {{dummy_run_time._link}}&f[asset_utilization_by_day_archive.asset_id]=&f[asset_utilization_by_day_archive.asset_class]=&sorts=asset_utilization_by_day_archive.day_formatted+desc&vis={{vis | encode_uri}}"
  }
  value_format_name: decimal_2
}

measure: total_idle_time_no_icon {
  type: sum
  sql: ${idle_time} ;;
  html: <a href="#drillmenu" target="_self">{{rendered_value}} hrs.</a> ;;
  # drill_fields: [detail*]
  value_format_name: decimal_2
}

measure: total_idle_time {
  type: sum
  sql: ${idle_time} ;;
  html: <a href="#drillmenu" target="_self">{{rendered_value}} hrs.
    <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a> ;;
  # drill_fields: [detail*]
  link: {
    label: "View Idle Time for Asset"
    icon_url: "https://imgur.com/ZCNurvk.png"
    url: "{% assign vis= '{\"x_axis_gridlines\":false,
    \"y_axis_gridlines\":true,
    \"show_view_names\":false,
    \"show_y_axis_labels\":true,
    \"show_y_axis_ticks\":true,
    \"y_axis_tick_density\":\"default\",
    \"y_axis_tick_density_custom\":5,
    \"show_x_axis_label\":true,
    \"show_x_axis_ticks\":true,
    \"y_axis_scale_mode\":\"linear\",
    \"x_axis_reversed\":false,
    \"y_axis_reversed\":false,
    \"plot_size_by_field\":false,
    \"trellis\":\"\",
    \"stacking\":\"\",
    \"limit_displayed_rows\":false,
    \"legend_position\":\"center\",
    \"point_style\":\"none\",
    \"show_value_labels\":false,
    \"label_density\":25,
    \"x_axis_scale\":\"auto\",
    \"y_axis_combined\":true,
    \"ordering\":\"none\",
    \"show_null_labels\":false,
    \"show_totals_labels\":false,
    \"show_silhouette\":false,
    \"totals_color\":\"#808080\",
    \"type\":\"looker_column\",
    \"defaults_version\":1}' %}

    {{dummy_idle_time._link}}&f[asset_utilization_by_day_archive.asset_id]=&f[asset_utilization_by_day_archive.asset_class]=&sorts=asset_utilization_by_day_archive.day_formatted+desc&vis={{vis | encode_uri}}"
  }
  value_format_name: decimal_2
}

measure: total_miles_driven_no_icon {
  type: sum
  sql: ${miles_driven} ;;
  html: <a href="#drillmenu" target="_self">{{rendered_value}} mi.</a> ;;
  # drill_fields: [detail*]
  value_format_name: decimal_2
}

measure: total_miles_driven {
  type: sum
  sql: ${miles_driven} ;;
  html: <a href="#drillmenu" target="_self">{{rendered_value}} mi.
    <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a> ;;
  # drill_fields: [detail*]
  link: {
    label: "View Miles Driven for Asset"
    icon_url: "https://imgur.com/ZCNurvk.png"
    url: "{% assign vis= '{\"x_axis_gridlines\":false,
    \"y_axis_gridlines\":true,
    \"show_view_names\":false,
    \"show_y_axis_labels\":true,
    \"show_y_axis_ticks\":true,
    \"y_axis_tick_density\":\"default\",
    \"y_axis_tick_density_custom\":5,
    \"show_x_axis_label\":true,
    \"show_x_axis_ticks\":true,
    \"y_axis_scale_mode\":\"linear\",
    \"x_axis_reversed\":false,
    \"y_axis_reversed\":false,
    \"plot_size_by_field\":false,
    \"trellis\":\"\",
    \"stacking\":\"\",
    \"limit_displayed_rows\":false,
    \"legend_position\":\"center\",
    \"point_style\":\"none\",
    \"show_value_labels\":false,
    \"label_density\":25,
    \"x_axis_scale\":\"auto\",
    \"y_axis_combined\":true,
    \"ordering\":\"none\",
    \"show_null_labels\":false,
    \"show_totals_labels\":false,
    \"show_silhouette\":false,
    \"totals_color\":\"#808080\",
    \"type\":\"looker_column\",
    \"defaults_version\":1}' %}

    {{dummy_miles_driven._link}}&f[asset_utilization_by_day_archive.asset_id]=&f[asset_utilization_by_day_archive.asset_class]=&sorts=asset_utilization_by_day_archive.day_formatted+desc&vis={{vis | encode_uri}}"
  }
  value_format_name: decimal_2
}

measure: total_on_time_no_icon {
  type: sum
  sql: ${on_time} ;;
  html: <a href="#drillmenu" target="_self">{{rendered_value}} hrs.</a> ;;
  # drill_fields: [detail*]
  value_format_name: decimal_2
}

measure: total_on_time {
  type: sum
  sql: ${on_time} ;;
  html: <a href="#drillmenu" target="_self">{{rendered_value}} hrs.
    <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a> ;;
  # drill_fields: [detail*]
  link: {
    label: "View On Time for Asset"
    icon_url: "https://imgur.com/ZCNurvk.png"
    url: "{% assign vis= '{\"x_axis_gridlines\":false,
    \"y_axis_gridlines\":true,
    \"show_view_names\":false,
    \"show_y_axis_labels\":true,
    \"show_y_axis_ticks\":true,
    \"y_axis_tick_density\":\"default\",
    \"y_axis_tick_density_custom\":5,
    \"show_x_axis_label\":true,
    \"show_x_axis_ticks\":true,
    \"y_axis_scale_mode\":\"linear\",
    \"x_axis_reversed\":false,
    \"y_axis_reversed\":false,
    \"plot_size_by_field\":false,
    \"trellis\":\"\",
    \"stacking\":\"\",
    \"limit_displayed_rows\":false,
    \"legend_position\":\"center\",
    \"point_style\":\"none\",
    \"show_value_labels\":false,
    \"label_density\":25,
    \"x_axis_scale\":\"auto\",
    \"y_axis_combined\":true,
    \"ordering\":\"none\",
    \"show_null_labels\":false,
    \"show_totals_labels\":false,
    \"show_silhouette\":false,
    \"totals_color\":\"#808080\",
    \"type\":\"looker_column\",
    \"defaults_version\":1}' %}

    {{dummy_on_time._link}}&f[asset_utilization_by_day_archive.asset_id]=&f[asset_utilization_by_day_archive.asset_class]=&sorts=asset_utilization_by_day_archive.day_formatted+desc&vis={{vis | encode_uri}}"
  }
  value_format_name: decimal_2
}

measure: total_run_time_drill_down {
  group_label: "Drill Downs"
  label: "Total Run Time"
  type: sum
  sql: ${run_time} ;;
  html: {{rendered_value}} hrs. ;;
  drill_fields: [run_time_detail*]
  value_format_name: decimal_2
}

measure: total_idle_time_drill_down {
  group_label: "Drill Downs"
  label: "Total Idle Time"
  type: sum
  sql: ${idle_time} ;;
  html: {{rendered_value}} hrs. ;;
  drill_fields: [idle_time_detail*]
  value_format_name: decimal_2
}

measure: total_miles_driven_drill_down {
  group_label: "Drill Downs"
  label: "Total Miles Driven"
  type: sum
  sql: ${miles_driven} ;;
  html: {{rendered_value}} mi. ;;
  drill_fields: [miles_driven_detail*]
  value_format_name: decimal_2
}

measure: total_on_time_drill_down {
  group_label: "Drill Downs"
  label: "Total On Time"
  type: sum
  sql: ${run_time} ;;
  html: {{rendered_value}} hrs. ;;
  drill_fields: [on_time_detail*]
  value_format_name: decimal_2
}

measure: total_days_used {
  type: sum
  sql: ${day_used} ;;
  html: <a href="#drillmenu" target="_self">{{rendered_value}}
    <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a> ;;
  # drill_fields: [detail*]
  link: {
    label: "View by Day Breakdown of Asset"
    icon_url: "https://imgur.com/ZCNurvk.png"
    url: "{% assign vis= '{\"x_axis_gridlines\":false,
    \"y_axis_gridlines\":true,
    \"show_view_names\":false,
    \"show_y_axis_labels\":true,
    \"show_y_axis_ticks\":true,
    \"y_axis_tick_density\":\"default\",
    \"y_axis_tick_density_custom\":5,
    \"show_x_axis_label\":true,
    \"show_x_axis_ticks\":true,
    \"y_axis_scale_mode\":\"linear\",
    \"x_axis_reversed\":false,
    \"y_axis_reversed\":false,
    \"plot_size_by_field\":false,
    \"trellis\":\"\",
    \"stacking\":\"\",
    \"limit_displayed_rows\":false,
    \"legend_position\":\"center\",
    \"point_style\":\"none\",
    \"show_value_labels\":false,
    \"label_density\":25,
    \"x_axis_scale\":\"auto\",
    \"y_axis_combined\":true,
    \"ordering\":\"none\",
    \"show_null_labels\":false,
    \"show_totals_labels\":false,
    \"show_silhouette\":false,
    \"totals_color\":\"#808080\",
    \"type\":\"looker_column\",
    \"defaults_version\":1}' %}

    {{dummy_run_time._link}}&f[asset_utilization_by_day_archive.asset_id]=&f[asset_utilization_by_day_archive.asset_class]=&sorts=asset_utilization_by_day_archive.day_formatted+desc&vis={{vis | encode_uri}}"
  }
}

measure: days_unused {
  type: number
  required_fields: [total_utilization_days]
  sql: coalesce(${total_utilization_days} - ${total_days_used},0) ;;
}

dimension: utilized_during_date {
  type: string
  sql: ${day_used} ;;
  html:
      {% if value > 0 %}
      <font color="#00CB86">✔</font>
      {% elsif value < 0 %}
      <font color="#DA344D">✘</font>
      {% else %}
      <font color="black">-</font>
      {% endif %} ;;
}

measure: total_assets {
  type: count_distinct
  sql: ${asset_id} ;;
}

measure: unused_asset_count {
  type: count_distinct
  sql: ${asset_id} ;;
  filters: [used_unused_designation: "unused"]
}

measure: used_asset_count {
  type: count_distinct
  sql: ${asset_id} ;;
  filters: [used_unused_designation: "used"]
}

dimension: asset_summary {
  # group_label: "Asset Summary"
  # label: "Work Order Information"
  type: string
  sql: 'Asset Summary' ;;
  html:
    <br/>
    <table>
    <tr>
      <td width="200px"><h4>Total Assets</h4></td>
      <td width="125px"><h4>{{total_assets._rendered_value}}</h4></td>
    </tr>
    <tr>
      <td width="200px"><h4>Number of Used Assets:</h4></td>
      <td width="125px"><h4>{{used_asset_count._rendered_value}}</h4></td>
    </tr>
    <tr>
      <td width="200px"><h4>Number of Unused Assets:</h4></td>
      <td width="125px"><h4>{{unused_asset_count._rendered_value}}</h4></td>
    </tr>
    <tr>
      <td width="200px"><h4>Total Run Time:</h4></td>
      <td width="125px"><h4>{{total_run_time_drill_down._rendered_value}} hrs.</h4></td>
    </tr>
    <tr>
      <td width="200px"><h4>Total Idle Time:</h4></td>
      <td width="125px"><h4>{{total_idle_time_drill_down._rendered_value}} hrs.</h4></td>
    </tr>
    <tr>
      <td width="200px"><h4>Total On Time:</h4></td>
      <td width="125px"><h4>{{total_on_time_drill_down._rendered_value}} hrs.</h4></td>
    </tr>
    <tr>
      <td width="200px"><h4>Total Miles Driven:</h4></td>
      <td width="125px"><h4>{{total_miles_driven_drill_down._rendered_value}} mi.</h4></td>
    </tr>
    <tr>
      <td></td>
      <td></td>
    </tr>
    </table>
      ;;
}

dimension: make_and_model {
  type: string
  sql: concat(${make},' ',${model}) ;;
}

filter: date_filter {
  type: date_time
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

measure: dynamic_utilization_percentage {
  label_from_parameter: utilization_hours
  sql:{% if utilization_hours._parameter_value == "'8 Hours'" %}
      round(${utilization_percentage_eight_hours}*100,1)
    {% elsif utilization_hours._parameter_value == "'10 Hours'" %}
      round(${utilization_percentage_ten_hours}*100,1)
    {% elsif utilization_hours._parameter_value == "'12 Hours'" %}
      round(${utilization_percentage_twelve_hours}*100,1)
    {% elsif utilization_hours._parameter_value == "'24 Hours'" %}
      round(${utilization_percentage_twenty_four_hours}*100,1)
    {% elsif utilization_hours._parameter_value == "'1 Hour'" %}
      round(${utilization_percentage_one_hours}*100,1)
    {% elsif utilization_hours._parameter_value == "'2 Hours'" %}
      round(${utilization_percentage_two_hours}*100,1)
    {% elsif utilization_hours._parameter_value == "'3 Hours'" %}
      round(${utilization_percentage_three_hours}*100,1)
    {% elsif utilization_hours._parameter_value == "'4 Hours'" %}
      round(${utilization_percentage_four_hours}*100,1)
    {% elsif utilization_hours._parameter_value == "'5 Hours'" %}
      round(${utilization_percentage_five_hours}*100,1)
    {% elsif utilization_hours._parameter_value == "'6 Hours'" %}
      round(${utilization_percentage_six_hours}*100,1)
    {% elsif utilization_hours._parameter_value == "'7 Hours'" %}
      round(${utilization_percentage_seven_hours}*100,1)
    {% else %}
      NULL
    {% endif %} ;;
  html: {{value}}% ;;
  # value_format_name: percent_1
}

measure: utilization_percentage_one_hours {
  type: number
  sql: coalesce(${total_run_time}/(1*(case when ${total_utilization_days} = 0 then null else ${total_utilization_days} end)),0) ;;
  value_format_name: percent_1
}

measure: utilization_percentage_two_hours {
  type: number
  sql: coalesce(${total_run_time}/(2*(case when ${total_utilization_days} = 0 then null else ${total_utilization_days} end)),0) ;;
  value_format_name: percent_1
}

measure: utilization_percentage_three_hours {
  type: number
  sql: coalesce(${total_run_time}/(3*(case when ${total_utilization_days} = 0 then null else ${total_utilization_days} end)),0) ;;
  value_format_name: percent_1
}

measure: utilization_percentage_four_hours {
  type: number
  sql: coalesce(${total_run_time}/(4*(case when ${total_utilization_days} = 0 then null else ${total_utilization_days} end)),0) ;;
  value_format_name: percent_1
}

measure: utilization_percentage_five_hours {
  type: number
  sql: coalesce(${total_run_time}/(5*(case when ${total_utilization_days} = 0 then null else ${total_utilization_days} end)),0) ;;
  value_format_name: percent_1
}

measure: utilization_percentage_six_hours {
  type: number
  sql: coalesce(${total_run_time}/(6*(case when ${total_utilization_days} = 0 then null else ${total_utilization_days} end)),0) ;;
  value_format_name: percent_1
}

measure: utilization_percentage_seven_hours {
  type: number
  sql: coalesce(${total_run_time}/(7*(case when ${total_utilization_days} = 0 then null else ${total_utilization_days} end)),0) ;;
  value_format_name: percent_1
}

measure: utilization_percentage_eight_hours {
  type: number
  sql: coalesce(${total_run_time}/(8*(case when ${total_utilization_days} = 0 then null else ${total_utilization_days} end)),0) ;;
  value_format_name: percent_1
}

measure: utilization_percentage_ten_hours {
  type: number
  sql: coalesce(${total_run_time}/(10*(case when ${total_utilization_days} = 0 then null else ${total_utilization_days} end)),0) ;;
  value_format_name: percent_1
}

measure: utilization_percentage_twelve_hours {
  type: number
  sql: coalesce(${total_run_time}/(12*(case when ${total_utilization_days} = 0 then null else ${total_utilization_days} end)),0) ;;
  value_format_name: percent_1
}

measure: utilization_percentage_twenty_four_hours {
  type: number
  sql: coalesce(${total_run_time}/(24*(case when ${total_utilization_days} = 0 then null else ${total_utilization_days} end)),0) ;;
  value_format_name: percent_1
}

filter: custom_name_filter {
  suggest_explore: asset_utilization_by_day_archive
  suggest_dimension: asset_utilization_by_day_archive.asset
}

filter: groups_filter {
  # suggest_explore: asset_utilization_by_day_archive
  # suggest_dimension: asset_utilization_by_day_archive.group_name
}

filter: ownership_filter {
  suggest_explore: asset_utilization_by_day_archive
  suggest_dimension: asset_utilization_by_day_archive.ownership
}

filter: asset_class_filter {
  suggest_explore: asset_utilization_by_day_archive
  suggest_dimension: asset_utilization_by_day_archive.asset_class
}

filter: branch_filter {
  suggest_explore: asset_utilization_by_day_archive
  suggest_dimension: asset_utilization_by_day_archive.branch
}

filter: category_filter {
  suggest_explore: asset_utilization_by_day_archive
  suggest_dimension: asset_utilization_by_day_archive.category
}

filter: asset_type_filter {
  suggest_explore: asset_utilization_by_day_archive
  suggest_dimension: asset_utilization_by_day_archive.asset_type
}

filter: tracker_grouping_filter {
  suggest_explore: asset_utilization_by_day_archive
  suggest_dimension: asset_utilization_by_day_archive.tracker_grouping
}

filter: job_name_filter {
  suggest_explore: job_list
  suggest_dimension: job_list.job_name
}

filter: phase_job_name_filter {
  suggest_explore: job_list
  suggest_dimension: job_list.phase_job_name
}

set: run_time_detail {
  fields: [day_formatted, asset, total_run_time_drill_down, total_idle_time_drill_down, total_miles_driven_drill_down]
}

set: idle_time_detail {
  fields: [day_formatted, asset, total_idle_time_drill_down, total_run_time_drill_down, total_miles_driven_drill_down]
}

set: miles_driven_detail {
  fields: [day_formatted, asset, total_miles_driven_drill_down, total_run_time_drill_down, total_idle_time_drill_down]
}

set: on_time_detail {
  fields: [day_formatted, asset, total_on_time_drill_down, total_run_time_drill_down, total_idle_time_drill_down, total_miles_driven_drill_down]
}

}

# ,possible_utilization_days as (
#       select
#           alr.asset_id,
#           ---alr.start_date::date,
#           --current_date,
#           --alr.end_date::date,
#           case
#           when alr.end_date::date = {% date_start date_filter %}::date then 1
#           when
#           alr.start_date::date = current_date and (alr.end_date::date >= {% date_end date_filter %}::date) OR alr.end_date::date < {% date_end date_filter %}::date then
#           1
#           when
#           alr.start_date::date <= {% date_start date_filter %}::date and alr.end_date <= {% date_end date_filter %}::date then
#           datediff(day,{% date_start date_filter %}::date,alr.end_date::date)+1
#           when
#           alr.start_date::date >= {% date_start date_filter %}::date and end_date::date >= {% date_end date_filter %}::date then
#           datediff(day,alr.start_date::date,{% date_end date_filter %}::date)
#           when
#           alr.start_date::date >= {% date_start date_filter %}::date and end_date::date <= {% date_end date_filter %}::date then
#           datediff(day,alr.start_date::date,alr.end_date::date)
#           when
#           alr.start_date::date <= {% date_start date_filter %}::date and end_date::date <= {% date_end date_filter %}::date then
#           datediff(day,{% date_start date_filter %}::date,alr.end_date::date)
#           else
#           datediff(day,{% date_start date_filter %}::date,{% date_end date_filter %}::date) -
#           {% if show_weekends._parameter_value == "'Yes'" %}
#           0
#           {% else %}
#           wd.weekend_flag
#           {% endif %}
#           end as possible_utilization_days
#       from
#           asset_list_rental alr
#           left join total_weekend_days_selected wd on 1=1
#       union
#       select
#         alo.asset_id,
#         datediff(day,{% date_start date_filter %}::date,{% date_end date_filter %}::date) as possible_utilization_days
#       from
#         asset_list_own alo
#       )

# AND
#           {% if show_out_of_lock_assets._parameter_value == "'Yes'" %}
#           (ool.asset_id is null or ool.asset_id is not null)
#           {% else %}
#           ool.asset_id is null
#           {% endif %}
# --left join v_out_of_lock ool on ool.asset_id = alo.asset_id
