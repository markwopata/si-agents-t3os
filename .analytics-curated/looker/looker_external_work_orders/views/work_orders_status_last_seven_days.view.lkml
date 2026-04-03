view: work_orders_status_last_seven_days {
  derived_table: {
    sql: with get_past_days as (
      select
        dateadd(
        day,
        '-' || row_number() over (order by null),
        dateadd(day, '+1', current_date()::timestamp)
        ) as generated_date
        from table (generator(rowcount => 14))
      )
      select
          generated_date::date as generated_date,
          wo.work_order_id,
          a.asset_id,
          a.inventory_branch_id,
          wo.date_created::date as date_created,
          wo.date_completed,
          'open' as wo_order_status
      from
          work_orders.work_orders wo
          join markets m on m.market_id = wo.branch_id
          left join assets a on a.asset_id = wo.asset_id
          left join organization_asset_xref x on a.asset_id = x.asset_id
          join get_past_days pd on pd.generated_date BETWEEN wo.date_created::date and coalesce(wo.date_completed::date,current_date())
      where
          wo.work_order_type_id = 1 and
          archived_date is null
          and (wo.date_completed is null OR pd.generated_date::date != wo.date_completed::date)
          and m.company_id in ('{{ _user_attributes['company_id'] }}'::numeric)
     union
       select
          generated_date::date as generated_date,
          wo.work_order_id,
          a.asset_id,
          a.inventory_branch_id,
          wo.date_created::date as date_created,
          wo.date_completed,
          'completed' as wo_order_status
      from
          work_orders.work_orders wo
          join markets m on m.market_id = wo.branch_id
          left join assets a on a.asset_id = wo.asset_id
          left join organization_asset_xref x on a.asset_id = x.asset_id
          join get_past_days pd on pd.generated_date::date = wo.date_completed::date
      where
          wo.work_order_type_id = 1 and
          archived_date is null
          and work_order_status_id in (3,4)
          and (wo.date_created::date < (current_date() - interval '14 days') OR pd.generated_date::date = wo.date_completed::date)
          and m.company_id in ('{{ _user_attributes['company_id'] }}'::numeric)
 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: generated_date {
    label: "Open As Of"
    type: date
    sql: ${TABLE}."GENERATED_DATE" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
    value_format_name: id
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    value_format_name: id
  }

  dimension: inventory_branch_id {
    type: number
    sql: ${TABLE}."INVENTORY_BRANCH_ID" ;;
  }

  # dimension: organization_id {
  #   type: number
  #   sql: ${TABLE}."ORGANIZATION_ID" ;;
  # }

  dimension: date_created {
    type: date
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: date_completed {
    type: date
    sql: ${TABLE}."DATE_COMPLETED" ;;
  }

  dimension: wo_order_status {
    type: string
    sql: ${TABLE}."WO_ORDER_STATUS" ;;
  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(${generated_date},${work_order_id}) ;;
  }

  measure: open_work_orders {
    type: sum
    sql: case when ${wo_order_status} = 'open' then 1 end ;;
    drill_fields: [detail*]
  }

  measure: completed_work_orders {
    type: sum
    sql: case when ${wo_order_status} = 'completed' then 1 end ;;
    drill_fields: [detail*]
  }

  dimension: work_order_open_seven_days_ago_flag {
    type: yesno
    sql: ${generated_date} >= current_date - interval '7 days' ;;
  }

  dimension: work_order_is_today {
    type: yesno
    sql: ${generated_date} = current_date ;;
  }

  measure: completed_wo_last_7_days {
    type: sum
    filters: [work_order_open_seven_days_ago_flag: "Yes"]
    sql: case when ${wo_order_status} = 'completed' then 1 end ;;
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
    html:
    <a href="#drillmenu" target="_self">
    {% if value > 0 %}
      <font color="00CB86">{{ rendered_value }}</font>
    {% elsif value < 0 %}
      <font color="DA344D">{{ rendered_value }}</font>
    {% else %}
      <font color="black">{{ rendered_value }}</font>
    {% endif %}
    </a>
    ;;
  }

  measure: open_wo_as_of_today {
    type: sum
    filters: [work_order_is_today: "Yes"]
    sql: case when ${wo_order_status} = 'open' then 1 end ;;
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

  measure: dummy {
    hidden: yes
    type: sum
    sql: 0 ;;
    drill_fields: [work_orders.soft_down_wo_count, work_orders.hard_down_wo_count]
  }

  measure: dummy_wow_change {
    hidden: yes
    type: sum
    sql: 0 ;;
    drill_fields: [work_orders.detail_with_completed*]
  }

  set: detail {
    fields: [
      generated_date,
      work_order_id,
      work_orders.link_to_work_order,
      work_orders.description,
      assets.custom_name,
      assets.make,
      assets.model,
      assets_types.asset_type,
      categories.name,
      urgency_levels.name,
      date_created,
      date_completed
    ]
  }
}