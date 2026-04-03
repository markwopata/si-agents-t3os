view: out_of_lock_count_seven_days_ago {
  derived_table: {
    sql: with asset_list as (
      select asset_id
      from table(assetlist({{ _user_attributes['user_id'] }}::numeric))
      )
      , asset_list_rental as (
      select asset_id, start_date, end_date
      from table(rental_asset_list({{ _user_attributes['user_id'] }}::numeric,
      convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', current_timestamp::date::timestamp_ntz),
      convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', current_timestamp::date::timestamp_ntz),
      '{{ _user_attributes['user_timezone'] }}'))
      )
      select
          al.asset_id
      from
          out_of_lock_7_days_rolling as ool
          join asset_list al on al.asset_id = ool.asset_id
      where
          datediff(day,snapshot_date::date,current_date) = 6
          and over_72_hours_flag = TRUE
          and ool.company_id = {{ _user_attributes['company_id'] }}
      UNION
      select
          al.asset_id
      from
          asset_list_rental al
          inner join out_of_lock_7_days_rolling as ool on al.asset_id = ool.asset_id and al.start_date >= ool.snapshot_date and al.end_date <= ool.snapshot_date
      where
          datediff(day,snapshot_date::date,current_date) = 6
          and over_72_hours_flag = TRUE
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: asset_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    value_format_name: id
  }

  set: detail {
    fields: [out_of_lock_history_count_by_day.snapshot_date, out_of_lock_history_count_by_day.count]
  }

  measure: dummy {
    hidden: yes
    type: sum
    sql: 0 ;;
    drill_fields: [detail*]
  }

  measure: week_over_week_change {
    type: number
    sql: ${out_of_lock.total_out_of_locks_over_72_hours} - ${count} ;;
    # drill_fields: [detail*]
    link: {
      label: "View Last 7 Day Out of Lock History"
      url: "
      {% assign vis= '{\"show_view_names\":false,
\"show_row_numbers\":false,
\"transpose\":false,
\"truncate_text\":true,
\"hide_totals\":false,
\"hide_row_totals\":false,
\"size_to_fit\":true,
\"table_theme\":\"white\",
\"limit_displayed_rows\":false,
\"enable_conditional_formatting\":false,
\"header_text_alignment\":\"left\",
\"header_font_size\":\"12\",
\"rows_font_size\":\"12\",
\"conditional_formatting_include_totals\":false,
\"conditional_formatting_include_nulls\":false,
\"show_sql_query_menu_options\":false,
\"show_totals\":true,
\"show_row_totals\":true,
\"series_cell_visualizations\":{\"out_of_lock_history_count_by_day.count\":{\"is_active\":true,
\"palette\":{\"palette_id\":\"471a8295-662d-46fc-bd2d-2d0acd370c1e\",
\"collection_id\":\"b43731d5-dc87-4a8e-b807-635bef3948e7\"}}},
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

{{dummy._link}}&f[trackers.tracker_information]=-No Tracker&f[asset_types.asset_type]=&vis={{vis | encode_uri}}"
    }
  }
}