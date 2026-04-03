view: latest_asset_battery_voltage {
  derived_table: {
    sql: with asset_list as (
    select asset_id
    from table(assetlist({{ _user_attributes['user_id'] }}::numeric))
    union
    SELECT coalesce(ea.asset_id, r.asset_id) as asset_id
FROM es_warehouse.public.orders o
join es_warehouse.public.users u on u.user_id = o.user_id
join es_warehouse.public.rentals r on r.order_id = o.order_id
left join es_warehouse.public.equipment_assignments ea on ea.rental_id = r.rental_id and ea.end_date is null
join es_warehouse.public.rental_types rt on rt.rental_type_id = r.rental_type_id
WHERE
    r.rental_status_id = 5
AND
    u.company_id
        IN (
        SELECT u.company_id
        FROM es_warehouse.public.users u
        WHERE u.user_id = {{ _user_attributes['user_id'] }}::numeric
        )
AND (
    u.user_id =
        CASE
            WHEN (
                SELECT security_level_id
                FROM es_warehouse.public.users u
                WHERE u.user_id = {{ _user_attributes['user_id'] }}::numeric
            )
            IN (1, 2)
            THEN u.user_id
            ELSE {{ _user_attributes['user_id'] }}::numeric
            END
            OR
            r.rental_id in (
            select r.rental_id
              from es_warehouse.public.rentals r
              join es_warehouse.public.orders o on o.order_id = r.order_id
              join es_warehouse.public.rental_location_assignments la on la.rental_id = r.rental_id
              join es_warehouse.public.geofences g on g.location_id = la.location_id
              join es_warehouse.public.organization_geofence_xref x on x.geofence_id = g.geofence_id
              join es_warehouse.public.organization_user_xref ux on ux.organization_id = x.organization_id
              where ux.user_id = {{ _user_attributes['user_id'] }}::numeric
            )
    )
    )
    select
        al.asset_id,
        akv.value as battery_voltage,
        akv.updated
      from
          asset_list al
          inner join asset_status_key_values akv on akv.asset_id = al.asset_id
      where
          akv.name = 'battery_voltage'
       ;;
  }

  measure: dummy {
    hidden: yes
    type: number
    sql: 0 ;;
    drill_fields: [detail*]
  }

  measure: dummy_all {
    hidden: yes
    type: number
    sql: 0 ;;
    drill_fields: [detail_no_history*]
  }

  measure: count {
    type: count
    # drill_fields: [detail*]
    html: {{rendered_value}} ({{count_percent._rendered_value}}) ;;
    link: {
      label: "View All 12V Battery Voltages"
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
\"header_font_size\":\"12\",
\"rows_font_size\":\"12\",
\"conditional_formatting_include_totals\":false,
\"conditional_formatting_include_nulls\":false,
\"color_application\":{\"collection_id\":\"b43731d5-dc87-4a8e-b807-635bef3948e7\",
\"palette_id\":\"fb7bb53e-b77b-4ab6-8274-9d420d3d73f3\",
\"options\":{\"steps\":5}},
\"show_sql_query_menu_options\":false,
\"show_totals\":true,
\"show_row_totals\":true,
\"series_cell_visualizations\":{\"asset_battery_prev_week_trend.battery_voltage\":{\"is_active\":false}},
\"conditional_formatting\":[{\"type\":\"less than\",
\"value\":11.9,
\"background_color\":\"#B32F37\",
\"font_color\":null,
\"color_application\":{\"collection_id\":\"b43731d5-dc87-4a8e-b807-635bef3948e7\",
\"palette_id\":\"85de97da-2ded-4dec-9dbd-e6a7d36d5825\"},
\"bold\":false,
\"italic\":false,
\"strikethrough\":false,
\"fields\":null},
{\"type\":\"greater than\",
\"value\":17.99,
\"background_color\":\"#FBB555\",
\"font_color\":null,
\"color_application\":{\"collection_id\":\"b43731d5-dc87-4a8e-b807-635bef3948e7\",
\"palette_id\":\"1e4d66b9-f066-4c33-b0b7-cc10b4810688\"},
\"bold\":false,
\"italic\":false,
\"strikethrough\":false,
\"fields\":null}],
\"x_axis_gridlines\":false,
\"y_axis_gridlines\":true,
\"show_y_axis_labels\":true,
\"show_y_axis_ticks\":true,
\"y_axis_tick_density\":\"default\",
\"y_axis_tick_density_custom\":5,
\"show_x_axis_label\":false,
\"show_x_axis_ticks\":true,
\"y_axis_scale_mode\":\"linear\",
\"x_axis_reversed\":false,
\"y_axis_reversed\":false,
\"plot_size_by_field\":false,
\"trellis\":\"\",
\"stacking\":\"\",
\"legend_position\":\"center\",
\"point_style\":\"circle\",
\"show_value_labels\":false,
\"label_density\":25,
\"x_axis_scale\":\"auto\",
\"y_axis_combined\":true,
\"show_null_points\":true,
\"interpolation\":\"linear\",
\"y_axes\":[{\"label\":\"\",
\"orientation\":\"left\",
\"series\":[{\"axisId\":\"asset_battery_prev_week_trend.battery_voltage\",
\"id\":\"133 - asset_battery_prev_week_trend.battery_voltage\",
\"name\":\"133\"},
{\"axisId\":\"asset_battery_prev_week_trend.battery_voltage\",
\"id\":\"141 - asset_battery_prev_week_trend.battery_voltage\",
\"name\":\"141\"},
{\"axisId\":\"asset_battery_prev_week_trend.battery_voltage\",
\"id\":\"691 - asset_battery_prev_week_trend.battery_voltage\",
\"name\":\"691\"}],
\"showLabels\":true,
\"showValues\":true,
\"unpinAxis\":true,
\"tickDensity\":\"default\",
\"tickDensityCustom\":5,
\"type\":\"linear\"}],
\"x_axis_label\":\"\",
\"series_types\":{},
\"series_colors\":{},
\"reference_lines\":[{\"reference_type\":\"line\",
\"margin_top\":\"deviation\",
\"margin_value\":\"mean\",
\"margin_bottom\":\"deviation\",
\"label_position\":\"right\",
\"color\":\"#B32F37\",
\"label\":\"Low Voltage\",
\"line_value\":\"11.5\",
\"range_start\":\"11.8\",
\"range_end\":\"0\"},
{\"reference_type\":\"line\",
\"margin_top\":\"deviation\",
\"margin_value\":\"mean\",
\"margin_bottom\":\"deviation\",
\"label_position\":\"right\",
\"color\":\"#FBB555\",
\"line_value\":\"18\",
\"label\":\"High Voltage\",
\"range_start\":\"18\",
\"range_end\":\"100\"}],
\"swap_axes\":false,
\"type\":\"looker_grid\",
\"defaults_version\":1}' %}

{{dummy_all._link}}&f[assets.custom_name]=&f[assets.ownership_type]=&f[battery_voltage_types.name]=12V&vis={{vis | encode_uri}}"
    }
    link: {
      label: "View All 24V Battery Voltages"
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
\"header_font_size\":\"12\",
\"rows_font_size\":\"12\",
\"conditional_formatting_include_totals\":false,
\"conditional_formatting_include_nulls\":false,
\"color_application\":{\"collection_id\":\"b43731d5-dc87-4a8e-b807-635bef3948e7\",
\"palette_id\":\"fb7bb53e-b77b-4ab6-8274-9d420d3d73f3\",
\"options\":{\"steps\":5}},
\"show_sql_query_menu_options\":false,
\"show_totals\":true,
\"show_row_totals\":true,
\"series_cell_visualizations\":{\"asset_battery_prev_week_trend.battery_voltage\":{\"is_active\":false}},
\"conditional_formatting\":[{\"type\":\"less than\",
\"value\":11.9,
\"background_color\":\"#B32F37\",
\"font_color\":null,
\"color_application\":{\"collection_id\":\"b43731d5-dc87-4a8e-b807-635bef3948e7\",
\"palette_id\":\"85de97da-2ded-4dec-9dbd-e6a7d36d5825\"},
\"bold\":false,
\"italic\":false,
\"strikethrough\":false,
\"fields\":null},
{\"type\":\"greater than\",
\"value\":17.99,
\"background_color\":\"#FBB555\",
\"font_color\":null,
\"color_application\":{\"collection_id\":\"b43731d5-dc87-4a8e-b807-635bef3948e7\",
\"palette_id\":\"1e4d66b9-f066-4c33-b0b7-cc10b4810688\"},
\"bold\":false,
\"italic\":false,
\"strikethrough\":false,
\"fields\":null}],
\"x_axis_gridlines\":false,
\"y_axis_gridlines\":true,
\"show_y_axis_labels\":true,
\"show_y_axis_ticks\":true,
\"y_axis_tick_density\":\"default\",
\"y_axis_tick_density_custom\":5,
\"show_x_axis_label\":false,
\"show_x_axis_ticks\":true,
\"y_axis_scale_mode\":\"linear\",
\"x_axis_reversed\":false,
\"y_axis_reversed\":false,
\"plot_size_by_field\":false,
\"trellis\":\"\",
\"stacking\":\"\",
\"legend_position\":\"center\",
\"point_style\":\"circle\",
\"show_value_labels\":false,
\"label_density\":25,
\"x_axis_scale\":\"auto\",
\"y_axis_combined\":true,
\"show_null_points\":true,
\"interpolation\":\"linear\",
\"y_axes\":[{\"label\":\"\",
\"orientation\":\"left\",
\"series\":[{\"axisId\":\"asset_battery_prev_week_trend.battery_voltage\",
\"id\":\"133 - asset_battery_prev_week_trend.battery_voltage\",
\"name\":\"133\"},
{\"axisId\":\"asset_battery_prev_week_trend.battery_voltage\",
\"id\":\"141 - asset_battery_prev_week_trend.battery_voltage\",
\"name\":\"141\"},
{\"axisId\":\"asset_battery_prev_week_trend.battery_voltage\",
\"id\":\"691 - asset_battery_prev_week_trend.battery_voltage\",
\"name\":\"691\"}],
\"showLabels\":true,
\"showValues\":true,
\"unpinAxis\":true,
\"tickDensity\":\"default\",
\"tickDensityCustom\":5,
\"type\":\"linear\"}],
\"x_axis_label\":\"\",
\"series_types\":{},
\"series_colors\":{},
\"reference_lines\":[{\"reference_type\":\"line\",
\"margin_top\":\"deviation\",
\"margin_value\":\"mean\",
\"margin_bottom\":\"deviation\",
\"label_position\":\"right\",
\"color\":\"#B32F37\",
\"label\":\"Low Voltage\",
\"line_value\":\"11.5\",
\"range_start\":\"11.8\",
\"range_end\":\"0\"},
{\"reference_type\":\"line\",
\"margin_top\":\"deviation\",
\"margin_value\":\"mean\",
\"margin_bottom\":\"deviation\",
\"label_position\":\"right\",
\"color\":\"#FBB555\",
\"line_value\":\"18\",
\"label\":\"High Voltage\",
\"range_start\":\"18\",
\"range_end\":\"100\"}],
\"swap_axes\":false,
\"type\":\"looker_grid\",
\"defaults_version\":1}' %}

{{dummy_all._link}}&f[assets.custom_name]=&f[assets.ownership_type]=&f[battery_voltage_types.name]=24V&vis={{vis | encode_uri}}"
    }
    link: {
      label: "12V Average Engine Off Battery Voltage 7 Day History"
      url: "{% assign vis= '{\"show_view_names\":false,
\"show_row_numbers\":true,
\"transpose\":false,
\"truncate_text\":true,
\"hide_totals\":false,
\"hide_row_totals\":false,
\"size_to_fit\":true,
\"table_theme\":\"white\",
\"limit_displayed_rows\":false,
\"enable_conditional_formatting\":true,
\"header_text_alignment\":\"left\",
\"header_font_size\":\"12\",
\"rows_font_size\":\"12\",
\"conditional_formatting_include_totals\":false,
\"conditional_formatting_include_nulls\":false,
\"color_application\":{\"collection_id\":\"b43731d5-dc87-4a8e-b807-635bef3948e7\",
\"palette_id\":\"fb7bb53e-b77b-4ab6-8274-9d420d3d73f3\",
\"options\":{\"steps\":5}},
\"show_sql_query_menu_options\":false,
\"show_totals\":true,
\"show_row_totals\":true,
\"series_cell_visualizations\":{\"asset_battery_prev_week_trend.battery_voltage\":{\"is_active\":false}},
\"conditional_formatting\":[{\"type\":\"less than\",
\"value\":11.9,
\"background_color\":\"#B32F37\",
\"font_color\":null,
\"color_application\":{\"collection_id\":\"b43731d5-dc87-4a8e-b807-635bef3948e7\",
\"palette_id\":\"85de97da-2ded-4dec-9dbd-e6a7d36d5825\"},
\"bold\":false,
\"italic\":false,
\"strikethrough\":false,
\"fields\":null},
{\"type\":\"greater than\",
\"value\":17.99,
\"background_color\":\"#FBB555\",
\"font_color\":null,
\"color_application\":{\"collection_id\":\"b43731d5-dc87-4a8e-b807-635bef3948e7\",
\"palette_id\":\"1e4d66b9-f066-4c33-b0b7-cc10b4810688\"},
\"bold\":false,
\"italic\":false,
\"strikethrough\":false,
\"fields\":null}],
\"x_axis_gridlines\":false,
\"y_axis_gridlines\":true,
\"show_y_axis_labels\":true,
\"show_y_axis_ticks\":true,
\"y_axis_tick_density\":\"default\",
\"y_axis_tick_density_custom\":5,
\"show_x_axis_label\":false,
\"show_x_axis_ticks\":true,
\"y_axis_scale_mode\":\"linear\",
\"x_axis_reversed\":false,
\"y_axis_reversed\":false,
\"plot_size_by_field\":false,
\"trellis\":\"\",
\"stacking\":\"\",
\"legend_position\":\"center\",
\"point_style\":\"circle\",
\"show_value_labels\":false,
\"label_density\":25,
\"x_axis_scale\":\"auto\",
\"y_axis_combined\":true,
\"show_null_points\":true,
\"interpolation\":\"linear\",
\"y_axes\":[{\"label\":\"\",
\"orientation\":\"left\",
\"series\":[{\"axisId\":\"asset_battery_prev_week_trend.battery_voltage\",
\"id\":\"133 - asset_battery_prev_week_trend.battery_voltage\",
\"name\":\"133\"},
{\"axisId\":\"asset_battery_prev_week_trend.battery_voltage\",
\"id\":\"141 - asset_battery_prev_week_trend.battery_voltage\",
\"name\":\"141\"},
{\"axisId\":\"asset_battery_prev_week_trend.battery_voltage\",
\"id\":\"691 - asset_battery_prev_week_trend.battery_voltage\",
\"name\":\"691\"}],
\"showLabels\":true,
\"showValues\":true,
\"unpinAxis\":true,
\"tickDensity\":\"default\",
\"tickDensityCustom\":5,
\"type\":\"linear\"}],
\"x_axis_label\":\"\",
\"series_types\":{},
\"series_colors\":{},
\"reference_lines\":[{\"reference_type\":\"line\",
\"margin_top\":\"deviation\",
\"margin_value\":\"mean\",
\"margin_bottom\":\"deviation\",
\"label_position\":\"right\",
\"color\":\"#B32F37\",
\"label\":\"Low Voltage\",
\"line_value\":\"11.5\",
\"range_start\":\"11.8\",
\"range_end\":\"0\"},
{\"reference_type\":\"line\",
\"margin_top\":\"deviation\",
\"margin_value\":\"mean\",
\"margin_bottom\":\"deviation\",
\"label_position\":\"right\",
\"color\":\"#FBB555\",
\"line_value\":\"18\",
\"label\":\"High Voltage\",
\"range_start\":\"18\",
\"range_end\":\"100\"}],
\"swap_axes\":false,
\"type\":\"looker_grid\",
\"defaults_version\":1}' %}

{{dummy._link}}&pivots=asset_battery_prev_week_trend.report_timestampdate&f[asset_battery_prev_week_trend.report_timestampdate]=NOT NULL&f[battery_voltage_types.name]=12V&vis={{vis | encode_uri}}"
    }
    link: {
      label: "24V Average Engine Off Battery Voltage 7 Day History"
      url: "{% assign vis= '{\"show_view_names\":false,
      \"show_row_numbers\":true,
      \"transpose\":false,
      \"truncate_text\":true,
      \"hide_totals\":false,
      \"hide_row_totals\":false,
      \"size_to_fit\":true,
      \"table_theme\":\"white\",
      \"limit_displayed_rows\":false,
      \"enable_conditional_formatting\":true,
      \"header_text_alignment\":\"left\",
      \"header_font_size\":\"12\",
      \"rows_font_size\":\"12\",
      \"conditional_formatting_include_totals\":false,
      \"conditional_formatting_include_nulls\":false,
      \"color_application\":{\"collection_id\":\"b43731d5-dc87-4a8e-b807-635bef3948e7\",
      \"palette_id\":\"fb7bb53e-b77b-4ab6-8274-9d420d3d73f3\",
      \"options\":{\"steps\":5}},
      \"show_sql_query_menu_options\":false,
      \"show_totals\":true,
      \"show_row_totals\":true,
      \"series_cell_visualizations\":{\"asset_battery_prev_week_trend.battery_voltage\":{\"is_active\":false}},
      \"conditional_formatting\":[{\"type\":\"less than\",
      \"value\":11.9,
      \"background_color\":\"#B32F37\",
      \"font_color\":null,
      \"color_application\":{\"collection_id\":\"b43731d5-dc87-4a8e-b807-635bef3948e7\",
      \"palette_id\":\"85de97da-2ded-4dec-9dbd-e6a7d36d5825\"},
      \"bold\":false,
      \"italic\":false,
      \"strikethrough\":false,
      \"fields\":null},
      {\"type\":\"greater than\",
      \"value\":17.99,
      \"background_color\":\"#FBB555\",
      \"font_color\":null,
      \"color_application\":{\"collection_id\":\"b43731d5-dc87-4a8e-b807-635bef3948e7\",
      \"palette_id\":\"1e4d66b9-f066-4c33-b0b7-cc10b4810688\"},
      \"bold\":false,
      \"italic\":false,
      \"strikethrough\":false,
      \"fields\":null}],
      \"x_axis_gridlines\":false,
      \"y_axis_gridlines\":true,
      \"show_y_axis_labels\":true,
      \"show_y_axis_ticks\":true,
      \"y_axis_tick_density\":\"default\",
      \"y_axis_tick_density_custom\":5,
      \"show_x_axis_label\":false,
      \"show_x_axis_ticks\":true,
      \"y_axis_scale_mode\":\"linear\",
      \"x_axis_reversed\":false,
      \"y_axis_reversed\":false,
      \"plot_size_by_field\":false,
      \"trellis\":\"\",
      \"stacking\":\"\",
      \"legend_position\":\"center\",
      \"point_style\":\"circle\",
      \"show_value_labels\":false,
      \"label_density\":25,
      \"x_axis_scale\":\"auto\",
      \"y_axis_combined\":true,
      \"show_null_points\":true,
      \"interpolation\":\"linear\",
      \"y_axes\":[{\"label\":\"\",
      \"orientation\":\"left\",
      \"series\":[{\"axisId\":\"asset_battery_prev_week_trend.battery_voltage\",
      \"id\":\"133 - asset_battery_prev_week_trend.battery_voltage\",
      \"name\":\"133\"},
      {\"axisId\":\"asset_battery_prev_week_trend.battery_voltage\",
      \"id\":\"141 - asset_battery_prev_week_trend.battery_voltage\",
      \"name\":\"141\"},
      {\"axisId\":\"asset_battery_prev_week_trend.battery_voltage\",
      \"id\":\"691 - asset_battery_prev_week_trend.battery_voltage\",
      \"name\":\"691\"}],
      \"showLabels\":true,
      \"showValues\":true,
      \"unpinAxis\":true,
      \"tickDensity\":\"default\",
      \"tickDensityCustom\":5,
      \"type\":\"linear\"}],
      \"x_axis_label\":\"\",
      \"series_types\":{},
      \"series_colors\":{},
      \"reference_lines\":[{\"reference_type\":\"line\",
      \"margin_top\":\"deviation\",
      \"margin_value\":\"mean\",
      \"margin_bottom\":\"deviation\",
      \"label_position\":\"right\",
      \"color\":\"#B32F37\",
      \"label\":\"Low Voltage\",
      \"line_value\":\"11.5\",
      \"range_start\":\"11.8\",
      \"range_end\":\"0\"},
      {\"reference_type\":\"line\",
      \"margin_top\":\"deviation\",
      \"margin_value\":\"mean\",
      \"margin_bottom\":\"deviation\",
      \"label_position\":\"right\",
      \"color\":\"#FBB555\",
      \"line_value\":\"18\",
      \"label\":\"High Voltage\",
      \"range_start\":\"18\",
      \"range_end\":\"100\"}],
      \"swap_axes\":false,
      \"type\":\"looker_grid\",
      \"defaults_version\":1}' %}

      {{dummy._link}}&pivots=asset_battery_prev_week_trend.report_timestampdate&f[asset_battery_prev_week_trend.report_timestampdate]=NOT NULL&f[battery_voltage_types.name]=24V&vis={{vis | encode_uri}}"
    }
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    primary_key: yes
  }

  dimension: battery_voltage {
    type: string
    sql: ${TABLE}."BATTERY_VOLTAGE" ;;
    value_format_name: decimal_2
  }

  dimension_group: updated {
    label: "Last Updated"
    type: time
    sql: convert_timezone('{{ _user_attributes['user_timezone'] }}',${TABLE}."UPDATED")
    ;;
  }

  dimension: voltage_level {
    type: string
    sql: case when ${assets.battery_voltage_type_id} = 1 and ${battery_voltage} <= 11.8 and ${battery_voltage} > 10.5 then 'Low'
    when ${assets.battery_voltage_type_id} = 1 and ${battery_voltage} >= 18 then 'High'
    when ${assets.battery_voltage_type_id} = 1 and ${battery_voltage} <= 10.5 then 'Critical'
    when ${assets.battery_voltage_type_id} = 2 and ${battery_voltage} <= 23.8 and ${battery_voltage} > 21 then 'Low'
    when ${assets.battery_voltage_type_id} = 2 and ${battery_voltage} <= 21 then 'Critical'
    when ${assets.battery_voltage_type_id} = 2 and ${battery_voltage} >= 30 then 'High'
    else 'Healthy'
    end;;
  }

  dimension: ranking_voltage_level {
    type: number
    sql: case
          when ${voltage_level} = 'Critical' then 1
          when ${voltage_level} = 'Low' then 2
          when ${voltage_level} = 'High' then 3
          else 4
          end;;
  }

  measure: count_percent {
    type: percent_of_total
    sql: ${count} ;;
  }

  set: detail {
    fields: [asset_battery_prev_week_trend.report_timestampdate, assets.custom_name, assets.make, assets.model, assets.ownership_type, asset_types.asset_types, categories.name, battery_voltage_types.name, voltage_level, battery_voltage, asset_last_location.location_address, asset_battery_prev_week_trend.battery_voltage]

  }

  set: detail_no_history {
    fields: [assets.custom_name, assets.make, assets.model, assets.ownership_type, asset_types.asset_types, categories.name, battery_voltage_types.name, voltage_level, battery_voltage, asset_last_location.location_address]

  }

# asset_battery_prev_week_trend.current_day_voltage, asset_battery_prev_week_trend.one_day_ago_voltage, asset_battery_prev_week_trend.two_days_ago_voltage, asset_battery_prev_week_trend.three_days_ago_voltage, asset_battery_prev_week_trend.four_days_ago_voltage, asset_battery_prev_week_trend.five_days_ago_voltage, asset_battery_prev_week_trend.six_days_ago_voltage, asset_battery_prev_week_trend.seven_days_ago_voltage]
  set: detail_avg_voltage {
    fields: [asset_id, asset_battery_prev_week_trend.report_timestampdate, asset_battery_prev_week_trend.daily_average_battery_voltage]
  }
}
