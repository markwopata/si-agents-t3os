view: asset_service_forecast {
  sql_table_name: DATA_SCIENCE.PUBLIC.VW_ASSET_SERVICE_FORECAST ;;

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(${asset_id},${maintenance_group_interval_id}) ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: maintenance_group_interval_id {
    type: number
    sql: ${TABLE}."MAINTENANCE_GROUP_INTERVAL_ID" ;;
  }

  dimension: projected_service_likely_date {
    type: date
    sql: ${TABLE}."PROJECTED_SERVICE_LIKELY_DATE" ;;
  }

  dimension: projected_service_early_date {
    type: date
    sql: ${TABLE}."PROJECTED_SERVICE_EARLY_DATE" ;;
  }

  dimension: projected_service_late_date {
    type: date
    sql: ${TABLE}."PROJECTED_SERVICE_LATE_DATE" ;;
  }

  dimension_group: make_model_market_utilization_forecast_date_created {
    type: time
    sql: ${TABLE}."MAKE_MODEL_MARKET_UTILIZATION_FORECAST_DATE_CREATED" ;;
  }

  dimension_group: date_created {
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: projected_service_likely_date_formatted {
    description: "Only available for service intervals. Based on utilization history this is the projected date of when maintence will need to take place"
    group_label: "HTML Passed Date Format" label: "Likely Service Date"
    sql: ${projected_service_likely_date} ;;
    type: date
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: projected_service_early_date_formatted {
    description: "Only available for service intervals. Based on utilization history this is the earliest projected date of when maintence will need to take place"
    group_label: "HTML Passed Date Format" label: "Early Service Date"
    sql: ${projected_service_early_date} ;;
    type: date
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: projected_service_late_date_formatted {
    description: "Only available for service intervals. Based on utilization history this is the latest projected date of when maintence will need to take place"
    group_label: "HTML Passed Date Format" label: "Late Service Date"
    sql: ${projected_service_late_date} ;;
    type: date
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  measure: days_until_project_service {
    type: number
    sql: datediff(days,current_date(),${projected_service_likely_date}) ;;
  }

  measure: dummy {
    hidden: yes
    type: sum
    sql: 0 ;;
    # drill_fields: [detail*]
    drill_fields: [detail*]
  }

  measure: upcoming_service_projected_next_60_days {
    type: sum
    sql: case when datediff(days,current_date(),${projected_service_likely_date}) <= 60 then 1 else null end ;;
    # drill_fields: [detail*]
    # link: {
    #   label: "View Upcoming Assets Due for 500 Hours Service Interval"
    #   icon_url: "https://imgur.com/ZCNurvk.png"
    #   url: "{% assign vis= '{\"show_view_names\":false,
    #         \"show_row_numbers\":true,
    #         \"transpose\":false,
    #         \"truncate_text\":true,
    #         \"hide_totals\":false,
    #         \"hide_row_totals\":false,
    #         \"size_to_fit\":true,
    #         \"table_theme\":\"white\",
    #         \"limit_displayed_rows\":false,
    #         \"enable_conditional_formatting\":false,
    #         \"header_text_alignment\":\"left\",
    #         \"header_font_size\":\"13\",
    #         \"rows_font_size\":\"12\",
    #         \"conditional_formatting_include_totals\":false,
    #         \"conditional_formatting_include_nulls\":false,
    #         \"show_sql_query_menu_options\":false,
    #         \"show_totals\":true,
    #         \"show_row_totals\":true,
    #         \"truncate_header\":false,
    #         \"header_font_color\":\"#000000\",
    #         \"header_background_color\":\"#E1E2E6\",
    #         \"type\":\"looker_grid\",
    #         \"series_types\":{},
    #         \"defaults_version\":1}' %}

    #         {% assign dynamic_fields= '[]' %}

    #         {{dummy._link}}&f[asset_types.asset_type]=&f[categories.name]=&f[asset_service_intervals.service_interval_name]='500 Hours'&vis={{vis | encode_uri}}&dynamic_fields={{dynamic_fields | encode_uri}}&sorts=asset_service_forecast.projected_service_likely_date_formatted+asc"
    # }
    # link: {
    #   label: "View Upcoming Assets Due for 1000 Hours Service Interval"
    #   icon_url: "https://imgur.com/ZCNurvk.png"
    #   url: "{% assign vis= '{\"show_view_names\":false,
    #   \"show_row_numbers\":true,
    #   \"transpose\":false,
    #   \"truncate_text\":true,
    #   \"hide_totals\":false,
    #   \"hide_row_totals\":false,
    #   \"size_to_fit\":true,
    #   \"table_theme\":\"white\",
    #   \"limit_displayed_rows\":false,
    #   \"enable_conditional_formatting\":false,
    #   \"header_text_alignment\":\"left\",
    #   \"header_font_size\":\"13\",
    #   \"rows_font_size\":\"12\",
    #   \"conditional_formatting_include_totals\":false,
    #   \"conditional_formatting_include_nulls\":false,
    #   \"show_sql_query_menu_options\":false,
    #   \"show_totals\":true,
    #   \"show_row_totals\":true,
    #   \"truncate_header\":false,
    #   \"header_font_color\":\"#000000\",
    #   \"header_background_color\":\"#E1E2E6\",
    #   \"type\":\"looker_grid\",
    #   \"series_types\":{},
    #   \"defaults_version\":1}' %}

    #   {% assign dynamic_fields= '[]' %}

    #   {{dummy._link}}&f[asset_types.asset_type]=&f[categories.name]=&f[asset_service_intervals.service_interval_name]='1000 Hours'&vis={{vis | encode_uri}}&dynamic_fields={{dynamic_fields | encode_uri}}&sorts=asset_service_forecast.projected_service_likely_date_formatted+asc"
    # }
    link: {
      label: "View Upcoming Assets Due for Service Interval"
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
      \"header_font_size\":\"13\",
      \"rows_font_size\":\"12\",
      \"conditional_formatting_include_totals\":false,
      \"conditional_formatting_include_nulls\":false,
      \"show_sql_query_menu_options\":false,
      \"show_totals\":true,
      \"show_row_totals\":true,
      \"truncate_header\":false,
      \"header_font_color\":\"#000000\",
      \"header_background_color\":\"#E1E2E6\",
      \"type\":\"looker_grid\",
      \"series_types\":{},
      \"defaults_version\":1}' %}

      {% assign dynamic_fields= '[]' %}

      {{dummy._link}}&f[asset_types.asset_type]=&f[categories.name]=&vis={{vis | encode_uri}}&dynamic_fields={{dynamic_fields | encode_uri}}&sorts=asset_service_forecast.projected_service_likely_date_formatted+asc"
    }
  }

  set: detail {
    fields: [
      assets.asset_custom_name_to_service_page,
      assets.make,
      assets.model,
      markets.name,
      asset_service_intervals.service_interval_name,
      asset_service_intervals.remaining_time,
      projected_service_likely_date_formatted,
      projected_service_early_date_formatted,
      projected_service_late_date_formatted
    ]
  }

}
