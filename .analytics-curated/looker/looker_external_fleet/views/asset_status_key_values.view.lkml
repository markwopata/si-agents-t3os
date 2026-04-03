view: asset_status_key_values {
  derived_table: {
    sql: select * from ES_WAREHOUSE.PUBLIC.ASSET_STATUS_KEY_VALUES where name = 'asset_inventory_status'
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: asset_status_key_value_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ASSET_STATUS_KEY_VALUE_ID" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset_status_value_type_id {
    type: number
    sql: ${TABLE}."ASSET_STATUS_VALUE_TYPE_ID" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: value {
    type: string
    label: "Asset Inventory Status"
    sql: ${TABLE}."VALUE" ;;
  }

  dimension_group: value_timestamp {
    type: time
    sql: ${TABLE}."VALUE_TIMESTAMP" ;;
  }

  dimension_group: updated {
    type: time
    sql: ${TABLE}."UPDATED" ;;
  }

  dimension_group: _es_update_timestamp {
    type: time
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }

  measure: number_of_statuses {
    type: count
    drill_fields: [asset_id,value,markets.name,assets_inventory.make,equipment_models.name,equipment_classes.name]
  }

  measure: dummy {
    hidden: yes
    type: number
    sql: 0 ;;
    drill_fields: [detail*]
  }

  measure: total_unavailable_assets {
    type: count
    filters: [value: "Hard Down"]
    html: <a href="#drillmenu" target="_self"> <font color="#DA344D">{{ value }}</font></a> ;;
    # drill_fields: [total_soft_down_assets,total_hard_down_assets]
    link: {
      label: "View Unavailable Assets"
      url: "{% assign vis= '{\"x_axis_gridlines\":false,
          \"y_axis_gridlines\":false,
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
          \"show_value_labels\":true,
          \"label_density\":25,
          \"x_axis_scale\":\"auto\",
          \"y_axis_combined\":true,
          \"ordering\":\"none\",
          \"show_null_labels\":false,
          \"show_totals_labels\":false,
          \"show_silhouette\":false,
          \"totals_color\":\"#808080\",
          \"color_application\":{\"collection_id\":\"7c56cc21-66e4-41c9-81ce-a60e1c3967b2\",
          \"palette_id\":\"5d189dfc-4f46-46f3-822b-bfb0b61777b1\",
          \"options\":{\"steps\":5}},
          \"y_axes\":[{\"label\":\"\",
          \"orientation\":\"left\",
          \"series\":[{\"axisId\":\"asset_status_key_values.total_soft_down_assets\",
          \"id\":\"asset_status_key_values.total_soft_down_assets\",
          \"name\":\"Total Soft Down Assets\"},
          {\"axisId\":\"asset_status_key_values.total_hard_down_assets\",
          \"id\":\"asset_status_key_values.total_hard_down_assets\",
          \"name\":\"Total Hard Down Assets\"}],
          \"showLabels\":false,
          \"showValues\":false,
          \"unpinAxis\":false,
          \"tickDensity\":\"default\",
          \"tickDensityCustom\":5,
          \"type\":\"linear\"}],
          \"font_size\":\"16px\",
          \"series_types\":{},
          \"series_colors\":{\"asset_status_key_values.total_hard_down_assets\":\"#F9AB00\",
          \"asset_status_key_values.total_soft_down_assets\":\"#80868B\"},
          \"column_spacing_ratio\":0.2,
          \"column_group_spacing_ratio\":0.7,
          \"type\":\"looker_column\",
          \"defaults_version\":1}' %}

          {{dummy._link}}&vis={{vis | encode_uri}}&f[asset_status_key_values.value]=Hard Down"
    }
  }

  measure: total_soft_down_assets {
    type: count
    filters: [value: "Soft Down"]
    drill_fields: [detail*]
  }

  measure: total_hard_down_assets {
    type: count
    filters: [value: "Hard Down"]
    drill_fields: [detail*]
  }

  dimension: hard_down_assets_over_5_days {
    type: yesno
    sql: value = 'Hard Down' AND datediff(day,${value_timestamp_date},current_date) >= 5 ;;
  }

  set: detail {
    fields: [
      assets.custom_name, assets.make, assets.model, value, asset_types.asset_types, categories.name, organizations.asset_groups, trackers.tracker_information
    ]
  }
}
