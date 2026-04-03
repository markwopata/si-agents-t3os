view: assets_aggregate_for_oec {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."ASSETS_AGGREGATE"
    ;;

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    primary_key: yes
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }

  dimension: asset_type_id {
    type: number
    sql: ${TABLE}."ASSET_TYPE_ID" ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: category_id {
    type: number
    sql: ${TABLE}."CATEGORY_ID" ;;
  }

  dimension: class {
    type: string
    sql: ${TABLE}."CLASS" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: custom_name {
    type: string
    sql: ${TABLE}."CUSTOM_NAME" ;;
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
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }

  dimension_group: first_rental {
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
    sql: CAST(${TABLE}."FIRST_RENTAL" AS TIMESTAMP_NTZ) ;;
  }

  dimension: inventory_branch_id {
    type: number
    sql: ${TABLE}."INVENTORY_BRANCH_ID" ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: make_model {
    type: string
    sql: CONCAT(${make}, ' ', ${model}) ;;
  }

  dimension: oec {
    type: number
    sql: ${TABLE}."OEC" ;;
  }

  dimension: owner {
    type: string
    sql: ${TABLE}."OWNER" ;;
  }

  dimension_group: purchase {
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
    sql: CAST(${TABLE}."PURCHASE_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: rental_branch_id {
    type: number
    sql: ${TABLE}."RENTAL_BRANCH_ID" ;;
  }

  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }

  dimension: vin {
    type: string
    sql: ${TABLE}."VIN" ;;
  }

  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }

  measure: count {
    type: count
    drill_fields: [custom_name]
  }

  measure: total_oec {
    type: sum
    value_format_name: "usd_0"
    sql: ${oec} ;;
    drill_fields: [detail*]
  }

  measure: total_oec_purchase_detail_drill {
    label: "Total OEC - Detail drill"
    type: sum
    value_format_name: "usd_0"
    sql: ${oec} ;;
    drill_fields: [asset_detail*]
  }

  measure: total_unavailable_oec {
    type: sum
    value_format_name: "usd_0"
    sql: ${oec} ;;
    filters: [asset_status_key_values.value: "Make Ready, Needs Inspection, Soft Down, Hard Down", asset_status_key_values.name: "asset_inventory_status"]
    drill_fields: [asset_detail*]
  }

  ## additions for OEC import #########################

  dimension:  last_30_days{
    type: yesno
    sql:  ${TABLE}."DATE_CREATED" <= current_date AND ${TABLE}."DATE_CREATED" >= (current_date - INTERVAL '30 days')
      ;;
  }

  measure: days_30_oec {
    type: sum
    filters: [last_30_days: "No"]
    value_format_name: usd
    value_format: "$#,##0"
    sql: ${oec} ;;
  }

  measure: days_30_unavailable_oec {
    type: sum
    filters: [last_30_days: "No", asset_status_key_values.value: "Make Ready, Needs Inspection, Soft Down, Hard Down", asset_status_key_values.name: "asset_inventory_status"]
    value_format_name: usd
    value_format: "$#,##0"
    sql: ${oec} ;;
  }

  dimension: asset_id_wo_link {
    type: number
    value_format_name: id
    sql: ${asset_id} ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id }}/service/work-orders" target="_blank">{{rendered_value}}</a></font></u> ;;
  }

  dimension: T3_Link{
    type:  string
    sql: ${asset_id} ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id }}/service/work-orders" target="_blank">T3 Workorders</a></font></u> ;;
  }

  dimension: t3_asset_wos_url {
    type: string
    sql: CONCAT('https://app.estrack.com/#/assets/all/asset/', ${asset_id}, '/service/work-orders') ;;
  }

  measure: total_unavailable_oec_2 {
    label: "Total Unavailable OEC"
    type: sum
    value_format_name: "usd_0"
    sql: ${oec} ;;
    filters: [asset_status_key_values.value: "Make Ready, Needs Inspection, Soft Down, Hard Down", asset_status_key_values.name: "asset_inventory_status"]
    drill_fields: [asset_detail*]
    #[asset_detail_2*, total_unavailable_oec_2]
  }

  measure: total_unavailable_oec_make_ready {
    type: sum
    value_format_name: "usd_0"
    sql: ${oec} ;;
    filters: [asset_status_key_values.value: "Make Ready", asset_status_key_values.name: "asset_inventory_status"]
    drill_fields: [asset_detail*]
  }

  measure: total_unavailable_oec_needs_inspection {
    type: sum
    value_format_name: "usd_0"
    sql: ${oec} ;;
    filters: [asset_status_key_values.value: "Needs Inspection", asset_status_key_values.name: "asset_inventory_status"]
    drill_fields: [asset_detail*]
  }

  measure: total_unavailable_oec_soft_down{
    type: sum
    value_format_name: "usd_0"
    sql: ${oec} ;;
    filters: [asset_status_key_values.value: "Soft Down", asset_status_key_values.name: "asset_inventory_status"]
    drill_fields: [asset_detail*]
  }

  measure: total_unavailable_oec_hard_down {
    type: sum
    value_format_name: "usd_0"
    sql: ${oec} ;;
    filters: [asset_status_key_values.value: "Hard Down", asset_status_key_values.name: "asset_inventory_status"]
    drill_fields: [asset_detail*]
  }

  measure: service_total_unavailable_oec {
    type: sum
    value_format_name: "usd_0"
    sql: ${oec} ;;
    filters: [asset_status_key_values.value: "Make Ready, Needs Inspection, Soft Down, Hard Down", asset_status_key_values.name: "asset_inventory_status"]
    drill_fields: [asset_detail_3*]#[asset_status_key_values.value, total_unavailable_oec_2]
    link: {
      label: "Market by Status"
      url: "
      {% assign vis_config = '{
      \"x_axis_gridlines\":false,\"y_axis_gridlines\":true,
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
      \"trellis\":\"\",\"stacking\":\"normal\",
      \"limit_displayed_rows\":false,
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
      \"color_application\":{\"collection_id\":\"ed5756e2-1ba8-4233-97d2-d565e309c03b\",
      \"palette_id\":\"ff31218a-4f9d-493c-ade2-22266f5934b8\",
      \"options\":{\"steps\":5,\"reverse\":true}},
      \"x_axis_zoom\":true,
      \"y_axis_zoom\":true,
      \"limit_displayed_rows_values\":{\"show_hide\":\"show\",\"first_last\":\"first\",\"num_rows\":\"\"},
      \"series_types\":{},
      \"series_colors\":{},
      \"series_labels\":{},
      \"type\":\"looker_column\",
      \"defaults_version\":1,
      \"hidden_pivots\":{},
      \"hidden_fields\":[\"assets_aggregate.total_unavailable_oec_2\"],
      \"hidden_points_if_no\":[]
      }'%}
      {{ link }}&vis_config={{ vis_config | encode_uri }}&toggle=dat,pik,vis&limit=5000"
    }
  }

  set: detail {
    fields: [
      asset_status_key_values.value,
      current_inventory_status.days_in_current_status,
      market_region_xwalk.market_name,
      asset_id_wo_link,
      serial_number,
      class,
      assets_inventory.make,
      assets_inventory.model,
      company_id,
      companies.name,
      T3_Link,
      t3_asset_wos_url,
      asset_status_key_values.value,
      asset_status_key_values.updated,
      asset_purchase_history_facts_final.OEC
    ]

  }

  set: asset_detail {
    fields: [ market_region_xwalk.market_name,
      asset_id_wo_link,
      serial_number,
      most_recent_rental.days_on_rent,
      assets_aggregate.category,
      assets_aggregate.class,
      assets_inventory.make,
      assets_inventory.model,
      company_id,
      companies.name,
      current_inventory_status.days_in_current_status,
      current_inventory_status.date_start_date,
      asset_purchase_history_facts_final.OEC,
      last_wo_update.update_type,
      asset_location.address,
      asset_location.map_link]
  }

  set: asset_detail_3 {
    fields: [
      total_unavailable_oec_2,
      market_region_xwalk.market_name,
      total_unavailable_oec_make_ready,
      total_unavailable_oec_needs_inspection,
      total_unavailable_oec_soft_down,
      total_unavailable_oec_hard_down
    ]
  }
}
