view: asset_hours_last_seven_days {
  derived_table: {
    sql:
    with asset_list as (
    select asset_id
    from table(assetlist({{ _user_attributes['user_id'] }}::numeric))
    union
    select rl.asset_id
    from table(rental_asset_list({{ _user_attributes['user_id'] }}::numeric,
    convert_timezone('{{ _user_attributes['user_timezone'] }}',current_timestamp)::date::timestamp_ntz,
    convert_timezone('{{ _user_attributes['user_timezone'] }}',current_timestamp)::date::timestamp_ntz,
    '{{ _user_attributes['user_timezone'] }}')) rl
    join assets a on a.asset_id = rl.asset_id
          where
          a.company_id <> {{ _user_attributes['company_id'] }}
    )
    select
      al.asset_id,
      a.custom_name,
      ats.name as asset_type,
      c.name as category_name,
      convert_timezone('{{ _user_attributes['user_timezone'] }}',report_range:start_range) as start_range,
      convert_timezone('{{ _user_attributes['user_timezone'] }}',report_range:end_range) as end_range,
      sum(on_time) as on_time,
      sum(idle_time) as idle_time
    from
      asset_list al
      inner join assets a on a.asset_id = al.asset_id
      inner join hourly_asset_usage hu on al.asset_id = hu.asset_id
      left join asset_types ats on a.asset_type_id = ats.asset_type_id
      left join categories c on c.category_id = a.category_id
    where
      report_range:start_range >= convert_timezone('{{ _user_attributes['user_timezone'] }}', 'UTC', convert_timezone('{{ _user_attributes['user_timezone'] }}',current_timestamp)::date - interval '10 days')
    group by
      al.asset_id,
      a.custom_name,
      ats.name,
      c.name,
      convert_timezone('{{ _user_attributes['user_timezone'] }}',report_range:start_range),
      convert_timezone('{{ _user_attributes['user_timezone'] }}',report_range:end_range)
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

  dimension_group: start_range {
    label: " "
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
    sql: ${TABLE}."START_RANGE" ;;
  }

  dimension: start_range_time_formatted {
    group_label: "HTML Passed Date Format" label: "Date"
    type: date
    sql: ${start_range_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension_group: end_range {
    type: time
    sql: ${TABLE}."END_RANGE" ;;
  }

  dimension: on_time {
    type: number
    sql: ${TABLE}."ON_TIME" ;;
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }

  dimension: category_name {
    type: string
    sql: ${TABLE}."CATEGORY_NAME" ;;
  }

  # dimension: hauled_time {
  #   type: number
  #   sql: ${TABLE}."HAULED_TIME" ;;
  # }

  # dimension: hauling_time {
  #   type: number
  #   sql: ${TABLE}."HAULING_TIME" ;;
  # }

  dimension: idle_time {
    type: number
    sql: ${TABLE}."IDLE_TIME" ;;
  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(${asset_id},${start_range_raw}) ;;
  }

  dimension: custom_name {
    label: "Asset"
    type: string
    sql: ${TABLE}."CUSTOM_NAME" ;;
  }

  measure: run_time_hours {
    type: sum
    sql: ${on_time}/3600 ;;
    value_format_name: decimal_2
  }

  # measure: hauled_time_hours {
  #   type: sum
  #   sql: ${hauled_time}/3600 ;;
  #   value_format_name: decimal_1
  # }

  # measure: hauling_time_hours {
  #   type: sum
  #   sql: ${hauling_time}/3600 ;;
  #   value_format_name: decimal_1
  # }

  measure: idle_time_hours {
    type: sum
    sql: ${idle_time}/3600 ;;
    value_format_name: decimal_2
  }

  measure: driving_hours {
    type: number
    sql: ${run_time_hours} - ${idle_time_hours} ;;
    value_format_name: decimal_2
  }

  measure: off_hours {
    type: number
    sql: 3600 - (${run_time_hours}) ;;
  }

  measure: distinct_asset_count {
    type: count_distinct
    sql: ${asset_id} ;;
  }

  measure: utilization_percentage {
    type: number
    sql: (100*${run_time_hours})/(8*${distinct_asset_count}) ;;
    value_format_name: percent_1
  }

  dimension: last_seven_days {
    type: yesno
    sql: ${start_range_date} BETWEEN current_date() - interval '6 days' AND current_date() ;;
  }

  dimension: last_eight_to_fourteen_days {
    type: yesno
    sql: ${start_range_date} BETWEEN current_date() - interval '13 days' AND current_date() - interval '7 days' ;;
  }

  measure: last_seven_days_on_time_hours {
    type: sum
    sql: ${on_time}/3600 ;;
    value_format_name: decimal_0
    filters: [last_seven_days: "Yes"]
    drill_fields: [detail*]
    link: {
      label: "Top 25 WoW Positive Utilized Assets"
      url: "{{ link }}&sorts=asset_hours_last_seven_days.week_over_week_on_time_change+desc&limit=25"
    }
    link: {
      label: "Top 25 WoW Negative Utilized Assets"
      url: "{{ link }}&sorts=asset_hours_last_seven_days.week_over_week_on_time_change+asc&limit=25"
      icon_url: "http://www.looker.com/favicon.ico"
    }
  }

  measure: previous_week_on_time_hours {
    type: sum
    sql: ${on_time}/3600 ;;
    value_format_name: decimal_0
    filters: [last_eight_to_fourteen_days: "Yes"]
    drill_fields: [detail*]
  }

  measure: week_over_week_on_time_change {
    type: number
    sql: ${last_seven_days_on_time_hours} - ${previous_week_on_time_hours} ;;
    value_format_name: decimal_0
    drill_fields: [detail_difference*]
    link: {
      label: "Top 25 WoW Positive Utilized Assets"
      url: "{{ link }}&sorts=asset_hours_last_seven_days.week_over_week_on_time_change+desc&limit=25"
    }
    link: {
      label: "Top 25 WoW Negative Utilized Assets"
      url: "{{ link }}&sorts=asset_hours_last_seven_days.week_over_week_on_time_change+asc&limit=25"
      icon_url: "http://www.looker.com/favicon.ico"
    }
  }

  measure: run_time_vs_total_time {
    type: number
    sql: ${run_time_hours}/case when (${run_time_hours}+${idle_time_hours}) = 0 then null else (${run_time_hours}+${idle_time_hours}) end;;
    value_format_name: percent_1
  }

  measure: idle_time_vs_total_time {
    type: number
    sql: ${idle_time_hours}/case when (${run_time_hours}+${idle_time_hours}) = 0 then null else (${run_time_hours}+${idle_time_hours}) end;;
    value_format_name: percent_1
  }

  measure: attachment_run_time_hours {
    type: sum
    sql: ${on_time}/3600 ;;
    filters: [asset_types.name: "attachment"]
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: bucket_run_time_hours {
    type: sum
    sql: ${on_time}/3600 ;;
    filters: [asset_types.name: "bucket"]
    value_format_name: decimal_2
    drill_fields: [detail*]
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

  set: detail {
    fields: [
      start_range_time_formatted, assets.custom_name, assets.make, assets.model, assets.ownership_type, organizations.asset_groups, run_time_hours, idle_time_hours
      ]
  }

  set: detail_difference {
    fields: [
    assets.custom_name, assets.make, assets.model, asset_types.name, categories.name, organizations.asset_groups, trackers.tracker_information, week_over_week_on_time_change
    ]
  }
}
