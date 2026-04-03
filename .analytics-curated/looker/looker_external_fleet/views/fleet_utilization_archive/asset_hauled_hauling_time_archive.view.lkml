view: asset_hauled_hauling_time_archive {
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
          , bdu.date as day
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
           , case
          when '{{ _user_attributes['user_timezone'] }}' = 'UTC' then NULLIF(hauled_time_utc/ 60 / 60,0)
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Chicago' then NULLIF(hauled_time_cst/ 60 / 60,0)
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Denver' then NULLIF(hauled_time_mnt/ 60 / 60,0)
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Los_Angeles' then NULLIF(hauled_time_wst/ 60 / 60,0)
          --- else is Eastern Standard Time
          else NULLIF(hauled_time_est/ 60 / 60,0)
          end as hauled_time
          , case
          when '{{ _user_attributes['user_timezone'] }}' = 'UTC' then NULLIF(hauling_time_utc/ 60 / 60,0)
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Chicago' then NULLIF(hauling_time_cst/ 60 / 60,0)
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Denver' then NULLIF(hauling_time_mnt/ 60 / 60,0)
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Los_Angeles' then NULLIF(hauling_time_wst/ 60 / 60,0)
          --- else is Eastern Standard Time
          else NULLIF(hauling_time_est/ 60 / 60,0)
          end as hauling_time

           , case
          when '{{ _user_attributes['user_timezone'] }}' = 'UTC' then hauled_distance_utc
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Chicago' then hauled_distance_cst
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Denver' then hauled_distance_mnt
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Los_Angeles' then hauled_distance_wst
          --- else is Eastern Standard Time
          else hauled_distance_est
          end as hauled_distance
          , case
          when '{{ _user_attributes['user_timezone'] }}' = 'UTC' then hauling_distance_utc
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Chicago' then hauling_distance_cst
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Denver' then hauling_distance_mnt
          when '{{ _user_attributes['user_timezone'] }}' = 'America/Los_Angeles' then hauling_distance_wst
          --- else is Eastern Standard Time
          else hauling_distance_est
          end as hauling_distance
          , case
          when hauling_time > 0 or hauled_time > 0 then 1
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

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: day {
    type: date
    sql: ${TABLE}."DAY" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset {
    type: string
    sql: ${TABLE}."ASSET" ;;
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

  dimension: used_unused_designation {
    type: string
    sql: ${TABLE}."USED_UNUSED_DESIGNATION" ;;
  }

  dimension: day_used {
    type: number
    sql: ${TABLE}."DAY_USED" ;;
  }

  dimension:  day_used_mod {
    type: number
    sql: ${TABLE}."DAY_USED_MOD" ;;
  }

  dimension: possible_utilization_days {
    type: number
    sql: ${TABLE}."POSSIBLE_UTILIZATION_DAYS_CALCED" ;;
  }


  dimension: hauled_distance {
    type: number
    sql: ${TABLE}."HAULED_DISTANCE" ;;
  }

  dimension: hauling_distance {
    type: number
    sql: ${TABLE}."HAULING_DISTANCE" ;;
  }

  dimension: hauled_time {
    type: number
    sql: ${TABLE}."HAULED_TIME" ;;
  }

  dimension: hauling_time {
    type: number
    sql: ${TABLE}."HAULING_TIME" ;;
  }

  dimension: odometer {
    type: number
    sql: ${TABLE}."ODO_MAX" ;;
    html: {{rendered_value}} mi. ;;
  }

  dimension: hours {
    type: number
    sql: ${TABLE}."HOURS_MAX" ;;
    html: {{rendered_value}} hrs. ;;
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

  dimension_group: last_checkin_timestamp {
    type: time
    sql: ${TABLE}."LAST_CHECKIN_TIMESTAMP" ;;
  }

  dimension: address {
    label: "Last Address"
    type: string
    sql: ${TABLE}."ADDRESS_MAX" ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/assets/all/asset/{{ assets.asset_id._value }}/history?selectedDate={{ current_date._value}}" target="_blank">{{value}}</a></font></u> ;;
  }

  dimension: geofence {
    label: "Last Geofence"
    type: string
    sql: ${TABLE}."GEOFENCE" ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/assets/all/asset/{{ assets.asset_id._value }}/history?selectedDate={{ current_date._value}}" target="_blank">{{value}}</a></font></u> ;;
  }

  dimension: location_address {
    label: "Location"
    type: string
    sql: ${address} ;;
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

  dimension: last_checkin_timestamp_formatted {
    group_label: "HTML Format"
    label: "Last Check In"
    type: date_time
    sql: convert_timezone(('{{ _user_attributes['user_timezone'] }}'),${last_checkin_timestamp_raw}) ;;
    html: {{ rendered_value | date: "%b %d, %Y %r  "  }} {{ _user_attributes['user_timezone_label'] }};;
    skip_drill_filter: yes
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
    fields: [asset_custom_name_to_asset_info, make_and_model, category, asset_class,

      fleet_utilization_asset_details_drilldown.hours, fleet_utilization_asset_details_drilldown.odometer,
      fleet_utilization_asset_details_drilldown.location_geofence, fleet_utilization_asset_details_drilldown.location_address, fleet_utilization_asset_details_drilldown.last_location_timestamp_formatted,
      fleet_utilization_asset_details_drilldown.last_checkin_timestamp_formatted]
  }

  # measure: total_utilization_days {
  #   type: sum
  #   sql: ${possible_utilization_days} ;;
  # }

  measure: total_utilization_days {
    type: count_distinct
    sql: ${day} ;;
  }

  measure: dummy_hauled_time {
    hidden: yes
    type: number
    sql: 0 ;;
    drill_fields: [hauled_time_detail*]
  }

  measure: dummy_hauling_time {
    hidden: yes
    type: number
    sql: 0 ;;
    drill_fields: [hauling_time_detail*]
  }

  measure: dummy_hauled_distance {
    hidden: yes
    type: number
    sql: 0 ;;
    drill_fields: [hauled_distance_detail*]
  }

  measure: dummy_hauling_distance {
    hidden: yes
    type: number
    sql: 0 ;;
    drill_fields: [hauling_distance_detail*]
  }

  measure: dummy_combined {
    hidden: yes
    type: number
    sql: 0 ;;
    drill_fields: [combined_detail*]
  }

  measure: total_hauling_time {
    type: string
    sql: coalesce(FLOOR(sum(${hauling_time})) || 'h ' ||  ROUND(((sum(${hauling_time}) - FLOOR(sum(${hauling_time}))) * 60)) || 'm', '0h 0m') ;;
    html: <a href="#drillmenu" target="_self">{{rendered_value}}
      <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a> ;;
    # drill_fields: [detail*]
    link: {
      label: "View Hauling Time for Asset"
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

      {{dummy_hauling_time._link}}&f[asset_utilization_by_day.asset_id]=&f[asset_utilization_by_day.asset_class]=&sorts=asset_utilization_by_day.day_formatted+desc&vis={{vis | encode_uri}}"
    }
    # value_format_name: decimal_2
  }

  measure: total_hauling_time_calc {
    type: sum
    sql: ${hauling_time} ;;
    html: <a href="#drillmenu" target="_self">{{rendered_value}} hrs.
      <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a> ;;
    # drill_fields: [detail*]
    link: {
      label: "View Hauling Time for Asset"
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

      {{dummy_hauling_time._link}}&f[asset_utilization_by_day.asset_id]=&f[asset_utilization_by_day.asset_class]=&sorts=asset_utilization_by_day.day_formatted+desc&vis={{vis | encode_uri}}"
    }
    value_format_name: decimal_0
  }

  measure: total_hauled_time {
    type: string
    sql: coalesce(FLOOR(sum(${hauled_time})) || 'h ' ||  ROUND(((sum(${hauled_time}) - FLOOR(sum(${hauled_time}))) * 60)) || 'm', '0h 0m') ;;
    html: <a href="#drillmenu" target="_self">{{rendered_value}}
      <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a> ;;
    # drill_fields: [detail*]
    link: {
      label: "View Hauled Time for Asset"
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

      {{dummy_hauled_time._link}}&f[asset_utilization_by_day.asset_id]=&f[asset_utilization_by_day.asset_class]=&sorts=asset_utilization_by_day.day_formatted+desc&vis={{vis | encode_uri}}"
    }
    # value_format_name: decimal_2
  }

  measure: total_hauled_time_calc {
    type: sum
    sql: ${hauled_time} ;;
    html: <a href="#drillmenu" target="_self">{{rendered_value}} hrs.
      <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a> ;;
    # drill_fields: [detail*]
    link: {
      label: "View Hauled Time for Asset"
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

      {{dummy_hauled_time._link}}&f[asset_utilization_by_day.asset_id]=&f[asset_utilization_by_day.asset_class]=&sorts=asset_utilization_by_day.day_formatted+desc&vis={{vis | encode_uri}}"
    }
    value_format_name: decimal_0
  }

  measure: total_hauling_distance {
    type: sum
    sql: ${hauling_distance} ;;
    html: <a href="#drillmenu" target="_self">{{rendered_value}} mi.
      <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a> ;;
    # drill_fields: [detail*]
    link: {
      label: "View Hauling Distance for Asset"
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

      {{dummy_hauling_distance._link}}&f[asset_utilization_by_day.asset_id]=&f[asset_utilization_by_day.asset_class]=&sorts=asset_utilization_by_day.day_formatted+desc&vis={{vis | encode_uri}}"
    }
    value_format_name: decimal_2
  }

  measure: total_hauled_distance {
    type: sum
    sql: ${hauled_distance} ;;
    html: <a href="#drillmenu" target="_self">{{rendered_value}} mi.
      <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a> ;;
    # drill_fields: [detail*]
    link: {
      label: "View Hauled Distance for Asset"
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

      {{dummy_hauled_distance._link}}&f[asset_utilization_by_day.asset_id]=&f[asset_utilization_by_day.asset_class]=&sorts=asset_utilization_by_day.day_formatted+desc&vis={{vis | encode_uri}}"
    }
    value_format_name: decimal_2
  }

  measure: total_hauling_time_drill_down {
    group_label: "Drill Downs"
    label: "Total Hauling Time"
    type: sum
    sql: ${hauling_time} ;;
    html: {{rendered_value}} hrs. ;;
    drill_fields: [hauling_time_detail*]
    value_format_name: decimal_0
  }

  measure: total_hauled_time_drill_down {
    group_label: "Drill Downs"
    label: "Total Hauled Time"
    type: sum
    sql: ${hauled_time} ;;
    html: {{rendered_value}} hrs. ;;
    drill_fields: [hauled_time_detail*]
    value_format_name: decimal_0
  }

  measure: total_hauling_distance_drill_down {
    group_label: "Drill Downs"
    label: "Total Hauling Distance"
    type: sum
    sql: ${hauling_distance} ;;
    html: {{rendered_value}} mi. ;;
    drill_fields: [hauling_distance_detail*]
    value_format_name: decimal_2
  }

  measure: total_hauled_distance_drill_down {
    group_label: "Drill Downs"
    label: "Total Hauled Distance"
    type: sum
    sql: ${hauled_distance} ;;
    html: {{rendered_value}} mi. ;;
    drill_fields: [hauled_distance_detail*]
    value_format_name: decimal_2
  }

  measure: total_days_used {
    type:  number
    sql: ceil(sum(${day_used_mod})) ;;
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

      {{dummy_combined._link}}&f[asset_utilization_by_day.asset_id]=&f[asset_utilization_by_day.asset_class]=&sorts=asset_utilization_by_day.day_formatted+desc&vis={{vis | encode_uri}}"
    }
  }

  measure: days_unused {
    type: number
    required_fields: [total_utilization_days]
    sql: coalesce(${total_utilization_days} - ${total_days_used},0) ;;
  }

  measure: total_assets {
    type: count_distinct
    sql: ${asset_id} ;;
  }

  measure: used_asset_count {
    type: count_distinct
    sql: CASE WHEN ${hauled_time} > 0 or ${hauling_time} > 0 THEN ${asset_id} ELSE NULL END ;;
  }

  measure: unused_asset_count {
    type: number
    sql: ${total_assets} - ${used_asset_count} ;;
  }

  dimension: make_and_model {
    type: string
    sql: concat(${make},' ',${model}) ;;
  }

  dimension: driver_formatted {
    label: "Driver"
    type: string
    sql: CASE WHEN ${asset_type} = 'Vehicle' --vehicle asset type
         THEN COALESCE(${driver_name},'')
         ELSE ''
         END;;
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
    sql: coalesce(coalesce(${total_hauled_time_calc},${total_hauling_time_calc})/(1*(case when ${total_utilization_days} = 0 then null else ${total_utilization_days} end)),0) ;;
    value_format_name: percent_1
  }

  measure: utilization_percentage_two_hours {
    type: number
    sql: coalesce(coalesce(${total_hauled_time_calc},${total_hauling_time_calc})/(2*(case when ${total_utilization_days} = 0 then null else ${total_utilization_days} end)),0) ;;
    value_format_name: percent_1
  }

  measure: utilization_percentage_three_hours {
    type: number
    sql: coalesce(coalesce(${total_hauled_time_calc},${total_hauling_time_calc})(3*(case when ${total_utilization_days} = 0 then null else ${total_utilization_days} end)),0) ;;
    value_format_name: percent_1
  }

  measure: utilization_percentage_four_hours {
    type: number
    sql: coalesce(coalesce(${total_hauled_time_calc},${total_hauling_time_calc})/(4*(case when ${total_utilization_days} = 0 then null else ${total_utilization_days} end)),0) ;;
    value_format_name: percent_1
  }

  measure: utilization_percentage_five_hours {
    type: number
    sql: coalesce(coalesce(${total_hauled_time_calc},${total_hauling_time_calc})/(5*(case when ${total_utilization_days} = 0 then null else ${total_utilization_days} end)),0) ;;
    value_format_name: percent_1
  }

  measure: utilization_percentage_six_hours {
    type: number
    sql: coalesce(coalesce(${total_hauled_time_calc},${total_hauling_time_calc})/(6*(case when ${total_utilization_days} = 0 then null else ${total_utilization_days} end)),0) ;;
    value_format_name: percent_1
  }

  measure: utilization_percentage_seven_hours {
    type: number
    sql: coalesce(coalesce(${total_hauled_time_calc},${total_hauling_time_calc})/(7*(case when ${total_utilization_days} = 0 then null else ${total_utilization_days} end)),0) ;;
    value_format_name: percent_1
  }

  measure: utilization_percentage_eight_hours {
    type: number
    sql: coalesce(coalesce(${total_hauled_time_calc},${total_hauling_time_calc})/(8*(case when ${total_utilization_days} = 0 then null else ${total_utilization_days} end)),0) ;;
    value_format_name: percent_1
  }

  measure: utilization_percentage_ten_hours {
    type: number
    sql: coalesce(coalesce(${total_hauled_time_calc},${total_hauling_time_calc})/(10*(case when ${total_utilization_days} = 0 then null else ${total_utilization_days} end)),0) ;;
    value_format_name: percent_1
  }

  measure: utilization_percentage_twelve_hours {
    type: number
    sql: coalesce(coalesce(${total_hauled_time_calc},${total_hauling_time_calc})/(12*(case when ${total_utilization_days} = 0 then null else ${total_utilization_days} end)),0) ;;
    value_format_name: percent_1
  }

  measure: utilization_percentage_twenty_four_hours {
    type: number
    sql: coalesce(coalesce(${total_hauled_time_calc},${total_hauling_time_calc})/(24*(case when ${total_utilization_days} = 0 then null else ${total_utilization_days} end)),0) ;;
    value_format_name: percent_1
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
      <td width="200px"><h4>Total Hauling Time:</h4></td>
      <td width="125px"><h4>{{total_hauling_time_drill_down._rendered_value}} hrs.</h4></td>
    </tr>
    <tr>
      <td width="200px"><h4>Total Hauling Distance:</h4></td>
      <td width="125px"><h4>{{total_hauling_distance_drill_down._rendered_value}} mi.</h4></td>
    </tr>
    <tr>
      <td width="200px"><h4>Total Hauled Time:</h4></td>
      <td width="125px"><h4>{{total_hauled_time_drill_down._rendered_value}} hrs.</h4></td>
    </tr>
    <tr>
      <td width="200px"><h4>Total Hauled Distance:</h4></td>
      <td width="125px"><h4>{{total_hauled_distance_drill_down._rendered_value}} mi.</h4></td>
    </tr>
    <tr>
      <td></td>
      <td></td>
    </tr>
    </table>
      ;;
  }


  ################################################################################
  measure: total_hauling_time_date_range {
    group_label: "Hauling Time"
    label: "Total Hauling Time"
    type: sum
    sql: ${hauling_time} ;;
    html: <a href="#drillmenu" target="_self">{{total_hauling_time._rendered_value}}
      <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a> ;;
    # drill_fields: [detail*]
    link: {
      label: "View Hauling Time for Asset"
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

      {{dummy_hauling_time._link}}&f[asset_utilization_by_day.asset_id]=&f[asset_utilization_by_day.asset_class]=&sorts=asset_utilization_by_day.day_formatted+desc&vis={{vis | encode_uri}}"
    }
    value_format_name: decimal_1
  }

  measure: total_hauled_time_date_range {
    group_label: "Hauled Time"
    label: "Total Hauled Time"
    type: sum
    sql: ${hauled_time} ;;
    html: <a href="#drillmenu" target="_self">{{total_hauled_time._rendered_value}}
      <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a> ;;
    # drill_fields: [detail*]
    link: {
      label: "View Hauled Time for Asset"
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

      {{dummy_hauled_time._link}}&f[asset_utilization_by_day.asset_id]=&f[asset_utilization_by_day.asset_class]=&sorts=asset_utilization_by_day.day_formatted+desc&vis={{vis | encode_uri}}"
    }
    value_format_name: decimal_1
  }
  ################################################################################

  filter: custom_name_filter {
    # suggest_explore: asset_utilization_by_day
    # suggest_dimension: asset_utilization_by_day.asset
  }

  filter: groups_filter {
    # suggest_explore: asset_utilization_by_day
    # suggest_dimension: asset_utilization_by_day.group_name
  }

  filter: ownership_filter {
    # suggest_explore: asset_utilization_by_day
    # suggest_dimension: asset_utilization_by_day.ownership
  }

  filter: asset_class_filter {
    # suggest_explore: asset_utilization_by_day
    # suggest_dimension: asset_utilization_by_day.asset_class
  }

  filter: branch_filter {
    # suggest_explore: asset_utilization_by_day
    # suggest_dimension: asset_utilization_by_day.branch
  }

  filter: category_filter {
    # suggest_explore: asset_utilization_by_day
    # suggest_dimension: asset_utilization_by_day.category
  }

  filter: asset_type_filter {
    # suggest_explore: asset_utilization_by_day
    # suggest_dimension: asset_utilization_by_day.asset_type
  }

  filter: tracker_grouping_filter {
    # suggest_explore: asset_utilization_by_day
    # suggest_dimension: asset_utilization_by_day.tracker_grouping
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
    fields: [
      day,
      asset_id,
      asset,
      asset_class,
      category,
      branch,
      make,
      model,
      serial_number_vin,
      asset_type,
      ownership,
      tracker_grouping,
      driver_name,
      used_unused_designation,
      day_used_mod,
      possible_utilization_days,
      hauled_distance,
      hauling_distance,
      hauled_time,
      hauling_time,
      job_id,
      job_name,
      phase_job_id,
      phase_job_name
    ]
  }

  set: hauling_time_detail {
    fields: [day_formatted, asset, total_hauling_time_drill_down, total_hauling_distance_drill_down]
  }

  set: hauled_time_detail {
    fields: [day_formatted, asset, total_hauled_time_drill_down, total_hauled_distance_drill_down]
  }

  set: hauling_distance_detail {
    fields: [day_formatted, asset, total_hauling_distance_drill_down, total_hauling_time_drill_down]
  }

  set: hauled_distance_detail {
    fields: [day_formatted, asset, total_hauled_distance_drill_down, total_hauled_time_drill_down]
  }

  set: combined_detail {
    fields: [day_formatted, asset, total_hauled_distance_drill_down, total_hauled_time_drill_down, total_hauling_time_drill_down, total_hauling_distance_drill_down]
  }

}
