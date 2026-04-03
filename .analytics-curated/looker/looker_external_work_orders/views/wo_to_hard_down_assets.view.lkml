view: wo_to_hard_down_assets {
  derived_table: {
    sql: with asset_list_own as (
      select
        asset_id
      from
        assets a
        inner join markets m on a.service_branch_id = m.market_id
      where
        m.company_id = {{ _user_attributes['company_id'] }}::numeric
        AND m.active = TRUE
      --table(assetlist({{ _user_attributes['user_id'] }}::numeric))
      )
      ,hard_down_assets as (
      select
          alo.asset_id,
          av.days_down
      from
          asset_list_own alo
          join (select asset_id, datediff(day,value_timestamp::date,current_date) as days_down from asset_status_key_values where value = 'Hard Down' and name = 'asset_inventory_status') av on av.asset_id = alo.asset_id
      )
      select
          hd.asset_id,
          hd.days_down,
          wo.work_order_id
      from
          hard_down_assets hd
          join work_orders.work_orders wo on hd.asset_id = wo.asset_id and wo.date_completed is null and archived_date is null
      where
          severity_level_id = 2
          --and hd.days_down >= 5
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(${work_order_id},${asset_id}) ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    value_format_name: id
  }

  dimension: days_down {
    type: number
    sql: ${TABLE}."DAYS_DOWN" ;;
  }

  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
    value_format_name: id
  }

  measure: dummy {
    hidden: yes
    type: number
    sql: 0 ;;
    drill_fields: [hard_down_assets_to_wo_detail*]
  }

  measure: view_hard_down_assets {
    type: string
    # sql: ${work_order_id} ;;
    sql: 'View Hard Down Assets tied to WOs' ;;
    html: <a href="#drillmenu" target="_self"><u><font color="#0063f3"> {{rendered_value}} </ul></a>;;
    # drill_fields: [hard_down_assets_to_wo_detail*]
    link: {
      label: "View Hard Down Assets tied to Work Orders"
      url: "{% assign vis= '{\"show_view_names\":false,
      \"show_row_numbers\":true,
      \"transpose\":false,
      \"truncate_text\":false,
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
      \"column_order\":[\"$$$_row_numbers_$$$\",
      \"assets.custom_name\",
      \"assets.make_and_model\",
      \"wo_to_hard_down_assets.days_down\",
      \"work_orders.work_order_id\",
      \"work_orders.link_to_work_order\",
      \"work_orders.date_formatted\",
      \"work_orders.description\"],
      \"show_totals\":true,
      \"show_row_totals\":true,
      \"series_labels\":{\"wo_to_hard_down_assets.days_down\":\"Days in Hard Down Status\"},
      \"series_column_widths\":{\"work_orders.date_formatted\":167},
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
      \"type\":\"looker_grid\",
      \"defaults_version\":1,
      \"series_types\":{}}' %}

      {{dummy._link}}&f[markets_branch.name]=&f[categories.name]=&vis={{vis | encode_uri}}"
    }
  }

  set: detail {
    fields: [asset_id, days_down, work_order_id]
  }

  set: hard_down_assets_to_wo_detail {
    fields: [assets.asset, assets.make_and_model, days_down, work_orders.work_order_id, work_orders.link_to_work_order, work_orders.created_date, work_orders.description]
  }
}
