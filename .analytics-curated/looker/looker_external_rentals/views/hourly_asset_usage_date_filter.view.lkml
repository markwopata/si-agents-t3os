view: hourly_asset_usage_date_filter {
  derived_table: {
    sql:
    with asset_list_rental as (
    select asset_id, start_date, end_date
    from table(rental_asset_list({{ _user_attributes['user_id'] }}::numeric, convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start rentals_spend_by.date_filter %}::timestamp_ntz), convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end rentals_spend_by.date_filter %}::timestamp_ntz), '{{ _user_attributes['user_timezone'] }}'))
    ),
    rental_available_dates as (
    select
        alr.asset_id,
        convert_timezone('{{ _user_attributes['user_timezone'] }}',report_range:start_range)::date as rental_start_date,
        convert_timezone('{{ _user_attributes['user_timezone'] }}',report_range:end_range)::date as rental_end_date,
        sum(on_time) as on_time,
        sum(idle_time) as idle_time,
        sum(miles_driven) as miles_driven
    from
        asset_list_rental alr
        join es_warehouse.public.hourly_asset_usage hau on alr.asset_id = hau.asset_id and hau.report_range:start_range >= alr.start_date AND hau.report_range:end_range <= alr.end_date
    where
        report_range:start_range >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start rentals_spend_by.date_filter %})
        AND report_range:end_range <= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end rentals_spend_by.date_filter %})
    group by
        alr.asset_id,
        convert_timezone('{{ _user_attributes['user_timezone'] }}',report_range:start_range)::date,
        convert_timezone('{{ _user_attributes['user_timezone'] }}',report_range:end_range)::date
    )
    select
        asset_id,
        'rented' as ownership_type,
        rental_start_date as start_date,
        rental_end_date as end_date,
        coalesce(count(distinct(start_date)),0) as days_used,
        sum(on_time) as on_time,
        sum(idle_time) as idle_time,
        round(sum(miles_driven),1) as miles_driven
    from
        rental_available_dates
    group by
        asset_id,
        rental_start_date,
        rental_end_date
      ;;
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    value_format_name: id
  }

  dimension: ownership_type {
    type: string
    sql: ${TABLE}."OWNERSHIP_TYPE" ;;
  }

  dimension_group: start_date {
    # label: " "
    #label is left with no name since a timeframe will be added on whatever the label name is and we want to avoid "date date" label
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year,
      day_of_week
    ]
    sql: ${TABLE}."START_DATE" ;;
  }

  dimension_group: end_date {
    #label is left with no name since a timeframe will be added on whatever the label name is and we want to avoid "date date" label
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
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

  dimension: days_used {
    type: number
    sql: ${TABLE}."DAYS_USED" ;;
  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(${asset_id},${start_date_raw},${ownership_type}) ;;
  }

  filter: date_filter {
    type: date_time
  }

  dimension: start_range_time_formatted {
    group_label: "HTML Passed Date Format" label: "Date"
    sql: ${start_date_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  measure: total_on_time {
    label: "Run Time Hours"
    type: sum
    sql: ${on_time}/3600 ;;
    value_format_name: decimal_2
    drill_fields: [rental_detail*]
  }

  measure: total_idle_time {
    label: "Idle Time Hours"
    type: sum
    sql: ${idle_time}/3600 ;;
    value_format_name: decimal_2
  }

  measure: dummy {
    hidden: yes
    type: number
    sql: 0 ;;
    drill_fields: [trip_detail*]
  }

  measure: total_days_used {
    type: sum
    sql: ${days_used} ;;
    label: "Days With Utilization"
    link: {
      # icon_url: "https://lh3.googleusercontent.com/tTUZk44oIlirNa5slVfqHwukDfkQ_xhlIB5JC8AxpBBnyNFiMMbVuCSW5XEP4MfhtSonD0fDBWxqcj9GG6Y0zF71WGSmyZXBzGnTm7r7wJV7bio9yZWF=w1280"
      # icon_url: "https://lh6.googleusercontent.com/SvnNgHm1Cwh-UJmX4xIqeN3KRuiS-cplGR-bmvou7izhoKNpqsvpBJdezrhElir2m57Yywqe4IzYhw1YZgBoarFYHfVeDAfbVwJUo46lcQV0cnDSACtd=w1280"
      label: "View Trip Log"
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
      \"x_axis_gridlines\":false,
      \"y_axis_gridlines\":true,
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
      \"defaults_version\":1,
      \"series_types\":{}}' %}

      {% assign dynamic_fields= '[]' %}

      {{dummy._link}}&sorts=trip_details.trip_start_time_formatted+asc&f[assets.custom_name]=&f[assets.ownership_type]=&vis={{vis | encode_uri}}&dynamic_fields={{dynamic_fields | encode_uri}}"
    }
  }

  measure: unused_asset_count {
    type: count
    filters: [on_time: "= 0, NULL"]
  }

  measure: used_asset_count {
    type: count
    filters: [on_time: "> 0"]
  }

  measure: distinct_asset_id_count {
    type: count_distinct
    label: "  Count"
    sql: ${asset_id} ;;
  }

  dimension: date_filter_difference {
    type: number
    sql: datediff(day,COALESCE(convert_timezone('UTC', '{{ _user_attributes['user_timezone'] }}', {% date_start date_filter %}::timestamp_ntz), convert_timezone('UTC', '{{ _user_attributes['user_timezone'] }}', current_date - interval '10 days')),COALESCE(convert_timezone('UTC', '{{ _user_attributes['user_timezone'] }}', {% date_end date_filter %}::timestamp_ntz), convert_timezone('{{ _user_attributes['user_timezone'] }}', current_date))) ;;
  }

  parameter: utilization_hours {
    type: string
    allowed_value: { value: "8 Hours"}
    allowed_value: { value: "10 Hours"}
    allowed_value: { value: "12 Hours"}
  }

  measure: dynamic_utilization_percentage {
    label_from_parameter: utilization_hours
    sql:{% if utilization_hours._parameter_value == "'8 Hours'" %}
      round(${utilization_percentage_eight_hours}*100,1)
    {% elsif utilization_hours._parameter_value == "'10 Hours'" %}
      round(${utilization_percentage_ten_hours}*100,1)
    {% elsif utilization_hours._parameter_value == "'12 Hours'" %}
      round(${utilization_percentage_twelve_hours}*100,1)
    {% else %}
      NULL
    {% endif %} ;;
    # value_format_name: percent_1
    }

  measure: dynamic_average_utilization_percentage {
    label_from_parameter: utilization_hours
    sql:{% if utilization_hours._parameter_value == "'8 Hours'" %}
            round(${average_utilization_kpi_eight_hours}*100,1)
          {% elsif utilization_hours._parameter_value == "'10 Hours'" %}
            round(${average_utilization_kpi_ten_hours}*100,1)
          {% elsif utilization_hours._parameter_value == "'12 Hours'" %}
            round(${average_utilization_kpi_twelve_hours}*100,1)
          {% else %}
            NULL
          {% endif %} ;;
          # value_format_name: percent_1
    }

    measure: utilization_percentage_eight_hours {
      type: number
      sql:
          case when ${date_filter_difference} >= 5 then
          (${total_on_time})/((8*5/7)*${date_filter_difference})
          when (${date_filter_difference} = 1 AND ${exclude_weekends} = 1) OR (${date_filter_difference} = 2 AND ${exclude_weekends} = 2) then
          (${total_on_time})/((8)*(${date_filter_difference}))
          when ${date_filter_difference} < 5 AND ${exclude_weekends} >= 1 then
          (${total_on_time})/((8)*(${date_filter_difference}-${exclude_weekends}))
          when ${date_filter_difference} < 5 and ${exclude_weekends} = 0 then
          (${total_on_time})/((8)*(${date_filter_difference}))
          end
          ;;
      value_format_name: percent_1
    }

    measure: exclude_weekends {
      type: sum
      sql: case when ${start_date_day_of_week} = 'Saturday' or ${start_date_day_of_week} = 'Sunday'
            then 1 else 0 end
            ;;
    }

    measure: utilization_percentage_ten_hours {
      type: number
      sql:
          case when ${date_filter_difference} >= 5 then
          (${total_on_time})/((10*5/7)*${date_filter_difference})
          when (${date_filter_difference} = 1 AND ${exclude_weekends} = 1) OR (${date_filter_difference} = 2 AND ${exclude_weekends} = 2) then
          (${total_on_time})/((10)*(${date_filter_difference}))
          when ${date_filter_difference} < 5 AND ${exclude_weekends} >= 1 then
          (${total_on_time})/((10)*(${date_filter_difference}-${exclude_weekends}))
          when ${date_filter_difference} < 5 and ${exclude_weekends} = 0 then
          (${total_on_time})/((10)*(${date_filter_difference}))
          end ;;
      value_format_name: percent_1
    }

    measure: utilization_percentage_twelve_hours {
      type: number
      sql:
          case when ${date_filter_difference} >= 5 then
          (${total_on_time})/((12*5/7)*${date_filter_difference})
          when (${date_filter_difference} = 1 AND ${exclude_weekends} = 1) OR (${date_filter_difference} = 2 AND ${exclude_weekends} = 2) then
          (${total_on_time})/((12)*(${date_filter_difference}))
          when ${date_filter_difference} < 5 AND ${exclude_weekends} >= 1 then
          (${total_on_time})/((12)*(${date_filter_difference}-${exclude_weekends}))
          when ${date_filter_difference} < 5 and ${exclude_weekends} = 0 then
          (${total_on_time})/((12)*(${date_filter_difference}))
          end ;;
      value_format_name: percent_1
    }

    measure: days_with_no_utilization {
      type: number
      sql: ${date_filter_difference} - ${total_days_used} ;;
    }

    measure: average_on_time_hours {
      type: average
      sql: coalesce((${on_time}/3600),0)/${date_filter_difference} ;;
      value_format_name: decimal_2
    }

    measure: total_miles_driven {
      type: sum
      sql: ${miles_driven} ;;
    }

    measure: average_utilization_kpi_eight_hours {
      type: number
      sql:
          case when ${date_filter_difference} >= 5 then
          ((${total_on_time})/((8*5/7)*${date_filter_difference}))/(${unused_asset_count} + ${used_asset_count})
          when (${date_filter_difference} = 1 AND ${exclude_weekends} = 1) OR (${date_filter_difference} = 2 AND ${exclude_weekends} = 2) then
          ((${total_on_time})/((8)*${date_filter_difference}))/(${unused_asset_count} + ${used_asset_count})
          when ${date_filter_difference} < 5 AND ${exclude_weekends} >= 1 then
          ((${total_on_time})/((8)*(${date_filter_difference}-${exclude_weekends})))/(${unused_asset_count} + ${used_asset_count})
          when ${date_filter_difference} < 5 AND ${exclude_weekends} = 0 then
          ((${total_on_time})/((8)*${date_filter_difference}))/(${unused_asset_count} + ${used_asset_count})
          end
          ;;
      value_format_name: percent_1
    }

    measure: average_utilization_kpi_ten_hours {
      type: number
      sql:
          case when ${date_filter_difference} >= 5 then
          ((${total_on_time})/((10*5/7)*${date_filter_difference}))/(${unused_asset_count} + ${used_asset_count})
          when (${date_filter_difference} = 1 AND ${exclude_weekends} = 1) OR (${date_filter_difference} = 2 AND ${exclude_weekends} = 2) then
          ((${total_on_time})/((8)*${date_filter_difference}))/(${unused_asset_count} + ${used_asset_count})
          when ${date_filter_difference} < 5 AND ${exclude_weekends} >= 1 then
          ((${total_on_time})/((10)*(${date_filter_difference}-${exclude_weekends})))/(${unused_asset_count} + ${used_asset_count})
          when ${date_filter_difference} < 5 AND ${exclude_weekends} = 0 then
          ((${total_on_time})/((10)*${date_filter_difference}))/(${unused_asset_count} + ${used_asset_count})
          end ;;
      value_format_name: percent_1
    }

    measure: average_utilization_kpi_twelve_hours {
      type: number
      sql:
          case when ${date_filter_difference} >= 5 then
          ((${total_on_time})/((12*5/7)*${date_filter_difference}))/(${unused_asset_count} + ${used_asset_count})
          when (${date_filter_difference} = 1 AND ${exclude_weekends} = 1) OR (${date_filter_difference} = 2 AND ${exclude_weekends} = 2) then
          ((${total_on_time})/((8)*${date_filter_difference}))/(${unused_asset_count} + ${used_asset_count})
          when ${date_filter_difference} < 5 AND ${exclude_weekends} >= 1 then
          ((${total_on_time})/((12)*(${date_filter_difference}-${exclude_weekends})))/(${unused_asset_count} + ${used_asset_count})
          when ${date_filter_difference} < 5 AND ${exclude_weekends} = 0 then
          ((${total_on_time})/((12)*${date_filter_difference}))/(${unused_asset_count} + ${used_asset_count})
          end ;;
      value_format_name: percent_1
    }

    dimension: used_or_unused_asset_string {
      type: string
      sql: case when ${on_time} > 0 then 'Used Asset' when ${on_time} is null and ${assets.tracker_id} is null then 'No Tracker' Else 'Unused Asset' END ;;
    }

    measure: equipment_run_time_hours {
      type: sum
      sql: ${on_time}/3600 ;;
      filters: [asset_types.name: "equipment"]
      value_format_name: decimal_2
      drill_fields: [detail*]
    }

    measure: trailer_run_time_hours {
      type: sum
      sql: ${on_time}/3600 ;;
      filters: [asset_types.name: "trailer"]
      value_format_name: decimal_2
      drill_fields: [detail*]
    }

    measure: vehicle_run_time_hours {
      type: sum
      sql: ${on_time}/3600 ;;
      filters: [asset_types.name: "vehicle"]
      value_format_name: decimal_2
      drill_fields: [detail*]
    }

  dimension: view_utilization {
    type: string
    sql: 'View Utilization' ;;
    html: <font color="#0063f3"><u><a href="https://analytics.estrack.com/dashboard/11" target="_blank">{{value}}</a></font></u> ;;
  }

    dimension: dynamic_spend_by_selection {
    label_from_parameter: rentals_spend_by.spend_by
    sql:{% if rentals_spend_by.spend_by._parameter_value == "'Jobsite'" %}
      ${locations.nickname}
    {% elsif rentals_spend_by.spend_by._parameter_value == "'PO'" %}
      ${purchase_orders.name}
    {% elsif rentals_spend_by.spend_by._parameter_value == "'Class'"  %}
      ${assets.asset_class}
    {% else %}
      NULL
    {% endif %} ;;
    # value_format_name: percent_1
    }

  #   dimension: during_timeframe_selected {
  #     type: yesno
  #     sql: convert_timezone('UTC','{{ _user_attributes['user_timezone'] }}', {% date_end rentals_spend_by.date_filter %}::date) <= coalesce(${equipment_assignments.end_date},'2999-12-31')
  #     AND
  #     convert_timezone('UTC','{{ _user_attributes['user_timezone'] }}', {% date_start rentals_spend_by.date_filter %}::date)
  #     >= ${equipment_assignments.start_date}

  #     ;;
  #   }

  # dimension: test1 {
  #   type: yesno
  #   sql: convert_timezone('UTC','{{ _user_attributes['user_timezone'] }}', {% date_end rentals_spend_by.date_filter %}::date) <= coalesce(${equipment_assignments.end_date},'2999-12-31')

  #     ;;
  # }

  # dimension: test2 {
  #   type: yesno
  #   sql:
  #     convert_timezone('UTC','{{ _user_attributes['user_timezone'] }}', {% date_start rentals_spend_by.date_filter %}::date)
  #     >= ${equipment_assignments.start_date}

  #     ;;
  # }

    set: detail {
      fields: [
        start_range_time_formatted, assets.custom_name, assets.make, assets.model, assets.ownership_type, organizations.asset_groups, total_on_time, total_idle_time
      ]
    }

    set: trip_detail {
      fields: [assets.custom_name, trip_details.trip_start_time_formatted, trip_details.start_location, trip_details.trip_end_time_formatted, trip_details.end_location, trip_details.trip_miles, trip_details.total_trip_hours, trip_details.total_idle_hours
      ]
    }

    set: rental_detail {
      fields: [rentals_spend_by.rental_id, assets.custom_name, rentals_spend_by.jobsite_list, rentals_spend_by.po, assets.asset_class, equipment_assignments.start_date, equipment_assignments.end_date, equipment_assignments.rental_status, total_days_used, total_on_time, total_idle_time, total_miles_driven, view_utilization]
    }

  }
