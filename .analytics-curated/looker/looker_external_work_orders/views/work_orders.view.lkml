view: work_orders {
  sql_table_name: "WORK_ORDERS"."WORK_ORDERS"
    ;;
  # drill_fields: [work_order_id]

  dimension: work_order_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
    value_format_name: id
  }

  dimension_group: _es_update_timestamp {
    hidden: yes
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
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: _work_order_id {
    type: number
    sql: ${TABLE}."_WORK_ORDER_ID" ;;
  }

  dimension: _work_order_status_id {
    type: number
    sql: ${TABLE}."_WORK_ORDER_STATUS_ID" ;;
  }

  dimension_group: archived {
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
    sql: CAST(${TABLE}."ARCHIVED_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    value_format_name: id
  }

  dimension: billing_notes {
    type: string
    sql: ${TABLE}."BILLING_NOTES" ;;
  }

  dimension: billing_type_id {
    type: number
    sql: ${TABLE}."BILLING_TYPE_ID" ;;
  }

  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: creator_user_id {
    type: number
    sql: ${TABLE}."CREATOR_USER_ID" ;;
  }

  dimension: customer_user_id {
    type: number
    sql: ${TABLE}."CUSTOMER_USER_ID" ;;
  }

  dimension_group: date_billed {
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
    sql: CAST(${TABLE}."DATE_BILLED" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_completed {
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
    sql: CAST(${TABLE}."DATE_COMPLETED" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_created {
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
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
    html: {{ rendered_value | date: "%b %d, %Y" }} ;;
  }

  dimension: date_formatted {
    type: date
    group_label: "HTML Format" label: "Work Order Date Created"
    sql: convert_timezone('{{ _user_attributes['user_timezone'] }}',${date_created_date}) ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: date_time_formatted {
    type: date_time
    group_label: "HTML Format" label: "WO Created Date/Time"
    sql: convert_timezone('{{ _user_attributes['user_timezone'] }}',${date_created_raw}) ;;
    html: {{rendered_value | date: "%b %d, %Y %r"}} {{ _user_attributes['user_timezone_label'] }};;
    skip_drill_filter: yes
  }

  dimension: date_time_completed_formatted {
    type: date_time
    group_label: "HTML Format" label: "WO Completed Date/Time"
    sql: convert_timezone('{{ _user_attributes['user_timezone'] }}',${date_completed_raw}) ;;
    html: {{rendered_value | date: "%b %d, %Y %r"}} {{ _user_attributes['user_timezone_label'] }};;
    skip_drill_filter: yes
  }

  dimension: date_completed_formatted {
    type: date
    group_label: "HTML Format" label: "Completed Date"
    sql: convert_timezone('{{ _user_attributes['user_timezone'] }}',${date_completed_date}) ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension_group: date_updated {
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
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: description {
    label: "Work Order Description"
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension_group: due {
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
    sql: CAST(${TABLE}."DUE_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: hours_at_service {
    type: number
    sql: ${TABLE}."HOURS_AT_SERVICE" ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }

  dimension: mileage_at_service {
    type: number
    sql: ${TABLE}."MILEAGE_AT_SERVICE" ;;
  }

  dimension: severity_level_id {
    type: number
    sql: ${TABLE}."SEVERITY_LEVEL_ID" ;;
  }

  dimension: solution {
    type: string
    sql: ${TABLE}."SOLUTION" ;;
  }

  dimension: urgency_level_id {
    type: number
    sql: ${TABLE}."URGENCY_LEVEL_ID" ;;
  }

  dimension: work_order_status_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_STATUS_ID" ;;
  }

  dimension: work_order_status_name {
    label: "Work Order Status"
    type: string
    sql: ${TABLE}."WORK_ORDER_STATUS_NAME" ;;
    html:  Work Order Status: {{rendered_value}};;
  }

  dimension: work_order_type_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_TYPE_ID" ;;
  }

  measure: work_orders_count {
    type: count
    filters: [work_order_type_id: "1",
      archived_date: "NULL"]
    drill_fields: [work_order_downtime_detail*]
  }

  measure: hard_down_wo_count {
    label: "Hard Down Work Order Count"
    type: count
    filters: [severity_level_id: "2"]
    drill_fields: [detail*]
  }

  measure: soft_down_wo_count {
    label: "Soft Down Work Order Count"
    type: count
    filters: [severity_level_id: "1"]
    drill_fields: [detail*]
  }

  set: detail {
    fields: [work_order_id, link_to_work_order, description,assets.custom_name,assets.make,assets.model,asset_last_location.last_location, asset_types.asset_type,categories.name,date_formatted,urgency_levels.name]
  }

  set: detail_with_completed {
    fields: [work_orders_status_last_seven_days.generated_date,work_orders_status_last_seven_days.open_work_orders,work_orders_status_last_seven_days.completed_work_orders]
  }

  dimension: work_order_open_flag {
    type: yesno
    sql: ${date_completed_date} is null AND ${archived_date} is null and ${work_order_type_id} = 1 ;;
  }

  dimension: work_order_open_seven_days_ago_flag {
    type: yesno
    sql: (${date_completed_date} >= current_date - interval '7 days' OR ${date_completed_date} is null) AND ${archived_date} is null ;;
  }

  measure: work_orders_completed {
    type: count
    filters: [work_order_status_id: "3,4"]
  }

  measure: dummy {
    hidden: yes
    type: sum
    sql: 0 ;;
    drill_fields: [soft_down_wo_count, hard_down_wo_count]
  }

  measure: work_orders_open_count {
    type: count
    filters: [work_order_open_flag: "Yes"]
    link: {
      label: "View Soft and Hard Down Work Order Count"
      url: "
      {% assign vis= '{\"x_axis_gridlines\":false,
      \"y_axis_gridlines\":false,
      \"show_view_names\":false,
      \"show_y_axis_labels\":false,
      \"show_y_axis_ticks\":false,
      \"y_axis_tick_density\":\"default\",
      \"y_axis_tick_density_custom\":5,
      \"show_x_axis_label\":false,
      \"show_x_axis_ticks\":false,
      \"y_axis_scale_mode\":\"linear\",
      \"x_axis_reversed\":false,
      \"y_axis_reversed\":false,
      \"plot_size_by_field\":false,
      \"trellis\":\"\",
      \"stacking\":\"\",
      \"limit_displayed_rows\":false,
      \"legend_position\":\"center\",
      \"point_style\":\"circle\",
      \"show_value_labels\":true,
      \"label_density\":25,
      \"x_axis_scale\":\"auto\",
      \"y_axis_combined\":true,
      \"ordering\":\"none\",
      \"show_null_labels\":true,
      \"show_totals_labels\":false,
      \"show_silhouette\":false,
      \"totals_color\":\"#808080\",
      \"color_application\":{\"collection_id\":\"7c56cc21-66e4-41c9-81ce-a60e1c3967b2\",
      \"palette_id\":\"5d189dfc-4f46-46f3-822b-bfb0b61777b1\",
      \"options\":{\"steps\":5}},
      \"y_axes\":[{\"label\":\"\",
      \"orientation\":\"bottom\",
      \"series\":[{\"axisId\":\"work_orders.hard_down_wo_count\",
      \"id\":\"work_orders.hard_down_wo_count\",
      \"name\":\"Hard Down Work Order Count\"},
      {\"axisId\":\"work_orders.soft_down_wo_count\",
      \"id\":\"work_orders.soft_down_wo_count\",
      \"name\":\"Soft Down Work Order Count\"}],
      \"showLabels\":false,
      \"showValues\":false,
      \"unpinAxis\":false,
      \"tickDensity\":\"default\",
      \"tickDensityCustom\":5,
      \"type\":\"linear\"}],
      \"colors\":[\"palette: Shoreline\"],
      \"font_size\":\"16px\",
      \"series_types\":{},
      \"series_colors\":{\"work_orders.soft_down_wo_count\":\"#F9AB00\",
      \"work_orders.hard_down_wo_count\":\"#80868B\"},
      \"series_labels\":{\"work_orders.soft_down_wo_count\":\"Soft Down Work Order Count\",
      \"work_orders.hard_down_wo_count\":\"Hard Down Work Order Count\"},
      \"column_spacing_ratio\":0.5,
      \"column_group_spacing_ratio\":0.7,
      \"show_null_points\":true,
      \"type\":\"looker_bar\",
      \"interpolation\":\"linear\",
      \"defaults_version\":1}' %}

      {{dummy._link}}&f[asset_types.asset_type]={{_filters['asset_types.asset_type'] | url_encode }}&f[assets.custom_name]={{_filters['assets.custom_name'] | url_encode }}&f[assets.ownership_type]={{_filters['assets.ownership_type'] | url_encode }}&f[categories.name]={{_filters['categories.name'] | url_encode }}&f[work_orders.work_order_open_flag]=Yes&vis={{vis | encode_uri}}"
    }
  }

  measure: open_work_orders_seven_days_ago {
    type: count
    filters: [work_order_open_seven_days_ago_flag: "Yes"]
  }

  measure: dummy_wow_change {
    hidden: yes
    type: sum
    sql: 0 ;;
    drill_fields: [detail_with_completed*]
  }

  measure: open_work_orders_wow_change {
    type: number
    sql: ${work_orders_open_count} - ${open_work_orders_seven_days_ago} ;;
    link: {
      label: "Work Orders History Last 14 Days"
      url: "{% assign vis= '{\"x_axis_gridlines\":false,
      \"y_axis_gridlines\":false,
      \"show_view_names\":false,
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
      \"limit_displayed_rows\":false,
      \"legend_position\":\"center\",
      \"point_style\":\"circle\",
      \"show_value_labels\":true,
      \"label_density\":25,
      \"x_axis_scale\":\"auto\",
      \"y_axis_combined\":true,
      \"show_null_points\":true,
      \"interpolation\":\"linear\",
      \"color_application\":{\"collection_id\":\"7c56cc21-66e4-41c9-81ce-a60e1c3967b2\",
      \"palette_id\":\"5d189dfc-4f46-46f3-822b-bfb0b61777b1\",
      \"options\":{\"steps\":5}},
      \"y_axes\":[{\"label\":\"\",
      \"orientation\":\"left\",
      \"series\":[{\"axisId\":\"work_orders_status_last_seven_days.open_work_orders\",
      \"id\":\"work_orders_status_last_seven_days.open_work_orders\",
      \"name\":\"Open Work Orders\"},
      {\"axisId\":\"work_orders_status_last_seven_days.completed_work_orders\",
      \"id\":\"work_orders_status_last_seven_days.completed_work_orders\",
      \"name\":\"Completed Work Orders\"}],
      \"showLabels\":true,
      \"showValues\":false,
      \"unpinAxis\":true,
      \"tickDensity\":\"default\",
      \"tickDensityCustom\":5,
      \"type\":\"linear\"}],
      \"series_colors\":{\"work_orders_status_last_seven_days.completed_work_orders\":\"#80868B\",
      \"work_orders_status_last_seven_days.open_work_orders\":\"#F9AB00\"},
      \"x_axis_datetime_label\":\"%b %e (%a)\",
      \"type\":\"looker_line\",
      \"defaults_version\":1,
      \"hidden_fields\":[]}' %}

      {{dummy_wow_change._link}}&f[asset_types.asset_type]={{_filters['asset_types.asset_type'] | url_encode }}&f[assets.custom_name]={{_filters['assets.custom_name'] | url_encode }}&f[assets.ownership_type]={{_filters['assets.ownership_type'] | url_encode }}&f[categories.name]={{_filters['categories.name'] | url_encode }}&vis={{vis | encode_uri}}"
    }
  }

  dimension: link_to_work_order {
    label: "Work Order"
    type: string
    sql: ${work_order_id} ;;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="_blank"> {{rendered_value}} </a></font></u> ;;
  }

  dimension: days_open {
    type: number
    sql: datediff('days',${date_created_date},coalesce(${date_completed_date},current_timestamp)) ;;
  }

  dimension: days_open_uncompleted_wo {
    label: " WO Days Open"
    type: number
    sql: datediff('days',${date_created_date},current_date()) ;;
  }

  measure: average_days_open {
    type: average
    sql: ${days_open} ;;
    value_format_name: decimal_1
    drill_fields: [work_order_downtime_detail*]
  }

  measure: high_and_critical_average_days_open {
    type: average
    sql: ${days_open} ;;
    value_format_name: decimal_1
    drill_fields: [work_order_downtime_detail*]
    filters: [urgency_level_id: "1,2"]
  }

  measure: total_days_open {
    type: sum
    sql: ${days_open} ;;
    html: {% if total_days_open._value == 1 %}
    {{rendered_value}} day
    {% else %}
    {{rendered_value}} days
    {% endif %}
    ;;
  }

  dimension: work_order_type_name {
    type: string
    sql: case when ${work_order_type_id} = 1 then 'General'
    when ${work_order_type_id} = 2 then 'Inspection'
    else 'Unknown'
    end;;
  }

  measure: high_and_critical_urgency_count {
    type: count
    html: <a href="#drillmenu" target="_self"><font color="#DA344D">{{rendered_value}}</font></a>;;
    filters: [work_order_open_flag: "Yes",
      urgency_level_id: "1,2",
      archived_date: "NULL",
      work_order_type_id: "1"]
    drill_fields: [work_order_detail*]
  }

  measure: percent_of_high_and_critical_urgency_wo {
    type: number
    sql: case when ${work_orders_count} = 0 then 0 else ${high_and_critical_urgency_count}/${work_orders_count} end ;;
    value_format_name: percent_1
    drill_fields: [work_order_downtime_detail*]
  }

  measure: critical_urgency_count {
    type: count_distinct
    sql: ${work_order_id};;
    filters: [urgency_level_id: "1",
      work_order_open_flag: "Yes"]
    drill_fields: [work_order_detail*]
  }

  measure: high_urgency_count {
    type: count_distinct
    sql: ${work_order_id};;
    filters: [urgency_level_id: "2",
      work_order_open_flag: "Yes"]
    drill_fields: [work_order_detail*]
  }

  measure: medium_urgency_count {
    type: count_distinct
    sql: ${work_order_id};;
    filters: [urgency_level_id: "3",
      work_order_open_flag: "Yes"]
    drill_fields: [work_order_detail*]
  }

  measure: low_urgency_count {
    type: count_distinct
    sql: ${work_order_id};;
    filters: [urgency_level_id: "4",
      work_order_open_flag: "Yes"]
    drill_fields: [work_order_detail*]
  }

  measure: dummy_wo_detail {
    hidden: yes
    type: sum
    sql: 0 ;;
    drill_fields: [work_order_detail*]
  }

  dimension: link_to_work_order_t3 {
    group_label: "Link to T3"
    label: "Work Order ID"
    type: string
    sql: concat(case when ${work_order_type_id} = 1 then 'WO-' else 'INSP-' end,${work_order_id}) ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="_blank">{{rendered_value}}</a></font></u> ;;
  }

  measure: total_open_work_orders {
    type: count
    filters: [work_order_open_flag: "Yes"]
    link: {
      label: "View Soft and Hard Down Work Order Count"
      url: "
      {% assign vis= '{\"x_axis_gridlines\":false,
      \"y_axis_gridlines\":false,
      \"show_view_names\":false,
      \"show_y_axis_labels\":false,
      \"show_y_axis_ticks\":false,
      \"y_axis_tick_density\":\"default\",
      \"y_axis_tick_density_custom\":5,
      \"show_x_axis_label\":false,
      \"show_x_axis_ticks\":false,
      \"y_axis_scale_mode\":\"linear\",
      \"x_axis_reversed\":false,
      \"y_axis_reversed\":false,
      \"plot_size_by_field\":false,
      \"trellis\":\"\",
      \"stacking\":\"\",
      \"limit_displayed_rows\":false,
      \"legend_position\":\"center\",
      \"point_style\":\"circle\",
      \"show_value_labels\":true,
      \"label_density\":25,
      \"x_axis_scale\":\"auto\",
      \"y_axis_combined\":true,
      \"ordering\":\"none\",
      \"show_null_labels\":true,
      \"show_totals_labels\":false,
      \"show_silhouette\":false,
      \"totals_color\":\"#808080\",
      \"color_application\":{\"collection_id\":\"7c56cc21-66e4-41c9-81ce-a60e1c3967b2\",
      \"palette_id\":\"5d189dfc-4f46-46f3-822b-bfb0b61777b1\",
      \"options\":{\"steps\":5}},
      \"y_axes\":[{\"label\":\"\",
      \"orientation\":\"bottom\",
      \"series\":[{\"axisId\":\"work_orders.hard_down_wo_count\",
      \"id\":\"work_orders.hard_down_wo_count\",
      \"name\":\"Hard Down Work Order Count\"},
      {\"axisId\":\"work_orders.soft_down_wo_count\",
      \"id\":\"work_orders.soft_down_wo_count\",
      \"name\":\"Soft Down Work Order Count\"}],
      \"showLabels\":false,
      \"showValues\":false,
      \"unpinAxis\":false,
      \"tickDensity\":\"default\",
      \"tickDensityCustom\":5,
      \"type\":\"linear\"}],
      \"colors\":[\"palette: Shoreline\"],
      \"font_size\":\"16px\",
      \"series_types\":{},
      \"series_colors\":{\"work_orders.soft_down_wo_count\":\"#F9AB00\",
      \"work_orders.hard_down_wo_count\":\"#80868B\"},
      \"series_labels\":{\"work_orders.soft_down_wo_count\":\"Soft Down Work Order Count\",
      \"work_orders.hard_down_wo_count\":\"Hard Down Work Order Count\"},
      \"column_spacing_ratio\":0.5,
      \"column_group_spacing_ratio\":0.7,
      \"show_null_points\":true,
      \"type\":\"looker_bar\",
      \"interpolation\":\"linear\",
      \"defaults_version\":1}' %}

      {{dummy._link}}&f[asset_types.asset_type]={{_filters['asset_types.asset_type'] | url_encode }}&f[assets.custom_name]={{_filters['assets.custom_name'] | url_encode }}&f[assets.ownership_type]={{_filters['assets.ownership_type'] | url_encode }}&f[categories.name]={{_filters['categories.name'] | url_encode }}&f[work_orders.work_order_open_flag]=Yes&vis={{vis | encode_uri}}"
    }
    link: {
      label: "View Critical Urgency Work Orders"
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

      {{dummy_wo_detail._link}}&f[work_orders.work_order_open_flag]=Yes&f[urgency_levels.name]=Critical&vis={{vis | encode_uri}}"
    }
    link: {
      label: "View High Urgency Work Orders"
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

      {{dummy_wo_detail._link}}&f[work_orders.work_order_open_flag]=Yes&f[urgency_levels.name]=High&vis={{vis | encode_uri}}"
    }
    link: {
      label: "View Medium Urgency Work Orders"
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

      {{dummy_wo_detail._link}}&f[work_orders.work_order_open_flag]=Yes&f[urgency_levels.name]=Medium&vis={{vis | encode_uri}}"
    }
    link: {
      label: "View Low Urgency Work Orders"
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

      {{dummy_wo_detail._link}}&f[work_orders.work_order_open_flag]=Yes&f[urgency_levels.name]=Low&vis={{vis | encode_uri}}"
    }
  }

  measure: open_work_orders {
    type: count
    filters: [work_order_type_id: "1",
      date_completed_date: "null",
      archived_date:  "null"]
    drill_fields: [work_order_info*]
  }

  measure: open_inspections {
    type: count
    filters: [work_order_type_id: "2",
      date_completed_date: "null",
      archived_date:  "null"]
    drill_fields: [work_order_info*]
  }

  set: work_order_downtime_detail {
    fields: [work_order_id, link_to_work_order, description,assets.custom_name,assets.make,assets.model,asset_last_location.last_location, asset_types.asset_type,categories.name,markets.name, date_formatted,date_completed_formatted,urgency_levels.name, total_days_open]
  }

  set: work_order_detail {
    fields: [work_order_id, link_to_work_order, description,assets.custom_name,assets.make,assets.model,asset_last_location.last_location, asset_types.asset_type,categories.name,markets.name, date_formatted,date_completed_formatted,urgency_levels.name]
  }

  set: work_order_info {
    fields: [
      link_to_work_order_t3,
      company_tags.tags_assigned_to_work_order,
      originator_type.name,
      date_formatted,
      description,
      assets.link_to_asset_service_view,
      asset_last_location.address,
      markets.name,
      total_days_open
    ]
  }

}
