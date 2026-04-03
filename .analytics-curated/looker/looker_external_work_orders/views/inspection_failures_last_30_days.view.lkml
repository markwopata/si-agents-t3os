view: inspection_failures_last_30_days {
  derived_table: {
    sql: with asset_list_own as (
        select asset_id
        from table(assetlist({{ _user_attributes['user_id'] }}::numeric))
      )
      select *
      from
        (
            select wo.asset_id, wo.work_order_id wo_id, wo.description, wo.date_created date_failed, wo.branch_id
            from
              asset_list_own alo
              join work_orders.work_orders wo on wo.asset_id = alo.asset_id
              join work_orders.work_order_originators woo on woo.work_order_id = wo.work_order_id
              where wo.work_order_type_id = 1
              and woo.originator_type_id = 6
              and wo.date_created >= current_timestamp() - interval '30 days'
        ) recent_insp_failure
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(${asset_id},${wo_id}) ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    value_format_name: id
  }

  dimension: wo_id {
    label: "Work Order ID"
    type: number
    sql: ${TABLE}."WO_ID" ;;
    value_format_name: id
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension_group: date_failed {
    type: time
    sql: ${TABLE}."DATE_FAILED" ;;
  }

  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: date_failed_formatted {
    type: date_time
    group_label: "HTML Passed Date Format" label: "Date Failed"
    sql: ${date_failed_raw} ;;
    html: {{ rendered_value | date: "%b %d, %Y %r"  }} {{ _user_attributes['user_timezone_label'] }};;
  }

  dimension: resulting_work_order_from_failed_inspection {
    type: string
    sql: ${wo_id} ;;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/service/work-orders/{{ wo_id._value }}" target="_blank">View Resulting Work Order from Failed Inspection</a></font></u> ;;
  }

  measure: dummy {
    hidden: yes
    type: number
    sql: 0 ;;
    drill_fields: [inspection_detail*]
  }

  dimension: view_avg_inspection_hours {
    type: string
    # sql: ${wo_id} ;;
    sql: 'View Average Inspection Hours' ;;
    link: {
      label: "View Average Inspections Hours by Make/Model"
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
      \"limit_displayed_rows\":true,
      \"legend_position\":\"center\",
      \"point_style\":\"none\",
      \"show_value_labels\":true,
      \"label_density\":25,
      \"x_axis_scale\":\"auto\",
      \"y_axis_combined\":true,
      \"ordering\":\"none\",
      \"show_null_labels\":false,
      \"show_totals_labels\":false,
      \"show_silhouette\":false,
      \"totals_color\":\"#808080\",
      \"y_axes\":[{\"label\":\"\",
      \"orientation\":\"bottom\",
      \"series\":[{\"axisId\":\"inspection_time_by_work_order.average_hours\",
      \"id\":\"inspection_time_by_work_order.average_hours\",
      \"name\":\"Average Hours\"}],
      \"showLabels\":true,
      \"showValues\":false,
      \"unpinAxis\":false,
      \"tickDensity\":\"default\",
      \"tickDensityCustom\":5,
      \"type\":\"linear\"}],
      \"limit_displayed_rows_values\":{\"show_hide\":\"show\",
      \"first_last\":\"first\",
      \"num_rows\":\"15\"},
      \"series_types\":{},
      \"column_spacing_ratio\":0.4,
      \"type\":\"looker_bar\",
      \"defaults_version\":1}' %}

      {{dummy._link}}&f[markets_branch.name]=&f[categories.name]=&vis={{vis | encode_uri}}"
    }
  }

  set: detail {
    fields: [wo_id, description, asset_id, date_failed_formatted, resulting_work_order_from_failed_inspection]
  }

  set: inspection_detail {
    fields: [inspection_time_by_work_order.make_and_model, inspection_time_by_work_order.average_hours]
  }
}
