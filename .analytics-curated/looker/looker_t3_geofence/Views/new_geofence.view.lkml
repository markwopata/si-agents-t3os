view: new_geofence {

  derived_table: {
    sql:
    SELECT
      gau.*, l.city as geofence_city, s.name as geofence_state
    FROM business_intelligence.triage.stg_t3__geofence_asset_usage gau
    LEFT JOIN es_warehouse.public.geofences g USING(geofence_id)
    LEFT JOIN es_warehouse.public.locations l USING(location_id)
    LEFT JOIN es_warehouse.public.states s on l.state_id = s.state_id
    WHERE gau.COMPANY_ID =
      CASE WHEN {{ _user_attributes['company_id'] }}::numeric = 1854
      THEN 109154
      ELSE  {{ _user_attributes['company_id'] }}::numeric END
          ;;
  }


  # ---------------------
  # Dimensions
  # ---------------------

  dimension_group: date {type: time sql: ${TABLE}.USAGE_DATE ;;}
  dimension: asset { type: string sql: ${TABLE}.ASSET ;; }
  dimension: asset_id { type: number sql: ${TABLE}.ASSET_ID ;; }
  dimension: serial_number_vin {type: string sql: ${TABLE}.SERIAL_NUMBER_VIN ;;}
  dimension: model { type: string sql: ${TABLE}.MODEL ;; }
  dimension: make { type: string sql: ${TABLE}.MAKE ;; }
  dimension: asset_type { type: string sql: ${TABLE}.ASSET_TYPE ;;}
  dimension: geofence_id { type: string sql: ${TABLE}.GEOFENCE_ID ;; }
  dimension: ownership { type: string sql: ${TABLE}.OWNERSHIP ;; }
  dimension: hours_in_geofence { type: number sql: ${TABLE}.HOURS_IN_GEOFENCE ;; }
  dimension: geofence_name { type: string sql: ${TABLE}.GEOFENCE_NAME ;; }
  dimension: geofence_created_date { type: date sql: ${TABLE}.GEOFENCE_CREATED_DATE ;; }
  dimension: geofence_last_usage_date { type: date sql: ${TABLE}.GEOFENCE_LAST_USAGE_DATE ;; }
  dimension: geofence_under_utilization_reason { type: string sql: ${TABLE}.GEOFENCE_UNDER_UTILIZATION_REASON ;; }
  dimension: asset_last_usage_date { type: date sql: ${TABLE}.ASSET_LAST_USAGE_DATE ;; }
  dimension: asset_under_utilization_reason { type: string sql: ${TABLE}.ASSET_UNDER_UTILIZATION_REASON ;; }
  dimension: driver_name { type: string sql: ${TABLE}.DRIVER_NAME ;; }
  dimension: tracker { type: string sql: ${TABLE}.TRACKER ;; }
  dimension: tracker_type { type: string sql: ${TABLE}.TRACKER_TYPE ;; }
  dimension: tracker_last_report_date { type: date sql: ${TABLE}.TRACKER_LAST_REPORT_DATE ;; }
  dimension: tracker_last_check_in_date { type: string sql: ${TABLE}.TRACKER_LAST_CHECK_IN_DATE ;; }
  dimension: tracker_health_status { type: string sql: ${TABLE}.TRACKER_HEALTH_STATUS ;; }
  dimension: geofence_pct_chg_7d { type: number sql: ${TABLE}.PCT_CHG_7D ;; }
  dimension: geofence_pct_chg_30d  { type: number sql: ${TABLE}.PCT_CHG_30D ;; }
  dimension: geofence_pct_chg_90d  { type: number sql: ${TABLE}.PCT_CHG_90D ;; }
  dimension: geojson  { type: string sql: ${TABLE}.GEOJSON ;; }
  dimension: geofence_city  { type: string sql: ${TABLE}.GEOFENCE_CITY ;; }
  dimension: geofence_state  { type: string sql: ${TABLE}.GEOFENCE_STATE ;; }

  dimension: asset_hyperlink {
    group_label: "Asset Hyperlink to T3"
    label: "Asset"
    type: string
    sql: ${TABLE}.ASSET ;;
    html: <font color="#0063f3"><u><img src="https://cdn-icons-png.flaticon.com/512/107/107799.png" height="15" width="15"><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id._filterable_value }}/status" target="_blank">{{value}}</a></font></u>;;
  }

  dimension: link_to_geofence_map {
    type: string
    group_label: "Hyperlink to Geofence"
    label: "Geofence"
    sql: ${geofence_name} ;;
    html: <font color="#0063f3"><u><img src="https://cdn-icons-png.flaticon.com/512/107/107799.png" height="15" width="15"><a href="https://app.estrack.com/#/geofences/{{ new_geofence.geofence_id._filterable_value }}" target="_blank">{{value}}</a></font></u>
      ;;
  }

  dimension: current_date {
    type: date
    sql: current_date() ;;
  }




  # ---------------------
  # Meaures
  # ---------------------

  measure: distinct_assets {
    type: count_distinct
    sql: ${asset_id} ;;
    value_format_name: decimal_0
    drill_fields: [asset, asset_type, asset_last_usage_date, asset_under_utilization_reason, ownership, make, model, tracker, tracker_type, tracker_health_status, tracker_last_report_date, tracker_last_check_in_date]
  }

  measure: distinct_geofences {
    type: count_distinct
    sql: ${geofence_id} ;;
    value_format_name: decimal_0
    drill_fields: [geofence_name, geofence_created_date, geofence_last_usage_date, geofence_under_utilization_reason, total_usage_hours]
  }

  measure: total_usage_hours {
    type: sum
    sql: ${hours_in_geofence} ;;
    value_format_name: decimal_0
    html: <a href="#drillmenu" target="_self">{{rendered_value}}
      <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a> ;;
    drill_fields: [link_to_geofence_map, asset_hyperlink, date_date, geofence_created_date, geofence_last_usage_date, asset_last_usage_date, hours_in_geofence, asset_type, make, model, serial_number_vin, ownership]
  }



  # ---------------------
  # Filters
  # ---------------------

  filter: date_filter {
    type: date_time
  }

  filter: asset_filter {
    type: string
  }

  filter: asset_type_filter {
    type: string
  }

  filter: geofence_name_filter {
    type: string
  }

  filter: ownership_filter {
    type: string
  }



  # ---------------------
  # Parameters
  # ---------------------

  # parameter: show_last_location_options {
  #   type: string
  #   allowed_value: { value: "Default"}
  #   allowed_value: { value: "Geofence"}
  #   allowed_value: { value: "Address"}
  # }




}
