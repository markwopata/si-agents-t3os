view: assets_aggregate {
  sql_table_name: (
    SELECT
      w.ASSET_ID,
      w.COMPANY_ID,
      w.CUSTOM_NAME,
      w.OWNER,
      w.EQUIPMENT_MAKE_ID,
      w.MAKE,
      w.EQUIPMENT_MODEL_ID,
      w.MODEL,
      w.EQUIPMENT_CLASS_ID,
      w.CLASS,
      w.CATEGORY_ID,
      w.CATEGORY,
      w.YEAR,
      w.SERIAL_NUMBER,
      w.VIN,
      w.ASSET_TYPE_ID,
      w.ASSET_TYPE,
      w.OEC,
      w.DATE_CREATED,
      w.PURCHASE_DATE,
      w.RENTAL_BRANCH_ID,
      w.INVENTORY_BRANCH_ID,
      w.FIRST_RENTAL,
      w.ASSET_CLASS,
      w.SERVICE_BRANCH_ID,
      w.BUSINESS_SEGMENT_ID,
      w.BUSINESS_SEGMENT_NAME,
      nullif(d.ASSET_FIRST_RENTAL_START_DATE,'0001-01-01') as asset_first_rental_start_date,

    CASE
    WHEN d.ASSET_FIRST_RENTAL_START_DATE > DATE '2015-01-01'
    THEN DATEDIFF('MONTH', d.ASSET_FIRST_RENTAL_START_DATE, CURRENT_DATE)
    ELSE NULL
    END AS asset_age_month,
    open_work_orders_on_asset

    FROM es_warehouse.public.assets_aggregate w
    LEFT JOIN platform.gold.dim_assets d
    ON w.ASSET_ID = d.ASSET_ID
    left join (select asset_id, count(work_order_id) open_work_orders_on_asset from es_warehouse.work_orders.work_orders
    where archived_date is null and work_order_status_name='Open'
    group by 1) wos --HL adding number of work orders open on an asset here to get us by temporarily, but will be moving off of this view completely to a dbt model long term 1.28.26
    on w.asset_id=wos.asset_id
    ) ;;

  dimension: asset_age_month {
    type: number
    sql: ${TABLE}.asset_age_month ;;
  }

  measure: avg_asset_age_month_calc {
    type: average
    sql: ${asset_age_month} ;;
    value_format: "0"
    description: "Row-level average asset age in months"
  }


  dimension: asset_id {
    primary_key: yes
    type: number
    value_format_name: id
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset_id_wo_link {
    type: number
    value_format_name: id
    sql: ${asset_id} ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id }}/service/work-orders" target="_blank">{{rendered_value}}</a></font></u> ;;
  }
dimension: open_work_orders_on_asset {
  type: number
  sql: ${TABLE}."OPEN_WORK_ORDERS_ON_ASSET" ;;
}
  dimension: asset_id_t3_link {
    label: "Asset ID T3"
    type: number
    value_format_name: id
    sql: ${asset_id} ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id }}/history" target="_blank">{{rendered_value}}</a></font></u> ;;
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
    value_format_name: id
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
    sql: CAST(${TABLE}."FIRST_RENTAL" AS TIMESTAMP_NTZ);;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;

  }

  #creating this to get a link to the open-wo-in-hard-soft-down-by-manufacturer for the Percent-Down-by-Manufacturer-with-Total look
  dimension: manufacturer {
    type: string
    sql: ${TABLE}."MAKE" ;;
    link: {
      label: "Open WO in Hard-Soft Down by Manufacturer"
      url: "https://equipmentshare.looker.com/looks/514?f[assets_aggregate.make]={{value}}&f[asset_nbv_all_owners.rental_status]=Soft Down,Hard Down&f[work_orders.work_order_status_name]=Open&f[work_orders.archived_date]=null&[work_orders.work_order_type_id]=1"
      #"https://equipmentshare.looker.com/looks/514?f[assets_aggregate.make]={{value}}" --this is the OG
    }
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
    label: "OEC"
    type: number
    sql: ${TABLE}."OEC" ;;
    value_format_name: usd_0
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

  dimension: non_rental_flag {
    type: yesno
    sql: ${class} like "%Non-Rental" or ${class} like "%DO NOT RENT%";;
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

  dimension: asset_first_rental_start_date {
    type: string
    sql: ${TABLE}."ASSET_FIRST_RENTAL_START_DATE" ;;
  }

  measure: count {
    type: count
    drill_fields: [asset_detail*]
  }

  measure: total_oec {
    type: sum
    value_format_name: "usd_0"
    sql: ${oec} ;;
    drill_fields: [detail*] #want to switch this to asset_status_summary drill but want it to align with markets dashboard and michael needs to decide if he's going to change the "rentable" filter there - HL
  }

  measure: total_oec_with_link{
    type: sum
    value_format_name: usd_0
    sql: ${oec} ;;
    drill_fields: [detail*]
    link: {
      label: "View Inventory Information Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/27?Equipment%20Category=&Equipment%20Class=&Inventory%20Status={{ asset_status_key_values.value._value | url_encode }}&Market={{ _filters['market_region_xwalk.market_name'] | url_encode }}&Region={{ _filters['market_region_xwalk.region_name'] | url_encode }}&District={{ _filters['market_region_xwalk.district'] | url_encode }}&"
    }
  }
  measure: total_overall_oec_percentage {
    label: "OEC %"
    type: percent_of_total
    sql: ${total_oec} ;;
    value_format: "0.0\%"
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
    filters: [asset_status_key_values.value: "Pending Return, Make Ready, Needs Inspection, Soft Down, Hard Down", asset_status_key_values.name: "asset_inventory_status"]
    drill_fields: [asset_detail*]
  }
  measure: total_unavailable_oec_pending_return {
    type: sum
    value_format_name: "usd_0"
    sql: ${oec} ;;
    filters: [asset_status_key_values.value: "Pending Return", asset_status_key_values.name: "asset_inventory_status"]
    drill_fields: [asset_detail*]
  }

  measure: total_unavailable_oec_make_ready {
    type: sum
    value_format_name: "usd_0"
    sql: ${oec} ;;
    filters: [asset_status_key_values.value: "Make Ready", asset_status_key_values.name: "asset_inventory_status"]
    drill_fields: [asset_detail*]
  }

  measure: total_make_ready_count {
    type: count
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

  measure: total_needs_inspection_count {
    type: count
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

  measure: total_unavailable_oec_2 {
    label: "Total Unavailable OEC"
    type: sum
    value_format_name: "usd_0"
    sql: ${oec} ;;
    filters: [asset_status_key_values.value: "Make Ready, Needs Inspection, Soft Down, Hard Down", asset_status_key_values.name: "asset_inventory_status"]
    drill_fields: [asset_detail*]
    #[asset_detail_2*, total_unavailable_oec_2]
  }

  measure: total_unavailable_count {
    type: count
    filters: [asset_status_key_values.value: "Make Ready, Needs Inspection, Soft Down, Hard Down", asset_status_key_values.name: "asset_inventory_status"]
    drill_fields: [asset_detail*]
  }

  measure: service_total_unavailable_oec { #2.25 HL adding pending return to service dashboard
    type: sum
    value_format_name: "usd_0"
    sql: ${oec} ;;
    filters: [asset_status_key_values.value: "Pending Return, Make Ready, Needs Inspection, Soft Down, Hard Down", asset_status_key_values.name: "asset_inventory_status"]
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

  measure: total_hard_down_oec {
    type: sum
    value_format_name: "usd_0"
    sql: ${oec} ;;
    filters: [asset_status_key_values.value: "Hard Down", asset_status_key_values.name: "asset_inventory_status"]
    drill_fields: [detail*]
  }

  measure: total_hard_down_count {
    type: count
    filters: [asset_status_key_values.value: "Hard Down", asset_status_key_values.name: "asset_inventory_status"]
    drill_fields: [detail*]
  }

  measure: hard_down_percent {
    #Place number of statuses out of the asset statuses table in view if it errors out on not including assets status in from clause
    description: "% of hard down OEC"
    type: number
    value_format: "0.0\%"
    sql:  (${total_hard_down_oec} / NULLIF(sum(${oec}), 0)) * 100 ;;
  }

  measure: total_soft_down_oec {
    type: sum
    value_format_name: "usd_0"
    sql: ${oec} ;;
    filters: [asset_status_key_values.value: "Soft Down", asset_status_key_values.name: "asset_inventory_status"]
    drill_fields: [detail*]
  }

  measure: total_soft_down_count {
    type: count
    filters: [asset_status_key_values.value: "Soft Down", asset_status_key_values.name: "asset_inventory_status"]
    drill_fields: [detail*]
  }

  measure: soft_down_percent {
    #Place number of statuses out of the asset statuses table in view if it errors out on not including assets status in from clause
    description: "% of soft down OEC"
    type: number
    value_format: "0.0\%"
    sql:  (${total_soft_down_oec} / NULLIF(sum(${oec}), 0)) * 100 ;;
  }

  measure: total_hard_soft_down_oec {
    type: sum
    value_format_name: "usd_0"
    sql: ${oec} ;;
    filters: [asset_status_key_values.value: "Hard Down, Soft Down", asset_status_key_values.name: "asset_inventory_status"]
    drill_fields: [detail*]
  }

  measure: total_hard_soft_down_count {
    type: count
    filters: [asset_status_key_values.value: "Hard Down, Soft Down", asset_status_key_values.name: "asset_inventory_status"]
    drill_fields: [detail*]
  }

  measure: hard_soft_down_percent {
    #Place number of statuses out of the asset statuses table in view if it errors out on not including assets status in from clause
    description: "% of hard & soft down OEC"
    type: number
    value_format: "0.0\%"
    sql:  ((${total_hard_down_oec} + ${total_soft_down_oec})/ NULLIF(sum(${oec}), 0)) * 100 ;;
  }

  measure: hard_down_avg_days_in_status{
    #Avg number of days in status
    description: "Average number of days in hard down status"
    type: average
    filters: [asset_status_key_values.value: "Hard Down", asset_status_key_values.name: "asset_inventory_status"]
    value_format: "0"
    sql:  DATEDIFF(day, asset_status_key_values.updated, GETDATE()) ;;
  }

  measure: soft_down_avg_days_in_status{
    #Avg number of days in status
    description: "Average number of days in soft down status"
    type: average
    filters: [asset_status_key_values.value: "Soft Down", asset_status_key_values.name: "asset_inventory_status"]
    value_format: "0"
    sql:  DATEDIFF(day, asset_status_key_values.updated, GETDATE()) ;;

  }

  measure: hard_soft_down_avg_days_in_status{
    #Avg number of days in status
    description: "Average number of days in hard or soft down status"
    type: average
    filters: [asset_status_key_values.value: "Hard Down, Soft Down", asset_status_key_values.name: "asset_inventory_status"]
    value_format: "0"
    sql:  DATEDIFF(day, asset_status_key_values.updated, GETDATE()) ;;
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
      asset_status_key_values.value,
      current_inventory_status.days_in_current_status,
      current_inventory_status.date_start_date,
      asset_purchase_history_facts_final.OEC,
      last_wo_update.update_type,
      asset_location.address,
      asset_location.map_link]
  }
#fields: [asset_id_wo_link, serial_number, class, make, model, company_id, companies.name, purchase_date, oec, t3_asset_wos_url]
  set: asset_detail_2 {
    fields: [asset_id_wo_link, serial_number, class, make, model, company_id, companies.name, t3_asset_wos_url]
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
      year,
      company_id,
      companies.name,
      T3_Link,
      t3_asset_wos_url,
      asset_status_key_values.value,
      asset_status_key_values.updated,
      total_oec,
      asset_first_rental_start_date
    ]

  }
  set: asset_status_summary {
    fields: [asset_status_key_values.value,
      count,
      total_oec,
      total_overall_oec_percentage
    ]
  }

  set: asset_detail_3 {
    fields: [
      total_unavailable_oec_2,
      market_region_xwalk.market_name,
      total_unavailable_oec_pending_return,
      total_unavailable_oec_make_ready,
      total_unavailable_oec_needs_inspection,
      total_unavailable_oec_soft_down,
      total_unavailable_oec_hard_down
    ]
  }
}
